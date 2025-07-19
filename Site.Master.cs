using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class Site : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                UpdateNavigationUI();
            }
        }

        private void UpdateNavigationUI()
        {
            // Check if user is logged in using the same session variables from login.aspx.cs
            bool isLoggedIn = Session["IsLoggedIn"] != null && (bool)Session["IsLoggedIn"];
            string userRole = Session["UserRole"] as string;

            if (isLoggedIn)
            {
                // Show user panel, hide login panel
                LoginPanel.Visible = false;
                UserPanel.Visible = true;
                MobileLoginPanel.Visible = false;
                MobileUserPanel.Visible = true;

                // Get user information from session (matching login.aspx.cs)
                string userName = Session["UserName"] as string ?? "User";
                string profileImagePath = Session["ProfileImage"] as string;

                // Set user name in both desktop and mobile
                UserNameLabel.Text = userName;
                MobileUserNameLabel.Text = userName;

                // Set profile image
                UserProfileImage.ImageUrl = $"~/images/profiles/{profileImagePath}";
                MobileUserProfileImage.ImageUrl = $"~/images/profiles/{profileImagePath}";

                // Show notification bell only for User role
                if (userRole == "User")
                {
                    UpdateUnreadNotificationCount();
                    int unreadCount = 0;
                    if (Session["UnreadNotificationCount"] != null)
                        int.TryParse(Session["UnreadNotificationCount"].ToString(), out unreadCount);
                    NotificationPanel.Visible = true;
                    NotificationCountLabel.Visible = unreadCount > 0;
                    NotificationCountLabel.Text = unreadCount.ToString();
                }
                else
                {
                    NotificationPanel.Visible = false;
                }
            }
            else
            {
                // Show login panel, hide user panel
                LoginPanel.Visible = true;
                UserPanel.Visible = false;
                MobileLoginPanel.Visible = true;
                MobileUserPanel.Visible = false;
                NotificationPanel.Visible = false;
            }
        }

        // Query unread notification count for the logged-in user and store in session
        private void UpdateUnreadNotificationCount()
        {
            if (Session["UserId"] == null) return;
            int userId = Convert.ToInt32(Session["UserId"]);
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            int unreadCount = 0;
            using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT COUNT(*) FROM Notification WHERE user_id = @userId AND is_read = 0", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    unreadCount = (int)cmd.ExecuteScalar();
                }
            }
            Session["UnreadNotificationCount"] = unreadCount;
        }

        protected void DashboardButton_Click(object sender, EventArgs e)
        {
            // Get user role from session
            string userRole = Session["UserRole"] as string;

            // Redirect based on user role
            if (userRole == "Admin")
            {
                Response.Redirect("~/admin-dashboard.aspx");
            }
            else
            {
                Response.Redirect("~/user-dashboard.aspx");
            }
        }

        protected void LogoutButton_Click(object sender, EventArgs e)
        {
            // Redirect to centralized logout page
            Response.Redirect("~/logout.aspx");
        }
    }
}