using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class user_bookmark : System.Web.UI.Page
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
                BindBookmarks();
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
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new System.Data.SqlClient.SqlCommand("SELECT cuisine_id, cuisine_name FROM Cuisine ORDER BY cuisine_name", conn))
                using (var reader = cmd.ExecuteReader())
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
            BindBookmarks();
        }

        private void BindBookmarks()
        {
            int userId = Convert.ToInt32(Session["UserId"] ?? "0");
            if (userId == 0)
                return;

            string cuisine = CuisineFilter.SelectedValue;
            string search = SearchBox.Text.Trim();

            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            var bookmarks = new List<BookmarkCard>();

            using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
            {
                conn.Open();
                var query = new System.Text.StringBuilder(@"
                    SELECT b.bookmark_id, r.recipe_id, r.recipe_name, r.recipe_image, r.date_created,
                           c.cuisine_name, (u.firstname + ' ' + u.lastname) as posted_by
                    FROM Bookmark b
                    INNER JOIN Recipe r ON b.recipe_id = r.recipe_id
                    INNER JOIN Cuisine c ON r.cuisine_id = c.cuisine_id
                    INNER JOIN [User] u ON r.user_id = u.user_id
                    WHERE b.user_id = @userId AND b.bookmark_status = 'Saved'
                ");

                if (cuisine != "all" && !string.IsNullOrEmpty(cuisine))
                    query.Append(" AND r.cuisine_id = @cuisineId");
                if (!string.IsNullOrEmpty(search))
                    query.Append(" AND r.recipe_name LIKE @search");

                query.Append(" ORDER BY r.date_created DESC");

                using (var cmd = new System.Data.SqlClient.SqlCommand(query.ToString(), conn))
                {
                    cmd.Parameters.AddWithValue("@userId", userId);
                    if (cuisine != "all" && !string.IsNullOrEmpty(cuisine))
                        cmd.Parameters.AddWithValue("@cuisineId", cuisine);
                    if (!string.IsNullOrEmpty(search))
                        cmd.Parameters.AddWithValue("@search", "%" + search + "%");

                    using (var reader = cmd.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            var recipeId = Convert.ToInt32(reader["recipe_id"]);
                            var bookmarkId = Convert.ToInt32(reader["bookmark_id"]);
                            var card = new BookmarkCard
                            {
                                BookmarkId = bookmarkId,
                                RecipeId = recipeId,
                                RecipeName = reader["recipe_name"].ToString(),
                                RecipeImageUrl = !string.IsNullOrEmpty(reader["recipe_image"].ToString())
                                    ? "/images/recipes/" + reader["recipe_image"].ToString()
                                    : "https://images.unsplash.com/photo-1559847844-5315695dadae?w=400&h=250&fit=crop",
                                DateCreated = Convert.ToDateTime(reader["date_created"]),
                                PostedBy = reader["posted_by"].ToString(),
                            };

                            // Get review stats
                            using (var reviewConn = new System.Data.SqlClient.SqlConnection(connectionString))
                            {
                                reviewConn.Open();
                                using (var reviewCmd = new System.Data.SqlClient.SqlCommand(@"
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

                            // Check completed
                            using (var progConn = new System.Data.SqlClient.SqlConnection(connectionString))
                            {
                                progConn.Open();
                                using (var progCmd = new System.Data.SqlClient.SqlCommand(@"
                                    SELECT TOP 1 is_completed FROM Progress WHERE user_id = @userId AND recipe_id = @recipeId", progConn))
                                {
                                    progCmd.Parameters.AddWithValue("@userId", userId);
                                    progCmd.Parameters.AddWithValue("@recipeId", recipeId);
                                    var completedObj = progCmd.ExecuteScalar();
                                    bool isCompleted = completedObj != null && Convert.ToBoolean(completedObj);
                                    card.CompletedLabel = isCompleted ?
                                        "<span class=\"bg-green-500 text-white px-2 py-1 rounded-full text-xs font-medium absolute top-2 left-2 flex items-center\"><i class='fas fa-check mr-1'></i>Completed</span>"
                                        : string.Empty;
                                }
                            }

                            bookmarks.Add(card);
                        }
                    }
                }
            }

            _totalRecords = bookmarks.Count;

            var pagedData = new PagedDataSource();
            pagedData.DataSource = bookmarks;
            pagedData.AllowPaging = true;
            pagedData.PageSize = PageSize;

            // Clamp PageIndex to valid range
            int pageCount = pagedData.PageCount;
            if (PageIndex >= pageCount && pageCount > 0)
                PageIndex = pageCount - 1;
            if (PageIndex < 0) PageIndex = 0;
            pagedData.CurrentPageIndex = PageIndex;

            BookmarksRepeater.DataSource = pagedData;
            BookmarksRepeater.DataBind();

            PaginationPanel.Visible = pageCount > 1;
            PrevPageButton.Enabled = !pagedData.IsFirstPage;
            NextPageButton.Enabled = !pagedData.IsLastPage;

            PageNumbersRepeater.DataSource = Enumerable.Range(0, pageCount);
            PageNumbersRepeater.DataBind();
        }

        protected void PrevPageButton_Click(object sender, EventArgs e)
        {
            if (PageIndex > 0) PageIndex--;
            BindBookmarks();
        }

        protected void NextPageButton_Click(object sender, EventArgs e)
        {
            PageIndex++;
            BindBookmarks();
        }

        protected void PageNumbersRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "Page")
            {
                PageIndex = Convert.ToInt32(e.CommandArgument);
                BindBookmarks();
            }
        }

        protected void BookmarksRepeater_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int id;
            if (!int.TryParse(e.CommandArgument.ToString(), out id))
                return;

            switch (e.CommandName)
            {
                case "View":
                    // id is RecipeId
                    Response.Redirect($"~/recipe-detail.aspx?id={id}");
                    break;
                case "Remove":
                    // id is BookmarkId
                    RemoveBookmark(id);
                    ShowSuccessMessage("Bookmark removed successfully!");
                    BindBookmarks();
                    break;
            }
        }

        private void RemoveBookmark(int bookmarkId)
        {
            string connectionString = System.Configuration.ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new System.Data.SqlClient.SqlConnection(connectionString))
            {
                conn.Open();
                using (var cmd = new System.Data.SqlClient.SqlCommand("UPDATE Bookmark SET bookmark_status = 'Removed' WHERE bookmark_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", bookmarkId);
                    cmd.ExecuteNonQuery();
                }
            }
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

        private void ShowSuccessMessage(string message)
        {
            MessageLabel.Text = message;
            MessagePanel.Visible = true;
            ScriptManager.RegisterStartupScript(this, GetType(), "hideMessage",
                "setTimeout(function() { closeMessage(); }, 5000);", true);
        }

        protected void UserLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/logout.aspx");
        }

        private class BookmarkCard
        {
            public int BookmarkId { get; set; }
            public int RecipeId { get; set; }
            public string RecipeName { get; set; }
            public string RecipeImageUrl { get; set; }
            public DateTime DateCreated { get; set; }
            public string PostedBy { get; set; }
            public string AverageRatingText { get; set; }
            public string StarHtml { get; set; }
            public string CompletedLabel { get; set; }
        }
    }
}