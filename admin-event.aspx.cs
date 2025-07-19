using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class admin_event : System.Web.UI.Page
    {
        private int _totalRecords = 0;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in and is admin
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/login.aspx");
                return;
            }

            string userRole = Session["UserRole"] as string;
            if (userRole != "Admin")
            {
                Response.Redirect("~/home.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadAdminProfile();
                LoadEvents();
                LoadEventStatistics();
            }
        }

        private void LoadAdminProfile()
        {
            string adminName = Session["UserName"] as string ?? "Admin";
            string profileImagePath = Session["ProfileImage"] as string;

            AdminNameLabel.Text = adminName;

            if (!string.IsNullOrEmpty(profileImagePath))
            {
                AdminProfileImage.ImageUrl = $"~/images/profiles/{profileImagePath}";
            }
            else
            {
                AdminProfileImage.ImageUrl = "https://via.placeholder.com/80x80/3B82F6/FFFFFF?text=Admin";
            }
        }

        private void LoadEvents()
        {
            try
            {
                List<UserEvent> events = new List<UserEvent>();
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                string query = @"
                    SELECT e.event_id, e.event_title, e.event_image, e.event_status, e.start_date, e.end_date,
                           e.event_type, e.cuisine_type, e.max_participant, e.location,
                           (u.firstname + ' ' + u.lastname) as created_by
                    FROM Event e
                    INNER JOIN [User] u ON e.user_id = u.user_id
                    ORDER BY e.start_date DESC";

                // Apply filters
                query = ApplyFilters(query);

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (reader["event_id"] == DBNull.Value)
                                    continue;

                                DateTime startDate = Convert.ToDateTime(reader["start_date"]);
                                DateTime endDate = Convert.ToDateTime(reader["end_date"]);
                                DateTime today = DateTime.Today; // Get today's date without time

                                events.Add(new UserEvent
                                {
                                    EventId = Convert.ToInt32(reader["event_id"]),
                                    EventTitle = reader["event_title"].ToString(),
                                    EventImage = reader["event_image"]?.ToString(),
                                    EventStatus = reader["event_status"].ToString(),
                                    StartDate = startDate,
                                    EndDate = endDate,
                                    EventType = reader["event_type"].ToString(),
                                    CuisineType = reader["cuisine_type"].ToString(),
                                    MaxParticipant = Convert.ToInt32(reader["max_participant"]),
                                    Location = reader["location"].ToString(),
                                    CreatedBy = reader["created_by"].ToString(),
                                    // Updated TimeCategory logic: >= today = Upcoming, < today = Past
                                    TimeCategory = startDate.Date >= today ? "Upcoming" : "Past"
                                });
                            }
                        }
                    }
                }

                _totalRecords = events.Count;
                EventsGrid.DataSource = events;
                EventsGrid.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading events: {ex.Message}");
            }
        }

        private void LoadEventStatistics()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
                    SELECT 
                        COUNT(*) as Total,
                        SUM(CASE WHEN event_status = 'Pending' THEN 1 ELSE 0 END) as Pending,
                        SUM(CASE WHEN event_status = 'Approved' THEN 1 ELSE 0 END) as Approved,
                        SUM(CASE WHEN event_status = 'Rejected' THEN 1 ELSE 0 END) as Rejected,
                        SUM(CASE WHEN event_status = 'Completed' THEN 1 ELSE 0 END) as Completed,
                        SUM(CASE WHEN event_status = 'Expired' THEN 1 ELSE 0 END) as Expired
                    FROM Event";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                TotalEventsLabel.Text = reader["Total"].ToString();
                                PendingEventsLabel.Text = reader["Pending"].ToString();
                                ApprovedEventsLabel.Text = reader["Approved"].ToString();
                                RejectedEventsLabel.Text = reader["Rejected"].ToString();
                                CompletedEventsLabel.Text = reader["Completed"].ToString();
                                ExpiredEventsLabel.Text = reader["Expired"].ToString();
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading statistics: {ex.Message}");
            }
        }

        private string ApplyFilters(string baseQuery)
        {
            // Apply status filter
            if (StatusFilter.SelectedValue != "all")
            {
                string statusCondition = $"AND e.event_status = '{StatusFilter.SelectedValue}'";
                baseQuery = baseQuery.Replace("ORDER BY", statusCondition + " ORDER BY");
            }

            // Apply date range filter
            if (DateRangeFilter.SelectedValue != "all")
            {
                string dateCondition = "";
                if (DateRangeFilter.SelectedValue == "upcoming")
                {
                    // Upcoming: events from current day and to the future
                    dateCondition = "AND e.start_date >= CAST(GETDATE() AS DATE)";
                }
                else if (DateRangeFilter.SelectedValue == "past")
                {
                    // Past: events from yesterday and go back
                    dateCondition = "AND e.start_date < CAST(GETDATE() AS DATE)";
                }
                baseQuery = baseQuery.Replace("ORDER BY", dateCondition + " ORDER BY");
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(SearchBox.Text))
            {
                string searchCondition = $"AND (e.event_title LIKE '%{SearchBox.Text.Replace("'", "''")}%' OR e.location LIKE '%{SearchBox.Text.Replace("'", "''")}%')";
                baseQuery = baseQuery.Replace("ORDER BY", searchCondition + " ORDER BY");
            }

            return baseQuery;
        }

        // Event Handlers
        protected void Filter_Changed(object sender, EventArgs e)
        {
            EventsGrid.PageIndex = 0;
            MessagePanel.Visible = false;
            LoadEvents();
            LoadEventStatistics();
            EventsUpdatePanel.Update();
        }

        protected void EventsGrid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int eventId))
            {
                System.Diagnostics.Debug.WriteLine($"Invalid CommandArgument: '{e.CommandArgument}' for CommandName: '{e.CommandName}'");
                return;
            }

            switch (e.CommandName)
            {
                case "ViewEvent":
                    Response.Redirect($"~/event-detail.aspx?id={eventId}");
                    break;
                case "ApproveEvent":
                    UpdateEventStatus(eventId, "Approved");
                    SaveApprovalNotification(eventId);
                    ShowSuccessMessage("Event approved successfully!");
                    break;
                case "RejectEvent":
                    ShowRejectModal(eventId);
                    break;
            }
        }

        protected void EventsGrid_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            int newPageIndex = e.NewPageIndex;

            string eventArgument = Request.Form["__EVENTARGUMENT"];
            if (!string.IsNullOrEmpty(eventArgument) && int.TryParse(eventArgument, out int parsedPageIndex))
            {
                newPageIndex = parsedPageIndex;
            }

            if (newPageIndex >= 0 && newPageIndex < EventsGrid.PageCount)
            {
                EventsGrid.PageIndex = newPageIndex;
                LoadEvents();
                EventsUpdatePanel.Update();
            }
            else
            {
                System.Diagnostics.Debug.WriteLine($"Invalid PageIndex: {newPageIndex}, PageCount: {EventsGrid.PageCount}");
                EventsGrid.PageIndex = 0;
                LoadEvents();
                EventsUpdatePanel.Update();
            }
        }

        private void ShowRejectModal(int eventId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
                    SELECT e.event_title, e.event_image, (u.firstname + ' ' + u.lastname) as created_by
                    FROM Event e
                    INNER JOIN [User] u ON e.user_id = u.user_id
                    WHERE e.event_id = @eventId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@eventId", eventId);
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string eventTitle = reader["event_title"].ToString();
                                string eventImage = GetEventImageUrl(reader["event_image"]);
                                string createdBy = reader["created_by"].ToString();

                                RejectEventIdHidden.Value = eventId.ToString();
                                RejectReasonTextBox.Text = "";

                                string script = $@"
                                    document.getElementById('reject-event-name').innerText = '{eventTitle.Replace("'", "\\'")}';
                                    document.getElementById('reject-event-author').innerText = 'by {createdBy.Replace("'", "\\'")}';
                                    document.getElementById('reject-event-image').src = '{eventImage}';
                                    showRejectModal();
                                ";
                                ScriptManager.RegisterStartupScript(this, GetType(), "showRejectModal", script, true);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading event for reject modal: {ex.Message}");
            }
        }

        protected void ConfirmReject_Click(object sender, EventArgs e)
        {
            string reason = RejectReasonTextBox.Text.Trim();
            if (!int.TryParse(RejectEventIdHidden.Value, out int eventId))
                return; // or handle error

            if (string.IsNullOrWhiteSpace(reason))
            {
                RejectReasonErrorLabel.Text = "Please provide a reason for rejection.";
                RejectReasonErrorLabel.Visible = true;
                ShowRejectModal(eventId); // Use the correct eventId here!
                return;
            }
            RejectReasonErrorLabel.Visible = false;

            UpdateEventStatus(eventId, "Rejected");
            SaveRejectionNotification(eventId, reason);
            ShowSuccessMessage("Event rejected successfully!");
            ScriptManager.RegisterStartupScript(this, GetType(), "closeRejectModal", "closeRejectModal();", true);
        }

        private void SaveRejectionNotification(int eventId, string rejectionReason)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                // First get the user_id and event_title for the event
                string getUserQuery = @"
                    SELECT e.user_id, e.event_title 
                    FROM Event e 
                    WHERE e.event_id = @eventId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    int userId = 0;
                    string eventTitle = "";

                    using (SqlCommand getUserCmd = new SqlCommand(getUserQuery, conn))
                    {
                        getUserCmd.Parameters.AddWithValue("@eventId", eventId);
                        using (SqlDataReader reader = getUserCmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                userId = Convert.ToInt32(reader["user_id"]);
                                eventTitle = reader["event_title"].ToString();
                            }
                        }
                    }

                    if (userId > 0)
                    {
                        // Create notification message
                        string notificationMessage = string.IsNullOrEmpty(rejectionReason)
                            ? $"Your event '{eventTitle}' has been rejected by the administrator."
                            : $"Your event '{eventTitle}' has been rejected. Reason: {rejectionReason}";

                        // Insert notification
                        string insertQuery = @"
                            INSERT INTO [Notification] 
                            (user_id, notification_type, related_id, notification_message, notification_date, is_read)
                            VALUES (@userId, @notificationType, @relatedId, @notificationMessage, @notificationDate, @isRead)";

                        using (SqlCommand insertCmd = new SqlCommand(insertQuery, conn))
                        {
                            insertCmd.Parameters.AddWithValue("@userId", userId);
                            insertCmd.Parameters.AddWithValue("@notificationType", "Event_Rejection");
                            insertCmd.Parameters.AddWithValue("@relatedId", eventId);
                            insertCmd.Parameters.AddWithValue("@notificationMessage", notificationMessage);
                            insertCmd.Parameters.AddWithValue("@notificationDate", DateTime.Today);
                            insertCmd.Parameters.AddWithValue("@isRead", false);

                            insertCmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error saving rejection notification: {ex.Message}");
            }
        }

        private void SaveApprovalNotification(int eventId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string getUserQuery = @"
            SELECT e.user_id, e.event_title 
            FROM Event e 
            WHERE e.event_id = @eventId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    int userId = 0;
                    string eventTitle = "";

                    using (SqlCommand getUserCmd = new SqlCommand(getUserQuery, conn))
                    {
                        getUserCmd.Parameters.AddWithValue("@eventId", eventId);
                        using (SqlDataReader reader = getUserCmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                userId = Convert.ToInt32(reader["user_id"]);
                                eventTitle = reader["event_title"].ToString();
                            }
                        }
                    }

                    if (userId > 0)
                    {
                        string notificationMessage = $"Your event '{eventTitle}' has been approved by the administrator.";

                        string insertQuery = @"
                    INSERT INTO [Notification] 
                    (user_id, notification_type, related_id, notification_message, notification_date, is_read)
                    VALUES (@userId, @notificationType, @relatedId, @notificationMessage, @notificationDate, @isRead)";

                        using (SqlCommand insertCmd = new SqlCommand(insertQuery, conn))
                        {
                            insertCmd.Parameters.AddWithValue("@userId", userId);
                            insertCmd.Parameters.AddWithValue("@notificationType", "Event_Approval");
                            insertCmd.Parameters.AddWithValue("@relatedId", eventId);
                            insertCmd.Parameters.AddWithValue("@notificationMessage", notificationMessage);
                            insertCmd.Parameters.AddWithValue("@notificationDate", DateTime.Today);
                            insertCmd.Parameters.AddWithValue("@isRead", false);

                            insertCmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error saving approval notification: {ex.Message}");
            }
        }

        private void UpdateEventStatus(int eventId, string status)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = "UPDATE Event SET event_status = @status WHERE event_id = @eventId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@status", status);
                        cmd.Parameters.AddWithValue("@eventId", eventId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadEvents();
                LoadEventStatistics();
                EventsUpdatePanel.Update();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating event status: {ex.Message}");
            }
        }

        private void ShowSuccessMessage(string message)
        {
            MessageLabel.Text = message;
            MessagePanel.Visible = true;

            ScriptManager.RegisterStartupScript(this, GetType(), "hideMessage",
                "setTimeout(function() { closeMessage(); }, 5000);", true);
        }

        protected void AdminLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/logout.aspx");
        }

        // Helper Methods
        protected string GetEventImageUrl(object eventImage)
        {
            string imageName = eventImage?.ToString();
            if (!string.IsNullOrEmpty(imageName))
            {
                return $"/images/events/{imageName}";
            }
            return "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=60&h=60&fit=crop";
        }

        protected string GetStatusBadgeClass(object status)
        {
            string statusText = status?.ToString().ToLower() ?? "";
            switch (statusText)
            {
                case "pending":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800";
                case "approved":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800";
                case "rejected":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800";
                case "completed":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-blue-100 text-blue-800";
                case "expired":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800";
                default:
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800";
            }
        }

        // Pagination Methods
        protected string GetStartIndex()
        {
            int startIndex = (EventsGrid.PageIndex * EventsGrid.PageSize) + 1;
            return startIndex.ToString();
        }

        protected string GetEndIndex()
        {
            int endIndex = Math.Min((EventsGrid.PageIndex + 1) * EventsGrid.PageSize, _totalRecords);
            return endIndex.ToString();
        }

        protected int GetTotalRecords()
        {
            return _totalRecords;
        }

        protected string GeneratePaginationButtons()
        {
            if (EventsGrid.PageCount <= 1)
                return "";

            var buttons = new System.Text.StringBuilder();
            int currentPage = EventsGrid.PageIndex;
            int totalPages = EventsGrid.PageCount;

            int startPage = Math.Max(0, currentPage - 2);
            int endPage = Math.Min(totalPages - 1, currentPage + 2);

            if (endPage - startPage < 4)
            {
                if (startPage == 0)
                {
                    endPage = Math.Min(totalPages - 1, startPage + 4);
                }
                else if (endPage == totalPages - 1)
                {
                    startPage = Math.Max(0, endPage - 4);
                }
            }

            for (int i = startPage; i <= endPage; i++)
            {
                string cssClass = i == currentPage
                    ? "bg-blue-50 border-blue-500 text-blue-600 relative inline-flex items-center px-4 py-2 border text-sm font-medium"
                    : "bg-white border-gray-300 text-gray-500 hover:bg-gray-50 relative inline-flex items-center px-4 py-2 border text-sm font-medium";

                buttons.AppendFormat(
                    "<button type=\"button\" onclick=\"__doPostBack('{0}', 'Page${1}')\" class=\"{2}\">{3}</button>",
                    EventsGrid.UniqueID,
                    i + 1,
                    cssClass,
                    i + 1
                );
            }

            return buttons.ToString();
        }

        // Data Class
        public class UserEvent
        {
            public int EventId { get; set; }
            public string EventTitle { get; set; }
            public string EventImage { get; set; }
            public string EventStatus { get; set; }
            public DateTime StartDate { get; set; }
            public DateTime EndDate { get; set; }
            public string EventType { get; set; }
            public string CuisineType { get; set; }
            public int MaxParticipant { get; set; }
            public string Location { get; set; }
            public string CreatedBy { get; set; }
            public string TimeCategory { get; set; }

            // Helper properties
            public string Status => EventStatus;
            public string DateRange => $"{StartDate:dd/MM/yy}-{EndDate:dd/MM/yy}";
            public DateTime CreatedAt => StartDate;
        }
    }
}