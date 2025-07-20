using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class edit_event : System.Web.UI.Page
    {
        protected int EventId
        {
            get
            {
                int id;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Only allow event owner
                if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
                {
                    Response.Redirect("~/login.aspx");
                    return;
                }
                int userId = Convert.ToInt32(Session["UserId"] ?? "0");
                EventInfo info = GetEventInfo(EventId);
                if (info == null || info.UserId != userId)
                {
                    Response.Redirect("~/user-event.aspx");
                    return;
                }
                // Only allow edit if upcoming and status is Pending/Approved
                if (info.StartDate < DateTime.Today || (info.Status != "Pending" && info.Status != "Approved"))
                {
                    Response.Redirect("~/user-event.aspx");
                    return;
                }
                // Fill fields
                StartDate.Text = info.StartDate.ToString("yyyy-MM-dd");
                EndDate.Text = info.EndDate.ToString("yyyy-MM-dd");
                StartTime.Text = info.StartTime.ToString(@"hh\:mm");
                EndTime.Text = info.EndTime.ToString(@"hh\:mm");
                Location.Text = info.Location;
            }
        }

        private class EventInfo
        {
            public int UserId;
            public DateTime StartDate;
            public DateTime EndDate;
            public TimeSpan StartTime;
            public TimeSpan EndTime;
            public string Location;
            public string Status;
        }

        private EventInfo GetEventInfo(int eventId)
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT user_id, start_date, end_date, start_time, end_time, location, event_status FROM Event WHERE event_id = @id";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", eventId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new EventInfo
                            {
                                UserId = Convert.ToInt32(reader["user_id"]),
                                StartDate = Convert.ToDateTime(reader["start_date"]),
                                EndDate = Convert.ToDateTime(reader["end_date"]),
                                StartTime = (TimeSpan)reader["start_time"],
                                EndTime = (TimeSpan)reader["end_time"],
                                Location = reader["location"].ToString(),
                                Status = reader["event_status"].ToString()
                            };
                        }
                    }
                }
            }
            return null;
        }

        protected void SaveBtn_Click(object sender, EventArgs e)
        {
            if (!Page.IsValid) return;

            int userId = Convert.ToInt32(Session["UserId"] ?? "0");
            EventInfo info = GetEventInfo(EventId);
            if (info == null || info.UserId != userId)
            {
                Response.Redirect("~/user-event.aspx");
                return;
            }
            // Only allow edit if upcoming and status is Pending/Approved
            if (info.StartDate < DateTime.Today || (info.Status != "Pending" && info.Status != "Approved"))
            {
                Response.Redirect("~/user-event.aspx");
                return;
            }

            DateTime startDate = DateTime.Parse(StartDate.Text);
            DateTime endDate = DateTime.Parse(EndDate.Text);
            TimeSpan startTime = TimeSpan.Parse(StartTime.Text);
            TimeSpan endTime = TimeSpan.Parse(EndTime.Text);
            string location = Location.Text.Trim();

            // If status is Approved, set to Pending
            string newStatus = info.Status == "Approved" ? "Pending" : info.Status;

            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"
                    UPDATE Event SET
                        start_date = @start_date,
                        end_date = @end_date,
                        start_time = @start_time,
                        end_time = @end_time,
                        location = @location,
                        event_status = @event_status
                    WHERE event_id = @id";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@start_date", startDate);
                    cmd.Parameters.AddWithValue("@end_date", endDate);
                    cmd.Parameters.AddWithValue("@start_time", startTime);
                    cmd.Parameters.AddWithValue("@end_time", endTime);
                    cmd.Parameters.AddWithValue("@location", location);
                    cmd.Parameters.AddWithValue("@event_status", newStatus);
                    cmd.Parameters.AddWithValue("@id", EventId);
                    cmd.ExecuteNonQuery();
                }
            }
            Response.Redirect("~/user-event.aspx");
        }
    }
}