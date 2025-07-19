using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class post_event : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                // Only allow logged in users (admin or organizer)
                if (Session["UserId"] == null)
                {
                    Response.Redirect("~/login.aspx");
                    return;
                }

                // Populate Event Type dropdown (6 options)
                EventType.Items.Clear();
                EventType.Items.Add(new ListItem("Select Event Type", ""));
                EventType.Items.Add(new ListItem("Taste Event", "Taste Event"));
                EventType.Items.Add(new ListItem("Cooking Competition", "Cooking Competition"));
                EventType.Items.Add(new ListItem("Food Festival", "Food Festival"));
                EventType.Items.Add(new ListItem("Live Cooking Show", "Live Cooking Show"));
                EventType.Items.Add(new ListItem("Street Food Fair", "Street Food Fair"));
                EventType.Items.Add(new ListItem("Other", "Other"));

                // Populate Cuisine Type dropdown (example 6 options)
                CuisineType.Items.Clear();
                CuisineType.Items.Add(new ListItem("Select Cuisine Type", ""));
                CuisineType.Items.Add(new ListItem("Chinese", "Chinese"));
                CuisineType.Items.Add(new ListItem("Malaysian", "Malaysian"));
                CuisineType.Items.Add(new ListItem("Indian", "Indian"));
                CuisineType.Items.Add(new ListItem("Western", "Western"));
                CuisineType.Items.Add(new ListItem("Vietnamese", "Vietnamese"));
                CuisineType.Items.Add(new ListItem("Other", "Other"));
            }
        }

        protected void PostEventBtn_Click(object sender, EventArgs e)
        {
            ErrorPanel.Visible = false;
            MessagePanel.Visible = false;

            if (!Page.IsValid)
                return;

            // Validate file upload
            if (!EventImage.HasFile)
            {
                ErrorPanel.Visible = true;
                ErrorLabel.Text = "Event image is required.";
                return;
            }

            string fileExt = Path.GetExtension(EventImage.FileName).ToLower();
            if (fileExt != ".jpg" && fileExt != ".jpeg" && fileExt != ".png" && fileExt != ".gif")
            {
                ErrorPanel.Visible = true;
                ErrorLabel.Text = "Only JPG, JPEG, PNG, or GIF images are allowed.";
                return;
            }

            // Parse dates and times
            DateTime startDate, endDate;
            TimeSpan startTime, endTime;
            try
            {
                startDate = DateTime.Parse(StartDate.Text);
                endDate = DateTime.Parse(EndDate.Text);
                startTime = TimeSpan.Parse(StartTime.Text);
                endTime = TimeSpan.Parse(EndTime.Text);
            }
            catch
            {
                ErrorPanel.Visible = true;
                ErrorLabel.Text = "Please enter valid dates and times.";
                return;
            }

            // Validate date and time logic
            if (endDate < startDate || (endDate == startDate && endTime <= startTime))
            {
                ErrorPanel.Visible = true;
                ErrorLabel.Text = "End date/time must be after start date/time.";
                return;
            }

            // Save image
            string imageName = Guid.NewGuid().ToString("N") + fileExt;
            string imagePath = Server.MapPath("~/images/events/" + imageName);
            EventImage.SaveAs(imagePath);

            // Get user id
            int userId = Convert.ToInt32(Session["UserId"]);

            // Prepare data
            string eventTitle = EventTitle.Text.Trim();
            string eventDescription = EventDescription.Text.Trim();
            string eventType = EventType.SelectedValue;
            string cuisineType = CuisineType.SelectedValue;
            int maxParticipant = int.Parse(MaxParticipant.Text);
            string location = Location.Text.Trim();
            string learningObjective = LearningObjectives.Text.Trim();
            string includedItem = IncludedItems.Text.Trim();
            string requirement = Requirements.Text.Trim();

            // Insert into DB
            string cs = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
            using (var conn = new SqlConnection(cs))
            {
                conn.Open();
                string sql = @"
                    INSERT INTO Event
                    (user_id, event_title, event_description, event_image, event_type, cuisine_type, start_date, end_date, start_time, end_time, max_participant, location, learning_objective, included_item, requirement, event_status)
                    VALUES
                    (@user_id, @event_title, @event_description, @event_image, @event_type, @cuisine_type, @start_date, @end_date, @start_time, @end_time, @max_participant, @location, @learning_objective, @included_item, @requirement, 'Pending')";
                using (var cmd = new SqlCommand(sql, conn))
                {
                    cmd.Parameters.AddWithValue("@user_id", userId);
                    cmd.Parameters.AddWithValue("@event_title", eventTitle);
                    cmd.Parameters.AddWithValue("@event_description", eventDescription);
                    cmd.Parameters.AddWithValue("@event_image", imageName);
                    cmd.Parameters.AddWithValue("@event_type", eventType);
                    cmd.Parameters.AddWithValue("@cuisine_type", cuisineType);
                    cmd.Parameters.AddWithValue("@start_date", startDate);
                    cmd.Parameters.AddWithValue("@end_date", endDate);
                    cmd.Parameters.AddWithValue("@start_time", startTime);
                    cmd.Parameters.AddWithValue("@end_time", endTime);
                    cmd.Parameters.AddWithValue("@max_participant", maxParticipant);
                    cmd.Parameters.AddWithValue("@location", location);
                    cmd.Parameters.AddWithValue("@learning_objective", learningObjective);
                    cmd.Parameters.AddWithValue("@included_item", includedItem);
                    cmd.Parameters.AddWithValue("@requirement", requirement);
                    cmd.ExecuteNonQuery();
                }
            }

            MessagePanel.Visible = true;
            MessageLabel.Text = "Event submitted successfully! It will be reviewed by an admin before publishing.";
            FormPanel.Visible = false;
        }

        protected void CancelBtn_Click(object sender, EventArgs e)
        {
            Response.Redirect("user-event.aspx");
        }
    }
}