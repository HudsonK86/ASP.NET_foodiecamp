using System;
using System.Web.UI;

namespace Hope
{
    public partial class logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // Complete session cleanup first
            Session.Remove("UserId");
            Session.Remove("UserName");
            Session.Remove("UserEmail");
            Session.Remove("UserRole");
            Session.Remove("ProfileImage");
            Session.Remove("IsLoggedIn");

            // Store logout message AFTER clearing other session data
            Session["LogoutSuccess"] = "You have been successfully logged out. Thank you for visiting FoodieCamp!";

            // Redirect to home page
            Response.Redirect("~/home.aspx");
        }
    }
}