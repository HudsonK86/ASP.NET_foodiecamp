using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class admin_user : System.Web.UI.Page
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
                LoadUsers();
                LoadUserStatistics();
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

        private void LoadUsers()
        {
            try
            {
                List<User> users = new List<User>();
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                string query = @"
                    SELECT user_id, firstname, lastname, email, user_role, is_activated, 
                           registered_date, last_login_date, profile_image
                    FROM [User]
                    ORDER BY registered_date DESC";

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
                                if (reader["user_id"] == DBNull.Value)
                                    continue;

                                bool isActivated = Convert.ToBoolean(reader["is_activated"]);
                                DateTime? lastLoginDate = reader["last_login_date"] as DateTime?;

                                string status = GetUserStatus(isActivated, lastLoginDate);

                                users.Add(new User
                                {
                                    UserId = Convert.ToInt32(reader["user_id"]),
                                    UserName = $"{reader["firstname"]} {reader["lastname"]}",
                                    Email = reader["email"].ToString(),
                                    UserRole = reader["user_role"].ToString(),
                                    IsActivated = isActivated,
                                    DateCreated = Convert.ToDateTime(reader["registered_date"]),
                                    LastLoginDate = lastLoginDate,
                                    ProfileImage = reader["profile_image"]?.ToString(),
                                    Status = status
                                });
                            }
                        }
                    }
                }

                _totalRecords = users.Count;
                UsersGrid.DataSource = users;
                UsersGrid.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading users: {ex.Message}");
            }
        }

        private void LoadUserStatistics()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
                    SELECT 
                        COUNT(*) as Total,
                        SUM(CASE WHEN is_activated = 1 AND last_login_date IS NOT NULL AND last_login_date >= DATEADD(day, -30, GETDATE()) THEN 1 ELSE 0 END) as Active,
                        SUM(CASE WHEN is_activated = 1 AND (last_login_date IS NULL OR last_login_date < DATEADD(day, -30, GETDATE())) THEN 1 ELSE 0 END) as Inactive,
                        SUM(CASE WHEN is_activated = 0 THEN 1 ELSE 0 END) as Blocked
                    FROM [User]";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                TotalUsersLabel.Text = reader["Total"].ToString();
                                ActiveUsersLabel.Text = reader["Active"].ToString();
                                InactiveUsersLabel.Text = reader["Inactive"].ToString();
                                BlockedUsersLabel.Text = reader["Blocked"].ToString();
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
            List<string> conditions = new List<string>();

            // Apply status filter
            if (StatusFilter?.SelectedValue != null && StatusFilter.SelectedValue != "all")
            {
                switch (StatusFilter.SelectedValue)
                {
                    case "active":
                        conditions.Add("is_activated = 1 AND last_login_date IS NOT NULL AND last_login_date >= DATEADD(day, -30, GETDATE())");
                        break;
                    case "inactive":
                        conditions.Add("is_activated = 1 AND (last_login_date IS NULL OR last_login_date < DATEADD(day, -30, GETDATE()))");
                        break;
                    case "blocked":
                        conditions.Add("is_activated = 0");
                        break;
                }
            }

            // Apply role filter
            if (RoleFilter?.SelectedValue != null && RoleFilter.SelectedValue != "all")
            {
                conditions.Add($"user_role = '{RoleFilter.SelectedValue}'");
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(SearchBox?.Text))
            {
                string searchText = SearchBox.Text.Replace("'", "''");
                conditions.Add($"(firstname LIKE '%{searchText}%' OR lastname LIKE '%{searchText}%' OR email LIKE '%{searchText}%')");
            }

            // Build the final query
            if (conditions.Count > 0)
            {
                string whereClause = "WHERE " + string.Join(" AND ", conditions);
                baseQuery = baseQuery.Replace("ORDER BY", whereClause + " ORDER BY");
            }

            System.Diagnostics.Debug.WriteLine($"Final Query: {baseQuery}");
            return baseQuery;
        }

        private string GetUserStatus(bool isActivated, DateTime? lastLoginDate)
        {
            if (!isActivated)
                return "Blocked";

            if (!lastLoginDate.HasValue || lastLoginDate.Value < DateTime.Now.AddDays(-30))
                return "Inactive";

            return "Active";
        }

        // Event Handlers
        protected void Filter_Changed(object sender, EventArgs e)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("Filter_Changed called");
                UsersGrid.PageIndex = 0;
                MessagePanel.Visible = false;
                LoadUsers();
                LoadUserStatistics();
                UsersUpdatePanel.Update();
                System.Diagnostics.Debug.WriteLine("Filter_Changed completed successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in Filter_Changed: {ex.Message}");
                ShowSuccessMessage($"Filter error: {ex.Message}");
            }
        }

        protected void UsersGrid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int userId))
            {
                System.Diagnostics.Debug.WriteLine($"Invalid CommandArgument: '{e.CommandArgument}' for CommandName: '{e.CommandName}'");
                return;
            }

            switch (e.CommandName)
            {
                case "ViewUser":
                    ShowUserModal(userId);
                    break;
                case "ToggleUserStatus":
                    ToggleUserStatus(userId);
                    break;
            }
        }

        protected void UsersGrid_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            int newPageIndex = e.NewPageIndex;

            string eventArgument = Request.Form["__EVENTARGUMENT"];
            if (!string.IsNullOrEmpty(eventArgument) && int.TryParse(eventArgument, out int parsedPageIndex))
            {
                newPageIndex = parsedPageIndex;
            }

            if (newPageIndex >= 0 && newPageIndex < UsersGrid.PageCount)
            {
                UsersGrid.PageIndex = newPageIndex;
                LoadUsers();
                UsersUpdatePanel.Update();
            }
            else
            {
                System.Diagnostics.Debug.WriteLine($"Invalid PageIndex: {newPageIndex}, PageCount: {UsersGrid.PageCount}");
                UsersGrid.PageIndex = 0;
                LoadUsers();
                UsersUpdatePanel.Update();
            }
        }

        private void ShowUserModal(int userId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                // Enhanced query to get user details including phone number
                string userQuery = @"
            SELECT firstname, lastname, email, phone_number, user_role, is_activated, 
                   registered_date, last_login_date, profile_image
            FROM [User]
            WHERE user_id = @userId";

                // Query to get contribution statistics
                string contributionQuery = @"
            SELECT 
                (SELECT COUNT(*) FROM Recipe WHERE user_id = @userId) as TotalRecipes,
                (SELECT COUNT(*) FROM Event WHERE user_id = @userId) as TotalEvents,
                (SELECT COUNT(*) FROM Review WHERE user_id = @userId) as TotalReviews";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Get user details
                    using (SqlCommand cmd = new SqlCommand(userQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string userName = $"{reader["firstname"]} {reader["lastname"]}";
                                string email = reader["email"].ToString();
                                string phoneNumber = reader["phone_number"].ToString();
                                string userRole = reader["user_role"].ToString();
                                bool isActivated = Convert.ToBoolean(reader["is_activated"]);
                                DateTime dateCreated = Convert.ToDateTime(reader["registered_date"]);
                                DateTime? lastLoginDate = reader["last_login_date"] as DateTime?;
                                string profileImage = reader["profile_image"]?.ToString();

                                string status = GetUserStatus(isActivated, lastLoginDate);
                                string lastLoginText = lastLoginDate?.ToString("MMM dd, yyyy") ?? "Never";

                                // Close the first reader before executing the second query
                                reader.Close();

                                // Get contribution statistics
                                int totalRecipes = 0, totalEvents = 0, totalReviews = 0;
                                using (SqlCommand contributionCmd = new SqlCommand(contributionQuery, conn))
                                {
                                    contributionCmd.Parameters.AddWithValue("@userId", userId);
                                    using (SqlDataReader contributionReader = contributionCmd.ExecuteReader())
                                    {
                                        if (contributionReader.Read())
                                        {
                                            totalRecipes = Convert.ToInt32(contributionReader["TotalRecipes"]);
                                            totalEvents = Convert.ToInt32(contributionReader["TotalEvents"]);
                                            totalReviews = Convert.ToInt32(contributionReader["TotalReviews"]);
                                        }
                                    }
                                }

                                // Display user profile image or initials
                                string userAvatarContent = "";
                                if (!string.IsNullOrEmpty(profileImage))
                                {
                                    userAvatarContent = $"<img src='images/profiles/{profileImage}' alt='{userName}' class='w-24 h-24 rounded-full object-cover mx-auto' />";
                                }
                                else
                                {
                                    userAvatarContent = $"<div class='w-24 h-24 bg-blue-500 rounded-full flex items-center justify-center text-white font-bold text-2xl mx-auto'>{GetUserInitials(userName)}</div>";
                                }

                                string modalContent = $@"
                            <div class='grid grid-cols-1 lg:grid-cols-2 gap-8'>
                                <!-- Left Column -->
                                <div class='space-y-6'>
                                    <!-- User Profile -->
                                    <div class='text-center border-b pb-6'>
                                        {userAvatarContent}
                                        <h3 class='text-2xl font-bold text-gray-800 mt-4'>{userName}</h3>
                                        <p class='text-lg text-gray-600'>{userRole}</p>
                                        <span class='inline-block mt-2 {GetStatusBadgeClass(status)}'>{status}</span>
                                    </div>

                                    <!-- Contact Information -->
                                    <div class='bg-gray-50 rounded-lg p-6'>
                                        <h4 class='text-lg font-semibold text-gray-800 mb-4 flex items-center justify-between'>
                                            <span class='flex items-center'>
                                                <i class='fas fa-address-card text-blue-600 mr-2'></i>
                                                Contact Information
                                            </span>
                                            <button type='button' onclick='openEditEmailModal({userId}, ""{userName.Replace("'", "\\'")}"", ""{email}"")' 
                                                class='text-blue-600 hover:text-blue-800 text-sm font-medium'>
                                                <i class='fas fa-edit mr-1'></i>Edit Email
                                            </button>
                                        </h4>
                                        <div class='space-y-3'>
                                            <div class='flex items-center'>
                                                <i class='fas fa-envelope text-gray-500 w-5 mr-3'></i>
                                                <span class='text-gray-700'>{email}</span>
                                            </div>
                                            <div class='flex items-center'>
                                                <i class='fas fa-phone text-gray-500 w-5 mr-3'></i>
                                                <span class='text-gray-700'>{phoneNumber}</span>
                                            </div>
                                        </div>
                                    </div>
                                </div>

                                <!-- Right Column -->
                                <div class='space-y-6'>
                                    <!-- Account Details -->
                                    <div class='bg-blue-50 rounded-lg p-6'>
                                        <h4 class='text-lg font-semibold text-gray-800 mb-4 flex items-center'>
                                            <i class='fas fa-user-cog text-blue-600 mr-2'></i>
                                            Account Details
                                        </h4>
                                        <div class='space-y-3'>
                                            <div class='flex justify-between'>
                                                <span class='text-gray-600'>Role:</span>
                                                <span class='font-medium text-gray-800'>{userRole}</span>
                                            </div>
                                            <div class='flex justify-between'>
                                                <span class='text-gray-600'>Member Since:</span>
                                                <span class='font-medium text-gray-800'>{dateCreated:MMM dd, yyyy}</span>
                                            </div>
                                            <div class='flex justify-between'>
                                                <span class='text-gray-600'>Last Login:</span>
                                                <span class='font-medium text-gray-800'>{lastLoginText}</span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- Contributions -->
                                    <div class='bg-green-50 rounded-lg p-6'>
                                        <h4 class='text-lg font-semibold text-gray-800 mb-4 flex items-center'>
                                            <i class='fas fa-chart-bar text-green-600 mr-2'></i>
                                            Contributions
                                        </h4>
                                        <div class='grid grid-cols-3 gap-4'>
                                            <div class='text-center p-4 bg-white rounded-lg shadow-sm'>
                                                <div class='text-2xl font-bold text-blue-600'>{totalRecipes}</div>
                                                <div class='text-sm text-gray-600 mt-1'>Recipes</div>
                                            </div>
                                            <div class='text-center p-4 bg-white rounded-lg shadow-sm'>
                                                <div class='text-2xl font-bold text-green-600'>{totalEvents}</div>
                                                <div class='text-sm text-gray-600 mt-1'>Events</div>
                                            </div>
                                            <div class='text-center p-4 bg-white rounded-lg shadow-sm'>
                                                <div class='text-2xl font-bold text-purple-600'>{totalReviews}</div>
                                                <div class='text-sm text-gray-600 mt-1'>Reviews</div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        ";

                                string script = $@"
                            document.getElementById('view-modal-title').innerText = 'User: {userName.Replace("'", "\\'")}';
                            document.getElementById('view-modal-content').innerHTML = `{modalContent}`;
                            showViewModal();
                        ";
                                ScriptManager.RegisterStartupScript(this, GetType(), "showViewModal", script, true);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading user details: {ex.Message}");
            }
        }

        protected void UpdateEmail_Click(object sender, EventArgs e)
        {
            try
            {
                int userId = Convert.ToInt32(EditUserIdHidden.Value);
                string newEmail = NewEmailTextBox.Text.Trim();

                System.Diagnostics.Debug.WriteLine($"Updating email for userId: {userId}, newEmail: {newEmail}");

                if (string.IsNullOrEmpty(newEmail))
                {
                    ShowEditModalError("Please enter a valid email address.");
                    return;
                }

                if (!IsValidEmail(newEmail))
                {
                    ShowEditModalError("Please enter a valid email format.");
                    return;
                }

                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                // Check if email already exists (excluding current user)
                string checkEmailQuery = "SELECT COUNT(*) FROM [User] WHERE email = @email AND user_id != @userId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(checkEmailQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@email", newEmail);
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        int emailCount = (int)cmd.ExecuteScalar();

                        if (emailCount > 0)
                        {
                            ShowEditModalError("This email address is already in use by another user. Please choose a different email.");
                            return;
                        }
                    }
                }

                // Update email if unique
                string updateQuery = "UPDATE [User] SET email = @email WHERE user_id = @userId";
                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@email", newEmail);
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                // Refresh data
                LoadUsers();
                LoadUserStatistics();
                UsersUpdatePanel.Update();

                // Close edit modal and show success message in view modal
                string script = $@"
                    closeEditEmailModal();
                    refreshViewModalEmail({userId}, '{newEmail.Replace("'", "\\'")}');
                    showViewModalMessage('Email updated successfully!');
                ";
                ScriptManager.RegisterStartupScript(this, GetType(), "emailUpdateSuccess", script, true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating email: {ex.Message}");
                ShowEditModalError("Error updating email. Please try again.");
            }
        }

        private bool IsValidEmail(string email)
        {
            try
            {
                var addr = new System.Net.Mail.MailAddress(email);
                return addr.Address == email;
            }
            catch
            {
                return false;
            }
        }

        private void ShowEditModalError(string message)
        {
            string escapedMessage = message.Replace("'", "\\'").Replace("\"", "\\\"").Replace("\r", "").Replace("\n", "");
            string script = $@"showEditEmailError('{escapedMessage}');";
            ScriptManager.RegisterStartupScript(this, GetType(), "showEditModalError", script, true);
        }

        private void ToggleUserStatus(int userId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                // Get current status
                string getCurrentQuery = "SELECT is_activated FROM [User] WHERE user_id = @userId";
                bool currentStatus = false;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(getCurrentQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        currentStatus = Convert.ToBoolean(result);
                    }
                }

                // Toggle status
                bool newStatus = !currentStatus;
                string updateQuery = "UPDATE [User] SET is_activated = @status WHERE user_id = @userId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@status", newStatus);
                        cmd.Parameters.AddWithValue("@userId", userId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadUsers();
                LoadUserStatistics();
                ShowSuccessMessage($"User {(newStatus ? "unblocked" : "blocked")} successfully!");
                UsersUpdatePanel.Update();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error toggling user status: {ex.Message}");
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
        protected string GetUserInitials(object userName)
        {
            string name = userName?.ToString() ?? "U";
            string[] nameParts = name.Split(' ');
            if (nameParts.Length >= 2)
            {
                return (nameParts[0].Substring(0, 1) + nameParts[1].Substring(0, 1)).ToUpper();
            }
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        protected string GetUserProfileImageOrInitials(object userName, object profileImage)
        {
            string userProfileImage = profileImage?.ToString();
            string name = userName?.ToString() ?? "U";

            if (!string.IsNullOrEmpty(userProfileImage))
            {
                return $"<img src='images/profiles/{userProfileImage}' alt='{name}' class='w-10 h-10 rounded-full object-cover' />";
            }
            else
            {
                return $"<div class='w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center text-white font-medium'>{GetUserInitials(name)}</div>";
            }
        }

        protected string GetStatusBadgeClass(object status)
        {
            string statusText = status?.ToString().ToLower() ?? "";
            switch (statusText)
            {
                case "active":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800";
                case "inactive":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800";
                case "blocked":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-red-100 text-red-800";
                default:
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800";
            }
        }

        protected string GetBlockUnblockButtonClass(object isActivated)
        {
            bool activated = Convert.ToBoolean(isActivated);
            return activated ? "text-red-600 hover:text-red-900" : "text-green-600 hover:text-green-900";
        }

        protected string GetBlockUnblockButtonText(object isActivated)
        {
            bool activated = Convert.ToBoolean(isActivated);
            return activated ? "<i class=\"fas fa-ban\"></i> Block" : "<i class=\"fas fa-check\"></i> Unblock";
        }

        protected string GetFormattedLastLogin(object lastLoginDate)
        {
            if (lastLoginDate == null || lastLoginDate == DBNull.Value)
                return "Never";

            DateTime loginDate = Convert.ToDateTime(lastLoginDate);
            TimeSpan timeDiff = DateTime.Now - loginDate;

            if (timeDiff.TotalDays < 1)
                return "Today";
            else if (timeDiff.TotalDays < 2)
                return "Yesterday";
            else if (timeDiff.TotalDays < 7)
                return $"{(int)timeDiff.TotalDays} days ago";
            else
                return loginDate.ToString("MMM dd, yyyy");
        }

        // Pagination Methods
        protected string GetStartIndex()
        {
            int startIndex = (UsersGrid.PageIndex * UsersGrid.PageSize) + 1;
            return startIndex.ToString();
        }

        protected string GetEndIndex()
        {
            int endIndex = Math.Min((UsersGrid.PageIndex + 1) * UsersGrid.PageSize, _totalRecords);
            return endIndex.ToString();
        }

        protected int GetTotalRecords()
        {
            return _totalRecords;
        }

        protected string GeneratePaginationButtons()
        {
            if (UsersGrid.PageCount <= 1)
                return "";

            var buttons = new System.Text.StringBuilder();
            int currentPage = UsersGrid.PageIndex;
            int totalPages = UsersGrid.PageCount;

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
                    UsersGrid.UniqueID,
                    i + 1,
                    cssClass,
                    i + 1
                );
            }

            return buttons.ToString();
        }

        // Data Class 
        public new class User
        {
            public int UserId { get; set; }
            public string UserName { get; set; }
            public string Email { get; set; }
            public string UserRole { get; set; }
            public bool IsActivated { get; set; }
            public DateTime DateCreated { get; set; }
            public DateTime? LastLoginDate { get; set; }
            public string ProfileImage { get; set; }
            public string Status { get; set; }
        }
    }
}