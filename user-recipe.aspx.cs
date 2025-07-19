using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class user_recipe : System.Web.UI.Page
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
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
                LoadCuisineFilter();
                PageIndex = 0;
                BindRecipes();
            }
        }

        private void LoadUserProfile()
        {
            string userName = Session["UserName"] as string ?? "User";
            string profileImagePath = Session["ProfileImage"] as string;

            UserNameLabel.Text = userName;
            UserProfileImage.ImageUrl = !string.IsNullOrEmpty(profileImagePath)
                ? $"~/images/profiles/{profileImagePath}"
                : "https://via.placeholder.com/80x80";
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

        protected void Filter_Changed(object sender, EventArgs e)
        {
            PageIndex = 0;
            BindRecipes();
        }

        private void BindRecipes()
        {
            int userId = Convert.ToInt32(Session["UserId"] ?? "0");
            if (userId == 0)
                return;

            string status = StatusFilter.SelectedValue;
            string cuisine = CuisineFilter.SelectedValue;
            string search = SearchBox.Text.Trim();

            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            var recipes = new List<RecipeCard>();

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                var query = new StringBuilder(@"
                    SELECT r.recipe_id, r.recipe_name, r.recipe_image, r.recipe_status, r.recipe_visibility, r.date_created,
                           c.cuisine_name, (u.firstname + ' ' + u.lastname) as posted_by
                    FROM Recipe r
                    INNER JOIN Cuisine c ON r.cuisine_id = c.cuisine_id
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    WHERE r.user_id = @userId
                ");

                if (status != "all" && !string.IsNullOrEmpty(status))
                    query.Append(" AND r.recipe_status = @status");
                if (cuisine != "all" && !string.IsNullOrEmpty(cuisine))
                    query.Append(" AND r.cuisine_id = @cuisineId");
                if (!string.IsNullOrEmpty(search))
                    query.Append(" AND r.recipe_name LIKE @search");

                query.Append(" ORDER BY r.date_created DESC");

                using (SqlCommand cmd = new SqlCommand(query.ToString(), conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (status != "all" && !string.IsNullOrEmpty(status))
                        cmd.Parameters.AddWithValue("@status", status.First().ToString().ToUpper() + status.Substring(1).ToLower());
                    if (cuisine != "all" && !string.IsNullOrEmpty(cuisine))
                        cmd.Parameters.AddWithValue("@cuisineId", cuisine);
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var recipeId = Convert.ToInt32(reader["recipe_id"]);
                            var recipe = new RecipeCard
                            {
                                RecipeId = recipeId,
                                RecipeName = reader["recipe_name"].ToString(),
                                RecipeImageUrl = !string.IsNullOrEmpty(reader["recipe_image"].ToString())
                                    ? "/images/recipes/" + reader["recipe_image"].ToString()
                                    : "https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&h=250&fit=crop",
                                RecipeStatus = reader["recipe_status"].ToString(),
                                RecipeVisibility = reader["recipe_visibility"].ToString(),
                                DateCreated = Convert.ToDateTime(reader["date_created"]),
                                PostedBy = reader["posted_by"].ToString(),
                                StatusBadgeClass = GetStatusBadgeClass(reader["recipe_status"].ToString())
                            };

                            // Get review stats
                            using (SqlConnection reviewConn = new SqlConnection(connectionString))
                            {
                                reviewConn.Open();
                                using (SqlCommand reviewCmd = new SqlCommand(@"
                                    SELECT COUNT(*) as ReviewCount, 
                                           ISNULL(AVG(CASE WHEN review_visibility = 'Show' THEN review_rating END), 0) as AvgRating
                                    FROM Review
                                    WHERE recipe_id = @recipeId", reviewConn))
                                {
                                    reviewCmd.Parameters.AddWithValue("@recipeId", recipeId);
                                    using (SqlDataReader reviewReader = reviewCmd.ExecuteReader())
                                    {
                                        if (reviewReader.Read())
                                        {
                                            int reviewCount = Convert.ToInt32(reviewReader["ReviewCount"]);
                                            double avgRating = Convert.ToDouble(reviewReader["AvgRating"]);
                                            recipe.AverageRatingText = $"{avgRating:0.0} ({reviewCount} reviews)";
                                            recipe.StarHtml = GetStarHtml(avgRating);
                                        }
                                    }
                                }
                            }

                            recipe.ActionButtons = GetActionButtons(recipe);
                            recipes.Add(recipe);
                        }
                    }
                }
            }

            _totalRecords = recipes.Count;

            PagedDataSource pagedData = new PagedDataSource();
            pagedData.DataSource = recipes;
            pagedData.AllowPaging = true;
            pagedData.PageSize = PageSize;

            // Clamp PageIndex to valid range
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

            // Bind page numbers to repeater
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

        protected void PageNumber_Click(object sender, EventArgs e)
        {
            int page = int.Parse((sender as Button).CommandArgument);
            PageIndex = page;
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

        private string GeneratePaginationButtons(int pageCount, int currentPage)
        {
            var sb = new StringBuilder();
            for (int i = 0; i < pageCount; i++)
            {
                string css = i == currentPage ? "bg-blue-600 text-white px-3 py-1 rounded" : "bg-gray-200 text-gray-700 px-3 py-1 rounded";
                sb.AppendFormat("<asp:Button runat='server' CssClass='{0}' CommandArgument='{1}' OnClick='PageNumber_Click' Text='{2}' /> ", css, i, i + 1);
            }
            return sb.ToString();
        }

        private string GetStatusBadgeClass(string status)
        {
            switch (status.ToLower())
            {
                case "approved": return "bg-green-500 text-white";
                case "pending": return "bg-yellow-500 text-white";
                case "rejected": return "bg-red-500 text-white";
                default: return "bg-gray-400 text-white";
            }
        }

        private string GetStarHtml(double avgRating)
        {
            var sb = new StringBuilder();
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

        private string GetActionButtons(RecipeCard recipe)
        {
            var sb = new StringBuilder();
            if (recipe.RecipeStatus == "Pending" || recipe.RecipeStatus == "Rejected")
            {
                sb.Append($@"
                    <a href='edit-recipe.aspx?id={recipe.RecipeId}' class='bg-green-600 hover:bg-green-700 text-white text-sm py-2 px-3 rounded-lg transition-colors' title='Edit recipe'>
                        <i class='fas fa-edit'></i>
                    </a>
                    <button type='button' onclick='deleteRecipe({recipe.RecipeId})' class='bg-red-600 hover:bg-red-700 text-white text-sm py-2 px-3 rounded-lg transition-colors' title='Delete recipe'>
                        <i class='fas fa-trash'></i>
                    </button>
                ");
            }
            else if (recipe.RecipeStatus == "Approved")
            {
                string toggleText = recipe.RecipeVisibility == "Show" ? "Hide" : "Show";
                string toggleIcon = recipe.RecipeVisibility == "Show" ? "fa-eye-slash" : "fa-eye";
                sb.Append($@"
                    <button type='button' onclick='toggleVisibility({recipe.RecipeId})' class='bg-gray-600 hover:bg-gray-700 text-white text-sm py-2 px-3 rounded-lg transition-colors' title='{toggleText} recipe'>
                        <i class='fas {toggleIcon}'></i> {toggleText}
                    </button>
                ");
            }
            return sb.ToString();
        }

        private void DeleteRecipe(int recipeId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("DELETE FROM Recipe WHERE recipe_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", recipeId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        protected void RecipesRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int recipeId;
            if (!int.TryParse(e.CommandArgument.ToString(), out recipeId))
                return;

            switch (e.CommandName)
            {
                case "View":
                    Response.Redirect($"~/recipe-detail.aspx?id={recipeId}");
                    break;
                case "Delete":
                    DeleteRecipe(recipeId);
                    ShowSuccessMessage("Recipe deleted successfully!");
                    BindRecipes();
                    break;
                case "ToggleVisibility":
                    ToggleRecipeVisibility(recipeId);
                    ShowSuccessMessage("Recipe visibility updated successfully!");
                    BindRecipes();
                    break;
            }
        }

        private void ToggleRecipeVisibility(int recipeId)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            string currentVisibility = "Hide";
            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                conn.Open();
                using (SqlCommand cmd = new SqlCommand("SELECT recipe_visibility FROM Recipe WHERE recipe_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", recipeId);
                    var result = cmd.ExecuteScalar();
                    if (result != null)
                        currentVisibility = result.ToString();
                }
                string newVisibility = (currentVisibility == "Show") ? "Hide" : "Show";
                using (SqlCommand cmd = new SqlCommand("UPDATE Recipe SET recipe_visibility = @visibility WHERE recipe_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@visibility", newVisibility);
                    cmd.Parameters.AddWithValue("@id", recipeId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void ShowSuccessMessage(string message)
        {
            MessageLabel.Text = message;
            MessagePanel.Visible = true;
            ScriptManager.RegisterStartupScript(this, GetType(), "hideMessage",
                "setTimeout(function() { closeMessage(); }, 5000);", true);
        }

        protected void PostRecipeButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/post-recipe.aspx");
        }

        protected void UserLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/logout.aspx");
        }

        private class RecipeCard
        {
            public int RecipeId { get; set; }
            public string RecipeName { get; set; }
            public string RecipeImageUrl { get; set; }
            public string RecipeStatus { get; set; }
            public string RecipeVisibility { get; set; }
            public DateTime DateCreated { get; set; }
            public string PostedBy { get; set; }
            public string StatusBadgeClass { get; set; }
            public string AverageRatingText { get; set; }
            public string StarHtml { get; set; }
            public string ActionButtons { get; set; }
        }
    }
}