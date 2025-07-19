using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class events : System.Web.UI.Page
    {
        private int PageSize => 6;
        public int PageIndex
        {
            get { object obj = ViewState["PageIndex"]; return obj == null ? 0 : (int)obj; }
            set { ViewState["PageIndex"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadEventTypeFilter();
                PageIndex = 0;
                BindEvents();
            }
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

        protected void Filter_Changed(object sender, EventArgs e)
        {
            PageIndex = 0;
            BindEvents();
        }

        private void BindEvents()
        {
            string time = TimeFilter.SelectedValue ?? "all";
            string eventType = EventTypeFilter.SelectedValue ?? "all";
            string search = SearchBox.Text?.Trim() ?? "";

            var events = new List<EventCard>();
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            var query = new System.Text.StringBuilder(@"
                SELECT e.event_id, e.event_title, e.event_image, e.event_status, e.start_date, e.end_date, e.start_time, e.end_time, e.max_participant,
                       (u.firstname + ' ' + u.lastname) as posted_by,
                       (SELECT COUNT(*) FROM Enrollment WHERE event_id = e.event_id AND enrollment_status = 'Registered') as participant_count
                FROM Event e
                INNER JOIN [User] u ON e.user_id = u.user_id
                WHERE (e.event_status = 'Approved' OR e.event_status = 'Completed')
            ");

            // Time filter
            if (time == "upcoming")
                query.Append(" AND e.start_date >= CAST(GETDATE() AS DATE)");
            else if (time == "past")
                query.Append(" AND e.start_date < CAST(GETDATE() AS DATE)");

            // Event type filter
            if (eventType != "all")
                query.Append(" AND e.event_type = @eventType");

            // Search filter
            if (!string.IsNullOrEmpty(search))
                query.Append(" AND (e.event_title LIKE @search OR e.event_type LIKE @search)");

            query.Append(" ORDER BY e.start_date DESC, e.event_id DESC");

            using (SqlConnection conn = new SqlConnection(connectionString))
            using (SqlCommand cmd = new SqlCommand(query.ToString(), conn))
            {
                if (eventType != "all")
                    cmd.Parameters.AddWithValue("@eventType", eventType);
                if (!string.IsNullOrEmpty(search))
                    cmd.Parameters.AddWithValue("@search", "%" + search + "%");

                conn.Open();
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        var startDate = Convert.ToDateTime(reader["start_date"]);
                        var endDate = Convert.ToDateTime(reader["end_date"]);
                        string eventStatus = reader["event_status"].ToString();

                        // Time label logic
                        string timeLabel = "Upcoming";
                        string timeBadgeClass = "bg-blue-500 text-white";
                        string timeBadgeIcon = "fas fa-calendar";
                        var now = DateTime.Now.Date;
                        if (now > endDate)
                        {
                            timeLabel = "Past";
                            timeBadgeClass = "bg-gray-500 text-white";
                            timeBadgeIcon = "fas fa-history";
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
                            EventId = Convert.ToInt32(reader["event_id"]),
                            EventTitle = reader["event_title"].ToString(),
                            EventImageUrl = eventImageUrl,
                            TimeLabel = timeLabel,
                            TimeBadgeClass = timeBadgeClass,
                            TimeBadgeIcon = timeBadgeIcon,
                            DateRange = startDate.ToString("MMM dd, yyyy") + " - " + endDate.ToString("MMM dd, yyyy"),
                            TimeRange = timeRangeStr,
                            PostedBy = reader["posted_by"].ToString(),
                            ParticipantCount = reader["participant_count"] != DBNull.Value ? Convert.ToInt32(reader["participant_count"]) : 0,
                            MaxParticipant = reader["max_participant"] != DBNull.Value ? Convert.ToInt32(reader["max_participant"]) : 0
                        });
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

        private void LoadEventTypeFilter()
        {
            EventTypeFilter.Items.Clear();
            EventTypeFilter.Items.Add(new ListItem("All", "all"));
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT DISTINCT event_type FROM Event WHERE event_type IS NOT NULL AND event_type <> '' ORDER BY event_type", conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        string type = reader["event_type"].ToString();
                        EventTypeFilter.Items.Add(new ListItem(type, type));
                    }
                }
            }
        }

        public class EventCard
        {
            public int EventId { get; set; }
            public string EventTitle { get; set; }
            public string EventImageUrl { get; set; }
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