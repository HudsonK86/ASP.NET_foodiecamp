using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class admin_review : System.Web.UI.Page
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
                LoadCuisineFilters();
                LoadReviews();
                LoadReviewStatistics();
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
                string query = "SELECT cuisine_id, cuisine_name FROM [Cuisine] ORDER BY cuisine_name";

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
                                CuisineFilter.Items.Add(new ListItem(cuisineName, cuisineId));
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

        private void LoadReviews()
        {
            try
            {
                List<Review> reviews = new List<Review>();
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                string query = @"
                    SELECT r.review_id, r.review_rating, r.review_comment, r.review_image, 
                           r.review_video, r.review_visibility, r.review_date,
                           (u.firstname + ' ' + u.lastname) as user_name, u.profile_image,
                           rec.recipe_name, c.cuisine_name
                    FROM Review r
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    INNER JOIN Recipe rec ON r.recipe_id = rec.recipe_id
                    INNER JOIN [Cuisine] c ON rec.cuisine_id = c.cuisine_id
                    ORDER BY r.review_date DESC";

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
                                if (reader["review_id"] == DBNull.Value)
                                    continue;

                                reviews.Add(new Review
                                {
                                    ReviewId = Convert.ToInt32(reader["review_id"]),
                                    ReviewRating = Convert.ToInt32(reader["review_rating"]),
                                    ReviewComment = reader["review_comment"].ToString(),
                                    ReviewImage = reader["review_image"]?.ToString(),
                                    ReviewVideo = reader["review_video"]?.ToString(),
                                    ReviewVisibility = reader["review_visibility"].ToString(),
                                    ReviewDate = Convert.ToDateTime(reader["review_date"]),
                                    UserName = reader["user_name"].ToString(),
                                    UserProfileImage = reader["profile_image"]?.ToString(),
                                    RecipeName = reader["recipe_name"].ToString(),
                                    CuisineName = reader["cuisine_name"].ToString()
                                });
                            }
                        }
                    }
                }

                _totalRecords = reviews.Count;
                ReviewsGrid.DataSource = reviews;
                ReviewsGrid.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading reviews: {ex.Message}");
            }
        }

        private void LoadReviewStatistics()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
                    SELECT 
                        COUNT(*) as Total,
                        SUM(CASE WHEN review_rating = 5 THEN 1 ELSE 0 END) as FiveStar,
                        SUM(CASE WHEN review_rating = 4 THEN 1 ELSE 0 END) as FourStar,
                        SUM(CASE WHEN review_rating = 3 THEN 1 ELSE 0 END) as ThreeStar,
                        SUM(CASE WHEN review_rating <= 2 THEN 1 ELSE 0 END) as LowStar
                    FROM Review";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                TotalReviewsLabel.Text = reader["Total"].ToString();
                                FiveStarLabel.Text = reader["FiveStar"].ToString();
                                FourStarLabel.Text = reader["FourStar"].ToString();
                                ThreeStarLabel.Text = reader["ThreeStar"].ToString();
                                LowStarLabel.Text = reader["LowStar"].ToString();
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
            // Apply rating filter
            if (RatingFilter.SelectedValue != "all")
            {
                string ratingCondition = $"AND r.review_rating = {RatingFilter.SelectedValue}";
                baseQuery = baseQuery.Replace("ORDER BY", ratingCondition + " ORDER BY");
            }

            // Apply visibility filter
            if (VisibilityFilter.SelectedValue != "all")
            {
                string dbValue = VisibilityFilter.SelectedValue == "show" ? "Show" : "Hide";
                string visibilityCondition = $"AND r.review_visibility = '{dbValue}'";
                baseQuery = baseQuery.Replace("ORDER BY", visibilityCondition + " ORDER BY");
            }

            // Apply cuisine filter
            if (CuisineFilter.SelectedValue != "all")
            {
                string cuisineCondition = $"AND rec.cuisine_id = {CuisineFilter.SelectedValue}";
                baseQuery = baseQuery.Replace("ORDER BY", cuisineCondition + " ORDER BY");
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(SearchBox.Text))
            {
                string searchCondition = $"AND (r.review_comment LIKE '%{SearchBox.Text.Replace("'", "''")}%' OR (u.firstname + ' ' + u.lastname) LIKE '%{SearchBox.Text.Replace("'", "''")}%')";
                baseQuery = baseQuery.Replace("ORDER BY", searchCondition + " ORDER BY");
            }

            return baseQuery;
        }

        // Event Handlers
        protected void Filter_Changed(object sender, EventArgs e)
        {
            ReviewsGrid.PageIndex = 0;
            MessagePanel.Visible = false;
            LoadReviews();
            LoadReviewStatistics();
            ReviewsUpdatePanel.Update();
        }

        protected void ReviewsGrid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int reviewId))
            {
                System.Diagnostics.Debug.WriteLine($"Invalid CommandArgument: '{e.CommandArgument}' for CommandName: '{e.CommandName}'");
                return;
            }

            switch (e.CommandName)
            {
                case "ViewReview":
                    ShowReviewModal(reviewId);
                    break;
                case "ToggleVisibility":
                    ToggleReviewVisibility(reviewId);
                    break;
            }
        }

        protected void ReviewsGrid_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            int newPageIndex = e.NewPageIndex;

            string eventArgument = Request.Form["__EVENTARGUMENT"];
            if (!string.IsNullOrEmpty(eventArgument) && int.TryParse(eventArgument, out int parsedPageIndex))
            {
                newPageIndex = parsedPageIndex;
            }

            if (newPageIndex >= 0 && newPageIndex < ReviewsGrid.PageCount)
            {
                ReviewsGrid.PageIndex = newPageIndex;
                LoadReviews();
                ReviewsUpdatePanel.Update();
            }
            else
            {
                System.Diagnostics.Debug.WriteLine($"Invalid PageIndex: {newPageIndex}, PageCount: {ReviewsGrid.PageCount}");
                ReviewsGrid.PageIndex = 0;
                LoadReviews();
                ReviewsUpdatePanel.Update();
            }
        }

        private void ShowReviewModal(int reviewId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
                    SELECT r.review_rating, r.review_comment, r.review_image, r.review_video, r.review_date,
                           (u.firstname + ' ' + u.lastname) as user_name, u.profile_image,
                           rec.recipe_name
                    FROM Review r
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    INNER JOIN Recipe rec ON r.recipe_id = rec.recipe_id
                    WHERE r.review_id = @reviewId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@reviewId", reviewId);
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string userName = reader["user_name"].ToString();
                                string userProfileImage = reader["profile_image"]?.ToString();
                                string recipeName = reader["recipe_name"].ToString();
                                int rating = Convert.ToInt32(reader["review_rating"]);
                                string comment = reader["review_comment"].ToString();
                                string reviewImage = reader["review_image"]?.ToString();
                                string reviewVideo = reader["review_video"]?.ToString();
                                DateTime reviewDate = Convert.ToDateTime(reader["review_date"]);

                                string stars = GetStarRating(rating);
                                string mediaContent = "";

                                if (!string.IsNullOrEmpty(reviewImage))
                                {
                                    mediaContent += $"<div class='mb-4'><img src='images/reviews/{reviewImage}' alt='Review Image' class='max-w-full h-auto rounded-lg' /></div>";
                                }

                                if (!string.IsNullOrEmpty(reviewVideo))
                                {
                                    mediaContent += $"<div class='mb-4'><video controls class='max-w-full h-auto rounded-lg'><source src='images/reviews/{reviewVideo}' type='video/mp4'>Your browser does not support the video tag.</video></div>";
                                }

                                // Display user profile image or initials
                                string userAvatarContent = "";
                                if (!string.IsNullOrEmpty(userProfileImage))
                                {
                                    userAvatarContent = $"<img src='images/profiles/{userProfileImage}' alt='{userName}' class='w-16 h-16 rounded-full object-cover' />";
                                }
                                else
                                {
                                    userAvatarContent = $"<div class='w-16 h-16 bg-blue-500 rounded-full flex items-center justify-center text-white font-medium text-lg'>{GetUserInitials(userName)}</div>";
                                }

                                string modalContent = $@"
                                    <div class='border-b pb-4'>
                                        <div class='flex items-center space-x-4 mb-4'>
                                            {userAvatarContent}
                                            <div>
                                                <h3 class='text-lg font-semibold text-gray-800'>{userName}</h3>
                                                <p class='text-sm text-gray-500'>Recipe: {recipeName}</p>
                                            </div>
                                        </div>
                                        <div class='flex items-center mb-2'>
                                            <span class='text-yellow-400 text-xl mr-2'>{stars}</span>
                                            <span class='text-sm text-gray-600'>{rating}.0 • {reviewDate:MMM dd, yyyy}</span>
                                        </div>
                                    </div>
                                    <div class='py-4'>
                                        <h4 class='font-medium text-gray-800 mb-2'>Review Comment:</h4>
                                        <p class='text-gray-700 leading-relaxed mb-4'>{comment}</p>
                                        {mediaContent}
                                    </div>
                                ";

                                string script = $@"
                                    document.getElementById('review-modal-title').innerText = 'Review by {userName.Replace("'", "\\'")}';
                                    document.getElementById('review-modal-content').innerHTML = `{modalContent}`;
                                    showReviewModal();
                                ";
                                ScriptManager.RegisterStartupScript(this, GetType(), "showReviewModal", script, true);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading review details: {ex.Message}");
            }
        }

        private void ToggleReviewVisibility(int reviewId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                // Get current visibility
                string getCurrentQuery = "SELECT review_visibility FROM Review WHERE review_id = @reviewId";
                string currentVisibility = "";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(getCurrentQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@reviewId", reviewId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        currentVisibility = result?.ToString() ?? "Hide";
                    }
                }

                // Toggle visibility
                string newVisibility = (currentVisibility == "Show") ? "Hide" : "Show";
                string updateQuery = "UPDATE Review SET review_visibility = @visibility WHERE review_id = @reviewId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@visibility", newVisibility);
                        cmd.Parameters.AddWithValue("@reviewId", reviewId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadReviews();
                LoadReviewStatistics();
                ShowSuccessMessage("Review visibility updated successfully!");
                ReviewsUpdatePanel.Update();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error toggling visibility: {ex.Message}");
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

        protected string GetStarRating(object rating)
        {
            int stars = Convert.ToInt32(rating ?? 0);
            return new string('★', stars) + new string('☆', 5 - stars);
        }

        protected string GetVisibilityText(object visibility)
        {
            return visibility?.ToString() ?? "Hide";
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

        // Pagination Methods (same pattern as admin-recipe)
        protected string GetStartIndex()
        {
            int startIndex = (ReviewsGrid.PageIndex * ReviewsGrid.PageSize) + 1;
            return startIndex.ToString();
        }

        protected string GetEndIndex()
        {
            int endIndex = Math.Min((ReviewsGrid.PageIndex + 1) * ReviewsGrid.PageSize, _totalRecords);
            return endIndex.ToString();
        }

        protected int GetTotalRecords()
        {
            return _totalRecords;
        }

        protected string GeneratePaginationButtons()
        {
            if (ReviewsGrid.PageCount <= 1)
                return "";

            var buttons = new System.Text.StringBuilder();
            int currentPage = ReviewsGrid.PageIndex;
            int totalPages = ReviewsGrid.PageCount;

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
                    ReviewsGrid.UniqueID,
                    i + 1,
                    cssClass,
                    i + 1
                );
            }

            return buttons.ToString();
        }

        // Helper method to get user profile image URL or return initials
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

        // Data Class
        public class Review
        {
            public int ReviewId { get; set; }
            public int ReviewRating { get; set; }
            public string ReviewComment { get; set; }
            public string ReviewImage { get; set; }
            public string ReviewVideo { get; set; }
            public string ReviewVisibility { get; set; }
            public DateTime ReviewDate { get; set; }
            public string UserName { get; set; }
            public string UserProfileImage { get; set; }
            public string RecipeName { get; set; }
            public string CuisineName { get; set; }
        }
    }
}