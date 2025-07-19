using System;
using System.Configuration;
using System.Data.SqlClient;

namespace Hope
{
    public partial class contact : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            MessagePanel.Visible = false;
        }

        protected void SendBtn_Click(object sender, EventArgs e)
        {
            MessagePanel.Visible = false;

            if (!Page.IsValid)
                return;

            try
            {
                string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                using (var conn = new SqlConnection(cs))
                {
                    conn.Open();
                    string sql = @"
                        INSERT INTO Inquiry (admin_id, full_name, email_address, subject, message, inquiry_status, submission_date)
                        VALUES (NULL, @full_name, @email_address, @subject, @message, 'Pending', @submission_date)";
                    using (var cmd = new SqlCommand(sql, conn))
                    {
                        cmd.Parameters.AddWithValue("@full_name", FullName.Text.Trim());
                        cmd.Parameters.AddWithValue("@email_address", Email.Text.Trim());
                        cmd.Parameters.AddWithValue("@subject", Subject.SelectedValue);
                        cmd.Parameters.AddWithValue("@message", Message.Text.Trim());
                        cmd.Parameters.AddWithValue("@submission_date", DateTime.Now.Date);
                        cmd.ExecuteNonQuery();
                    }
                }
                MessagePanel.CssClass = "fixed top-20 left-1/2 transform -translate-x-1/2 z-50";
                MessageLabel.Text = "Your message has been sent!";
                MessagePanel.Visible = true;

                // Clear all fields
                FullName.Text = Email.Text = Message.Text = "";
                Subject.SelectedIndex = 0;
            }
            catch
            {
                MessagePanel.CssClass = "fixed top-20 left-1/2 transform -translate-x-1/2 z-50 bg-red-50 border border-red-200 text-red-800";
                MessageLabel.Text = "There was an error sending your message. Please try again.";
                MessagePanel.Visible = true;
            }
        }
    }
}