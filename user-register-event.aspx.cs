using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class user_register_event : System.Web.UI.Page
    {
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
            // Set user name and profile image in sidebar
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

            string timeFilter = TimeFilter.SelectedValue;
            string search = SearchBox.Text.Trim();
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            var events = new List<EventCard>();

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                var query = @"
                    SELECT en.enrollment_id, en.event_id, ev.event_title, ev.event_image, ev.start_date, ev.end_date, ev.start_time, ev.end_time, ev.max_participant, ev.user_id as event_owner_id, (u.firstname + ' ' + u.lastname) as posted_by
                    FROM Enrollment en
                    INNER JOIN Event ev ON en.event_id = ev.event_id
                    INNER JOIN [User] u ON ev.user_id = u.user_id
                    WHERE en.user_id = @userId AND en.enrollment_status = 'Registered'";
                if (!string.IsNullOrEmpty(search))
                    query += " AND (ev.event_title LIKE @search OR ev.location LIKE @search)";
                query += " ORDER BY ev.start_date DESC, en.enrollment_id DESC";

                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var startDate = Convert.ToDateTime(reader["start_date"]);
                            var endDate = Convert.ToDateTime(reader["end_date"]);
                            var now = DateTime.Now.Date;
                            string timeLabel = "Upcoming";
                            string timeBadgeClass = "bg-blue-500 text-white";
                            bool isUpcoming = true;
                            if (now > endDate)
                            {
                                timeLabel = "Past";
                                timeBadgeClass = "bg-gray-500 text-white";
                                isUpcoming = false;
                            }
                            // Time range filter
                            if (timeFilter == "upcoming" && !isUpcoming)
                                continue;
                            if (timeFilter == "past" && isUpcoming)
                                continue;
                            string timeRangeStr = "";
                            if (reader["start_time"] != DBNull.Value && reader["end_time"] != DBNull.Value)
                            {
                                var startTime = TimeSpan.Parse(reader["start_time"].ToString());
                                var endTime = TimeSpan.Parse(reader["end_time"].ToString());
                                timeRangeStr = DateTime.Today.Add(startTime).ToString("h:mm tt") + " - " + DateTime.Today.Add(endTime).ToString("h:mm tt");
                            }
                            string eventImageUrl = !string.IsNullOrEmpty(reader["event_image"].ToString())
                                ? "/images/events/" + reader["event_image"].ToString()
                                : "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=250&fit=crop";

                            // Retrieve participant count for this event
                            int eventId = Convert.ToInt32(reader["event_id"]);
                            int participantCount = 0;
                            int maxParticipant = reader["max_participant"] != DBNull.Value ? Convert.ToInt32(reader["max_participant"]) : 0;
                            using (var enrollConn = new SqlConnection(connectionString))
                            {
                                enrollConn.Open();
                                using (var enrollCmd = new SqlCommand(@"SELECT COUNT(*) FROM Enrollment WHERE event_id = @eventId AND enrollment_status = 'Registered'", enrollConn))
                                {
                                    enrollCmd.Parameters.AddWithValue("@eventId", eventId);
                                    participantCount = Convert.ToInt32(enrollCmd.ExecuteScalar());
                                }
                            }

                            events.Add(new EventCard
                            {
                                EnrollmentId = Convert.ToInt32(reader["enrollment_id"]),
                                EventId = eventId,
                                EventTitle = reader["event_title"].ToString(),
                                EventImageUrl = eventImageUrl,
                                TimeLabel = timeLabel,
                                TimeBadgeClass = timeBadgeClass,
                                DateRange = startDate.ToString("MMM dd, yyyy") + " - " + endDate.ToString("MMM dd, yyyy"),
                                TimeRange = timeRangeStr,
                                PostedBy = reader["posted_by"].ToString(),
                                IsUpcoming = isUpcoming,
                                ParticipantCount = participantCount,
                                MaxParticipant = maxParticipant
                            });
                        }
                    }
                }
            }
            // Paging
            var pagedData = new PagedDataSource();
            pagedData.DataSource = events;
            pagedData.AllowPaging = true;
            pagedData.PageSize = PageSize;
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
            PageNumbersRepeater.DataSource = System.Linq.Enumerable.Range(0, pageCount);
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
            int enrollmentId;
            if (!int.TryParse(e.CommandArgument.ToString(), out enrollmentId))
                return;
            switch (e.CommandName)
            {
                case "View":
                    // View event details
                    Response.Redirect($"~/event-detail.aspx?id={enrollmentId}");
                    break;
                case "Cancel":
                    CancelEnrollment(enrollmentId);
                    ShowSuccessMessage("Event registration canceled.");
                    BindEvents();
                    break;
            }
        }

        private void CancelEnrollment(int enrollmentId)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new SqlCommand("UPDATE Enrollment SET enrollment_status = 'Canceled' WHERE enrollment_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", enrollmentId);
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

        protected void UserLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/login.aspx");
        }

        private class EventCard
        {
            public int EnrollmentId { get; set; }
            public int EventId { get; set; }
            public string EventTitle { get; set; }
            public string EventImageUrl { get; set; }
            public string TimeLabel { get; set; }
            public string TimeBadgeClass { get; set; }
            public string DateRange { get; set; }
            public string TimeRange { get; set; }
            public string PostedBy { get; set; }
            public bool IsUpcoming { get; set; }
            public int ParticipantCount { get; set; }
            public int MaxParticipant { get; set; }
        }
    }
}