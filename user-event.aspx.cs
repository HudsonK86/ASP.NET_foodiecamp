using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class user_event : System.Web.UI.Page
    {
        private int _totalRecords = 0;
        private int PageSize => 6;
        public int PageIndex
        {
            get { object obj = ViewState["PageIndex"]; return obj == null ? 0 : (int)obj; }
            set { ViewState["PageIndex"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
                PageIndex = 0;
                BindEvents();
            }
        }

        private void LoadUserProfile()
        {
            string userName = Session["UserName"] as string ?? "User";
            string profileImagePath = Session["ProfileImage"] as string;

            UserNameLabel.Text = userName;
            UserProfileImage.ImageUrl = !string.IsNullOrEmpty(profileImagePath)
                ? $"~/images/profiles/{profileImagePath}"
                : "https://via.placeholder.com/80x80";
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            PageIndex = 0;
            BindEvents();
        }

        private void BindEvents()
        {
            int userId = Convert.ToInt32(Session["UserId"] ?? "0");
            if (userId == 0)
                return;

            string status = StatusFilter.SelectedValue;
            string timeRange = TimeRangeFilter.SelectedValue;
            string search = SearchBox.Text.Trim();

            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            var events = new List<EventCard>();

            using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
            {
                conn.Open();
                var query = new System.Text.StringBuilder(@"
                    SELECT e.event_id, e.event_title, e.event_image, e.event_status, e.start_date, e.end_date, e.start_time, e.end_time, e.max_participant,
                           (u.firstname + ' ' + u.lastname) as posted_by
                    FROM Event e
                    INNER JOIN [User] u ON e.user_id = u.user_id
                    WHERE e.user_id = @userId
                ");

                if (status != "all" && !string.IsNullOrEmpty(status))
                    query.Append(" AND e.event_status = @status");

                if (!string.IsNullOrEmpty(search))
                    query.Append(" AND (e.event_title LIKE @search OR e.location LIKE @search)");

                query.Append(" ORDER BY e.start_date DESC, e.event_id DESC");

                using (var cmd = new System.Data.SqlClient.SqlCommand(query.ToString(), conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (status != "all" && !string.IsNullOrEmpty(status))
                        cmd.Parameters.AddWithValue("@status", status.First().ToString().ToUpper() + status.Substring(1).ToLower());
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var eventId = Convert.ToInt32(reader["event_id"]);
                            var startDate = Convert.ToDateTime(reader["start_date"]);
                            var endDate = Convert.ToDateTime(reader["end_date"]);
                            var now = DateTime.Now.Date;
                            string eventStatus = reader["event_status"].ToString();

                            // Time label logic
                            string timeLabel = "Upcoming";
                            string timeBadgeClass = "bg-blue-500 text-white";
                            string timeBadgeIcon = "fas fa-calendar";
                            if (now > endDate)
                            {
                                timeLabel = "Past";
                                timeBadgeClass = "bg-gray-500 text-white";
                                timeBadgeIcon = "fas fa-history";
                            }

                            // Time range filter
                            if (timeRange == "upcoming" && now > endDate)
                                continue;
                            if (timeRange == "past" && now <= endDate)
                                continue;

                            // Status badge logic
                            string statusBadgeClass = "bg-gray-400 text-white";
                            string statusBadgeIcon = "fas fa-clock";
                            switch (eventStatus.ToLower())
                            {
                                case "pending":
                                    statusBadgeClass = "bg-yellow-500 text-white";
                                    statusBadgeIcon = "fas fa-clock";
                                    break;
                                case "approved":
                                    statusBadgeClass = "bg-green-500 text-white";
                                    statusBadgeIcon = "fas fa-check";
                                    break;
                                case "rejected":
                                    statusBadgeClass = "bg-red-500 text-white";
                                    statusBadgeIcon = "fas fa-times";
                                    break;
                                case "completed":
                                    statusBadgeClass = "bg-blue-500 text-white";
                                    statusBadgeIcon = "fas fa-check";
                                    break;
                                case "expired":
                                    statusBadgeClass = "bg-red-500 text-white";
                                    statusBadgeIcon = "fas fa-clock";
                                    break;
                            }

                            // Participant count
                            int participantCount = 0;
                            int maxParticipant = reader["max_participant"] != DBNull.Value ? Convert.ToInt32(reader["max_participant"]) : 0;
                            using (var enrollConn = new System.Data.SqlClient.SqlConnection(connectionString))
                            {
                                enrollConn.Open();
                                using (var enrollCmd = new System.Data.SqlClient.SqlCommand(@"SELECT COUNT(*) FROM Enrollment WHERE event_id = @eventId AND enrollment_status = 'Registered'", enrollConn))
                                {
                                    enrollCmd.Parameters.AddWithValue("@eventId", eventId);
                                    participantCount = Convert.ToInt32(enrollCmd.ExecuteScalar());
                                }
                            }

                            // Time range string
                            string timeRangeStr = "";
                            if (reader["start_time"] != DBNull.Value && reader["end_time"] != DBNull.Value)
                            {
                                var startTime = TimeSpan.Parse(reader["start_time"].ToString());
                                var endTime = TimeSpan.Parse(reader["end_time"].ToString());
                                timeRangeStr = DateTime.Today.Add(startTime).ToString("h:mm tt") + " - " + DateTime.Today.Add(endTime).ToString("h:mm tt");
                            }

                            // Event image
                            string eventImageUrl = !string.IsNullOrEmpty(reader["event_image"].ToString())
                                ? "/images/events/" + reader["event_image"].ToString()
                                : "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=250&fit=crop";

                            events.Add(new EventCard
                            {
                                EventId = eventId,
                                EventTitle = reader["event_title"].ToString(),
                                EventImageUrl = eventImageUrl,
                                EventStatus = eventStatus,
                                StatusBadgeClass = statusBadgeClass,
                                StatusBadgeIcon = statusBadgeIcon,
                                TimeLabel = timeLabel,
                                TimeBadgeClass = timeBadgeClass,
                                TimeBadgeIcon = timeBadgeIcon,
                                DateRange = startDate.ToString("MMM dd, yyyy") + " - " + endDate.ToString("MMM dd, yyyy"),
                                TimeRange = timeRangeStr,
                                PostedBy = reader["posted_by"].ToString(),
                                ParticipantCount = participantCount,
                                MaxParticipant = maxParticipant
                            });
                        }
                    }
                }
            }

            _totalRecords = events.Count;

            var pagedData = new PagedDataSource();
            pagedData.DataSource = events;
            pagedData.AllowPaging = true;
            pagedData.PageSize = PageSize;

            // Clamp PageIndex to valid range
            int pageCount = pagedData.PageCount;
            if (PageIndex >= pageCount && pageCount > 0)
                PageIndex = pageCount - 1;
            if (PageIndex < 0) PageIndex = 0;
            pagedData.CurrentPageIndex = PageIndex;

            EventsRepeater.DataSource = pagedData;
            EventsRepeater.DataBind();

            PaginationPanel.Visible = pageCount > 1;
            PrevPageButton.Enabled = !pagedData.IsFirstPage;
            NextPageButton.Enabled = !pagedData.IsLastPage;

            PageNumbersRepeater.DataSource = Enumerable.Range(0, pageCount);
            PageNumbersRepeater.DataBind();
        }

        protected void PrevPageButton_Click(object sender, EventArgs e)
        {
            if (PageIndex > 0) PageIndex--;
            BindEvents();
        }

        protected void NextPageButton_Click(object sender, EventArgs e)
        {
            PageIndex++;
            BindEvents();
        }

        protected void PageNumbersRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Page")
            {
                PageIndex = Convert.ToInt32(e.CommandArgument);
                BindEvents();
            }
        }

        protected void EventsRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int eventId;
            if (!int.TryParse(e.CommandArgument.ToString(), out eventId))
                return;

            switch (e.CommandName)
            {
                case "View":
                    Response.Redirect($"~/event-detail.aspx?id={eventId}");
                    break;
                case "Edit":
                    Response.Redirect($"~/edit-event.aspx?id={eventId}");
                    break;
                case "Delete":
                    DeleteEvent(eventId);
                    ShowSuccessMessage("Event deleted successfully!");
                    BindEvents();
                    break;
            }
        }

        private void DeleteEvent(int eventId)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new System.Data.SqlClient.SqlCommand("DELETE FROM Event WHERE event_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", eventId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void ShowSuccessMessage(string message)
        {
            MessageLabel.Text = message;
            MessagePanel.Visible = true;
            ScriptManager.RegisterStartupScript(this, GetType(), "hideMessage",
                "setTimeout(function() { closeMessage(); }, 5000);", true);
        }

        protected void PostEventButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/post-event.aspx");
        }

        protected void UserLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/logout.aspx");
        }

        private class EventCard
        {
            public int EventId { get; set; }
            public string EventTitle { get; set; }
            public string EventImageUrl { get; set; }
            public string EventStatus { get; set; }
            public string StatusBadgeClass { get; set; }
            public string StatusBadgeIcon { get; set; }
            public string TimeLabel { get; set; }
            public string TimeBadgeClass { get; set; }
            public string TimeBadgeIcon { get; set; }
            public string DateRange { get; set; }
            public string TimeRange { get; set; }
            public string PostedBy { get; set; }
            public int ParticipantCount { get; set; }
            public int MaxParticipant { get; set; }
        }
    }
}