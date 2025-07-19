using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class recipes : System.Web.UI.Page
    {
        private int _totalRecords = 0;
        private int PageSize => 6;
        public int PageIndex
        {
            get { object obj = ViewState["PageIndex"]; return obj == null ? 0 : (int)obj; }
            set { ViewState["PageIndex"] = value; }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadCuisineFilter();
                // Set selected value from query string if present
                string cuisine = Request.QueryString["cuisine"];
                if (!string.IsNullOrEmpty(cuisine) && CuisineFilter.Items.FindByValue(cuisine) != null)
                    CuisineFilter.SelectedValue = cuisine;

                PageIndex = 0;
                BindRecipes();
            }
        }

        protected void Filter_Changed(object sender, EventArgs e)
        {
            PageIndex = 0;
            BindRecipes();
        }

        private void LoadCuisineFilter()
        {
            CuisineFilter.Items.Clear();
            CuisineFilter.Items.Add(new ListItem("All Cuisines", "all"));

            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT cuisine_id, cuisine_name FROM Cuisine ORDER BY cuisine_name", conn))
                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    while (reader.Read())
                    {
                        CuisineFilter.Items.Add(new ListItem(reader["cuisine_name"].ToString(), reader["cuisine_id"].ToString()));
                    }
                }
            }
        }

        private void BindRecipes()
        {
            string cuisine = CuisineFilter.SelectedValue ?? "all";
            string search = SearchBox?.Text?.Trim() ?? "";

            bool isLoggedIn = Session["IsLoggedIn"] != null && (bool)Session["IsLoggedIn"];
            string userRole = Session["UserRole"] as string ?? "";
            int userId = isLoggedIn && userRole == "User" ? Convert.ToInt32(Session["UserId"]) : 0;

            var recipes = new List<RecipeCard>();
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

            using (var conn = new SqlConnection(connectionString))
            {
                conn.Open();
                var query = new System.Text.StringBuilder(@"
                    SELECT r.recipe_id, r.recipe_name, r.recipe_image, r.date_created,
                           c.cuisine_name, (u.firstname + ' ' + u.lastname) as posted_by
                    FROM Recipe r
                    INNER JOIN Cuisine c ON r.cuisine_id = c.cuisine_id
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    WHERE r.recipe_status = 'Approved' AND r.recipe_visibility = 'Show'
                ");

                if (cuisine != "all" && !string.IsNullOrEmpty(cuisine))
                    query.Append(" AND r.cuisine_id = @cuisineId");
                if (!string.IsNullOrEmpty(search))
                    query.Append(" AND r.recipe_name LIKE @search");

                query.Append(" ORDER BY r.date_created DESC");

                using (var cmd = new SqlCommand(query.ToString(), conn))
                {
                    if (cuisine != "all" && !string.IsNullOrEmpty(cuisine))
                        cmd.Parameters.AddWithValue("@cuisineId", cuisine);
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var recipeId = Convert.ToInt32(reader["recipe_id"]);
                            var card = new RecipeCard
                            {
                                RecipeId = recipeId,
                                RecipeName = reader["recipe_name"].ToString(),
                                RecipeImageUrl = !string.IsNullOrEmpty(reader["recipe_image"].ToString())
                                    ? "/images/recipes/" + reader["recipe_image"].ToString()
                                    : "https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&h=250&fit=crop",
                                DateCreated = Convert.ToDateTime(reader["date_created"]),
                                PostedBy = reader["posted_by"].ToString(),
                                ShowBookmark = isLoggedIn && userRole == "User",
                                ShowCompleted = isLoggedIn && userRole == "User"
                            };

                            // If logged in as user, get bookmark/completed info
                            if (card.ShowBookmark)
                            {
                                // Bookmark
                                using (var bmConn = new SqlConnection(connectionString))
                                {
                                    bmConn.Open();
                                    using (var bmCmd = new SqlCommand("SELECT COUNT(*) FROM Bookmark WHERE user_id=@userId AND recipe_id=@recipeId AND bookmark_status='Saved'", bmConn))
                                    {
                                        bmCmd.Parameters.AddWithValue("@userId", userId);
                                        bmCmd.Parameters.AddWithValue("@recipeId", recipeId);
                                        card.IsBookmarked = (int)bmCmd.ExecuteScalar() > 0;
                                    }
                                }
                                // Completed
                                using (var progConn = new SqlConnection(connectionString))
                                {
                                    progConn.Open();
                                    using (var progCmd = new SqlCommand("SELECT TOP 1 is_completed FROM Progress WHERE user_id=@userId AND recipe_id=@recipeId", progConn))
                                    {
                                        progCmd.Parameters.AddWithValue("@userId", userId);
                                        progCmd.Parameters.AddWithValue("@recipeId", recipeId);
                                        var completedObj = progCmd.ExecuteScalar();
                                        card.IsCompleted = completedObj != null && Convert.ToBoolean(completedObj);
                                    }
                                }
                            }

                            // Get review stats
                            using (var reviewConn = new SqlConnection(connectionString))
                            {
                                reviewConn.Open();
                                using (var reviewCmd = new SqlCommand(@"
                                    SELECT COUNT(*) as ReviewCount, 
                                           ISNULL(AVG(CASE WHEN review_visibility = 'Show' THEN review_rating END), 0) as AvgRating
                                    FROM Review
                                    WHERE recipe_id = @recipeId", reviewConn))
                                {
                                    reviewCmd.Parameters.AddWithValue("@recipeId", recipeId);
                                    using (var reviewReader = reviewCmd.ExecuteReader())
                                    {
                                        if (reviewReader.Read())
                                        {
                                            int reviewCount = Convert.ToInt32(reviewReader["ReviewCount"]);
                                            double avgRating = Convert.ToDouble(reviewReader["AvgRating"]);
                                            card.AverageRatingText = $"{avgRating:0.0} ({reviewCount} reviews)";
                                            card.StarHtml = GetStarHtml(avgRating);
                                        }
                                    }
                                }
                            }

                            recipes.Add(card);
                        }
                    }
                }
            }

            _totalRecords = recipes.Count;

            var pagedData = new PagedDataSource();
            pagedData.DataSource = recipes;
            pagedData.AllowPaging = true;
            pagedData.PageSize = PageSize;

            int pageCount = pagedData.PageCount;
            if (PageIndex >= pageCount && pageCount > 0)
                PageIndex = pageCount - 1;
            if (PageIndex < 0) PageIndex = 0;
            pagedData.CurrentPageIndex = PageIndex;

            RecipesRepeater.DataSource = pagedData;
            RecipesRepeater.DataBind();

            PaginationPanel.Visible = pageCount > 1;
            PrevPageButton.Enabled = !pagedData.IsFirstPage;
            NextPageButton.Enabled = !pagedData.IsLastPage;

            PageNumbersRepeater.DataSource = Enumerable.Range(0, pageCount);
            PageNumbersRepeater.DataBind();
        }

        protected void PrevPageButton_Click(object sender, EventArgs e)
        {
            if (PageIndex > 0) PageIndex--;
            BindRecipes();
        }

        protected void NextPageButton_Click(object sender, EventArgs e)
        {
            PageIndex++;
            BindRecipes();
        }

        protected void PageNumbersRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Page")
            {
                PageIndex = Convert.ToInt32(e.CommandArgument);
                BindRecipes();
            }
        }

        // Recipe card class
        private class RecipeCard
        {
            public int RecipeId { get; set; }
            public string RecipeName { get; set; }
            public string RecipeImageUrl { get; set; }
            public DateTime DateCreated { get; set; }
            public string PostedBy { get; set; }
            public bool ShowBookmark { get; set; }
            public bool ShowCompleted { get; set; }
            public bool IsBookmarked { get; set; }
            public bool IsCompleted { get; set; }
            public string AverageRatingText { get; set; }      // Add this
            public string StarHtml { get; set; }               // Add this
        }

        private string GetStarHtml(double avgRating)
        {
            var sb = new System.Text.StringBuilder();
            int fullStars = (int)Math.Floor(avgRating);
            bool halfStar = avgRating - fullStars >= 0.5;
            for (int i = 0; i < fullStars; i++)
                sb.Append("<i class='fas fa-star'></i>");
            if (halfStar)
                sb.Append("<i class='fas fa-star-half-alt'></i>");
            for (int i = fullStars + (halfStar ? 1 : 0); i < 5; i++)
                sb.Append("<i class='fas fa-star text-gray-400'></i>");
            return sb.ToString();
        }
    }
}