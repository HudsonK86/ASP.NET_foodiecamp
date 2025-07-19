using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using BCrypt.Net;

namespace Hope
{
    public partial class user_profile : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["IsLoggedIn"] == null || !(bool)Session["IsLoggedIn"])
            {
                Response.Redirect("~/login.aspx");
                return;
            }

            string userRole = Session["UserRole"] as string;
            if (userRole != "User")
            {
                Response.Redirect("~/home.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadUserProfile();
            }
        }

        private void LoadUserProfile()
        {
            try
            {
                int userId = Convert.ToInt32(Session["UserId"]);
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
            SELECT firstname, lastname, email, phone_number, gender, 
                   date_of_birth, nationality, profile_image
            FROM [User]
            WHERE user_id = @UserId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        conn.Open();

                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                FirstNameTextBox.Text = reader["firstname"].ToString();
                                LastNameTextBox.Text = reader["lastname"].ToString();
                                EmailTextBox.Text = reader["email"].ToString();
                                PhoneTextBox.Text = reader["phone_number"].ToString();
                                GenderDropDownList.SelectedValue = reader["gender"].ToString();
                                DateOfBirthTextBox.Text = Convert.ToDateTime(reader["date_of_birth"]).ToString("yyyy-MM-dd");
                                NationalityDropDownList.SelectedValue = reader["nationality"].ToString();

                                string profileImage = reader["profile_image"]?.ToString();
                                string imageUrl = !string.IsNullOrEmpty(profileImage)
                                    ? $"~/images/profiles/{profileImage}"
                                    : "~/images/profiles/default-avatar.png";

                                // Update both the profile form and sidebar image
                                CurrentProfileImage.ImageUrl = imageUrl;
                                UserProfileImage.ImageUrl = imageUrl;
                                CurrentProfileImage.Visible = !string.IsNullOrEmpty(profileImage);
                                DefaultProfileImage.Visible = string.IsNullOrEmpty(profileImage);

                                // Set user name in the sidebar
                                UserNameLabel.Text = $"{reader["firstname"]} {reader["lastname"]}";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Error loading profile: " + ex.Message, false);
            }
        }


        protected void SaveButton_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    int userId = Convert.ToInt32(Session["UserId"]);
                    string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                    string profileImageName = null;

                    // Handle profile image upload
                    if (ProfileImageUpload.HasFile)
                    {
                        string fileExtension = Path.GetExtension(ProfileImageUpload.FileName).ToLower();
                        string[] allowedExtensions = { ".jpg", ".jpeg", ".png", ".gif" };

                        if (Array.IndexOf(allowedExtensions, fileExtension) == -1)
                        {
                            ShowMessage("Please upload only image files (.jpg, .jpeg, .png, .gif)", false);
                            return;
                        }

                        // Generate unique filename
                        profileImageName = $"profile_{userId}_{DateTime.Now.Ticks}{fileExtension}";
                        string savePath = Server.MapPath("~/images/profiles/" + profileImageName);

                        // Save the file to images/profiles/
                        ProfileImageUpload.SaveAs(savePath);
                    }

                    // Update database
                    string updateQuery = @"
                UPDATE [User]
                SET firstname = @FirstName,
                    lastname = @LastName,
                    gender = @Gender,
                    date_of_birth = @DateOfBirth,
                    nationality = @Nationality,
                    phone_number = @PhoneNumber"
                            + (profileImageName != null ? ", profile_image = @ProfileImage" : "") +
                        @" WHERE user_id = @UserId";

                    using (SqlConnection conn = new SqlConnection(connectionString))
                    {
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@FirstName", FirstNameTextBox.Text.Trim());
                            cmd.Parameters.AddWithValue("@LastName", LastNameTextBox.Text.Trim());
                            cmd.Parameters.AddWithValue("@Gender", GenderDropDownList.SelectedValue);
                            cmd.Parameters.AddWithValue("@DateOfBirth", DateTime.Parse(DateOfBirthTextBox.Text));
                            cmd.Parameters.AddWithValue("@Nationality", NationalityDropDownList.SelectedValue);
                            cmd.Parameters.AddWithValue("@PhoneNumber", PhoneTextBox.Text.Trim());
                            cmd.Parameters.AddWithValue("@UserId", userId);

                            if (profileImageName != null)
                                cmd.Parameters.AddWithValue("@ProfileImage", profileImageName);

                            conn.Open();
                            cmd.ExecuteNonQuery();
                        }
                    }

                    // Update session variables
                    Session["UserName"] = $"{FirstNameTextBox.Text.Trim()} {LastNameTextBox.Text.Trim()}";
                    if (profileImageName != null)
                        Session["ProfileImage"] = profileImageName;

                    LoadUserProfile();
                    ShowMessage("Profile updated successfully!", true);
                }
                catch (Exception ex)
                {
                    ShowMessage("Error updating profile: " + ex.Message, false);
                }
            }
        }

        protected void ChangePasswordButton_Click(object sender, EventArgs e)
        {
            string currentPassword = CurrentPasswordTextBox.Text;
            string newPassword = NewPasswordTextBox.Text;
            string confirmPassword = ConfirmPasswordTextBox.Text;

            ChangePasswordMessagePanel.Visible = true;
            bool hasError = false;

            if (string.IsNullOrWhiteSpace(currentPassword) ||
                string.IsNullOrWhiteSpace(newPassword) ||
                string.IsNullOrWhiteSpace(confirmPassword))
            {
                ChangePasswordMessageLabel.Text = "All fields are required.";
                ChangePasswordMessageLabel.CssClass = "block text-sm font-medium p-3 rounded-md bg-red-50 text-red-800 border border-red-200";
                hasError = true;
            }
            else if (newPassword.Length < 8)
            {
                ChangePasswordMessageLabel.Text = "New password must be at least 8 characters.";
                ChangePasswordMessageLabel.CssClass = "block text-sm font-medium p-3 rounded-md bg-red-50 text-red-800 border border-red-200";
                hasError = true;
            }
            else if (newPassword != confirmPassword)
            {
                ChangePasswordMessageLabel.Text = "New password and confirmation do not match.";
                ChangePasswordMessageLabel.CssClass = "block text-sm font-medium p-3 rounded-md bg-red-50 text-red-800 border border-red-200";
                hasError = true;
            }
            else
            {
                int userId = Convert.ToInt32(Session["UserId"]);
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string getPasswordQuery = "SELECT password FROM [User] WHERE user_id = @UserId";

                try
                {
                    string hashedPassword = null;
                    using (SqlConnection conn = new SqlConnection(connectionString))
                    using (SqlCommand cmd = new SqlCommand(getPasswordQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@UserId", userId);
                        conn.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                            hashedPassword = result.ToString();
                    }

                    if (hashedPassword == null || !BCrypt.Net.BCrypt.Verify(currentPassword, hashedPassword))
                    {
                        ChangePasswordMessageLabel.Text = "Current password is incorrect.";
                        ChangePasswordMessageLabel.CssClass = "block text-sm font-medium p-3 rounded-md bg-red-50 text-red-800 border border-red-200";
                        hasError = true;
                    }
                    else
                    {
                        // Update password
                        string newHashedPassword = BCrypt.Net.BCrypt.HashPassword(newPassword);
                        string updateQuery = "UPDATE [User] SET password = @Password WHERE user_id = @UserId";
                        using (SqlConnection conn = new SqlConnection(connectionString))
                        using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                        {
                            cmd.Parameters.AddWithValue("@Password", newHashedPassword);
                            cmd.Parameters.AddWithValue("@UserId", userId);
                            conn.Open();
                            cmd.ExecuteNonQuery();
                        }

                        // Success: close modal and show success message
                        ScriptManager.RegisterStartupScript(this, GetType(), "closeChangePasswordModal",
                            "closeChangePasswordModal();", true);
                        ShowMessage("Password changed successfully!", true);
                        ChangePasswordMessagePanel.Visible = false;
                        CurrentPasswordTextBox.Text = "";
                        NewPasswordTextBox.Text = "";
                        ConfirmPasswordTextBox.Text = "";
                    }
                }
                catch (Exception ex)
                {
                    ChangePasswordMessageLabel.Text = "Error changing password: " + ex.Message;
                    ChangePasswordMessageLabel.CssClass = "block text-sm font-medium p-3 rounded-md bg-red-50 text-red-800 border border-red-200";
                    hasError = true;
                }
            }

            // If there was an error, keep the modal open
            if (hasError)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "showChangePasswordModal",
                    "showChangePasswordModal();", true);
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            MessagePanel.Visible = true;
            MessageLabel.Text = message;
            if (isSuccess)
            {
                MessageLabel.CssClass = "text-green-800";
                MessagePanel.CssClass = "fixed top-20 left-1/2 transform -translate-x-1/2 z-50 bg-green-50 border border-green-200 text-green-800 px-6 py-4 rounded-lg shadow-lg max-w-md mx-auto";
            }
            else
            {
                MessageLabel.CssClass = "text-red-800";
                MessagePanel.CssClass = "fixed top-20 left-1/2 transform -translate-x-1/2 z-50 bg-red-50 border border-red-200 text-red-800 px-6 py-4 rounded-lg shadow-lg max-w-md mx-auto";
            }
            // Auto-hide message after 5 seconds
            ScriptManager.RegisterStartupScript(this, GetType(), "hideMessage",
                "setTimeout(function() { document.getElementById('" + MessagePanel.ClientID + "').style.display = 'none'; }, 5000);", true);
        }

        protected void UserLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/logout.aspx");
        }
    }
}