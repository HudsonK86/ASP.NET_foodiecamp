using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class user_dashboard : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Check if user is logged in
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
                LoadUserAnalytics();
                LoadLearningProgressChart();
            }
        }

        private void LoadUserProfile()
        {
            string userName = Session["UserName"] as string ?? "User";
            string profileImagePath = Session["ProfileImage"] as string;

            UserNameLabel.Text = userName;

            if (!string.IsNullOrEmpty(profileImagePath))
            {
                UserProfileImage.ImageUrl = $"~/images/profiles/{profileImagePath}";
            }
            else
            {
                UserProfileImage.ImageUrl = "https://via.placeholder.com/80x80";
            }
        }

        private void LoadUserAnalytics()
        {
            int userId = Convert.ToInt32(Session["UserId"] ?? "0");
            if (userId == 0)
                return;

            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

            int recipePending = 0, recipeApproved = 0, recipeRejected = 0, recipeTotal = 0;
            int eventPending = 0, eventApproved = 0, eventRejected = 0, eventTotal = 0;
            int bookmarkTotal = 0, completedTotal = 0;

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Recipe stats
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        SUM(CASE WHEN recipe_status = 'Pending' THEN 1 ELSE 0 END) as Pending,
                        SUM(CASE WHEN recipe_status = 'Approved' THEN 1 ELSE 0 END) as Approved,
                        SUM(CASE WHEN recipe_status = 'Rejected' THEN 1 ELSE 0 END) as Rejected,
                        COUNT(*) as Total
                    FROM Recipe
                    WHERE user_id = @userId", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            recipePending = reader["Pending"] != DBNull.Value ? Convert.ToInt32(reader["Pending"]) : 0;
                            recipeApproved = reader["Approved"] != DBNull.Value ? Convert.ToInt32(reader["Approved"]) : 0;
                            recipeRejected = reader["Rejected"] != DBNull.Value ? Convert.ToInt32(reader["Rejected"]) : 0;
                            recipeTotal = reader["Total"] != DBNull.Value ? Convert.ToInt32(reader["Total"]) : 0;
                        }
                    }
                }

                // Event stats
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT 
                        SUM(CASE WHEN event_status = 'Pending' THEN 1 ELSE 0 END) as Pending,
                        SUM(CASE WHEN event_status = 'Approved' THEN 1 ELSE 0 END) as Approved,
                        SUM(CASE WHEN event_status = 'Rejected' THEN 1 ELSE 0 END) as Rejected,
                        COUNT(*) as Total
                    FROM Event
                    WHERE user_id = @userId", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            eventPending = reader["Pending"] != DBNull.Value ? Convert.ToInt32(reader["Pending"]) : 0;
                            eventApproved = reader["Approved"] != DBNull.Value ? Convert.ToInt32(reader["Approved"]) : 0;
                            eventRejected = reader["Rejected"] != DBNull.Value ? Convert.ToInt32(reader["Rejected"]) : 0;
                            eventTotal = reader["Total"] != DBNull.Value ? Convert.ToInt32(reader["Total"]) : 0;
                        }
                    }
                }

                // Bookmarks
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) FROM Bookmark
                    WHERE user_id = @userId AND bookmark_status = 'Saved'", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    bookmarkTotal = Convert.ToInt32(cmd.ExecuteScalar());
                }

                // Recipe Completed
                using (SqlCommand cmd = new SqlCommand(@"
                    SELECT COUNT(*) FROM Progress
                    WHERE user_id = @userId AND is_completed = 1", conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    completedTotal = Convert.ToInt32(cmd.ExecuteScalar());
                }
            }

            // Set values to labels
            RecipePendingLabel.Text = recipePending.ToString();
            RecipeApprovedLabel.Text = recipeApproved.ToString();
            RecipeRejectedLabel.Text = recipeRejected.ToString();
            RecipeTotalLabel.Text = recipeTotal.ToString();

            EventPendingLabel.Text = eventPending.ToString();
            EventApprovedLabel.Text = eventApproved.ToString();
            EventRejectedLabel.Text = eventRejected.ToString();
            EventTotalLabel.Text = eventTotal.ToString();

            BookmarkTotalLabel.Text = bookmarkTotal.ToString();
            CompletedTotalLabel.Text = completedTotal.ToString();
        }

        private void LoadLearningProgressChart()
        {
            int userId = Convert.ToInt32(Session["UserId"] ?? "0");
            if (userId == 0)
                return;

            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            var progressList = new List<CuisineProgress>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();

                // Get all cuisines
                var cuisines = new List<Cuisine>();
                using (SqlCommand cmd = new SqlCommand("SELECT cuisine_id, cuisine_name FROM Cuisine", conn))
                {
                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            cuisines.Add(new Cuisine
                            {
                                CuisineId = Convert.ToInt32(reader["cuisine_id"]),
                                CuisineName = reader["cuisine_name"].ToString()
                            });
                        }
                    }
                }

                foreach (var cuisine in cuisines)
                {
                    // A: Total approved recipes for this cuisine
                    int totalApproved = 0;
                    using (SqlCommand cmd = new SqlCommand(@"
                        SELECT COUNT(*) FROM Recipe
                        WHERE cuisine_id = @cuisineId AND recipe_status = 'Approved'", conn))
                    {
                        cmd.Parameters.AddWithValue("@cuisineId", cuisine.CuisineId);
                        totalApproved = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // B: Completed recipes for this cuisine by this user
                    int completed = 0;
                    using (SqlCommand cmd = new SqlCommand(@"
                        SELECT COUNT(*) FROM Progress p
                        INNER JOIN Recipe r ON p.recipe_id = r.recipe_id
                        WHERE p.user_id = @userId AND p.is_completed = 1 AND r.cuisine_id = @cuisineId AND r.recipe_status = 'Approved'", conn))
                    {
                        cmd.Parameters.AddWithValue("@userId", userId);
                        cmd.Parameters.AddWithValue("@cuisineId", cuisine.CuisineId);
                        completed = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // C: Calculate percentage
                    double percent = (totalApproved > 0) ? (completed * 100.0 / totalApproved) : 0.0;

                    progressList.Add(new CuisineProgress
                    {
                        CuisineName = cuisine.CuisineName,
                        ProgressPercentage = Math.Round(percent, 1)
                    });
                }
            }

            // Serialize to JSON for chart
            var serializer = new JavaScriptSerializer();
            string progressJson = serializer.Serialize(progressList);

            // Register as JS variable for chart rendering
            string script = $@"
                window.userLearningProgress = {progressJson};
            ";
            ScriptManager.RegisterStartupScript(this, GetType(), "userLearningProgress", script, true);
        }

        protected void UserLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/logout.aspx");
        }

        private class Cuisine
        {
            public int CuisineId { get; set; }
            public string CuisineName { get; set; }
        }

        private class CuisineProgress
        {
            public string CuisineName { get; set; }
            public double ProgressPercentage { get; set; }
        }
    }
}