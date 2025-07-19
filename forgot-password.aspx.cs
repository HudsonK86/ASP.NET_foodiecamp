using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class forgot_password : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Display any messages passed from other pages
            if (Session["ForgotPasswordMessage"] != null)
            {
                ShowMessage(Session["ForgotPasswordMessage"].ToString(), false);
                Session.Remove("ForgotPasswordMessage");
            }
        }

        protected void SendCodeButton_Click(object sender, EventArgs e)
        {
            try
            {
                // Check page validation
                if (!Page.IsValid)
                {
                    return;
                }

                string email = EmailTextBox.Text.Trim().ToLower();
                string password = PasswordTextBox.Text;
                string confirmPassword = ConfirmPasswordTextBox.Text;

                // Check if email exists in database
                if (!IsEmailExists(email))
                {
                    ShowMessage("Email address not found. Please check your email or register for a new account.", false);
                    return;
                }

                // Hash the password before storing in session
                string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

                // Store password reset data in session
                Session["ForgotPassword_Email"] = email;
                Session["ForgotPassword_Password"] = hashedPassword;

                // Send OTP email and redirect to OTP page
                SendOtpEmail(email);
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred. Please try again.", false);
                System.Diagnostics.Debug.WriteLine($"Forgot Password Error: {ex.Message}");
            }
        }

        private void SendOtpEmail(string userEmail)
        {
            try
            {
                // Generate 4-digit OTP
                Random rnd = new Random();
                string otp = rnd.Next(1000, 9999).ToString();

                // Store OTP in session
                Session["OTP"] = otp;
                Session["OTPTime"] = DateTime.Now;
                Session["Email"] = userEmail;

                // Create email message
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress("sharingiscaring6688@gmail.com", "FoodieCamp");
                mail.To.Add(userEmail);
                mail.Subject = "FoodieCamp - Password Reset Verification Code";
                mail.Body = $@"
            <html>
            <body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                <div style='background-color: #f8f9fa; padding: 20px; text-align: center;'>
                    <h2 style='color: #2563eb; margin-bottom: 10px;'>
                        🍽️ FoodieCamp
                    </h2>
                    <h3 style='color: #374151;'>Password Reset Verification</h3>
                </div>
                
                <div style='padding: 30px; background-color: white; border: 1px solid #e5e7eb;'>
                    <p style='color: #374151; font-size: 16px;'>
                        You requested to reset your password. Please verify your email with this code:
                    </p>
                    
                    <div style='text-align: center; margin: 30px 0;'>
                        <div style='background-color: #eff6ff; border: 2px solid #2563eb; 
                                   border-radius: 8px; padding: 20px; display: inline-block;'>
                            <p style='margin: 0; font-size: 36px; font-weight: bold; 
                                     color: #2563eb; letter-spacing: 8px; font-family: monospace;'>
                                {otp}
                            </p>
                        </div>
                    </div>
                    
                    <p style='color: #6b7280; font-size: 14px; text-align: center;'>
                        This code expires in 5 minutes.
                    </p>
                    
                    <p style='color: #6b7280; font-size: 12px; text-align: center; margin-top: 20px;'>
                        If you didn't request this password reset, please ignore this email.
                    </p>
                </div>
                
                <div style='background-color: #f8f9fa; padding: 15px; text-align: center; 
                           border-top: 1px solid #e5e7eb;'>
                    <p style='color: #9ca3af; font-size: 12px; margin: 0;'>
                        © 2024 FoodieCamp. All rights reserved.
                    </p>
                </div>
            </body>
            </html>";
                mail.IsBodyHtml = true;

                // Gmail SMTP configuration
                SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587);
                smtp.Credentials = new NetworkCredential("sharingiscaring6688@gmail.com", "pzik pfzv arqu souv");
                smtp.EnableSsl = true;

                // Send the email
                smtp.Send(mail);

                // Redirect to OTP verification page
                Response.Redirect("~/otp-verification.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage($"Failed to send email: {ex.Message}", false);
                System.Diagnostics.Debug.WriteLine($"Email Error: {ex.Message}");
            }
        }

        private bool IsEmailExists(string email)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            string query = "SELECT COUNT(*) FROM [User] WHERE email = @Email";

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    cmd.Parameters.AddWithValue("@Email", email);
                    conn.Open();

                    int count = (int)cmd.ExecuteScalar();
                    return count > 0;
                }
            }
        }

        // Static method to update user password (called from OTP verification page)
        public static bool UpdateUserPassword(string email, string hashedPassword)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = "UPDATE [User] SET password = @Password WHERE email = @Email";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@Password", hashedPassword);
                        cmd.Parameters.AddWithValue("@Email", email);

                        conn.Open();
                        int rowsAffected = cmd.ExecuteNonQuery();
                        return rowsAffected > 0;
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Password Update Error: {ex.Message}");
                return false;
            }
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            MessagePanel.Visible = true;
            MessageLabel.Text = message;
            MessageLabel.CssClass = isSuccess
                ? "block text-sm font-medium p-3 rounded-md bg-green-50 text-green-800 border border-green-200"
                : "block text-sm font-medium p-3 rounded-md bg-red-50 text-red-800 border border-red-200";
        }
    }
}