using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Reflection;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Hope
{
    public partial class admin_inquiry : System.Web.UI.Page
    {
        private int _totalRecords = 0;

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
                LoadInquiries();
                LoadInquiryStatistics();
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

        private void LoadInquiries()
        {
            try
            {
                List<Inquiry> inquiries = new List<Inquiry>();
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;

                string query = @"
                    SELECT inquiry_id, full_name, email_address, subject, message, 
                           inquiry_status, submission_date, admin_id
                    FROM [Inquiry]
                    ORDER BY submission_date DESC";

                // Apply filters
                query = ApplyFilters(query);

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            while (reader.Read())
                            {
                                if (reader["inquiry_id"] == DBNull.Value)
                                    continue;

                                inquiries.Add(new Inquiry
                                {
                                    InquiryId = Convert.ToInt32(reader["inquiry_id"]),
                                    FullName = reader["full_name"].ToString(),
                                    EmailAddress = reader["email_address"].ToString(),
                                    Subject = reader["subject"].ToString(),
                                    Message = reader["message"].ToString(),
                                    InquiryStatus = reader["inquiry_status"].ToString(),
                                    SubmissionDate = Convert.ToDateTime(reader["submission_date"]),
                                    AdminId = reader["admin_id"] == DBNull.Value ? (int?)null : Convert.ToInt32(reader["admin_id"])
                                });
                            }
                        }
                    }
                }

                _totalRecords = inquiries.Count;
                InquiriesGrid.DataSource = inquiries;
                InquiriesGrid.DataBind();
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading inquiries: {ex.Message}");
            }
        }

        private void LoadInquiryStatistics()
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
            SELECT 
                COUNT(*) as Total,
                SUM(CASE WHEN UPPER(LTRIM(RTRIM(inquiry_status))) = 'PENDING' THEN 1 ELSE 0 END) as Pending,
                SUM(CASE WHEN UPPER(LTRIM(RTRIM(inquiry_status))) = 'SOLVED' THEN 1 ELSE 0 END) as Solved
            FROM [Inquiry]";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                TotalInquiriesLabel.Text = reader["Total"].ToString();
                                PendingInquiriesLabel.Text = reader["Pending"].ToString();
                                SolvedInquiriesLabel.Text = reader["Solved"].ToString();

                                // Debug output to check values
                                System.Diagnostics.Debug.WriteLine($"Statistics - Total: {reader["Total"]}, Pending: {reader["Pending"]}, Solved: {reader["Solved"]}");
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading statistics: {ex.Message}");
            }
        }

        private string ApplyFilters(string baseQuery)
        {
            List<string> conditions = new List<string>();

            // Apply status filter
            if (StatusFilter?.SelectedValue != null && StatusFilter.SelectedValue != "all")
            {
                conditions.Add($"inquiry_status = '{StatusFilter.SelectedValue}'");
            }

            // Apply type filter
            if (TypeFilter?.SelectedValue != null && TypeFilter.SelectedValue != "all")
            {
                conditions.Add($"subject = '{TypeFilter.SelectedValue}'");
            }

            // Apply search filter
            if (!string.IsNullOrEmpty(SearchBox?.Text))
            {
                string searchText = SearchBox.Text.Replace("'", "''");
                conditions.Add($"(full_name LIKE '%{searchText}%' OR email_address LIKE '%{searchText}%' OR message LIKE '%{searchText}%')");
            }

            // Build the final query
            if (conditions.Count > 0)
            {
                string whereClause = "WHERE " + string.Join(" AND ", conditions);
                baseQuery = baseQuery.Replace("ORDER BY", whereClause + " ORDER BY");
            }

            System.Diagnostics.Debug.WriteLine($"Final Query: {baseQuery}");
            return baseQuery;
        }

        // Event Handlers
        protected void Filter_Changed(object sender, EventArgs e)
        {
            try
            {
                System.Diagnostics.Debug.WriteLine("Filter_Changed called");
                InquiriesGrid.PageIndex = 0;
                MessagePanel.Visible = false;
                LoadInquiries();
                LoadInquiryStatistics();
                InquiriesUpdatePanel.Update();
                System.Diagnostics.Debug.WriteLine("Filter_Changed completed successfully");
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error in Filter_Changed: {ex.Message}");
                ShowSuccessMessage($"Filter error: {ex.Message}");
            }
        }

        protected void InquiriesGrid_RowCommand(object sender, GridViewCommandEventArgs e)
        {
            if (!int.TryParse(e.CommandArgument?.ToString(), out int inquiryId))
            {
                System.Diagnostics.Debug.WriteLine($"Invalid CommandArgument: '{e.CommandArgument}' for CommandName: '{e.CommandName}'");
                return;
            }

            switch (e.CommandName)
            {
                case "ViewInquiry":
                    ShowInquiryModal(inquiryId);
                    break;
            }
        }

        protected void InquiriesGrid_PageIndexChanging(object sender, GridViewPageEventArgs e)
        {
            int newPageIndex = e.NewPageIndex;

            string eventArgument = Request.Form["__EVENTARGUMENT"];
            if (!string.IsNullOrEmpty(eventArgument) && int.TryParse(eventArgument, out int parsedPageIndex))
            {
                newPageIndex = parsedPageIndex;
            }

            if (newPageIndex >= 0 && newPageIndex < InquiriesGrid.PageCount)
            {
                InquiriesGrid.PageIndex = newPageIndex;
                LoadInquiries();
                InquiriesUpdatePanel.Update();
            }
            else
            {
                System.Diagnostics.Debug.WriteLine($"Invalid PageIndex: {newPageIndex}, PageCount: {InquiriesGrid.PageCount}");
                InquiriesGrid.PageIndex = 0;
                LoadInquiries();
                InquiriesUpdatePanel.Update();
            }
        }

        private void ShowInquiryModal(int inquiryId)
        {
            try
            {
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string query = @"
            SELECT inquiry_id, full_name, email_address, subject, message, 
                   inquiry_status, submission_date, admin_id
            FROM [Inquiry]
            WHERE inquiry_id = @inquiryId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(query, conn))
                    {
                        cmd.Parameters.AddWithValue("@inquiryId", inquiryId);
                        conn.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string fullName = reader["full_name"].ToString();
                                string emailAddress = reader["email_address"].ToString();
                                string subject = reader["subject"].ToString();
                                string message = reader["message"].ToString();
                                string inquiryStatus = reader["inquiry_status"].ToString();
                                DateTime submissionDate = Convert.ToDateTime(reader["submission_date"]);

                                InquiryIdHidden.Value = inquiryId.ToString();

                                string modalContent = $@"
                            <div class='space-y-6'>
                                <!-- Inquiry Header -->
                                <div class='border-b pb-4'>
                                    <div class='flex items-center justify-between mb-4'>
                                        <h3 class='text-xl font-semibold text-gray-800'>Inquiry #{inquiryId}</h3>
                                        <span class='{GetStatusBadgeClass(inquiryStatus)}'>{inquiryStatus}</span>
                                    </div>
                                    <div class='grid grid-cols-1 md:grid-cols-2 gap-4'>
                                        <div>
                                            <p class='text-sm text-gray-600'>From:</p>
                                            <p class='font-medium text-gray-800'>{fullName}</p>
                                            <p class='text-sm text-gray-600'>{emailAddress}</p>
                                        </div>
                                        <div>
                                            <p class='text-sm text-gray-600'>Type:</p>
                                            <p class='font-medium text-gray-800'>{subject}</p>
                                            <p class='text-sm text-gray-600'>Submitted: {submissionDate:MMM dd, yyyy}</p>
                                        </div>
                                    </div>
                                </div>

                                <!-- Message Content -->
                                <div>
                                    <h4 class='font-medium text-gray-800 mb-3'>Message:</h4>
                                    <div class='bg-gray-50 rounded-lg p-4'>
                                        <p class='text-gray-700 whitespace-pre-wrap'>{message}</p>
                                    </div>
                                </div>
                            </div>
                        ";

                                // Updated script with better error handling and re-registration
                                string script = $@"
                            try {{
                                document.getElementById('inquiry-modal-title').innerText = 'Inquiry Details';
                                document.getElementById('inquiry-modal-content').innerHTML = `{modalContent}`;
                                
                                // Show/hide solve button based on status
                                const solveBtn = document.getElementById('{SolveInquiryBtn.ClientID}');
                                if (solveBtn) {{
                                    if ('{inquiryStatus}' === 'Pending') {{
                                        solveBtn.style.display = 'inline-block';
                                    }} else {{
                                        solveBtn.style.display = 'none';
                                    }}
                                }}
                                
                                // Ensure modal functions are available
                                if (typeof showInquiryModal === 'function') {{
                                    showInquiryModal();
                                }} else {{
                                    // Fallback: show modal directly
                                    const modal = document.getElementById('inquiry-modal');
                                    if (modal) {{
                                        modal.classList.remove('hidden');
                                        document.body.style.overflow = 'hidden';
                                    }}
                                }}
                            }} catch (error) {{
                                console.error('Error showing modal:', error);
                                alert('Error opening inquiry details. Please try again.');
                            }}
                        ";

                                // Use a unique key for each script registration to prevent conflicts
                                ScriptManager.RegisterStartupScript(this, GetType(), "showInquiryModal_" + inquiryId, script, true);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error loading inquiry details: {ex.Message}");

                // Show error message to user
                string errorScript = "alert('Error loading inquiry details. Please try again.');";
                ScriptManager.RegisterStartupScript(this, GetType(), "modalError", errorScript, true);
            }
        }

        protected void SolveInquiry_Click(object sender, EventArgs e)
        {
            try
            {
                int inquiryId = Convert.ToInt32(InquiryIdHidden.Value);
                int adminId = Convert.ToInt32(Session["UserId"]);
             
                string connectionString = ConfigurationManager.ConnectionStrings["ConnectionString"].ConnectionString;
                string updateQuery = "UPDATE [Inquiry] SET inquiry_status = 'Solved', admin_id = @adminId WHERE inquiry_id = @inquiryId";

                using (SqlConnection conn = new SqlConnection(connectionString))
                {
                    using (SqlCommand cmd = new SqlCommand(updateQuery, conn))
                    {
                        cmd.Parameters.AddWithValue("@adminId", adminId);
                        cmd.Parameters.AddWithValue("@inquiryId", inquiryId);
                        conn.Open();
                        cmd.ExecuteNonQuery();
                    }
                }

                // Refresh data
                LoadInquiries();
                LoadInquiryStatistics();
                InquiriesUpdatePanel.Update();
                ShowSuccessMessage("Inquiry marked as solved successfully!");

                // Close modal
                ScriptManager.RegisterStartupScript(this, GetType(), "closeInquiryModal", "closeInquiryModal();", true);
            }
            catch (Exception ex)
            {
                System.Diagnostics.Debug.WriteLine($"Error solving inquiry: {ex.Message}");
                ShowSuccessMessage("Error updating inquiry status.");
            }
        }

        private void ShowSuccessMessage(string message)
        {
            MessageLabel.Text = message;
            MessagePanel.Visible = true;

            ScriptManager.RegisterStartupScript(this, GetType(), "hideMessage",
                "setTimeout(function() { closeMessage(); }, 5000);", true);
        }

        protected void AdminLogoutButton_Click(object sender, EventArgs e)
        {
            Response.Redirect("~/logout.aspx");
        }

        // Helper Methods
        protected string GetStatusBadgeClass(object status)
        {
            string statusText = status?.ToString().ToLower() ?? "";
            switch (statusText)
            {
                case "pending":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-yellow-100 text-yellow-800";
                case "solved":
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-green-100 text-green-800";
                default:
                    return "px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-gray-100 text-gray-800";
            }
        }

        protected string GetFormattedDate(object date)
        {
            if (date == null || date == DBNull.Value)
                return "N/A";

            DateTime submissionDate = Convert.ToDateTime(date);
            TimeSpan timeDiff = DateTime.Now - submissionDate;

            if (timeDiff.TotalDays < 1)
                return "Today";
            else if (timeDiff.TotalDays < 2)
                return "Yesterday";
            else if (timeDiff.TotalDays < 7)
                return $"{(int)timeDiff.TotalDays} days ago";
            else
                return submissionDate.ToString("MMM dd, yyyy");
        }

        // Pagination Methods
        protected string GetStartIndex()
        {
            int startIndex = (InquiriesGrid.PageIndex * InquiriesGrid.PageSize) + 1;
            return startIndex.ToString();
        }

        protected string GetEndIndex()
        {
            int endIndex = Math.Min((InquiriesGrid.PageIndex + 1) * InquiriesGrid.PageSize, _totalRecords);
            return endIndex.ToString();
        }

        protected int GetTotalRecords()
        {
            return _totalRecords;
        }

        protected string GeneratePaginationButtons()
        {
            if (InquiriesGrid.PageCount <= 1)
                return "";

            var buttons = new System.Text.StringBuilder();
            int currentPage = InquiriesGrid.PageIndex;
            int totalPages = InquiriesGrid.PageCount;

            int startPage = Math.Max(0, currentPage - 2);
            int endPage = Math.Min(totalPages - 1, currentPage + 2);

            if (endPage - startPage < 4)
            {
                if (startPage == 0)
                {
                    endPage = Math.Min(totalPages - 1, startPage + 4);
                }
                else if (endPage == totalPages - 1)
                {
                    startPage = Math.Max(0, endPage - 4);
                }
            }

            for (int i = startPage; i <= endPage; i++)
            {
                string cssClass = i == currentPage
                    ? "bg-blue-50 border-blue-500 text-blue-600 relative inline-flex items-center px-4 py-2 border text-sm font-medium"
                    : "bg-white border-gray-300 text-gray-500 hover:bg-gray-50 relative inline-flex items-center px-4 py-2 border text-sm font-medium";

                buttons.AppendFormat(
                    "<button type=\"button\" onclick=\"__doPostBack('{0}', 'Page${1}')\" class=\"{2}\">{3}</button>",
                    InquiriesGrid.UniqueID,
                    i + 1,
                    cssClass,
                    i + 1
                );
            }

            return buttons.ToString();
        }

        // Data Class
        public class Inquiry
        {
            public int InquiryId { get; set; }
            public string FullName { get; set; }
            public string EmailAddress { get; set; }
            public string Subject { get; set; }
            public string Message { get; set; }
            public string InquiryStatus { get; set; }
            public DateTime SubmissionDate { get; set; }
            public int? AdminId { get; set; }
        }
    }
}