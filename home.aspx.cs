using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class home : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Always update event statuses before anything else
            UpdateEventStatuses();

            if (!IsPostBack)
            {
                // Check for login success message
                if (Session["LoginSuccess"] != null)
                {
                    ShowMessage(Session["LoginSuccess"].ToString());
                    Session.Remove("LoginSuccess");
                }

                // Check for logout success message
                else if (Session["LogoutSuccess"] != null)
                {
                    ShowMessage(Session["LogoutSuccess"].ToString());
                    Session.Remove("LogoutSuccess");
                }

                // Load cuisines from database
                LoadCuisines();
                LoadHomeEvents();
            }
        }

        // Add this method to update event statuses
        private void UpdateEventStatuses()
        {
            try
            {
                string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();

                    // Pending -> Expired if start_date = today
                    string updatePending = @"
                        UPDATE Event
                        SET event_status = 'Expired'
                        WHERE event_status = 'Pending' AND start_date = CAST(GETDATE() AS DATE)";
                    using (var cmd = new SqlCommand(updatePending, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }

                    // Approved -> Completed if start_date = today
                    string updateApproved = @"
                        UPDATE Event
                        SET event_status = 'Completed'
                        WHERE event_status = 'Approved' AND start_date = CAST(GETDATE() AS DATE)";
                    using (var cmd = new SqlCommand(updateApproved, conn))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating event statuses: {ex.Message}");
            }
        }

        // Load cuisines from the database and bind to the repeater
        private void LoadCuisines()
        {
            try
            {
                List<Cuisine> cuisines = new List<Cuisine>();
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = "SELECT TOP 6 cuisine_id, cuisine_name, cuisine_image FROM [Cuisine] ORDER BY cuisine_id";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                cuisines.Add(new Cuisine
                                {
                                    CuisineId = (int)reader["cuisine_id"],
                                    CuisineName = reader["cuisine_name"].ToString(),
                                    CuisineImage = reader["cuisine_image"].ToString()
                                });
                            }
                        }
                    }
                }

                // Bind to repeater
                CuisineRepeater.DataSource = cuisines;
                CuisineRepeater.DataBind();
            }
            catch (Exception ex)
            {
                // Log error and show fallback
                System.Diagnostics.Debug.WriteLine($"Error loading cuisines: {ex.Message}");
                // Optionally show error message to user
            }
        }
        
        // Load the three newest upcoming approved events for the home page
        private void LoadHomeEvents()
        {
            try
            {
                List<HomeEventCard> events = new List<HomeEventCard>();
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
                    SELECT TOP 3 e.event_id, e.event_title, e.event_image, e.event_status, e.start_date, e.end_date, e.start_time, e.end_time, e.max_participant,
                           (u.firstname + ' ' + u.lastname) as posted_by,
                           (SELECT COUNT(*) FROM Enrollment WHERE event_id = e.event_id AND enrollment_status = 'Registered') as participant_count
                    FROM Event e
                    INNER JOIN [User] u ON e.user_id = u.user_id
                    WHERE e.event_status = 'Approved' AND e.start_date >= @today
                    ORDER BY e.start_date ASC, e.event_id DESC";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@today", DateTime.Today);
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

                                events.Add(new HomeEventCard
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
                }

                HomeEventsRepeater.DataSource = events;
                HomeEventsRepeater.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading home events: {ex.Message}");
            }
        }

        private void ShowMessage(string message)
        {
            MessagePanel.Visible = true;
            MessageLabel.Text = message;
        }

        // Cuisine class for data binding
        public class Cuisine
        {
            public int CuisineId { get; set; }
            public string CuisineName { get; set; }
            public string CuisineImage { get; set; }
            public string FullImagePath => $"~/images/cuisines/{CuisineImage}";
        }
        
        // Event card class for home page event repeater
        public class HomeEventCard
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