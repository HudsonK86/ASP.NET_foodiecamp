using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class edit_recipe : System.Web.UI.Page
    {
        protected int RecipeId
        {
            get
            {
                int id;
                int.TryParse(Request.QueryString["id"], out id);
                return id;
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Allow if admin OR if user owns the recipe
                bool isAdmin = Session["UserRole"]?.ToString() == "Admin";
                int userId = Convert.ToInt32(Session["UserId"] ?? "0");
                int recipeOwnerId = GetRecipeOwnerId(RecipeId);

                if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"] ||
                    (!isAdmin && userId != recipeOwnerId))
                {
                    Response.Redirect("~/login.aspx");
                    return;
                }

                // Populate cuisine dropdown
                CuisineType.Items.Clear();
                CuisineType.Items.Add(new ListItem("Select Cuisine Type", ""));
                CuisineType.Items.Add(new ListItem("Chinese", "1"));
                CuisineType.Items.Add(new ListItem("Malaysian", "2"));
                CuisineType.Items.Add(new ListItem("Indian", "3"));
                CuisineType.Items.Add(new ListItem("Western", "4"));
                CuisineType.Items.Add(new ListItem("Vietnamese", "5"));
                CuisineType.Items.Add(new ListItem("Other", "6"));

                LoadRecipe();
            }
        }

        private void LoadRecipe()
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = "SELECT * FROM Recipe WHERE recipe_id = @id";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@id", RecipeId);
                    using (var reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            RecipeName.Text = reader["recipe_name"].ToString();
                            CuisineType.SelectedValue = reader["cuisine_id"].ToString();
                            Difficulty.SelectedValue = reader["difficulty_level"].ToString();
                            CookingTime.Text = reader["cooking_time"].ToString();
                            Servings.Text = reader["servings"].ToString();
                            RecipeDescription.Text = reader["recipe_description"].ToString();
                            CookingIngredient.Text = reader["cooking_ingredient"].ToString();
                            CookingInstruction.Text = reader["cooking_instruction"].ToString();
                        }
                        else
                        {
                            ErrorPanel.Visible = true;
                            ErrorLabel.Text = "Recipe not found.";
                            FormPanel.Visible = false;
                        }
                    }
                }
            }
        }

        // Helper to get the recipe's owner
        private int GetRecipeOwnerId(int recipeId)
        {
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                using (var cmd = new SqlCommand("SELECT user_id FROM Recipe WHERE recipe_id = @id", conn))
                {
                    cmd.Parameters.AddWithValue("@id", recipeId);
                    var result = cmd.ExecuteScalar();
                    return result != null ? Convert.ToInt32(result) : 0;
                }
            }
        }

        protected void SaveBtn_Click(object sender, EventArgs e)
        {
            ErrorPanel.Visible = false;
            MessagePanel.Visible = false;

            if (!Page.IsValid)
                return;

            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            string imageName = null;

            // Handle image upload if a new file is provided
            if (RecipeImage.HasFile)
            {
                string fileExt = System.IO.Path.GetExtension(RecipeImage.FileName).ToLower();
                if (fileExt != ".jpg" && fileExt != ".jpeg" && fileExt != ".png" && fileExt != ".gif")
                {
                    ErrorPanel.Visible = true;
                    ErrorLabel.Text = "Only JPG, JPEG, PNG, or GIF images are allowed.";
                    return;
                }
                imageName = Guid.NewGuid().ToString("N") + fileExt;
                string imagePath = Server.MapPath("~/images/recipes/" + imageName);
                RecipeImage.SaveAs(imagePath);
            }

            // Prepare data
            int cuisineId = int.Parse(CuisineType.SelectedValue);
            string recipeName = RecipeName.Text.Trim();
            string difficulty = Difficulty.SelectedValue;
            int cookingTime = int.Parse(CookingTime.Text);
            int servings = int.Parse(Servings.Text);
            string recipeVideo = RecipeVideo.Text.Trim();
            string recipeDescription = RecipeDescription.Text.Trim();
            string cookingIngredient = CookingIngredient.Text.Trim();
            string cookingInstruction = CookingInstruction.Text.Trim();
            int? calory = string.IsNullOrWhiteSpace(Calory.Text) ? (int?)null : int.Parse(Calory.Text);
            int? protein = string.IsNullOrWhiteSpace(Protein.Text) ? (int?)null : int.Parse(Protein.Text);
            int? carb = string.IsNullOrWhiteSpace(Carb.Text) ? (int?)null : int.Parse(Carb.Text);
            int? fat = string.IsNullOrWhiteSpace(Fat.Text) ? (int?)null : int.Parse(Fat.Text);

            // Check if user is editing their own recipe and status is Rejected
            bool isAdmin = Session["UserRole"]?.ToString() == "Admin";
            int userId = Convert.ToInt32(Session["UserId"] ?? "0");
            int recipeOwnerId = GetRecipeOwnerId(RecipeId);
            string currentStatus = "";

            using (var conn = new SqlConnection(cs))
            {
                conn.Open();

                // Get current status
                using (var cmdStatus = new SqlCommand("SELECT recipe_status FROM Recipe WHERE recipe_id = @id", conn))
                {
                    cmdStatus.Parameters.AddWithValue("@id", RecipeId);
                    var result = cmdStatus.ExecuteScalar();
                    currentStatus = result?.ToString();
                }

                // If user (not admin) edits and status is Rejected, set to Pending
                string statusSql = "";
                if (!isAdmin && userId == recipeOwnerId && currentStatus == "Rejected")
                {
                    statusSql = ", recipe_status = 'Pending'";
                }

                string sql = $@"
                    UPDATE Recipe SET
                        cuisine_id = @cuisine_id,
                        recipe_name = @recipe_name,
                        difficulty_level = @difficulty_level,
                        cooking_time = @cooking_time,
                        servings = @servings,
                        recipe_video = @recipe_video,
                        recipe_description = @recipe_description,
                        cooking_ingredient = @cooking_ingredient,
                        cooking_instruction = @cooking_instruction,
                        calory = @calory,
                        protein = @protein,
                        carb = @carb,
                        fat = @fat
                        {statusSql}
                        {{0}}
                    WHERE recipe_id = @id";
                string imageSql = "";
                if (imageName != null)
                    imageSql = ", recipe_image = @recipe_image";
                sql = string.Format(sql, imageSql);

                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@cuisine_id", cuisineId);
                    cmd.Parameters.AddWithValue("@recipe_name", recipeName);
                    cmd.Parameters.AddWithValue("@difficulty_level", difficulty);
                    cmd.Parameters.AddWithValue("@cooking_time", cookingTime);
                    cmd.Parameters.AddWithValue("@servings", servings);
                    cmd.Parameters.AddWithValue("@recipe_video", recipeVideo);
                    cmd.Parameters.AddWithValue("@recipe_description", recipeDescription);
                    cmd.Parameters.AddWithValue("@cooking_ingredient", cookingIngredient);
                    cmd.Parameters.AddWithValue("@cooking_instruction", cookingInstruction);
                    cmd.Parameters.AddWithValue("@calory", (object)calory ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@protein", (object)protein ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@carb", (object)carb ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@fat", (object)fat ?? DBNull.Value);
                    if (imageName != null)
                        cmd.Parameters.AddWithValue("@recipe_image", imageName);
                    cmd.Parameters.AddWithValue("@id", RecipeId);

                    int rows = cmd.ExecuteNonQuery();
                    if (rows > 0)
                    {
                        MessagePanel.Visible = true;
                        MessageLabel.Text = "Recipe updated successfully!";
                        FormPanel.Visible = false;
                    }
                    else
                    {
                        ErrorPanel.Visible = true;
                        ErrorLabel.Text = "Failed to update recipe.";
                    }
                }
            }
        }
    }
}