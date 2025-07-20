using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class recipe_detail : System.Web.UI.Page
    {
        protected RecipeDetailModel Recipe { get; set; }
        protected List<ReviewModel> Reviews { get; set; }
        protected double AverageRating { get; set; }
        protected int ReviewCount { get; set; }

        protected bool IsBookmarked { get; set; }
        protected bool IsCompleted { get; set; }
        protected string UserRole { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            int recipeId;
            if (!int.TryParse(Request.QueryString["id"], out recipeId))
            {
                Response.Redirect("recipes.aspx");
                return;
            }

            LoadRecipe(recipeId);
            BindReviews(recipeId);

            // Check bookmark/completed status if logged in and user is not admin
            if (Session["UserId"] != null)
            {
                UserRole = Session["UserRole"] as string ?? "User";
                if (UserRole == "User")
                {
                    int userId = Convert.ToInt32(Session["UserId"]);
                    IsBookmarked = CheckBookmarked(userId, recipeId);
                    IsCompleted = CheckCompleted(userId, recipeId);
                }
            }
            // Add this to ensure buttons get correct text and style
            this.DataBind();
        }

        private void LoadRecipe(int recipeId)
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT r.*, c.cuisine_name, u.firstname, u.lastname
                    FROM Recipe r
                    INNER JOIN Cuisine c ON r.cuisine_id = c.cuisine_id
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    WHERE r.recipe_id = @recipeId";
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@recipeId", recipeId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            Recipe = new RecipeDetailModel
                            {
                                RecipeId = recipeId,
                                RecipeName = reader["recipe_name"].ToString(),
                                CuisineName = reader["cuisine_name"].ToString(),
                                DifficultyLevel = reader["difficulty_level"].ToString(),
                                CookingTime = Convert.ToInt32(reader["cooking_time"]),
                                Servings = Convert.ToInt32(reader["servings"]),
                                RecipeImage = !string.IsNullOrEmpty(reader["recipe_image"].ToString())
                                    ? "/images/recipes/" + reader["recipe_image"].ToString()
                                    : "https://images.unsplash.com/photo-1612929633738-8fe44f7ec841?w=400&h=250&fit=crop",
                                RecipeVideo = reader["recipe_video"].ToString(),
                                RecipeDescription = reader["recipe_description"].ToString(),
                                CookingIngredient = reader["cooking_ingredient"].ToString(),
                                CookingInstruction = reader["cooking_instruction"].ToString(),
                                Calory = reader["calory"] != DBNull.Value ? Convert.ToInt32(reader["calory"]) : (int?)null,
                                Protein = reader["protein"] != DBNull.Value ? Convert.ToInt32(reader["protein"]) : (int?)null,
                                Carb = reader["carb"] != DBNull.Value ? Convert.ToInt32(reader["carb"]) : (int?)null,
                                Fat = reader["fat"] != DBNull.Value ? Convert.ToInt32(reader["fat"]) : (int?)null,
                                DateCreated = Convert.ToDateTime(reader["date_created"]),
                                PostedBy = $"{reader["firstname"]} {reader["lastname"]}",
                                PostedByUserId = Convert.ToInt32(reader["user_id"]) // Add this line
                            };
                        }
                    }
                }
            }
        }

        private void LoadReviews(int recipeId)
        {
            Reviews = new List<ReviewModel>();
            double totalRating = 0;
            int count = 0;
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    SELECT r.*, u.firstname, u.lastname, u.profile_image
                    FROM Review r
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    WHERE r.recipe_id = @recipeId AND r.review_visibility = 'Show'
                    ORDER BY r.review_date DESC";
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@recipeId", recipeId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var rating = Convert.ToInt32(reader["review_rating"]);
                            totalRating += rating;
                            count++;
                            Reviews.Add(new ReviewModel
                            {
                                ReviewerName = $"{reader["firstname"]} {reader["lastname"]}",
                                ReviewerImage = !string.IsNullOrEmpty(reader["profile_image"].ToString())
                                    ? "/images/profiles/" + reader["profile_image"].ToString()
                                    : "https://via.placeholder.com/48x48",
                                Rating = rating,
                                Comment = reader["review_comment"].ToString(),
                                ReviewDate = Convert.ToDateTime(reader["review_date"]),
                                ReviewImage = reader["review_image"] != DBNull.Value ? reader["review_image"].ToString() : null,
                                ReviewVideo = reader["review_video"] != DBNull.Value ? reader["review_video"].ToString() : null
                            });
                        }
                    }
                }
            }
            AverageRating = count > 0 ? totalRating / count : 0;
            ReviewCount = count;
        }

        private void SaveReview(int userId, int recipeId, int rating, string comment, string reviewImage, string reviewVideo)
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
                    INSERT INTO Review (user_id, recipe_id, review_rating, review_comment, review_image, review_video, review_visibility, review_date)
                    VALUES (@user_id, @recipe_id, @review_rating, @review_comment, @review_image, @review_video, 'Show', GETDATE())";
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@user_id", userId);
                    cmd.Parameters.AddWithValue("@recipe_id", recipeId);
                    cmd.Parameters.AddWithValue("@review_rating", rating);
                    cmd.Parameters.AddWithValue("@review_comment", comment);
                    cmd.Parameters.AddWithValue("@review_image", (object)reviewImage ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@review_video", (object)reviewVideo ?? DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void BindReviews(int recipeId)
        {
            LoadReviews(recipeId);
            ReviewRepeater.DataSource = Reviews;
            ReviewRepeater.DataBind();
            NoReviewsPanel.Visible = Reviews.Count == 0;
        }

        protected void SubmitReviewBtn_Click(object sender, EventArgs e)
        {
            ReviewError.Visible = false;

            int recipeId;
            if (!int.TryParse(Request.QueryString["id"], out recipeId)) return;
            if (Session["UserId"] == null) return;

            int rating = 0;
            int.TryParse(ReviewRating.Text, out rating);
            string comment = ReviewComment.Text.Trim();

            if (rating < 1 || rating > 5)
            {
                ReviewError.Text = "Please select a star rating.";
                ReviewError.Visible = true;
                return;
            }
            if (string.IsNullOrWhiteSpace(comment))
            {
                ReviewError.Text = "Please enter your review.";
                ReviewError.Visible = true;
                return;
            }

            string reviewImage = null, reviewVideo = null;

            // Handle image upload
            if (ReviewPhoto.HasFile)
            {
                string fileExtension = System.IO.Path.GetExtension(ReviewPhoto.FileName).ToLower();
                string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };
                if (Array.Exists(allowedExtensions, ext => ext.Equals(fileExtension, StringComparison.OrdinalIgnoreCase)))
                {
                    reviewImage = $"review_{Session["UserId"]}_{DateTime.Now.Ticks}{fileExtension}";
                    string savePath = Server.MapPath("~/images/reviews/" + reviewImage);
                    ReviewPhoto.SaveAs(savePath);
                }
            }

            // Handle video upload
            if (ReviewVideo.HasFile)
            {
                string fileExtension = System.IO.Path.GetExtension(ReviewVideo.FileName).ToLower();
                string[] allowedVideoExtensions = { ".mp4", ".webm", ".ogg" };
                if (Array.Exists(allowedVideoExtensions, ext => ext.Equals(fileExtension, StringComparison.OrdinalIgnoreCase)))
                {
                    reviewVideo = $"review_{Session["UserId"]}_{DateTime.Now.Ticks}{fileExtension}";
                    string savePath = Server.MapPath("~/images/reviews/" + reviewVideo);
                    ReviewVideo.SaveAs(savePath);
                }
            }

            int userId = Convert.ToInt32(Session["UserId"]);
            SaveReview(userId, recipeId, rating, comment, reviewImage, reviewVideo);

            // Reset form fields
            ReviewRating.Text = "";
            ReviewComment.Text = "";

            // Rebind reviews to show the new one
            BindReviews(recipeId);
            ReviewUpdatePanel.Update();
        }

        private bool CheckBookmarked(int userId, int recipeId)
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT COUNT(*) FROM Bookmark WHERE user_id=@userId AND recipe_id=@recipeId AND bookmark_status='Saved'";
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    cmd.Parameters.AddWithValue("@recipeId", recipeId);
                    return (int)cmd.ExecuteScalar() > 0;
                }
            }
        }

        private bool CheckCompleted(int userId, int recipeId)
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = "SELECT is_completed FROM Progress WHERE user_id=@userId AND recipe_id=@recipeId";
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    cmd.Parameters.AddWithValue("@recipeId", recipeId);
                    var result = cmd.ExecuteScalar();
                    return result != null && Convert.ToBoolean(result);
                }
            }
        }

        protected void BookmarkBtn_Click(object sender, EventArgs e)
        {
            int recipeId = int.Parse(Request.QueryString["id"]);
            int userId = Convert.ToInt32(Session["UserId"]);
            if (IsBookmarked)
            {
                // Remove bookmark
                string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string query = "UPDATE Bookmark SET bookmark_status='Removed' WHERE user_id=@userId AND recipe_id=@recipeId";
                    using (var cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        cmd.Parameters.AddWithValue("@recipeId", recipeId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            else
            {
                // Add bookmark
                string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string query = @"
                IF EXISTS (SELECT 1 FROM Bookmark WHERE user_id=@userId AND recipe_id=@recipeId)
                    UPDATE Bookmark SET bookmark_status='Saved' WHERE user_id=@userId AND recipe_id=@recipeId
                ELSE
                    INSERT INTO Bookmark (user_id, recipe_id, bookmark_status) VALUES (@userId, @recipeId, 'Saved')";
                    using (var cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        cmd.Parameters.AddWithValue("@recipeId", recipeId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            Response.Redirect(Request.RawUrl); // Refresh to update button state
        }

        protected void CompletedBtn_Click(object sender, EventArgs e)
        {
            int recipeId = int.Parse(Request.QueryString["id"]);
            int userId = Convert.ToInt32(Session["UserId"]);
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string query = @"
            IF EXISTS (SELECT 1 FROM Progress WHERE user_id=@userId AND recipe_id=@recipeId)
                UPDATE Progress SET is_completed=@isCompleted WHERE user_id=@userId AND recipe_id=@recipeId
            ELSE
                INSERT INTO Progress (user_id, recipe_id, is_completed) VALUES (@userId, @recipeId, @isCompleted)";
                using (var cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    cmd.Parameters.AddWithValue("@recipeId", recipeId);
                    cmd.Parameters.AddWithValue("@isCompleted", !IsCompleted);
                    cmd.ExecuteNonQuery();
                }
            }
            Response.Redirect(Request.RawUrl); // Refresh to update button state
        }

        public class RecipeDetailModel
        {
            public int RecipeId { get; set; }
            public string RecipeName { get; set; }
            public string CuisineName { get; set; }
            public string DifficultyLevel { get; set; }
            public int CookingTime { get; set; }
            public int Servings { get; set; }
            public string RecipeImage { get; set; }
            public string RecipeVideo { get; set; }
            public string RecipeDescription { get; set; }
            public string CookingIngredient { get; set; }
            public string CookingInstruction { get; set; }
            public int? Calory { get; set; }
            public int? Protein { get; set; }
            public int? Carb { get; set; }
            public int? Fat { get; set; }
            public DateTime DateCreated { get; set; }
            public string PostedBy { get; set; }
            public int PostedByUserId { get; set; } // Add this property
        }

        public class ReviewModel
        {
            public string ReviewerName { get; set; }
            public string ReviewerImage { get; set; }
            public int Rating { get; set; }
            public string Comment { get; set; }
            public DateTime ReviewDate { get; set; }
            public string ReviewImage { get; set; }
            public string ReviewVideo { get; set; }
        }

        // Helper for star HTML
        protected string GetStarHtml(double avg)
        {
            int full = (int)Math.Floor(avg);
            bool half = avg - full >= 0.5;
            var html = "";
            for (int i = 0; i < full; i++) html += "<i class='fas fa-star'></i>";
            if (half) html += "<i class='fas fa-star-half-alt'></i>";
            for (int i = full + (half ? 1 : 0); i < 5; i++) html += "<i class='fas fa-star text-gray-300'></i>";
            return html;
        }

        protected string GetStarHtml(object ratingObj)
        {
            double avg = Convert.ToDouble(ratingObj);
            int full = (int)Math.Floor(avg);
            bool half = avg - full >= 0.5;
            var html = "";
            for (int i = 0; i < full; i++) html += "<i class='fas fa-star'></i>";
            if (half) html += "<i class='fas fa-star-half-alt'></i>";
            for (int i = full + (half ? 1 : 0); i < 5; i++) html += "<i class='fas fa-star text-gray-300'></i>";
            return html;
        }

        protected string GetYouTubeEmbedUrl(string url)
        {
            if (string.IsNullOrEmpty(url)) return "";
            var uri = new Uri(url);
            string videoId = "";
            if (uri.Host.Contains("youtu.be"))
            {
                videoId = uri.AbsolutePath.Trim('/');
            }
            else if (uri.Host.Contains("youtube.com"))
            {
                var query = System.Web.HttpUtility.ParseQueryString(uri.Query);
                videoId = query["v"];
            }
            return !string.IsNullOrEmpty(videoId)
                ? $"https://www.youtube.com/embed/{videoId}"
                : url;
        }
    }
}