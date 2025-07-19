using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using BCrypt.Net;

namespace Hope
{
    public partial class login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check for success messages from registration or password reset
                if (Session["RegistrationSuccess"] != null)
                {
                    ShowMessage(Session["RegistrationSuccess"].ToString(), true);
                    Session.Remove("RegistrationSuccess");
                }
                else if (Session["PasswordResetSuccess"] != null)
                {
                    ShowMessage(Session["PasswordResetSuccess"].ToString(), true);
                    Session.Remove("PasswordResetSuccess");
                }

                // Set focus to email field
                EmailTextBox.Focus();
            }
        }

        protected void LoginButton_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    string email = EmailTextBox.Text.Trim().ToLower();
                    string password = PasswordTextBox.Text;

                    // Authenticate user
                    var authResult = AuthenticateUser(email, password);

                    if (authResult.IsSuccess && authResult.User != null)
                    {
                        // Store essential user information in session for quick access
                        Session["UserId"] = authResult.User.UserId;
                        Session["UserName"] = authResult.User.FullName;
                        Session["UserEmail"] = authResult.User.Email;
                        Session["UserRole"] = authResult.User.UserRole;
                        Session["ProfileImage"] = authResult.User.ProfileImage; // For avatar display
                        Session["IsLoggedIn"] = true;

                        // Add login success message
                        Session["LoginSuccess"] = $"Welcome back, {authResult.User.FirstName}! You have successfully logged in.";

                        // Always redirect to home.aspx after successful login
                        Response.Redirect("~/home.aspx");
                    }
                    else
                    {
                        // Show appropriate error message based on authentication result
                        ShowMessage(authResult.ErrorMessage, false);
                    }
                }
                catch (Exception ex)
                {
                    ShowMessage("An error occurred during login. Please try again.", false);
                    System.Diagnostics.Debug.WriteLine($"Login Error: {ex.Message}");
                }
            }
        }

        private AuthenticationResult AuthenticateUser(string email, string password)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            string query = @"
                SELECT user_id, firstname, lastname, email, password, user_role, is_activated, profile_image 
                FROM [User] 
                WHERE email = @Email";

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    conn.Open();

                    using (SqlDataReader reader = cmd.ExecuteReader())
                    {
                        if (reader.Read())
                        {
                            bool isActivated = (bool)reader["is_activated"];

                            // Check if account is activated
                            if (!isActivated)
                            {
                                return new AuthenticationResult
                                {
                                    IsSuccess = false,
                                    ErrorMessage = "Your account has been blocked. Please contact the administrator for support.",
                                    User = null
                                };
                            }

                            string hashedPassword = reader["password"].ToString();

                            // Verify password using BCrypt
                            if (BCrypt.Net.BCrypt.Verify(password, hashedPassword))
                            {
                                var user = new UserInfo
                                {
                                    UserId = (int)reader["user_id"],
                                    FirstName = reader["firstname"].ToString(),
                                    LastName = reader["lastname"].ToString(),
                                    Email = reader["email"].ToString(),
                                    UserRole = reader["user_role"].ToString(),
                                    ProfileImage = reader["profile_image"] as string // Null if no image
                                };

                                return new AuthenticationResult
                                {
                                    IsSuccess = true,
                                    ErrorMessage = null,
                                    User = user
                                };
                            }
                            else
                            {
                                return new AuthenticationResult
                                {
                                    IsSuccess = false,
                                    ErrorMessage = "Invalid email or password. Please try again.",
                                    User = null
                                };
                            }
                        }
                        else
                        {
                            return new AuthenticationResult
                            {
                                IsSuccess = false,
                                ErrorMessage = "Invalid email or password. Please try again.",
                                User = null
                            };
                        }
                    }
                }
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            MessagePanel.Visible = true;
            MessageLabel.Text = message;

            if (isSuccess)
            {
                MessageLabel.CssClass = "block text-sm font-medium p-3 rounded-md bg-green-50 text-green-800 border border-green-200";
            }
            else
            {
                MessageLabel.CssClass = "block text-sm font-medium p-3 rounded-md bg-red-50 text-red-800 border border-red-200";
            }
        }

        // Helper class for authentication result
        public class AuthenticationResult
        {
            public bool IsSuccess { get; set; }
            public string ErrorMessage { get; set; }
            public UserInfo User { get; set; }
        }

        // Helper class for user information
        public class UserInfo
        {
            public int UserId { get; set; }
            public string FirstName { get; set; }
            public string LastName { get; set; }
            public string Email { get; set; }
            public string UserRole { get; set; }
            public string ProfileImage { get; set; }

            // Computed property for full name
            public string FullName => $"{FirstName} {LastName}".Trim();
        }
    }
}