using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class user_notification : System.Web.UI.Page
    {
        // Sidebar profile controls
        protected global::System.Web.UI.WebControls.Label UserNameLabel;
        protected global::System.Web.UI.WebControls.Image UserProfileImage;
        // Paging controls
        protected global::System.Web.UI.WebControls.Panel PaginationPanel;
        protected global::System.Web.UI.WebControls.Button PrevPageButton;
        protected global::System.Web.UI.WebControls.Button NextPageButton;
        protected global::System.Web.UI.WebControls.Repeater PageNumbersRepeater;
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
                BindNotifications();
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

        private int PageSize => 10;
        public int PageIndex
        {
            get { object obj = ViewState["PageIndex"]; return obj == null ? 0 : (int)obj; }
            set { ViewState["PageIndex"] = value; }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            PageIndex = 0;
            BindNotifications();
        }

        private void BindNotifications()
        {
            int userId = Convert.ToInt32(Session["UserId"] ?? "0");
            if (userId == 0)
                return;

            string readFilter = ReadFilter.SelectedValue;
            string typeFilter = TypeFilter.SelectedValue;
            string search = SearchBox.Text.Trim();
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            var notifications = new List<NotificationItem>();

            using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
            {
                conn.Open();
                var query = @"SELECT notification_id, notification_type, related_id, notification_message, notification_date, is_read FROM Notification WHERE user_id = @userId";
                if (readFilter == "read")
                    query += " AND is_read = 1";
                else if (readFilter == "unread")
                    query += " AND is_read = 0";
                if (typeFilter == "recipe")
                    query += " AND (notification_type = 'Recipe_Approval' OR notification_type = 'Recipe_Rejection')";
                else if (typeFilter == "event")
                    query += " AND (notification_type = 'Event_Approval' OR notification_type = 'Event_Rejection')";
                if (!string.IsNullOrEmpty(search))
                    query += " AND notification_message LIKE @search";
                query += " ORDER BY notification_date DESC, notification_id DESC";

                using (var cmd = new System.Data.SqlClient.SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            notifications.Add(new NotificationItem
                            {
                                NotificationId = Convert.ToInt32(reader["notification_id"]),
                                NotificationType = reader["notification_type"].ToString(),
                                RelatedId = Convert.ToInt32(reader["related_id"]),
                                NotificationMessage = reader["notification_message"].ToString(),
                                NotificationDate = Convert.ToDateTime(reader["notification_date"]),
                                IsRead = Convert.ToBoolean(reader["is_read"])
                            });
                        }
                    }
                }
            }

            var pagedData = new PagedDataSource();
            pagedData.DataSource = notifications;
            pagedData.AllowPaging = true;
            pagedData.PageSize = PageSize;
            int pageCount = pagedData.PageCount;
            if (PageIndex >= pageCount && pageCount > 0)
                PageIndex = pageCount - 1;
            if (PageIndex < 0) PageIndex = 0;
            pagedData.CurrentPageIndex = PageIndex;
            NotificationRepeater.DataSource = pagedData;
            NotificationRepeater.DataBind();

            // Paging controls
            if (PaginationPanel != null)
            {
                PaginationPanel.Visible = pageCount > 1;
            }
            if (PrevPageButton != null)
            {
                PrevPageButton.Enabled = !pagedData.IsFirstPage;
            }
            if (NextPageButton != null)
            {
                NextPageButton.Enabled = !pagedData.IsLastPage;
            }
            if (PageNumbersRepeater != null)
            {
                PageNumbersRepeater.DataSource = Enumerable.Range(0, pageCount);
                PageNumbersRepeater.DataBind();
            }
        }
        // These methods are required for ASP.NET event wiring from markup
        public void PrevPageButton_Click(object sender, EventArgs e)
        {
            if (PageIndex > 0) PageIndex--;
            BindNotifications();
        }

        public void NextPageButton_Click(object sender, EventArgs e)
        {
            PageIndex++;
            BindNotifications();
        }

        public void PageNumbersRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Page")
            {
                PageIndex = Convert.ToInt32(e.CommandArgument);
                BindNotifications();
            }
        }

        protected void NotificationRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int notificationId;
            if (!int.TryParse(e.CommandArgument.ToString(), out notificationId))
                return;
            switch (e.CommandName)
            {
                case "View":
                    // Redirect to related page
                    var notification = GetNotificationById(notificationId);
                    if (notification != null)
                    {
                        if (notification.NotificationType.StartsWith("Recipe"))
                            Response.Redirect($"~/recipe-detail.aspx?id={notification.RelatedId}");
                        else if (notification.NotificationType.StartsWith("Event"))
                            Response.Redirect($"~/event-detail.aspx?id={notification.RelatedId}");
                    }
                    break;
                case "MarkRead":
                    MarkNotificationAsRead(notificationId);
                    BindNotifications();
                    break;
            }
        }

        private NotificationItem GetNotificationById(int notificationId)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT notification_id, notification_type, related_id FROM Notification WHERE notification_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", notificationId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            return new NotificationItem
                            {
                                NotificationId = Convert.ToInt32(reader["notification_id"]),
                                NotificationType = reader["notification_type"].ToString(),
                                RelatedId = Convert.ToInt32(reader["related_id"])
                            };
                        }
                    }
                }
            }
            return null;
        }

        private void MarkNotificationAsRead(int notificationId)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new System.Data.SqlClient.SqlCommand("UPDATE Notification SET is_read = 1 WHERE notification_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", notificationId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        // Helper for badge class
        protected string GetTypeBadgeClass(object type)
        {
            string t = type?.ToString().ToLower() ?? "";
            if (t == "recipe_approval" || t == "event_approval")
                return "bg-blue-100 text-blue-800";
            if (t == "recipe_rejection" || t == "event_rejection")
                return "bg-red-100 text-red-700";
            return "bg-gray-200 text-gray-700";
        }

        protected void UserLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/login.aspx");
        }

        // Notification data class
        private class NotificationItem
        {
            public int NotificationId { get; set; }
            public string NotificationType { get; set; }
            public int RelatedId { get; set; }
            public string NotificationMessage { get; set; }
            public DateTime NotificationDate { get; set; }
            public bool IsRead { get; set; }
        }
    }
}