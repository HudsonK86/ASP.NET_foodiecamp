using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.Script.Serialization;
using System.Web.UI;

namespace Hope
{
    public partial class admin_dashboard : System.Web.UI.Page
    {
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
                LoadAnalytics();
            }
        }

        private void LoadAdminProfile()
        {
            // Get admin information from session
            string adminName = Session["UserName"] as string ?? "Admin";
            string profileImagePath = Session["ProfileImage"] as string;

            // Set admin name
            AdminNameLabel.Text = adminName;

            // Set profile image with fallback
            if (!string.IsNullOrEmpty(profileImagePath))
            {
                AdminProfileImage.ImageUrl = $"~/images/profiles/{profileImagePath}";
            }
            else
            {
                AdminProfileImage.ImageUrl = "https://via.placeholder.com/80x80/3B82F6/FFFFFF?text=Admin";
            }
        }

        private void LoadAnalytics()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    conn.Open();

                    // Load Recipe Analytics
                    var recipeStats = GetRecipeStatistics(conn);
                    RecipePendingLabel.Text = recipeStats.Pending.ToString();
                    RecipeApprovedLabel.Text = recipeStats.Approved.ToString();
                    RecipeRejectedLabel.Text = recipeStats.Rejected.ToString();
                    RecipeTotalLabel.Text = recipeStats.Total.ToString();

                    // Load Event Analytics
                    var eventStats = GetEventStatistics(conn);
                    EventPendingLabel.Text = eventStats.Pending.ToString();
                    EventApprovedLabel.Text = eventStats.Approved.ToString();
                    EventRejectedLabel.Text = eventStats.Rejected.ToString();
                    EventTotalLabel.Text = eventStats.Total.ToString();

                    // Load Inquiry Analytics
                    var inquiryStats = GetInquiryStatistics(conn);
                    InquiryPendingLabel.Text = inquiryStats.Pending.ToString();
                    InquirySolvedLabel.Text = inquiryStats.Solved.ToString();
                    InquiryTotalLabel.Text = inquiryStats.Total.ToString();

                    // Load User Statistics for Pie Chart
                    var userStats = GetUserStatistics(conn);

                    // Store user statistics in hidden fields for JavaScript access
                    UserBlockedHidden.Value = userStats.Blocked.ToString();
                    UserActiveHidden.Value = userStats.Active.ToString();
                    UserInactiveHidden.Value = userStats.Inactive.ToString();


                    // Load Cuisine Learning Progress for Bar Chart
                    var cuisineProgress = GetCuisineProgress(conn);
                    CuisineProgressHidden.Value = new JavaScriptSerializer().Serialize(cuisineProgress);

                    // Load Overall Cuisine Ratings for Bar Chart
                    var cuisineRatings = GetCuisineRatings(conn);
                    CuisineRatingsHidden.Value = new JavaScriptSerializer().Serialize(cuisineRatings);
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading analytics: {ex.Message}");
                // Set default values on error
                SetDefaultAnalytics();
            }
        }

        private RecipeStatistics GetRecipeStatistics(SqlConnection conn)
        {
            string query = @"
                SELECT 
                    COUNT(*) as Total,
                    SUM(CASE WHEN recipe_status = 'Pending' THEN 1 ELSE 0 END) as Pending,
                    SUM(CASE WHEN recipe_status = 'Approved' THEN 1 ELSE 0 END) as Approved,
                    SUM(CASE WHEN recipe_status = 'Rejected' THEN 1 ELSE 0 END) as Rejected
                FROM [Recipe]";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return new RecipeStatistics
                        {
                            Total = Convert.ToInt32(reader["Total"]),
                            Pending = Convert.ToInt32(reader["Pending"]),
                            Approved = Convert.ToInt32(reader["Approved"]),
                            Rejected = Convert.ToInt32(reader["Rejected"])
                        };
                    }
                }
            }
            return new RecipeStatistics();
        }

        private EventStatistics GetEventStatistics(SqlConnection conn)
        {
            string query = @"
                SELECT 
                    COUNT(*) as Total,
                    SUM(CASE WHEN event_status = 'Pending' THEN 1 ELSE 0 END) as Pending,
                    SUM(CASE WHEN event_status = 'Approved' THEN 1 ELSE 0 END) as Approved,
                    SUM(CASE WHEN event_status = 'Rejected' THEN 1 ELSE 0 END) as Rejected
                FROM [Event]";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return new EventStatistics
                        {
                            Total = Convert.ToInt32(reader["Total"]),
                            Pending = Convert.ToInt32(reader["Pending"]),
                            Approved = Convert.ToInt32(reader["Approved"]),
                            Rejected = Convert.ToInt32(reader["Rejected"])
                        };
                    }
                }
            }
            return new EventStatistics();
        }

        private InquiryStatistics GetInquiryStatistics(SqlConnection conn)
        {
            string query = @"
                SELECT 
                    COUNT(*) as Total,
                    SUM(CASE WHEN inquiry_status = 'Pending' THEN 1 ELSE 0 END) as Pending,
                    SUM(CASE WHEN inquiry_status = 'Solved' THEN 1 ELSE 0 END) as Solved
                FROM [Inquiry]";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return new InquiryStatistics
                        {
                            Total = Convert.ToInt32(reader["Total"]),
                            Pending = Convert.ToInt32(reader["Pending"]),
                            Solved = Convert.ToInt32(reader["Solved"])
                        };
                    }
                }
            }
            return new InquiryStatistics();
        }

        private UserStatistics GetUserStatistics(SqlConnection conn)
        {
            string query = @"
                SELECT 
                    SUM(CASE WHEN is_activated = 0 THEN 1 ELSE 0 END) as Blocked,
                    SUM(CASE WHEN is_activated = 1 AND last_login_date IS NOT NULL AND last_login_date >= DATEADD(day, -30, GETDATE()) THEN 1 ELSE 0 END) as Active,
                    SUM(CASE WHEN is_activated = 1 AND (last_login_date IS NULL OR last_login_date < DATEADD(day, -30, GETDATE())) THEN 1 ELSE 0 END) as Inactive
                FROM [User]";

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (reader.Read())
                    {
                        return new UserStatistics
                        {
                            Blocked = Convert.ToInt32(reader["Blocked"]),
                            Active = Convert.ToInt32(reader["Active"]),
                            Inactive = Convert.ToInt32(reader["Inactive"])
                        };
                    }
                }
            }
            return new UserStatistics();
        }

        private List<CuisineProgress> GetCuisineProgress(SqlConnection conn)
        {
            string query = @"
                WITH CuisineRecipeStats AS (
                    SELECT 
                        c.cuisine_id,
                        c.cuisine_name,
                        COUNT(r.recipe_id) as TotalRecipes,
                        CASE 
                            WHEN COUNT(r.recipe_id) = 0 THEN 0
                            ELSE AVG(CAST(recipe_completion.CompletionRate as FLOAT))
                        END as AvgCompletionRate
                    FROM [Cuisine] c
                    LEFT JOIN [Recipe] r ON c.cuisine_id = r.cuisine_id AND r.recipe_status = 'Approved'
                    LEFT JOIN (
                        SELECT 
                            r2.recipe_id,
                            CASE 
                                WHEN COUNT(DISTINCT u.user_id) = 0 THEN 0
                                ELSE (COUNT(DISTINCT CASE WHEN p.is_completed = 1 THEN u.user_id END) * 100.0) / COUNT(DISTINCT u.user_id)
                            END as CompletionRate
                        FROM [Recipe] r2
                        CROSS JOIN [User] u
                        LEFT JOIN [Progress] p ON r2.recipe_id = p.recipe_id AND u.user_id = p.user_id
                        WHERE r2.recipe_status = 'Approved'
                        GROUP BY r2.recipe_id
                    ) recipe_completion ON r.recipe_id = recipe_completion.recipe_id
                    GROUP BY c.cuisine_id, c.cuisine_name
                )
                SELECT 
                    cuisine_name,
                    ROUND(ISNULL(AvgCompletionRate, 0), 1) as ProgressPercentage
                FROM CuisineRecipeStats
                ORDER BY cuisine_name";

            List<CuisineProgress> progressList = new List<CuisineProgress>();

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        progressList.Add(new CuisineProgress
                        {
                            CuisineName = reader["cuisine_name"].ToString(),
                            ProgressPercentage = Convert.ToDouble(reader["ProgressPercentage"])
                        });
                    }
                }
            }

            return progressList;
        }

        private List<CuisineRating> GetCuisineRatings(SqlConnection conn)
        {
            string query = @"
                WITH CuisineRatingStats AS (
                    SELECT 
                        c.cuisine_id,
                        c.cuisine_name,
                        COUNT(DISTINCT r.recipe_id) as TotalApprovedRecipes,
                        AVG(CAST(recipe_ratings.AvgRating as FLOAT)) as OverallRating
                    FROM [Cuisine] c
                    LEFT JOIN [Recipe] r ON c.cuisine_id = r.cuisine_id AND r.recipe_status = 'Approved'
                    LEFT JOIN (
                        SELECT 
                            rv.recipe_id,
                            AVG(CAST(rv.review_rating as FLOAT)) as AvgRating
                        FROM [Review] rv
                        GROUP BY rv.recipe_id
                    ) recipe_ratings ON r.recipe_id = recipe_ratings.recipe_id
                    GROUP BY c.cuisine_id, c.cuisine_name
                    HAVING COUNT(DISTINCT r.recipe_id) > 0
                )
                SELECT 
                    cuisine_name,
                    ROUND(ISNULL(OverallRating, 0), 1) as AverageRating
                FROM CuisineRatingStats
                ORDER BY cuisine_name";

            List<CuisineRating> ratingsList = new List<CuisineRating>();

            using (SqlCommand cmd = new SqlCommand(query, conn))
            {
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        ratingsList.Add(new CuisineRating
                        {
                            CuisineName = reader["cuisine_name"].ToString(),
                            AverageRating = Convert.ToDouble(reader["AverageRating"])
                        });
                    }
                }
            }

            return ratingsList;
        }

        private void SetDefaultAnalytics()
        {
            // Set default values if database query fails
            RecipePendingLabel.Text = "0";
            RecipeApprovedLabel.Text = "0";
            RecipeRejectedLabel.Text = "0";
            RecipeTotalLabel.Text = "0";

            EventPendingLabel.Text = "0";
            EventApprovedLabel.Text = "0";
            EventRejectedLabel.Text = "0";
            EventTotalLabel.Text = "0";

            InquiryPendingLabel.Text = "0";
            InquirySolvedLabel.Text = "0";
            InquiryTotalLabel.Text = "0";

            // Default user statistics
            UserBlockedHidden.Value = "0";
            UserActiveHidden.Value = "0";
            UserInactiveHidden.Value = "0";

            // Default cuisine progress
            CuisineProgressHidden.Value = "[]";

            // Default cuisine ratings
            CuisineRatingsHidden.Value = "[]";
        }

        protected void AdminLogoutButton_Click(object sender, EventArgs e)
        {
            // Redirect to centralized logout page
            Response.Redirect("~/logout.aspx");
        }

        // Helper classes for statistics
        public class RecipeStatistics
        {
            public int Total { get; set; }
            public int Pending { get; set; }
            public int Approved { get; set; }
            public int Rejected { get; set; }
        }

        public class EventStatistics
        {
            public int Total { get; set; }
            public int Pending { get; set; }
            public int Approved { get; set; }
            public int Rejected { get; set; }
        }

        public class InquiryStatistics
        {
            public int Total { get; set; }
            public int Pending { get; set; }
            public int Solved { get; set; }
        }

        public class UserStatistics
        {
            public int Blocked { get; set; }
            public int Active { get; set; }
            public int Inactive { get; set; }
        }

        public class CuisineProgress
        {
            public string CuisineName { get; set; }
            public double ProgressPercentage { get; set; }
        }

        public class CuisineRating
        {
            public string CuisineName { get; set; }
            public double AverageRating { get; set; }
        }
    }
}