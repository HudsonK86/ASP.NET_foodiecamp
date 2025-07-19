using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class admin_recipe : System.Web.UI.Page
    {
        // Add these private fields at the top of your class
        private int _adminTotalRecords = 0;
        private int _userTotalRecords = 0;

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
                LoadCuisineFilters();
                LoadAdminRecipes();
                LoadUserRecipes();
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

        private void LoadCuisineFilters()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = "SELECT cuisine_id, cuisine_name FROM [Cuisine] ORDER BY cuisine_id";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                string cuisineId = reader["cuisine_id"].ToString();
                                string cuisineName = reader["cuisine_name"].ToString();

                                // Add to both dropdowns
                                AdminCuisineFilter.Items.Add(new ListItem(cuisineName, cuisineId));
                                UserCuisineFilter.Items.Add(new ListItem(cuisineName, cuisineId));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading cuisines: {ex.Message}");
            }
        }

        // UPDATE this method to track total records and handle NULL values
        private void LoadAdminRecipes()
        {
            try
            {
                List<AdminRecipe> recipes = new List<AdminRecipe>();
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                string query = @"
                    SELECT r.recipe_id, r.recipe_name, r.recipe_image, r.recipe_visibility, r.date_created,
                           c.cuisine_name, (u.firstname + ' ' + u.lastname) as created_by
                    FROM Recipe r
                    INNER JOIN Cuisine c ON r.cuisine_id = c.cuisine_id
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    WHERE u.user_role = 'Admin'
                    ORDER BY r.date_created DESC";

                // Apply filters
                query = ApplyAdminFilters(query);

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                // Skip rows with NULL recipe_id
                                if (reader["recipe_id"] == DBNull.Value)
                                    continue;

                                recipes.Add(new AdminRecipe
                                {
                                    RecipeId = Convert.ToInt32(reader["recipe_id"]),
                                    RecipeName = reader["recipe_name"].ToString(),
                                    RecipeImage = reader["recipe_image"].ToString(),
                                    CuisineName = reader["cuisine_name"].ToString(),
                                    RecipeVisibility = reader["recipe_visibility"].ToString(),
                                    DateCreated = Convert.ToDateTime(reader["date_created"]),
                                    CreatedBy = reader["created_by"].ToString()
                                });
                            }
                        }
                    }
                }

                _adminTotalRecords = recipes.Count; // Store total records for pagination
                AdminRecipesGrid.DataSource = recipes;
                AdminRecipesGrid.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading admin recipes: {ex.Message}");
            }
        }

        // UPDATE this method to track total records and handle NULL values
        private void LoadUserRecipes()
        {
            try
            {
                List<UserRecipe> recipes = new List<UserRecipe>();
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                string query = @"
                    SELECT r.recipe_id, r.recipe_name, r.recipe_image, r.recipe_visibility, r.date_created,
                           r.recipe_status, c.cuisine_name, (u.firstname + ' ' + u.lastname) as created_by
                    FROM Recipe r
                    INNER JOIN Cuisine c ON r.cuisine_id = c.cuisine_id
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    WHERE u.user_role = 'User'
                    ORDER BY r.date_created DESC";

                // Apply filters
                query = ApplyUserFilters(query);

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                // Skip rows with NULL recipe_id
                                if (reader["recipe_id"] == DBNull.Value)
                                    continue;

                                recipes.Add(new UserRecipe
                                {
                                    RecipeId = Convert.ToInt32(reader["recipe_id"]),
                                    RecipeName = reader["recipe_name"].ToString(),
                                    RecipeImage = reader["recipe_image"].ToString(),
                                    CuisineName = reader["cuisine_name"].ToString(),
                                    RecipeStatus = reader["recipe_status"].ToString(),
                                    RecipeVisibility = reader["recipe_visibility"].ToString(),
                                    DateCreated = Convert.ToDateTime(reader["date_created"]),
                                    CreatedBy = reader["created_by"].ToString()
                                });
                            }
                        }
                    }
                }

                _userTotalRecords = recipes.Count; // Store total records for pagination
                UserRecipesGrid.DataSource = recipes;
                UserRecipesGrid.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading user recipes: {ex.Message}");
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
                        SUM(CASE WHEN recipe_status = 'Pending' THEN 1 ELSE 0 END) as Pending,
                        SUM(CASE WHEN recipe_status = 'Approved' THEN 1 ELSE 0 END) as Approved,
                        SUM(CASE WHEN recipe_status = 'Rejected' THEN 1 ELSE 0 END) as Rejected
                    FROM Recipe r
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    WHERE u.user_role = 'User'";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                TotalRecipesLabel.Text = reader["Total"].ToString();
                                PendingRecipesLabel.Text = reader["Pending"].ToString();
                                ApprovedRecipesLabel.Text = reader["Approved"].ToString();
                                RejectedRecipesLabel.Text = reader["Rejected"].ToString();
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

        private string ApplyAdminFilters(string baseQuery)
        {
            // Apply visibility filter
            if (AdminVisibilityFilter.SelectedValue != "all")
            {
                // Map the filter values to proper database values
                string dbValue = AdminVisibilityFilter.SelectedValue == "show" ? "Show" : "Hide";
                string visibilityCondition = $"AND r.recipe_visibility = '{dbValue}'";
                baseQuery = baseQuery.Replace("ORDER BY", visibilityCondition + " ORDER BY");
            }

            // Apply cuisine filter
            if (AdminCuisineFilter.SelectedValue != "all")
            {
                string cuisineCondition = $"AND r.cuisine_id = {AdminCuisineFilter.SelectedValue}";
                baseQuery = baseQuery.Replace("ORDER BY", cuisineCondition + " ORDER BY");
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(AdminSearchBox.Text))
            {
                string searchCondition = $"AND r.recipe_name LIKE '%{AdminSearchBox.Text.Replace("'", "''")}%'";
                baseQuery = baseQuery.Replace("ORDER BY", searchCondition + " ORDER BY");
            }

            return baseQuery;
        }

        private string ApplyUserFilters(string baseQuery)
        {
            // Apply status filter
            if (UserStatusFilter.SelectedValue != "all")
            {
                string statusCondition = $"AND r.recipe_status = '{UserStatusFilter.SelectedValue}'";
                baseQuery = baseQuery.Replace("ORDER BY", statusCondition + " ORDER BY");
            }

            // Apply visibility filter
            if (UserVisibilityFilter.SelectedValue != "all")
            {
                string visibilityCondition = $"AND r.recipe_visibility = '{UserVisibilityFilter.SelectedValue}'";
                baseQuery = baseQuery.Replace("ORDER BY", visibilityCondition + " ORDER BY");
            }

            // Apply cuisine filter
            if (UserCuisineFilter.SelectedValue != "all")
            {
                string cuisineCondition = $"AND r.cuisine_id = {UserCuisineFilter.SelectedValue}";
                baseQuery = baseQuery.Replace("ORDER BY", cuisineCondition + " ORDER BY");
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(UserSearchBox.Text))
            {
                string searchCondition = $"AND r.recipe_name LIKE '%{UserSearchBox.Text.Replace("'", "''")}%'";
                baseQuery = baseQuery.Replace("ORDER BY", searchCondition + " ORDER BY");
            }

            return baseQuery;
        }

        // Event Handlers
        protected void PostRecipeButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/post-recipe.aspx");
        }

        // UPDATED: Added UpdatePanel support for Admin filters
        protected void AdminFilter_Changed(object sender, EventArgs e)
        {
            AdminRecipesGrid.PageIndex = 0; // Reset to first page when filtering
            MessagePanel.Visible = false;
            LoadAdminRecipes();
            // Manually trigger UpdatePanel update
            AdminRecipesUpdatePanel.Update();
        }

        // UPDATED: Added UpdatePanel support for User filters
        protected void UserFilter_Changed(object sender, EventArgs e)
        {
            UserRecipesGrid.PageIndex = 0; // Reset to first page when filtering
            LoadUserRecipes();
            LoadUserStatistics();
            // Manually trigger UpdatePanel update
            UserRecipesUpdatePanel.Update();
        }

        // UPDATED: Added UpdatePanel support for Admin grid actions
        protected void AdminRecipesGrid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            // Validate CommandArgument before conversion
            if (!int.TryParse(e.CommandArgument?.ToString(), out int recipeId))
            {
                // Log the error for debugging
                System.Diagnostics.Debug.WriteLine($"Invalid CommandArgument: '{e.CommandArgument}' for CommandName: '{e.CommandName}'");
                return;
            }

            switch (e.CommandName)
            {
                case "ViewRecipe":
                    Response.Redirect($"~/recipe-detail.aspx?id={recipeId}");
                    break;
                case "EditRecipe":
                    Response.Redirect($"~/edit-recipe.aspx?id={recipeId}");
                    break;
                case "ToggleVisibility":
                    ToggleRecipeVisibility(recipeId);
                    // UpdatePanel will be updated inside ToggleRecipeVisibility method
                    break;
            }
        }

        // Update your existing UserRecipesGrid_RowCommand method
        protected void UserRecipesGrid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int recipeId))
            {
                System.Diagnostics.Debug.WriteLine($"Invalid CommandArgument: '{e.CommandArgument}' for CommandName: '{e.CommandName}'");
                return;
            }

            switch (e.CommandName)
            {
                case "ViewUserRecipe":
                    Response.Redirect($"~/recipe-detail.aspx?id={recipeId}");
                    break;
                case "ApproveRecipe":
                    // Direct approval without modal
                    UpdateRecipeStatus(recipeId, "Approved");
                    SaveApprovalNotification(recipeId);
                    ShowSuccessMessage("Recipe approved successfully!");
                    break;
                case "RejectRecipe":
                    // Show reject modal
                    ShowRejectModal(recipeId);
                    break;
            }
        }

        private void ShowRejectModal(int recipeId)
        {
            try
            {
                // Get recipe details for the modal
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
                    SELECT r.recipe_name, r.recipe_image, (u.firstname + ' ' + u.lastname) as created_by
                    FROM Recipe r
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    WHERE r.recipe_id = @recipeId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@recipeId", recipeId);
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string recipeName = reader["recipe_name"].ToString();
                                string recipeImage = GetRecipeImageUrl(reader["recipe_image"]);
                                string createdBy = reader["created_by"].ToString();

                                // Store recipe ID for later use
                                RejectRecipeIdHidden.Value = recipeId.ToString();

                                // Clear previous reason
                                RejectReasonTextBox.Text = "";

                                // Show modal with recipe info
                                string script = $@"
                                    document.getElementById('reject-recipe-name').innerText = '{recipeName.Replace("'", "\\'")}';
                                    document.getElementById('reject-recipe-author').innerText = 'by {createdBy.Replace("'", "\\'")}';
                                    document.getElementById('reject-recipe-image').src = '{recipeImage}';
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
                System.Diagnostics.Debug.WriteLine($"Error loading recipe for reject modal: {ex.Message}");
            }
        }

        protected void ConfirmReject_Click(object sender, EventArgs e)
        {
            string reason = RejectReasonTextBox.Text.Trim();
            if (!int.TryParse(RejectRecipeIdHidden.Value, out int recipeId))
                return; // or handle error

            if (string.IsNullOrWhiteSpace(reason))
            {
                // Show error message on the modal (use a Label control in the modal)
                RejectReasonErrorLabel.Text = "Please provide a reason for rejection.";
                RejectReasonErrorLabel.Visible = true;
                ShowRejectModal(recipeId); // Show the modal with the error message
                return;
            }
            RejectReasonErrorLabel.Visible = false;

            UpdateRecipeStatus(recipeId, "Rejected");
            SaveRejectionNotification(recipeId, reason);
            ShowSuccessMessage("Recipe rejected successfully!");
            ScriptManager.RegisterStartupScript(this, GetType(), "closeRejectModal", "closeRejectModal();", true);
        }

        private void SaveRejectionNotification(int recipeId, string reason)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                int userId = 0;
                string recipeName = "";
                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand("SELECT user_id, recipe_name FROM Recipe WHERE recipe_id = @recipeId", conn))
                {
                    cmd.Parameters.AddWithValue("@recipeId", recipeId);
                    conn.Open();
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            userId = Convert.ToInt32(reader["user_id"]);
                            recipeName = reader["recipe_name"].ToString();
                        }
                    }
                }

                if (userId == 0)
                    return;

                string notificationMessage = string.IsNullOrEmpty(reason)
                    ? $"Your recipe '{recipeName}' has been rejected by the administrator."
                    : $"Your recipe '{recipeName}' has been rejected. Reason: {reason}";

                using (SqlConnection conn = new SqlConnection(connectionString))
                using (SqlCommand cmd = new SqlCommand(@"
                INSERT INTO Notification (user_id, notification_type, related_id, notification_message, notification_date, is_read)
                VALUES (@user_id, @type, @related_id, @message, @date, @is_read)", conn))
                {
                    cmd.Parameters.AddWithValue("@user_id", userId);
                    cmd.Parameters.AddWithValue("@type", "Recipe_Rejection");
                    cmd.Parameters.AddWithValue("@related_id", recipeId);
                    cmd.Parameters.AddWithValue("@message", notificationMessage);
                    cmd.Parameters.AddWithValue("@date", DateTime.Today);
                    cmd.Parameters.AddWithValue("@is_read", false);
                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error saving rejection notification: {ex.Message}");
            }
        }

        private void SaveApprovalNotification(int recipeId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string getUserQuery = @"
            SELECT r.user_id, r.recipe_name 
            FROM Recipe r 
            WHERE r.recipe_id = @recipeId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    int userId = 0;
                    string recipeName = "";

                    using (SqlCommand getUserCmd = new SqlCommand(getUserQuery, conn))
                    {
                        getUserCmd.Parameters.AddWithValue("@recipeId", recipeId);
                        using (SqlDataReader reader = getUserCmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                userId = Convert.ToInt32(reader["user_id"]);
                                recipeName = reader["recipe_name"].ToString();
                            }
                        }
                    }

                    if (userId > 0)
                    {
                        string notificationMessage = $"Your recipe '{recipeName}' has been approved by the administrator.";

                        string insertQuery = @"
                    INSERT INTO [Notification] 
                    (user_id, notification_type, related_id, notification_message, notification_date, is_read)
                    VALUES (@userId, @notificationType, @relatedId, @notificationMessage, @notificationDate, @isRead)";

                        using (SqlCommand insertCmd = new SqlCommand(insertQuery, conn))
                        {
                            insertCmd.Parameters.AddWithValue("@userId", userId);
                            insertCmd.Parameters.AddWithValue("@notificationType", "Recipe_Approval");
                            insertCmd.Parameters.AddWithValue("@relatedId", recipeId);
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

        // UPDATED: Added UpdatePanel support
        private void ToggleRecipeVisibility(int recipeId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                // First get current visibility
                string getCurrentQuery = "SELECT recipe_visibility FROM Recipe WHERE recipe_id = @recipeId";
                string currentVisibility = "";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(getCurrentQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@recipeId", recipeId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        currentVisibility = result?.ToString() ?? "Hide";
                    }
                }

                // Toggle visibility - handle proper casing
                string newVisibility = (currentVisibility == "Show") ? "Hide" : "Show";  // Changed from .ToLower()
                string updateQuery = "UPDATE Recipe SET recipe_visibility = @visibility WHERE recipe_id = @recipeId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@visibility", newVisibility);
                        cmd.Parameters.AddWithValue("@recipeId", recipeId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadAdminRecipes();
                ShowSuccessMessage("Recipe visibility updated successfully!");

                // ADDED: Manually trigger UpdatePanel update
                AdminRecipesUpdatePanel.Update();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error toggling visibility: {ex.Message}");
            }
        }

        // UPDATED: Added UpdatePanel support
        private void UpdateRecipeStatus(int recipeId, string status)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = "UPDATE Recipe SET recipe_status = @status WHERE recipe_id = @recipeId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@status", status);
                        cmd.Parameters.AddWithValue("@recipeId", recipeId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadUserRecipes();
                LoadUserStatistics();

                // ADDED: Manually trigger UpdatePanel update
                UserRecipesUpdatePanel.Update();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error updating recipe status: {ex.Message}");
            }
        }

        private void ShowSuccessMessage(string message)
        {
            MessageLabel.Text = message;
            MessagePanel.Visible = true;
            
            // Use ScriptManager to register a script that will hide the message after 5 seconds
            ScriptManager.RegisterStartupScript(this, GetType(), "hideMessage",
                "setTimeout(function() { closeMessage(); }, 5000);", true);
        }

        private void ShowErrorMessage(string message)
        {
            // Show error message using JavaScript alert for now
            // You can enhance this to use a proper error message panel
            ScriptManager.RegisterStartupScript(this, GetType(), "showError", 
                $"alert('Error: {message.Replace("'", "\\'")}');", true);
        }

        protected void AdminLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/logout.aspx");
        }

        // Helper Methods for Data Binding
        protected string GetRecipeImageUrl(object RecipeImage)
        {
            string imageName = RecipeImage?.ToString();
            if (!string.IsNullOrEmpty(imageName))
            {
                return $"/images/recipes/{imageName}";
            }
            return "https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=60&h=60&fit=crop";
        }

        protected string GetVisibilityText(object visibility)
        {
            string visibilityText = visibility?.ToString() ?? "Hide";
            return visibilityText;
        }

        protected string GetVisibilityBadgeClass(object visibility)
        {
            string visibilityText = visibility?.ToString() ?? "Hide";
            return visibilityText == "Show"  
                ? "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800"
                : "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-200 text-gray-600";
        }

        protected string GetToggleVisibilityText(object visibility)
        {
            string visibilityText = visibility?.ToString() ?? "Hide";
            return visibilityText == "Show" 
                ? "<i class=\"fas fa-eye-slash\"></i> Hide"
                : "<i class=\"fas fa-eye\"></i> Show";
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
                default:
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800";
            }
        }

        protected void AdminRecipesGrid_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            // Handle both direct page clicks and next/prev navigation
            int newPageIndex = e.NewPageIndex;

            // Get the postback event argument to handle custom pagination buttons
            string eventArgument = Request.Form["__EVENTARGUMENT"];
            if (!string.IsNullOrEmpty(eventArgument) && int.TryParse(eventArgument, out int parsedPageIndex))
            {
                newPageIndex = parsedPageIndex;
            }

            // Add validation to prevent ArgumentOutOfRangeException
            if (newPageIndex >= 0 && newPageIndex < AdminRecipesGrid.PageCount)
            {
                AdminRecipesGrid.PageIndex = newPageIndex;
                LoadAdminRecipes();
                AdminRecipesUpdatePanel.Update();
            }
            else
            {
                // Log the error and reset to first page
                System.Diagnostics.Debug.WriteLine($"Invalid PageIndex: {newPageIndex}, PageCount: {AdminRecipesGrid.PageCount}");
                AdminRecipesGrid.PageIndex = 0;
                LoadAdminRecipes();
                AdminRecipesUpdatePanel.Update();
            }
        }

        protected void UserRecipesGrid_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            // Handle both direct page clicks and next/prev navigation
            int newPageIndex = e.NewPageIndex;

            // Get the postback event argument to handle custom pagination buttons
            string eventArgument = Request.Form["__EVENTARGUMENT"];
            if (!string.IsNullOrEmpty(eventArgument) && int.TryParse(eventArgument, out int parsedPageIndex))
            {
                newPageIndex = parsedPageIndex;
            }

            // Add validation to prevent ArgumentOutOfRangeException
            if (newPageIndex >= 0 && newPageIndex < UserRecipesGrid.PageCount)
            {
                UserRecipesGrid.PageIndex = newPageIndex;
                LoadUserRecipes();
                LoadUserStatistics();
                UserRecipesUpdatePanel.Update();
            }
            else
            {
                // Log the error and reset to first page
                System.Diagnostics.Debug.WriteLine($"Invalid PageIndex: {newPageIndex}, PageCount: {UserRecipesGrid.PageCount}");
                UserRecipesGrid.PageIndex = 0;
                LoadUserRecipes();
                LoadUserStatistics();
                UserRecipesUpdatePanel.Update();
            }
        }

        // Admin-specific methods that call the generic ones
        protected string GetStartIndex()
        {
            return GetStartIndexForGrid("admin");
        }

        protected string GetEndIndex()
        {
            return GetEndIndexForGrid("admin");
        }

        protected int GetTotalRecords()
        {
            return GetTotalRecordsForGrid("admin");
        }

        protected string GeneratePaginationButtons()
        {
            return GeneratePaginationButtonsForGrid("admin");
        }

        // User-specific methods that call the generic ones
        protected string GetUserStartIndex()
        {
            return GetStartIndexForGrid("user");
        }

        protected string GetUserEndIndex()
        {
            return GetEndIndexForGrid("user");
        }

        protected int GetUserTotalRecords()
        {
            return GetTotalRecordsForGrid("user");
        }

        protected string GenerateUserPaginationButtons()
        {
            return GeneratePaginationButtonsForGrid("user");
        }

        // Generic helper methods that do the actual work
        private string GetStartIndexForGrid(string gridType)
        {
            if (gridType == "user")
            {
                int startIndex = (UserRecipesGrid.PageIndex * UserRecipesGrid.PageSize) + 1;
                return startIndex.ToString();
            }
            else
            {
                int startIndex = (AdminRecipesGrid.PageIndex * AdminRecipesGrid.PageSize) + 1;
                return startIndex.ToString();
            }
        }

        private string GetEndIndexForGrid(string gridType)
        {
            if (gridType == "user")
            {
                int endIndex = Math.Min((UserRecipesGrid.PageIndex + 1) * UserRecipesGrid.PageSize, _userTotalRecords);
                return endIndex.ToString();
            }
            else
            {
                int endIndex = Math.Min((AdminRecipesGrid.PageIndex + 1) * AdminRecipesGrid.PageSize, _adminTotalRecords);
                return endIndex.ToString();
            }
        }

        private int GetTotalRecordsForGrid(string gridType)
        {
            return gridType == "user" ? _userTotalRecords : _adminTotalRecords;
        }

        private string GeneratePaginationButtonsForGrid(string gridType)
        {
            GridView targetGrid = gridType == "user" ? UserRecipesGrid : AdminRecipesGrid;

            if (targetGrid.PageCount <= 1)
                return "";

            var buttons = new System.Text.StringBuilder();
            int currentPage = targetGrid.PageIndex;
            int totalPages = targetGrid.PageCount;

            // Show 5 pages max
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
                    targetGrid.UniqueID,
                    i + 1,
                    cssClass,
                    i + 1
                );
            }

            return buttons.ToString();
        }


        // Updated Data Classes to match your database schema
        public class AdminRecipe
        {
            public int RecipeId { get; set; }
            public string RecipeName { get; set; }
            public string RecipeImage { get; set; }
            public string CuisineName { get; set; }
            public string RecipeVisibility { get; set; }
            public DateTime DateCreated { get; set; }
            public string CreatedBy { get; set; }

            // Helper properties for compatibility with ASPX bindings
            public bool IsVisible => RecipeVisibility?.ToLower() == "show";
            public DateTime CreatedAt => DateCreated;
        }

        public class UserRecipe
        {
            public int RecipeId { get; set; }
            public string RecipeName { get; set; }
            public string RecipeImage { get; set; }
            public string CuisineName { get; set; }
            public string RecipeStatus { get; set; }
            public string RecipeVisibility { get; set; }
            public DateTime DateCreated { get; set; }
            public string CreatedBy { get; set; }

            // Helper properties for compatibility with ASPX bindings
            public string Status => RecipeStatus;
            public bool IsVisible => RecipeVisibility?.ToLower() == "show";
            public DateTime CreatedAt => DateCreated;
        }
    }
}