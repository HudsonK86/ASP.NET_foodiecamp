<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="admin-event.aspx.cs" Inherits="Hope.admin_event" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- AJAX Loading Progress -->
    <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="EventsUpdatePanel">
        <ProgressTemplate>
            <div class="updateprogress">
                <div class="flex items-center">
                    <i class="fas fa-spinner fa-spin text-blue-600 mr-3"></i>
                    <span class="text-gray-700">Loading...</span>
                </div>
            </div>
        </ProgressTemplate>
    </asp:UpdateProgress>

    <!-- Admin Sidebar -->
    <div class="admin-sidebar bg-white shadow-lg fixed left-0 top-16 z-40">
        <div class="p-4 border-b">
            <div class="flex items-center">
                <asp:Image ID="AdminProfileImage" runat="server" 
                    ImageUrl="https://via.placeholder.com/80x80" 
                    AlternateText="Admin Profile"
                    CssClass="w-20 h-20 rounded-full mr-4 object-cover" />
                <div>
                    <asp:Label ID="AdminNameLabel" runat="server" 
                        Text="Admin" 
                        CssClass="text-lg font-bold text-gray-800 block"></asp:Label>
                    <span class="text-sm text-gray-600">Administrator</span>
                </div>
            </div>
        </div>
        <nav class="mt-4">
            <a href="admin-dashboard.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-tachometer-alt mr-3"></i>
                Dashboard
            </a>
            <a href="admin-cuisine.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-utensils mr-3"></i>
                Cuisine
            </a>
            <a href="admin-recipe.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-book mr-3"></i>
                Recipe
            </a>
            <a href="admin-review.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-star mr-3"></i>
                Review
            </a>
            <a href="admin-event.aspx" class="flex items-center px-4 py-3 text-white bg-blue-600">
                <i class="fas fa-calendar mr-3"></i>
                Event
            </a>
            <a href="admin-user.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-users mr-3"></i>
                User
            </a>
            <a href="admin-inquiry.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-envelope mr-3"></i>
                Inquiry
            </a>
            <a href="admin-profile.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-cog mr-3"></i>
                Profile
            </a>
        </nav>
        <div class="absolute bottom-4 left-4 right-4">
            <asp:LinkButton ID="AdminLogoutButton" runat="server" OnClick="AdminLogoutButton_Click"
                CssClass="flex items-center justify-center w-full px-4 py-3 text-white bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors">
                <i class="fas fa-sign-out-alt mr-2"></i>
                Logout
            </asp:LinkButton>
        </div>
    </div>

    <!-- Main Content -->
    <div class="admin-main-content bg-gray-50 min-h-screen">
        <div class="p-8">
            <!-- Mobile Menu Button -->
            <div class="md:hidden mb-4">
                <button onclick="toggleAdminSidebar()" class="bg-blue-600 text-white px-4 py-2 rounded-lg">
                    <i class="fas fa-bars mr-2"></i>Menu
                </button>
            </div>

            <!-- Header -->
            <div class="flex justify-between items-center mb-8">
                <h1 class="text-3xl font-bold text-gray-800">Manage Events</h1>
            </div>

            <!-- Events Section with UpdatePanel -->
            <asp:UpdatePanel ID="EventsUpdatePanel" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <!-- Success Message Panel -->
                    <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="fixed top-20 left-1/2 transform -translate-x-1/2 z-50">
                        <div class="bg-green-50 border border-green-200 text-green-800 px-6 py-4 rounded-lg shadow-lg max-w-md mx-auto">
                            <div class="flex items-center">
                                <i class="fas fa-check-circle text-green-600 mr-3"></i>
                                <asp:Label ID="MessageLabel" runat="server" CssClass="font-medium"></asp:Label>
                                <button type="button" onclick="closeMessage()" class="ml-4 text-green-600 hover:text-green-800">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        </div>
                    </asp:Panel>

                    <!-- Filter and Search -->
                    <div class="bg-white rounded-lg shadow p-6 mb-6">
                        <div class="grid md:grid-cols-3 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Status</label>
                                <asp:DropDownList ID="StatusFilter" runat="server" 
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                    OnSelectedIndexChanged="Filter_Changed" AutoPostBack="true">
                                    <asp:ListItem Value="all" Text="All" Selected="True" />
                                    <asp:ListItem Value="Pending" Text="Pending" />
                                    <asp:ListItem Value="Approved" Text="Approved" />
                                    <asp:ListItem Value="Rejected" Text="Rejected" />
                                    <asp:ListItem Value="Completed" Text="Completed" />
                                    <asp:ListItem Value="Expired" Text="Expired" />
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Date Range</label>
                                <asp:DropDownList ID="DateRangeFilter" runat="server" 
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                    OnSelectedIndexChanged="Filter_Changed" AutoPostBack="true">
                                    <asp:ListItem Value="all" Text="All" Selected="True" />
                                    <asp:ListItem Value="upcoming" Text="Upcoming" />
                                    <asp:ListItem Value="past" Text="Past" />
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Search</label>
                                <div class="relative">
                                    <asp:TextBox ID="SearchBox" runat="server" 
                                        placeholder="Search events..." 
                                        CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 pl-10"
                                        OnTextChanged="Filter_Changed" AutoPostBack="true" />
                                    <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Statistics Cards -->
                    <div class="grid md:grid-cols-6 gap-4 mb-6">
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-calendar text-3xl text-blue-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Total Events</h3>
                                    <p class="text-3xl font-bold text-blue-600">
                                        <asp:Label ID="TotalEventsLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-clock text-3xl text-yellow-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Pending</h3>
                                    <p class="text-3xl font-bold text-yellow-600">
                                        <asp:Label ID="PendingEventsLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-check text-3xl text-green-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Approved</h3>
                                    <p class="text-3xl font-bold text-green-600">
                                        <asp:Label ID="ApprovedEventsLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-times text-3xl text-red-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Rejected</h3>
                                    <p class="text-3xl font-bold text-red-600">
                                        <asp:Label ID="RejectedEventsLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-check-circle text-3xl text-blue-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Completed</h3>
                                    <p class="text-3xl font-bold text-blue-600">
                                        <asp:Label ID="CompletedEventsLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-clock text-3xl text-gray-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Expired</h3>
                                    <p class="text-3xl font-bold text-gray-600">
                                        <asp:Label ID="ExpiredEventsLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Events Table -->
                    <div class="bg-white rounded-lg shadow overflow-hidden">
                        <div class="p-6 border-b">
                            <h3 class="text-xl font-bold text-gray-800">User Events</h3>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="EventsGrid" runat="server" 
                                CssClass="w-full" 
                                AutoGenerateColumns="false"
                                OnRowCommand="EventsGrid_RowCommand"
                                GridLines="None"
                                AllowPaging="true"
                                PageSize="10"
                                OnPageIndexChanging="EventsGrid_PageIndexChanging">
                                <HeaderStyle CssClass="bg-gray-50" />
                                <RowStyle CssClass="bg-white divide-y divide-gray-200" />
                                <Columns>
                                    <asp:TemplateField HeaderText="Name">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Name</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <div class="flex items-center">
                                                    <img src='<%# GetEventImageUrl(Eval("EventImage")) %>' 
                                                         alt='<%# Eval("EventTitle") %>' 
                                                         class="w-12 h-12 rounded-lg mr-4"
                                                         onerror="this.src='https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=60&h=60&fit=crop';" />
                                                    <div>
                                                        <div class="text-sm font-medium text-gray-900"><%# Eval("EventTitle") %></div>
                                                    </div>
                                                </div>
                                            </td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Status">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <span class='<%# GetStatusBadgeClass(Eval("Status")) %>'>
                                                    <%# Eval("Status") %>
                                                </span>
                                            </td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Time">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Time</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%# Eval("DateRange") %></td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Upcoming/Past">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Upcoming/Past</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%# Eval("TimeCategory") %></td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Created By">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created By</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%# Eval("CreatedBy") %></td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Actions">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                                                <asp:LinkButton ID="ViewEventButton" runat="server" 
                                                    CommandName="ViewEvent" 
                                                    CommandArgument='<%# Eval("EventId") %>'
                                                    CssClass="text-blue-600 hover:text-blue-900">
                                                    <i class="fas fa-eye"></i> View
                                                </asp:LinkButton>
                                                
                                                <asp:LinkButton ID="ApproveButton" runat="server" 
                                                    CommandName="ApproveEvent" 
                                                    CommandArgument='<%# Eval("EventId") %>'
                                                    CssClass="text-green-600 hover:text-green-900"
                                                    Visible='<%# Eval("Status").ToString() == "Pending" %>'>
                                                    <i class="fas fa-check"></i> Approve
                                                </asp:LinkButton>
                                                
                                                <asp:LinkButton ID="RejectButton" runat="server" 
                                                    CommandName="RejectEvent" 
                                                    CommandArgument='<%# Eval("EventId") %>'
                                                    CssClass="text-red-600 hover:text-red-900"
                                                    Visible='<%# Eval("Status").ToString() == "Pending" %>'>
                                                    <i class="fas fa-times"></i> Reject
                                                </asp:LinkButton>
                                            </td>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                </Columns>

                                <PagerTemplate>
                                    <div class="bg-white px-4 py-3 flex items-center justify-between border-t border-gray-200">
                                        <div class="flex-1 flex justify-between sm:hidden">
                                            <asp:LinkButton ID="MobilePrevPage" runat="server" CommandName="Page" CommandArgument="Prev" 
                                                CssClass="relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
                                                Previous
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="MobileNextPage" runat="server" CommandName="Page" CommandArgument="Next" 
                                                CssClass="ml-3 relative inline-flex items-center px-4 py-2 border border-gray-300 text-sm font-medium rounded-md text-gray-700 bg-white hover:bg-gray-50">
                                                Next
                                            </asp:LinkButton>
                                        </div>
                                        <div class="hidden sm:flex-1 sm:flex sm:items-center sm:justify-between">
                                            <div>
                                                <p class="text-sm text-gray-700">
                                                    Showing 
                                                    <span class="font-medium"><%# GetStartIndex() %></span>
                                                    to 
                                                    <span class="font-medium"><%# GetEndIndex() %></span>
                                                    of 
                                                    <span class="font-medium"><%# GetTotalRecords() %></span>
                                                    results
                                                </p>
                                            </div>
                                            <div>
                                                <nav class="relative z-0 inline-flex rounded-md shadow-sm -space-x-px">
                                                    <asp:LinkButton ID="PrevPage" runat="server" CommandName="Page" CommandArgument="Prev" 
                                                        CssClass="relative inline-flex items-center px-2 py-2 rounded-l-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                                                        ToolTip="Previous page">
                                                        <i class="fas fa-chevron-left"></i>
                                                    </asp:LinkButton>
                                                    
                                                    <%# GeneratePaginationButtons() %>
                                                    
                                                    <asp:LinkButton ID="NextPage" runat="server" CommandName="Page" CommandArgument="Next" 
                                                        CssClass="relative inline-flex items-center px-2 py-2 rounded-r-md border border-gray-300 bg-white text-sm font-medium text-gray-500 hover:bg-gray-50"
                                                        ToolTip="Next page">
                                                        <i class="fas fa-chevron-right"></i>
                                                    </asp:LinkButton>
                                                </nav>
                                            </div>
                                        </div>
                                    </div>
                                </PagerTemplate>
                            </asp:GridView>
                        </div>
                    </div>

                    <!-- Reject Event Modal -->
                    <div id="reject-modal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
                        <div class="flex items-center justify-center min-h-screen p-4">
                            <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-screen overflow-y-auto">
                                <div class="p-6">
                                    <div class="flex justify-between items-center mb-6">
                                        <h2 id="reject-modal-title" class="text-2xl font-bold text-gray-800">Reject Event</h2>
                                        <button type="button" onclick="closeRejectModal()" class="text-gray-500 hover:text-gray-700" title="Close modal">
                                            <i class="fas fa-times text-xl"></i>
                                        </button>
                                    </div>

                                    <div class="space-y-6">
                                        <!-- Event Info Display -->
                                        <div id="reject-event-info" class="bg-gray-50 p-4 rounded-lg">
                                            <div class="flex items-center">
                                                <img id="reject-event-image" src="" alt="" class="w-16 h-16 rounded-lg mr-4">
                                                <div>
                                                    <h3 id="reject-event-name" class="font-semibold text-gray-900"></h3>
                                                    <p id="reject-event-author" class="text-sm text-gray-600"></p>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Rejection Reason -->
                                        <div>
                                            <label for="reject-reason" class="block text-sm font-medium text-gray-700 mb-2">Reason for Rejection *</label>
                                            <asp:Label ID="RejectReasonErrorLabel" runat="server" CssClass="text-red-600 text-sm mb-2" Visible="false"></asp:Label>
                                            <asp:TextBox ID="RejectReasonTextBox" runat="server" TextMode="MultiLine" Rows="4"
                                                placeholder="Please provide a detailed reason for rejecting this event..."
                                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"></asp:TextBox>
                                        </div>

                                        <!-- Common Rejection Reasons -->
                                        <div>
                                            <label class="block text-sm font-medium text-gray-700 mb-2">Quick Select Reasons</label>
                                            <div class="space-y-2">
                                                <label class="flex items-center">
                                                    <input type="checkbox" class="reason-checkbox mr-2" value="Incomplete event details">
                                                    <span class="text-sm text-gray-700">Incomplete event details</span>
                                                </label>
                                                <label class="flex items-center">
                                                    <input type="checkbox" class="reason-checkbox mr-2" value="Inappropriate content">
                                                    <span class="text-sm text-gray-700">Inappropriate content</span>
                                                </label>
                                                <label class="flex items-center">
                                                    <input type="checkbox" class="reason-checkbox mr-2" value="Invalid location">
                                                    <span class="text-sm text-gray-700">Invalid location</span>
                                                </label>
                                                <label class="flex items-center">
                                                    <input type="checkbox" class="reason-checkbox mr-2" value="Conflicting schedule">
                                                    <span class="text-sm text-gray-700">Conflicting schedule</span>
                                                </label>
                                                <label class="flex items-center">
                                                    <input type="checkbox" class="reason-checkbox mr-2" value="Duplicate event">
                                                    <span class="text-sm text-gray-700">Duplicate event</span>
                                                </label>
                                            </div>
                                        </div>

                                        <!-- Hidden field to store event ID -->
                                        <asp:HiddenField ID="RejectEventIdHidden" runat="server" />

                                        <!-- Form Actions -->
                                        <div class="flex space-x-4 pt-6">
                                            <asp:Button ID="ConfirmRejectBtn" runat="server" Text="Reject Event" 
                                                CssClass="flex-1 bg-red-600 text-white py-3 px-4 rounded-lg hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-red-500 transition duration-300"
                                                OnClick="ConfirmReject_Click" />
                                            <button type="button" onclick="closeRejectModal()" class="flex-1 bg-gray-300 text-gray-700 py-3 px-4 rounded-lg hover:bg-gray-400 transition duration-300">
                                                Cancel
                                            </button>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </ContentTemplate>
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="StatusFilter" EventName="SelectedIndexChanged" />
                    <asp:AsyncPostBackTrigger ControlID="DateRangeFilter" EventName="SelectedIndexChanged" />
                    <asp:AsyncPostBackTrigger ControlID="SearchBox" EventName="TextChanged" />
                    <asp:AsyncPostBackTrigger ControlID="EventsGrid" EventName="PageIndexChanging" />
                    <asp:AsyncPostBackTrigger ControlID="ConfirmRejectBtn" EventName="Click" />
                </Triggers>
            </asp:UpdatePanel>
        </div>
    </div>

    <script>
        function toggleAdminSidebar() {
            const sidebar = document.querySelector('.admin-sidebar');
            sidebar.classList.toggle('mobile-open');
        }

        function closeMessage() {
            const messagePanel = document.querySelector('[id*="MessagePanel"]');
            if (messagePanel) {
                messagePanel.style.display = 'none';
            }
        }

        // Reject Modal Functions
        function showRejectModal() {
            document.getElementById('reject-modal').classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeRejectModal() {
            document.getElementById('reject-modal').classList.add('hidden');
            document.body.style.overflow = 'auto';

            // Clear form
            const textArea = document.querySelector('[id*="RejectReasonTextBox"]');
            if (textArea) textArea.value = '';

            // Uncheck all checkboxes
            document.querySelectorAll('.reason-checkbox').forEach(checkbox => {
                checkbox.checked = false;
            });
        }

        // Handle quick select reasons
        document.addEventListener('DOMContentLoaded', function () {
            document.querySelectorAll('.reason-checkbox').forEach(checkbox => {
                checkbox.addEventListener('change', function () {
                    const textArea = document.querySelector('[id*="RejectReasonTextBox"]');
                    if (textArea) {
                        const checkedReasons = Array.from(document.querySelectorAll('.reason-checkbox:checked'))
                            .map(cb => cb.value);

                        if (checkedReasons.length > 0) {
                            textArea.value = checkedReasons.join(', ') + '. ';
                        }
                    }
                });
            });
        });

        // Close modal when clicking outside
        window.onclick = function (event) {
            const modal = document.getElementById('reject-modal');
            if (event.target === modal) {
                closeRejectModal();
            }
        }

        function bindReasonCheckboxHandlers() {
            document.querySelectorAll('.reason-checkbox').forEach(checkbox => {
                // Remove previous handler to avoid duplicates
                checkbox.onchange = null;
                checkbox.addEventListener('change', function () {
                    const textArea = document.querySelector('[id*="RejectReasonTextBox"]');
                    if (textArea) {
                        const checkedReasons = Array.from(document.querySelectorAll('.reason-checkbox:checked'))
                            .map(cb => cb.value);

                        if (checkedReasons.length > 0) {
                            textArea.value = checkedReasons.join(', ') + '. ';
                        } else {
                            textArea.value = '';
                        }
                    }
                });
            });
        }

        document.addEventListener('DOMContentLoaded', bindReasonCheckboxHandlers);

        if (window.Sys && Sys.WebForms && Sys.WebForms.PageRequestManager) {
            Sys.WebForms.PageRequestManager.getInstance().add_endRequest(bindReasonCheckboxHandlers);
        }
    </script>
</asp:Content>