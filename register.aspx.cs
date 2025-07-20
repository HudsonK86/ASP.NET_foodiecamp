using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;
using BCrypt.Net;
using System.Net.Mail;
using System.Net;

namespace Hope
{
    public partial class register : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Set focus to first name field
                FirstNameTextBox.Focus();
            }
        }

        // Add this method for checkbox validation
        protected void TermsRequired_ServerValidate(object source, ServerValidateEventArgs args)
        {
            // Check if the checkbox is checked
            args.IsValid = TermsCheckBox.Checked;
        }

        protected void RegisterButton_Click(object sender, EventArgs e)
        {
            if (Page.IsValid)
            {
                try
                {
                    // Get form values
                    string firstName = FirstNameTextBox.Text.Trim();
                    string lastName = LastNameTextBox.Text.Trim();
                    string email = EmailTextBox.Text.Trim().ToLower();
                    string phone = PhoneTextBox.Text.Trim();
                    string password = PasswordTextBox.Text;
                    string gender = GenderDropDownList.SelectedValue;
                    DateTime dateOfBirth = DateTime.Parse(DateOfBirthTextBox.Text);
                    string nationality = NationalityDropDownList.SelectedValue;

                    // Check if email already exists
                    if (IsEmailExists(email))
                    {
                        ShowMessage("Email address already exists. Please use a different email.", false);
                        return;
                    }

                    // Hash password using BCrypt
                    string hashedPassword = BCrypt.Net.BCrypt.HashPassword(password);

                    // Store user data in session
                    Session["PendingUser_FirstName"] = firstName;
                    Session["PendingUser_LastName"] = lastName;
                    Session["PendingUser_Email"] = email;
                    Session["PendingUser_Phone"] = phone;
                    Session["PendingUser_Password"] = hashedPassword;
                    Session["PendingUser_Gender"] = gender;
                    Session["PendingUser_DateOfBirth"] = dateOfBirth;
                    Session["PendingUser_Nationality"] = nationality;

                    // Send OTP email and redirect to otp-verification page
                    SendOtpEmail(email);
                }
                catch (Exception ex)
                {
                    // Log the exception (implement logging as needed)
                    ShowMessage("An error occurred during registration. Please try again.", false);
                }
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
                Session["OTP_Message"] = $"Verification code sent to {userEmail}";

                // Create email message
                MailMessage mail = new MailMessage();
                mail.From = new MailAddress("sharingiscaring6688@gmail.com", "FoodieCamp");
                mail.To.Add(userEmail);
                mail.Subject = "FoodieCamp - Email Verification Code";
                mail.Body = $@"
            <html>
            <body style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;'>
                <div style='background-color: #f8f9fa; padding: 20px; text-align: center;'>
                    <h2 style='color: #2563eb; margin-bottom: 10px;'>
                        🍽️ FoodieCamp
                    </h2>
                    <h3 style='color: #374151;'>Email Verification</h3>
                </div>
                
                <div style='padding: 30px; background-color: white; border: 1px solid #e5e7eb;'>
                    <p style='color: #374151; font-size: 16px;'>
                        Welcome to FoodieCamp! Please verify your email with this code:
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
                        If you didn't request this verification, please ignore this email.
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

                // Gmail SMTP configuration with your credentials
                SmtpClient smtp = new SmtpClient("smtp.gmail.com", 587);
                smtp.Credentials = new NetworkCredential("sharingiscaring6688@gmail.com", "pzik pfzv arqu souv");
                smtp.EnableSsl = true;

                // Send the email
                smtp.Send(mail);

                // Redirect immediately to OTP page
                Response.Redirect("~/otp-verification.aspx");
            }
            catch (Exception ex)
            {
                ShowMessage($"Failed to send email: {ex.Message}", false);

                // For debugging - log the actual error
                System.Diagnostics.Debug.WriteLine($"Email Error: {ex.Message}");
                System.Diagnostics.Debug.WriteLine($"Stack Trace: {ex.StackTrace}");
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

        // This method will be called from OTP verification page after successful verification
        public static int RegisterUser(string firstName, string lastName, string email, string phone,
                               string hashedPassword, string gender, DateTime dateOfBirth, string nationality)
        {
            string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            string query = @"
                INSERT INTO [User] 
                (firstname, lastname, gender, date_of_birth, nationality, email, phone_number, 
                 password, profile_image, user_role, is_activated, registered_date)
                VALUES 
                (@FirstName, @LastName, @Gender, @DateOfBirth, @Nationality, @Email, @PhoneNumber, 
                 @Password, @ProfileImage, @UserRole, @IsActivated, @RegisteredDate);
                SELECT SCOPE_IDENTITY();";

            using (SqlConnection conn = new SqlConnection(connectionString))
            {
                using (SqlCommand cmd = new SqlCommand(query, conn))
                {
                    // Add parameters
                    cmd.Parameters.AddWithValue("@FirstName", firstName);
                    cmd.Parameters.AddWithValue("@LastName", lastName);
                    cmd.Parameters.AddWithValue("@Gender", gender);
                    cmd.Parameters.AddWithValue("@DateOfBirth", dateOfBirth);
                    cmd.Parameters.AddWithValue("@Nationality", nationality);
                    cmd.Parameters.AddWithValue("@Email", email);
                    cmd.Parameters.AddWithValue("@PhoneNumber", phone);
                    cmd.Parameters.AddWithValue("@Password", hashedPassword);
                    cmd.Parameters.AddWithValue("@ProfileImage", "default-avatar.png"); // Default avatar, can be changed later
                    cmd.Parameters.AddWithValue("@UserRole", "User");
                    cmd.Parameters.AddWithValue("@IsActivated", true); 
                    cmd.Parameters.AddWithValue("@RegisteredDate", DateTime.Now.Date);

                    conn.Open();

                    object result = cmd.ExecuteScalar();
                    return result != null ? Convert.ToInt32(result) : 0;
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
    }
}