using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class admin_cuisine : System.Web.UI.Page
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
                LoadCuisines();
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

        private void LoadCuisines()
        {
            try
            {
                List<Cuisine> cuisines = new List<Cuisine>();
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = "SELECT cuisine_id, cuisine_name, cuisine_image FROM [Cuisine] ORDER BY cuisine_id";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                cuisines.Add(new Cuisine
                                {
                                    CuisineId = Convert.ToInt32(reader["cuisine_id"]),
                                    CuisineName = reader["cuisine_name"].ToString(),
                                    CuisineImage = reader["cuisine_image"].ToString()
                                });
                            }
                        }
                    }
                }

                CuisineRepeater.DataSource = cuisines;
                CuisineRepeater.DataBind();
            }
            catch (Exception ex)
            {
                // Handle error
                System.Diagnostics.Debug.WriteLine($"Error loading cuisines: {ex.Message}");
            }
        }

        protected void EditButton_Command(object sender, CommandEventArgs e)
        {
            if (e.CommandName == "Edit")
            {
                int cuisineId = Convert.ToInt32(e.CommandArgument);

                // Get cuisine details
                var cuisine = GetCuisineById(cuisineId);
                if (cuisine != null)
                {
                    // Hide any previous error messages
                    ModalErrorPanel.Visible = false;

                    // Populate modal
                    SelectedCuisineId.Value = cuisineId.ToString();
                    ModalCuisineName.Text = cuisine.CuisineName;
                    ModalCurrentImage.ImageUrl = cuisine.FullImagePath;

                    // Show modal
                    EditModal.Visible = true;
                }
            }
        }

        protected void SaveButton_Click(object sender, EventArgs e)
        {
            if (CuisineFileUpload.HasFile)
            {
                try
                {
                    int cuisineId = Convert.ToInt32(SelectedCuisineId.Value);

                    // Validate file
                    string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };
                    string fileExtension = Path.GetExtension(CuisineFileUpload.FileName).ToLower();

                    if (Array.Exists(allowedExtensions, ext => ext == fileExtension))
                    {
                        // Validate file size (10MB max)
                        if (CuisineFileUpload.PostedFile.ContentLength > 10 * 1024 * 1024)
                        {
                            ShowModalError("File size too large. Maximum 10MB allowed.");
                            return;
                        }

                        // Generate filename
                        string fileName = $"cuisine_{cuisineId}_{DateTime.Now.Ticks}{fileExtension}";
                        string uploadPath = Server.MapPath("~/images/cuisines/");

                        // Create directory if it doesn't exist
                        if (!Directory.Exists(uploadPath))
                        {
                            Directory.CreateDirectory(uploadPath);
                        }

                        // Save file
                        string fullPath = Path.Combine(uploadPath, fileName);
                        CuisineFileUpload.SaveAs(fullPath);

                        // Update database
                        UpdateCuisineImage(cuisineId, fileName);

                        // Hide modal and reload
                        EditModal.Visible = false;
                        LoadCuisines(); // Reload data

                        // Show success message
                        ShowSuccessMessage("Cuisine image updated successfully!");
                    }
                    else
                    {
                        ShowModalError("Please select a valid image file (JPG, PNG, GIF).");
                    }
                }
                catch (Exception ex)
                {
                    ShowModalError($"Error: {ex.Message}");
                }
            }
            else
            {
                ShowModalError("Please select an image file.");
            }
        }

        protected void CancelButton_Click(object sender, EventArgs e)
        {
            EditModal.Visible = false;
            ModalErrorPanel.Visible = false; // Hide any error messages
        }

        private void ShowSuccessMessage(string message)
        {
            MessageLabel.Text = message;
            MessagePanel.Visible = true;
        }

        private void ShowModalError(string message)
        {
            ModalErrorLabel.Text = message;
            ModalErrorPanel.Visible = true;
            // Keep modal open to show the error
        }

        private Cuisine GetCuisineById(int cuisineId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = "SELECT cuisine_id, cuisine_name, cuisine_image FROM [Cuisine] WHERE cuisine_id = @id";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@id", cuisineId);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                return new Cuisine
                                {
                                    CuisineId = Convert.ToInt32(reader["cuisine_id"]),
                                    CuisineName = reader["cuisine_name"].ToString(),
                                    CuisineImage = reader["cuisine_image"].ToString()
                                };
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error getting cuisine: {ex.Message}");
            }
            return null;
        }

        private void UpdateCuisineImage(int cuisineId, string fileName)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            string query = "UPDATE [Cuisine] SET cuisine_image = @fileName WHERE cuisine_id = @cuisineId";

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@fileName", fileName);
                    cmd.Parameters.AddWithValue("@cuisineId", cuisineId);

                    conn.Open();
                    cmd.ExecuteNonQuery();
                }
            }
        }

        protected void AdminLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/logout.aspx");
        }

        public class Cuisine
        {
            public int CuisineId { get; set; }
            public string CuisineName { get; set; }
            public string CuisineImage { get; set; }
            public string FullImagePath => $"~/images/cuisines/{CuisineImage}";
        }
    }
}