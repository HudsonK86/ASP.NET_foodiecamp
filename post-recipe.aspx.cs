using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class post_recipe : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Only allow logged in users
                if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
                {
                    Response.Redirect("~/login.aspx");
                    return;
                }

                // Populate cuisine dropdown (6 cuisines)
                CuisineType.Items.Clear();
                CuisineType.Items.Add(new ListItem("Select Cuisine Type", ""));
                CuisineType.Items.Add(new ListItem("Chinese", "1"));
                CuisineType.Items.Add(new ListItem("Malaysian", "2"));
                CuisineType.Items.Add(new ListItem("Indian", "3"));
                CuisineType.Items.Add(new ListItem("Western", "4"));
                CuisineType.Items.Add(new ListItem("Vietnamese", "5"));
                CuisineType.Items.Add(new ListItem("Other", "6"));
            }
        }

        protected void PublishBtn_Click(object sender, EventArgs e)
        {
            ErrorPanel.Visible = false;
            MessagePanel.Visible = false;

            if (!Page.IsValid)
                return;

            // Validate file upload
            if (!RecipeImage.HasFile)
            {
                ErrorPanel.Visible = true;
                ErrorLabel.Text = "Recipe image is required.";
                return;
            }

            string fileExt = Path.GetExtension(RecipeImage.FileName).ToLower();
            if (fileExt != ".jpg" && fileExt != ".jpeg" && fileExt != ".png" && fileExt != ".gif")
            {
                ErrorPanel.Visible = true;
                ErrorLabel.Text = "Only JPG, JPEG, PNG, or GIF images are allowed.";
                return;
            }

            // Save image
            string imageName = Guid.NewGuid().ToString("N") + fileExt;
            string imagePath = Server.MapPath("~/images/recipes/" + imageName);
            RecipeImage.SaveAs(imagePath);

            // Get user id
            int userId = Convert.ToInt32(Session["UserId"]);

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

            // Insert into DB
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"
                    INSERT INTO Recipe
                    (user_id, cuisine_id, recipe_name, difficulty_level, cooking_time, servings, recipe_image, recipe_video, recipe_description, cooking_ingredient, cooking_instruction, calory, protein, carb, fat, recipe_status, recipe_visibility, date_created)
                    VALUES
                    (@user_id, @cuisine_id, @recipe_name, @difficulty_level, @cooking_time, @servings, @recipe_image, @recipe_video, @recipe_description, @cooking_ingredient, @cooking_instruction, @calory, @protein, @carb, @fat, 'Pending', 'Hide', GETDATE())";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@user_id", userId);
                    cmd.Parameters.AddWithValue("@cuisine_id", cuisineId);
                    cmd.Parameters.AddWithValue("@recipe_name", recipeName);
                    cmd.Parameters.AddWithValue("@difficulty_level", difficulty);
                    cmd.Parameters.AddWithValue("@cooking_time", cookingTime);
                    cmd.Parameters.AddWithValue("@servings", servings);
                    cmd.Parameters.AddWithValue("@recipe_image", imageName);
                    cmd.Parameters.AddWithValue("@recipe_video", recipeVideo);
                    cmd.Parameters.AddWithValue("@recipe_description", recipeDescription);
                    cmd.Parameters.AddWithValue("@cooking_ingredient", cookingIngredient);
                    cmd.Parameters.AddWithValue("@cooking_instruction", cookingInstruction);
                    cmd.Parameters.AddWithValue("@calory", (object)calory ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@protein", (object)protein ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@carb", (object)carb ?? DBNull.Value);
                    cmd.Parameters.AddWithValue("@fat", (object)fat ?? DBNull.Value);
                    cmd.ExecuteNonQuery();
                }
            }

            MessagePanel.Visible = true;
            MessageLabel.Text = "Recipe submitted successfully! It will be reviewed by an admin before publishing.";
            FormPanel.Visible = false;
        }
    }
}