<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="admin-user.aspx.cs" Inherits="Hope.admin_user" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- AJAX Loading Progress -->
    <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="UsersUpdatePanel">
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
            <a href="admin-event.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-calendar mr-3"></i>
                Event
            </a>
            <a href="admin-user.aspx" class="flex items-center px-4 py-3 text-white bg-blue-600">
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
                <h1 class="text-3xl font-bold text-gray-800">User Management</h1>
            </div>

            <!-- Users Section with UpdatePanel -->
            <asp:UpdatePanel ID="UsersUpdatePanel" runat="server" UpdateMode="Conditional">
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
                                    <asp:ListItem Value="active" Text="Active" />
                                    <asp:ListItem Value="inactive" Text="Inactive" />
                                    <asp:ListItem Value="blocked" Text="Blocked" />
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Role</label>
                                <asp:DropDownList ID="RoleFilter" runat="server" 
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                    OnSelectedIndexChanged="Filter_Changed" AutoPostBack="true">
                                    <asp:ListItem Value="all" Text="All" Selected="True" />
                                    <asp:ListItem Value="User" Text="User" />
                                    <asp:ListItem Value="Admin" Text="Admin" />
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Search</label>
                                <div class="relative">
                                    <asp:TextBox ID="SearchBox" runat="server" 
                                        placeholder="Search users..." 
                                        CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 pl-10"
                                        OnTextChanged="Filter_Changed" AutoPostBack="true" />
                                    <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Statistics Cards -->
                    <div class="grid md:grid-cols-4 gap-4 mb-6">
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-users text-3xl text-blue-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Total Users</h3>
                                    <p class="text-3xl font-bold text-blue-600">
                                        <asp:Label ID="TotalUsersLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-user-check text-3xl text-green-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Active Users</h3>
                                    <p class="text-3xl font-bold text-green-600">
                                        <asp:Label ID="ActiveUsersLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-user-clock text-3xl text-yellow-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Inactive Users</h3>
                                    <p class="text-3xl font-bold text-yellow-600">
                                        <asp:Label ID="InactiveUsersLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-user-times text-3xl text-red-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Blocked Users</h3>
                                    <p class="text-3xl font-bold text-red-600">
                                        <asp:Label ID="BlockedUsersLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Users Table -->
                    <div class="bg-white rounded-lg shadow overflow-hidden">
                        <div class="p-6 border-b">
                            <h3 class="text-xl font-bold text-gray-800">All Users</h3>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="UsersGrid" runat="server" 
                                CssClass="w-full" 
                                AutoGenerateColumns="false"
                                OnRowCommand="UsersGrid_RowCommand"
                                GridLines="None"
                                AllowPaging="true"
                                PageSize="10"
                                OnPageIndexChanging="UsersGrid_PageIndexChanging">
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
                                                    <%# GetUserProfileImageOrInitials(Eval("UserName"), Eval("ProfileImage")) %>
                                                    <div class="ml-3">
                                                        <div class="text-sm font-medium text-gray-900"><%# Eval("UserName") %></div>
                                                    </div>
                                                </div>
                                            </td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Email">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Email</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%# Eval("Email") %></td>
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

                                    <asp:TemplateField HeaderText="Role">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Role</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%# Eval("UserRole") %></td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Last Login">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Last Login</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%# GetFormattedLastLogin(Eval("LastLoginDate")) %></td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Actions">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                                                <asp:LinkButton ID="ViewUserButton" runat="server" 
                                                    CommandName="ViewUser" 
                                                    CommandArgument='<%# Eval("UserId") %>'
                                                    CssClass="text-blue-600 hover:text-blue-900">
                                                    <i class="fas fa-eye"></i> View
                                                </asp:LinkButton>
                                                
                                                <asp:LinkButton ID="BlockUnblockButton" runat="server" 
                                                    CommandName="ToggleUserStatus" 
                                                    CommandArgument='<%# Eval("UserId") %>'
                                                    CssClass='<%# GetBlockUnblockButtonClass(Eval("IsActivated")) %>'>
                                                    <%# GetBlockUnblockButtonText(Eval("IsActivated")) %>
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
                </ContentTemplate>
                <Triggers>
                    <asp:AsyncPostBackTrigger ControlID="StatusFilter" EventName="SelectedIndexChanged" />
                    <asp:AsyncPostBackTrigger ControlID="RoleFilter" EventName="SelectedIndexChanged" />
                    <asp:AsyncPostBackTrigger ControlID="SearchBox" EventName="TextChanged" />
                    <asp:AsyncPostBackTrigger ControlID="UsersGrid" EventName="PageIndexChanging" />
                    <asp:AsyncPostBackTrigger ControlID="UpdateEmailBtn" EventName="Click" />
                </Triggers>
            </asp:UpdatePanel>
        </div>
    </div>

    <!-- View User Modal -->
    <div id="view-modal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-xl max-w-4xl w-full max-h-screen overflow-y-auto">
                <div class="p-8">
                    <div class="flex justify-between items-center mb-8">
                        <h2 id="view-modal-title" class="text-3xl font-bold text-gray-800">User Details</h2>
                        <button type="button" onclick="closeViewModal()" class="text-gray-500 hover:text-gray-700 p-2" title="Close modal">
                            <i class="fas fa-times text-2xl"></i>
                        </button>
                    </div>

                    <!-- Success Message Panel for View Modal -->
                    <div id="view-modal-message-panel" class="bg-green-50 border border-green-200 text-green-800 px-6 py-4 rounded-lg shadow-sm mb-6 hidden">
                        <div class="flex items-center">
                            <i class="fas fa-check-circle text-green-600 mr-3"></i>
                            <span id="view-modal-message-text" class="font-medium"></span>
                            <button type="button" onclick="hideViewModalMessage()" class="ml-auto text-green-600 hover:text-green-800">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>

                    <div id="view-modal-content" class="space-y-8">
                        <!-- User content will be loaded here -->
                        <div class="animate-pulse">
                            <div class="grid grid-cols-1 lg:grid-cols-2 gap-8">
                                <div class="space-y-4">
                                    <div class="h-6 bg-gray-200 rounded w-3/4"></div>
                                    <div class="h-4 bg-gray-200 rounded w-1/2"></div>
                                    <div class="h-32 bg-gray-200 rounded"></div>
                                </div>
                                <div class="space-y-4">
                                    <div class="h-6 bg-gray-200 rounded w-2/3"></div>
                                    <div class="h-4 bg-gray-200 rounded w-3/4"></div>
                                    <div class="h-32 bg-gray-200 rounded"></div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Email Modal -->
    <div id="edit-email-modal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-xl max-w-md w-full">
                <div class="p-6">
                    <div class="flex justify-between items-center mb-6">
                        <h2 class="text-2xl font-bold text-gray-800">Edit Email Address</h2>
                        <button type="button" onclick="closeEditEmailModal()" class="text-gray-500 hover:text-gray-700" title="Close modal">
                            <i class="fas fa-times text-xl"></i>
                        </button>
                    </div>

                    <div class="space-y-6">
                        <!-- Error Message Panel -->
                        <div id="edit-email-error-panel" class="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg hidden">
                            <div class="flex items-center">
                                <i class="fas fa-exclamation-circle text-red-600 mr-3"></i>
                                <span id="edit-email-error-message" class="font-medium"></span>
                            </div>
                        </div>

                        <!-- User Info Display -->
                        <div class="bg-gray-50 p-4 rounded-lg">
                            <div class="text-center">
                                <h3 id="edit-email-user-name" class="font-semibold text-gray-900 text-lg"></h3>
                                <p class="text-sm text-gray-600 mt-1">Current Email:</p>
                                <p id="edit-email-current-email" class="text-sm text-gray-800 font-medium"></p>
                            </div>
                        </div>

                        <!-- New Email Input -->
                        <div>
                            <label for="new-email" class="block text-sm font-medium text-gray-700 mb-2">New Email Address *</label>
                            <asp:TextBox ID="NewEmailTextBox" runat="server" TextMode="Email"
                                placeholder="Enter new email address..."
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                MaxLength="100" 
                                required="true"></asp:TextBox>
                        </div>

                        <!-- Hidden field to store user ID -->
                        <asp:HiddenField ID="EditUserIdHidden" runat="server" />

                        <!-- Form Actions -->
                        <div class="flex space-x-4 pt-6">
                            <asp:Button ID="UpdateEmailBtn" runat="server" Text="Update Email" 
                                CssClass="flex-1 bg-blue-600 text-white py-3 px-4 rounded-lg hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-300"
                                OnClick="UpdateEmail_Click" />
                            <button type="button" onclick="closeEditEmailModal()" class="flex-1 bg-gray-300 text-gray-700 py-3 px-4 rounded-lg hover:bg-gray-400 transition duration-300">
                                Cancel
                            </button>
                        </div>
                    </div>
                </div>
            </div>
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

        // View Modal Functions
        function showViewModal() {
            document.getElementById('view-modal').classList.remove('hidden');
            document.body.style.overflow = 'hidden';
        }

        function closeViewModal() {
            document.getElementById('view-modal').classList.add('hidden');
            document.body.style.overflow = 'auto';
            // Hide message panel when closing modal
            hideViewModalMessage();
        }

        // View Modal Message Functions
        function showViewModalMessage(message) {
            console.log('Showing view modal message:', message);
            const messagePanel = document.getElementById('view-modal-message-panel');
            const messageText = document.getElementById('view-modal-message-text');

            if (messagePanel && messageText) {
                messageText.innerText = message;
                messagePanel.classList.remove('hidden');

                // Auto-hide after 5 seconds
                setTimeout(hideViewModalMessage, 5000);

                // Scroll to top of modal to show message
                const modal = document.getElementById('view-modal');
                if (modal) {
                    modal.scrollTop = 0;
                }
            }
        }

        function hideViewModalMessage() {
            const messagePanel = document.getElementById('view-modal-message-panel');
            if (messagePanel) {
                messagePanel.classList.add('hidden');
            }
        }

        // Edit Email Modal Functions
        function openEditEmailModal(userId, userName, currentEmail) {
            console.log('Opening edit email modal for:', userId, userName, currentEmail);

            // Set hidden field value
            const hiddenField = document.querySelector('[id*="EditUserIdHidden"]');
            if (hiddenField) {
                hiddenField.value = userId;
            }

            // Set user info in modal
            document.getElementById('edit-email-user-name').innerText = userName;
            document.getElementById('edit-email-current-email').innerText = currentEmail;

            // Clear previous input and errors
            const emailTextBox = document.querySelector('[id*="NewEmailTextBox"]');
            if (emailTextBox) {
                emailTextBox.value = '';
            }
            hideEditEmailError();

            // Show modal
            document.getElementById('edit-email-modal').classList.remove('hidden');
            document.body.style.overflow = 'hidden';

            // Focus on email input
            setTimeout(() => {
                if (emailTextBox) {
                    emailTextBox.focus();
                }
            }, 100);
        }

        function closeEditEmailModal() {
            document.getElementById('edit-email-modal').classList.add('hidden');
            document.body.style.overflow = 'auto';

            // Clear form and errors
            const emailTextBox = document.querySelector('[id*="NewEmailTextBox"]');
            if (emailTextBox) {
                emailTextBox.value = '';
            }
            hideEditEmailError();
        }

        // Edit Email Error Functions
        function showEditEmailError(message) {
            console.log('Showing edit email error:', message);
            const errorPanel = document.getElementById('edit-email-error-panel');
            const errorMessage = document.getElementById('edit-email-error-message');

            if (errorPanel && errorMessage) {
                errorMessage.innerText = message;
                errorPanel.classList.remove('hidden');

                // Scroll to top of modal to show error
                const modal = document.getElementById('edit-email-modal');
                if (modal) {
                    modal.scrollTop = 0;
                }
            }
        }

        function hideEditEmailError() {
            const errorPanel = document.getElementById('edit-email-error-panel');
            if (errorPanel) {
                errorPanel.classList.add('hidden');
            }
        }

        // Function to refresh view modal with updated email
        function refreshViewModalEmail(userId, newEmail) {
            // Find and update the email display in the view modal
            const viewModalContent = document.getElementById('view-modal-content');
            if (viewModalContent) {
                // Update the email in the contact information section
                const emailElements = viewModalContent.querySelectorAll('span');
                emailElements.forEach(element => {
                    if (element.textContent && element.textContent.includes('@')) {
                        element.textContent = newEmail;
                    }
                });
            }
        }

        // Real-time email validation
        document.addEventListener('DOMContentLoaded', function () {
            const emailTextBox = document.querySelector('[id*="NewEmailTextBox"]');
            if (emailTextBox) {
                emailTextBox.addEventListener('input', function () {
                    hideEditEmailError();
                });
            }
        });

        // Close modals when clicking outside
        window.onclick = function (event) {
            const viewModal = document.getElementById('view-modal');
            const editEmailModal = document.getElementById('edit-email-modal');

            if (event.target === viewModal) {
                closeViewModal();
            }
            if (event.target === editEmailModal) {
                closeEditEmailModal();
            }
        }
    </script>
</asp:Content>