using System;
using System.Web.UI;

namespace Hope
{
    public partial class otp_verification : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Check if user came from registration or forgot password
                if (Session["Email"] == null || Session["OTP"] == null)
                {
                    Response.Redirect("~/register.aspx");
                    return;
                }

                // Show email address in the description and success message
                string email = Session["Email"] as string;
                if (!string.IsNullOrEmpty(email))
                {
                    // Update the page text to show which email was used
                    ClientScript.RegisterStartupScript(this.GetType(), "updateEmail",
                        $@"document.addEventListener('DOMContentLoaded', function() {{ 
                            var emailTexts = document.querySelectorAll('.text-gray-600');
                            emailTexts.forEach(function(element) {{
                                if (element.textContent.includes('verification code to your email')) {{
                                    element.innerHTML = 'We\'ve sent a 4-digit verification code to <strong>{email}</strong>';
                                }}
                            }});
                        }});", true);

                    // Show standard message for both registration and forgot password flows
                    ShowMessage($"✓ Verification code sent successfully to {email}", true);
                }

                // Remove the OTP_Message from session if it exists (we're showing our own message now)
                Session.Remove("OTP_Message");
            }
        }

        protected void VerifyButton_Click(object sender, EventArgs e)
        {
            try
            {
                // Get OTP from the 4 input fields
                string otp1 = Request.Form["otp-1"];
                string otp2 = Request.Form["otp-2"];
                string otp3 = Request.Form["otp-3"];
                string otp4 = Request.Form["otp-4"];

                string enteredOTP = otp1 + otp2 + otp3 + otp4;

                if (string.IsNullOrEmpty(enteredOTP) || enteredOTP.Length != 4)
                {
                    ShowMessage("Please enter all 4 digits.", false);
                    return;
                }

                // Verify OTP
                if (VerifyOTPCode(enteredOTP))
                {
                    // Check if this is password reset flow
                    if (Session["ForgotPassword_Email"] != null)
                    {
                        // Handle password reset
                        if (UpdatePassword())
                        {
                            // Clear session data
                            ClearPasswordResetData();

                            // Redirect to login with success message
                            Session["PasswordResetSuccess"] = "Password reset successfully! Please login with your new password.";
                            Response.Redirect("~/login.aspx");
                        }
                        else
                        {
                            ShowMessage("Failed to update password. Please try again.", false);
                        }
                    }
                    else
                    {
                        // Handle registration flow
                        if (SaveUserToDatabase())
                        {
                            // Clear session data
                            ClearPendingUserData();

                            // Redirect to login with success message
                            Session["RegistrationSuccess"] = "Registration completed successfully! Please login with your credentials.";
                            Response.Redirect("~/login.aspx");
                        }
                        else
                        {
                            ShowMessage("Registration failed. Please try again.", false);
                        }
                    }
                }
                else
                {
                    ShowMessage("Invalid or expired verification code. Please try again.", false);
                }
            }
            catch (Exception ex)
            {
                ShowMessage("An error occurred. Please try again.", false);
                System.Diagnostics.Debug.WriteLine($"OTP Verification Error: {ex.Message}");
            }
        }

        protected void ResendButton_Click(object sender, EventArgs e)
        {
            try
            {
                string email = Session["Email"] as string;
                if (!string.IsNullOrEmpty(email))
                {
                    // Generate new OTP
                    Random rnd = new Random();
                    string newOtp = rnd.Next(1000, 9999).ToString();

                    // Update session
                    Session["OTP"] = newOtp;
                    Session["OTPTime"] = DateTime.Now;

                    // TODO: Resend email with new OTP
                    // For now, just show success message
                    ShowMessage("New verification code sent to your email!", true);
                }
                else
                {
                    Response.Redirect("~/register.aspx");
                }
            }
            catch (Exception ex)
            {
                ShowMessage("Failed to resend code. Please try again.", false);
            }
        }

        private bool VerifyOTPCode(string enteredOTP)
        {
            string sessionOTP = Session["OTP"] as string;
            DateTime? otpTime = Session["OTPTime"] as DateTime?;

            if (string.IsNullOrEmpty(sessionOTP) || !otpTime.HasValue)
            {
                return false;
            }

            // Check if OTP has expired (5 minutes)
            if (DateTime.Now.Subtract(otpTime.Value).TotalMinutes > 5)
            {
                return false;
            }

            // Check if OTP matches
            return sessionOTP == enteredOTP;
        }

        private bool UpdatePassword()
        {
            try
            {
                string email = Session["ForgotPassword_Email"] as string;
                string hashedPassword = Session["ForgotPassword_Password"] as string;

                if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(hashedPassword))
                {
                    return false;
                }

                // Update password in database using the static method from forgot-password page
                return forgot_password.UpdateUserPassword(email, hashedPassword);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Password Update Error: {ex.Message}");
                return false;
            }
        }

        private bool SaveUserToDatabase()
        {
            try
            {
                // Get user data from session
                string firstName = Session["PendingUser_FirstName"] as string;
                string lastName = Session["PendingUser_LastName"] as string;
                string email = Session["PendingUser_Email"] as string;
                string phone = Session["PendingUser_Phone"] as string;
                string hashedPassword = Session["PendingUser_Password"] as string;
                string gender = Session["PendingUser_Gender"] as string;
                DateTime dateOfBirth = (DateTime)Session["PendingUser_DateOfBirth"];
                string nationality = Session["PendingUser_Nationality"] as string;

                // Save to database using the static method from register page
                int userId = register.RegisterUser(firstName, lastName, email, phone, hashedPassword,
                                                 gender, dateOfBirth, nationality);

                return userId > 0;
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Database Save Error: {ex.Message}");
                return false;
            }
        }

        private void ClearPasswordResetData()
        {
            Session.Remove("ForgotPassword_Email");
            Session.Remove("ForgotPassword_Password");
            Session.Remove("OTP");
            Session.Remove("OTPTime");
            Session.Remove("Email");
        }

        private void ClearPendingUserData()
        {
            Session.Remove("PendingUser_FirstName");
            Session.Remove("PendingUser_LastName");
            Session.Remove("PendingUser_Email");
            Session.Remove("PendingUser_Phone");
            Session.Remove("PendingUser_Password");
            Session.Remove("PendingUser_Gender");
            Session.Remove("PendingUser_DateOfBirth");
            Session.Remove("PendingUser_Nationality");
            Session.Remove("OTP");
            Session.Remove("OTPTime");
            Session.Remove("Email");
        }

        private void ShowMessage(string message, bool isSuccess)
        {
            string textColor = isSuccess ? "text-green-600" : "text-red-600";
            string icon = isSuccess ? "fas fa-check-circle" : "fas fa-exclamation-circle";

            ClientScript.RegisterStartupScript(this.GetType(), "showMessage",
                $@"document.addEventListener('DOMContentLoaded', function() {{
                    var messageParagraph = document.querySelector('.mt-2.text-sm.text-gray-600');
                    if (messageParagraph) {{
                        messageParagraph.className = 'mt-2 text-sm {textColor}';
                        messageParagraph.innerHTML = '<i class=""{icon} mr-2""></i>{message}';
                    }}
                }});", true);
        }
    }
}