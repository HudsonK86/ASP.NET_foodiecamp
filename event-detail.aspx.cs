using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace Hope
{
    public partial class event_detail : System.Web.UI.Page
    {
        protected EventDetailModel Event { get; set; }
        protected bool ShowRegisterButton { get; set; }
        protected bool ShowCancelButton { get; set; }
        protected int SpotsRemaining { get; set; }
        protected bool IsPastEvent { get; set; }
        protected string SuccessMessage { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            int eventId;
            if (!int.TryParse(Request.QueryString["id"], out eventId))
            {
                Event = null;
                return;
            }

            LoadEvent(eventId);

            ShowRegisterButton = false;
            ShowCancelButton = false;
            SpotsRemaining = 0;
            IsPastEvent = false;
            SuccessMessage = "";

            if (Event != null)
            {
                DateTime now = DateTime.Now.Date;
                if (now > Event.EndDate)
                {
                    IsPastEvent = true;
                }
                else if (Session["UserId"] != null && (Session["UserRole"] == null || Session["UserRole"].ToString() == "User"))
                {
                    int participantCount = GetParticipantCount(eventId);
                    SpotsRemaining = Event.MaxParticipant - participantCount;

                    int userId = Convert.ToInt32(Session["UserId"]);
                    bool isRegistered = IsUserRegistered(userId, eventId);

                    // Use user_id for owner check
                    bool isOwner = Event.UserId == userId;
                    if (isOwner)
                    {
                        ShowRegisterButton = false;
                        ShowCancelButton = false;
                        return;
                    }

                    if (isRegistered)
                    {
                        ShowCancelButton = true;
                    }
                    else if (SpotsRemaining > 0)
                    {
                        ShowRegisterButton = true;
                    }
                }
            }

            if (Session["EventSuccessMessage"] != null)
            {
                SuccessMessage = Session["EventSuccessMessage"].ToString();
                Session.Remove("EventSuccessMessage");
            }
        }

        private void LoadEvent(int eventId)
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT e.*, u.firstname, u.lastname, u.phone_number
                    FROM Event e
                    INNER JOIN [User] u ON e.user_id = u.user_id
                    WHERE e.event_id = @eventId";
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@eventId", eventId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            Event = new EventDetailModel
                            {
                                EventId = eventId,
                                UserId = Convert.ToInt32(reader["user_id"]), // <-- Add this line
                                EventTitle = reader["event_title"].ToString(),
                                EventDescription = reader["event_description"]?.ToString() ?? "",
                                EventImageUrl = !string.IsNullOrEmpty(reader["event_image"].ToString())
                                    ? "/images/events/" + reader["event_image"].ToString()
                                    : "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&h=600&fit=crop",
                                EventType = reader["event_type"].ToString(),
                                CuisineType = reader["cuisine_type"].ToString(),
                                StartDate = Convert.ToDateTime(reader["start_date"]),
                                EndDate = Convert.ToDateTime(reader["end_date"]),
                                StartTime = reader["start_time"] != DBNull.Value ? TimeSpan.Parse(reader["start_time"].ToString()) : (TimeSpan?)null,
                                EndTime = reader["end_time"] != DBNull.Value ? TimeSpan.Parse(reader["end_time"].ToString()) : (TimeSpan?)null,
                                MaxParticipant = Convert.ToInt32(reader["max_participant"]),
                                Location = reader["location"].ToString(),
                                Organizer = $"{reader["firstname"]} {reader["lastname"]}",
                                Contact = reader["phone_number"]?.ToString() ?? "",
                                LearningObjectives = new List<string> { "Traditional Asian cooking techniques", "Flavor balancing and seasoning", "Modern presentation techniques", "Knife skills and food preparation", "Recipe adaptations for home cooking" },
                                IncludedItems = new List<string> { "All cooking equipment and ingredients", "Recipe booklet to take home", "Welcome drink and refreshments", "Professional photos of your dishes", "Certificate of completion" },
                                Requirements = new List<string> { "No prior cooking experience required", "Comfortable clothing recommended", "Closed-toe shoes required", "Please arrive 15 minutes early", "Passion for learning and food!" }
                            };
                        }
                    }
                }
            }
        }

        private int GetParticipantCount(int eventId)
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT COUNT(*) FROM Enrollment WHERE event_id=@eventId AND enrollment_status='Registered'";
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@eventId", eventId);
                    return (int)cmd.ExecuteScalar();
                }
            }
        }

        private bool IsUserRegistered(int userId, int eventId)
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT COUNT(*) FROM Enrollment WHERE user_id=@userId AND event_id=@eventId AND enrollment_status='Registered'";
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    cmd.Parameters.AddWithValue("@eventId", eventId);
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        protected void RegisterBtn_Click(object sender, EventArgs e)
        {
            if (Event == null || Session["UserId"] == null) return;
            int userId = Convert.ToInt32(Session["UserId"]);
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string checkQuery = "SELECT COUNT(*) FROM Enrollment WHERE user_id=@userId AND event_id=@eventId AND enrollment_status='Registered'";
                using (var checkCmd = new SqlCommand(checkQuery, conn))
                {
                    checkCmd.Parameters.AddWithValue("@userId", userId);
                    checkCmd.Parameters.AddWithValue("@eventId", Event.EventId);
                    int exists = (int)checkCmd.ExecuteScalar();
                    if (exists == 0)
                    {
                        string insertQuery = "INSERT INTO Enrollment (user_id, event_id, enrollment_status) VALUES (@userId, @eventId, 'Registered')";
                        using (var insertCmd = new SqlCommand(insertQuery, conn))
                        {
                            insertCmd.Parameters.AddWithValue("@userId", userId);
                            insertCmd.Parameters.AddWithValue("@eventId", Event.EventId);
                            insertCmd.ExecuteNonQuery();
                        }
                        Session["EventSuccessMessage"] = "Successfully registered for the event!";
                    }
                }
            }
            Response.Redirect(Request.RawUrl);
        }

        protected void CancelBtn_Click(object sender, EventArgs e)
        {
            if (Event == null || Session["UserId"] == null) return;
            int userId = Convert.ToInt32(Session["UserId"]);
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string updateQuery = "UPDATE Enrollment SET enrollment_status='Cancelled' WHERE user_id=@userId AND event_id=@eventId AND enrollment_status='Registered'";
                using (var cmd = new SqlCommand(updateQuery, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    cmd.Parameters.AddWithValue("@eventId", Event.EventId);
                    cmd.ExecuteNonQuery();
                }
                Session["EventSuccessMessage"] = "Registration cancelled successfully.";
            }
            Response.Redirect(Request.RawUrl);
        }

        public class EventDetailModel
        {
            public int EventId { get; set; }
            public int UserId { get; set; } 
            public string EventTitle { get; set; }
            public string EventDescription { get; set; }
            public string EventImageUrl { get; set; }
            public string EventType { get; set; }
            public string CuisineType { get; set; }
            public DateTime StartDate { get; set; }
            public DateTime EndDate { get; set; }
            public TimeSpan? StartTime { get; set; }
            public TimeSpan? EndTime { get; set; }
            public int MaxParticipant { get; set; }
            public string Location { get; set; }
            public string Organizer { get; set; }
            public string Contact { get; set; }
            public List<string> LearningObjectives { get; set; }
            public List<string> IncludedItems { get; set; }
            public List<string> Requirements { get; set; }
            public string DateRange => $"{StartDate:MMM dd, yyyy} - {EndDate:MMM dd, yyyy}";
            public string TimeRange
            {
                get
                {
                    if (StartTime.HasValue && EndTime.HasValue)
                        return $"{DateTime.Today.Add(StartTime.Value):h:mm tt} - {DateTime.Today.Add(EndTime.Value):h:mm tt}";
                    return "-";
                }
            }
        }
    }
}