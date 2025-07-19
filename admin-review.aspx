<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="admin-review.aspx.cs" Inherits="Hope.admin_review" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- AJAX Loading Progress -->
    <asp:UpdateProgress ID="UpdateProgress1" runat="server" AssociatedUpdatePanelID="ReviewsUpdatePanel">
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
            <a href="admin-review.aspx" class="flex items-center px-4 py-3 text-white bg-blue-600">
                <i class="fas fa-star mr-3"></i>
                Review
            </a>
            <a href="admin-event.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
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
                <h1 class="text-3xl font-bold text-gray-800">Manage Reviews</h1>
            </div>

            <!-- Reviews Section with UpdatePanel -->
            <asp:UpdatePanel ID="ReviewsUpdatePanel" runat="server" UpdateMode="Conditional">
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
                        <div class="grid md:grid-cols-4 gap-4">
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Rating</label>
                                <asp:DropDownList ID="RatingFilter" runat="server" 
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                    OnSelectedIndexChanged="Filter_Changed" AutoPostBack="true">
                                    <asp:ListItem Value="all" Text="All Ratings" Selected="True" />
                                    <asp:ListItem Value="5" Text="5 Stars" />
                                    <asp:ListItem Value="4" Text="4 Stars" />
                                    <asp:ListItem Value="3" Text="3 Stars" />
                                    <asp:ListItem Value="2" Text="2 Stars" />
                                    <asp:ListItem Value="1" Text="1 Star" />
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Visibility</label>
                                <asp:DropDownList ID="VisibilityFilter" runat="server" 
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                    OnSelectedIndexChanged="Filter_Changed" AutoPostBack="true">
                                    <asp:ListItem Value="all" Text="All" Selected="True" />
                                    <asp:ListItem Value="show" Text="Show" />
                                    <asp:ListItem Value="hide" Text="Hide" />
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Cuisine</label>
                                <asp:DropDownList ID="CuisineFilter" runat="server" 
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                    OnSelectedIndexChanged="Filter_Changed" AutoPostBack="true">
                                    <asp:ListItem Value="all" Text="All Cuisines" Selected="True" />
                                </asp:DropDownList>
                            </div>
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Search</label>
                                <div class="relative">
                                    <asp:TextBox ID="SearchBox" runat="server" 
                                        placeholder="Search reviews..." 
                                        CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500 pl-10"
                                        OnTextChanged="Filter_Changed" AutoPostBack="true" />
                                    <i class="fas fa-search absolute left-3 top-3 text-gray-400"></i>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Statistics Cards -->
                    <div class="grid md:grid-cols-5 gap-4 mb-6">
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-star text-3xl text-blue-600 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">Total Reviews</h3>
                                    <p class="text-3xl font-bold text-blue-600">
                                        <asp:Label ID="TotalReviewsLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-star text-3xl text-yellow-500 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">5 Stars</h3>
                                    <p class="text-3xl font-bold text-yellow-500">
                                        <asp:Label ID="FiveStarLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-star text-3xl text-yellow-400 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">4 Stars</h3>
                                    <p class="text-3xl font-bold text-yellow-400">
                                        <asp:Label ID="FourStarLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-star text-3xl text-orange-400 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">3 Stars</h3>
                                    <p class="text-3xl font-bold text-orange-400">
                                        <asp:Label ID="ThreeStarLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                        <div class="bg-white rounded-lg shadow p-6">
                            <div class="flex items-center">
                                <i class="fas fa-star text-3xl text-red-400 mr-4"></i>
                                <div>
                                    <h3 class="text-lg font-semibold text-gray-800">≤2 Stars</h3>
                                    <p class="text-3xl font-bold text-red-400">
                                        <asp:Label ID="LowStarLabel" runat="server" Text="0"></asp:Label>
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Reviews Table -->
                    <div class="bg-white rounded-lg shadow overflow-hidden">
                        <div class="p-6 border-b">
                            <h3 class="text-xl font-bold text-gray-800">Reviews</h3>
                        </div>
                        <div class="overflow-x-auto">
                            <asp:GridView ID="ReviewsGrid" runat="server" 
                                CssClass="w-full" 
                                AutoGenerateColumns="false"
                                OnRowCommand="ReviewsGrid_RowCommand"
                                GridLines="None"
                                AllowPaging="true"
                                PageSize="10"
                                OnPageIndexChanging="ReviewsGrid_PageIndexChanging">
                                <HeaderStyle CssClass="bg-gray-50" />
                                <RowStyle CssClass="bg-white divide-y divide-gray-200" />
                                <Columns>
                                    <asp:TemplateField HeaderText="User">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">User</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <div class="flex items-center">
                                                    <%# GetUserProfileImageOrInitials(Eval("UserName"), Eval("UserProfileImage")) %>
                                                    <div class="ml-3">
                                                        <div class="text-sm font-medium text-gray-900"><%# Eval("UserName") %></div>
                                                    </div>
                                                </div>
                                            </td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Recipe">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Recipe</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <div class="text-sm text-gray-900"><%# Eval("RecipeName") %></div>
                                                <div class="text-xs text-gray-500"><%# Eval("CuisineName") %></div>
                                            </td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Rating">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Rating</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <div class="flex items-center">
                                                    <span class="text-yellow-400 text-lg mr-2"><%# GetStarRating(Eval("ReviewRating")) %></span>
                                                    <span class="text-sm text-gray-600"><%# Eval("ReviewRating") %>.0</span>
                                                </div>
                                            </td>
                                        </ItemTemplate>
                                    </asp:TemplateField>
                                 
                                    <asp:TemplateField HeaderText="Visibility">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Visibility</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap">
                                                <span class='<%# GetVisibilityBadgeClass(Eval("ReviewVisibility")) %>'>
                                                    <%# GetVisibilityText(Eval("ReviewVisibility")) %>
                                                </span>
                                            </td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Date">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Date</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900"><%# Eval("ReviewDate", "{0:MMM dd, yyyy}") %></td>
                                        </ItemTemplate>
                                    </asp:TemplateField>

                                    <asp:TemplateField HeaderText="Actions">
                                        <HeaderTemplate>
                                            <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
                                        </HeaderTemplate>
                                        <ItemTemplate>
                                            <td class="px-6 py-4 whitespace-nowrap text-sm font-medium space-x-2">
                                                <asp:LinkButton ID="ViewButton" runat="server" 
                                                    CommandName="ViewReview" 
                                                    CommandArgument='<%# Eval("ReviewId") %>'
                                                    CssClass="text-blue-600 hover:text-blue-900">
                                                    <i class="fas fa-eye"></i> View
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="ToggleVisibilityButton" runat="server" 
                                                    CommandName="ToggleVisibility" 
                                                    CommandArgument='<%# Eval("ReviewId") %>'
                                                    CssClass="text-gray-600 hover:text-gray-900">
                                                    <%# GetToggleVisibilityText(Eval("ReviewVisibility")) %>
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
                    <asp:AsyncPostBackTrigger ControlID="RatingFilter" EventName="SelectedIndexChanged" />
                    <asp:AsyncPostBackTrigger ControlID="VisibilityFilter" EventName="SelectedIndexChanged" />
                    <asp:AsyncPostBackTrigger ControlID="CuisineFilter" EventName="SelectedIndexChanged" />
                    <asp:AsyncPostBackTrigger ControlID="SearchBox" EventName="TextChanged" />
                    <asp:AsyncPostBackTrigger ControlID="ReviewsGrid" EventName="PageIndexChanging" />
                </Triggers>
            </asp:UpdatePanel>
        </div>
    </div>

    <!-- Review Details Modal -->
    <div id="review-modal" class="fixed inset-0 bg-black bg-opacity-50 hidden z-50">
        <div class="flex items-center justify-center min-h-screen p-4">
            <div class="bg-white rounded-lg shadow-xl max-w-2xl w-full max-h-screen overflow-y-auto">
                <div class="p-6">
                    <div class="flex justify-between items-center mb-6">
                        <h2 id="review-modal-title" class="text-2xl font-bold text-gray-800">Review Details</h2>
                        <button type="button" onclick="closeReviewModal(event); return false;" class="text-gray-500 hover:text-gray-700" title="Close modal">
                            <i class="fas fa-times text-xl"></i>
                        </button>
                    </div>

                    <div id="review-modal-content" class="space-y-6">
                        <!-- Review content will be loaded here -->
                        <div class="animate-pulse">
                            <div class="h-4 bg-gray-200 rounded w-3/4 mb-2"></div>
                            <div class="h-4 bg-gray-200 rounded w-1/2 mb-2"></div>
                            <div class="h-32 bg-gray-200 rounded mb-4"></div>
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

                // Also update the server-side control state to prevent re-showing
                var hiddenField = document.createElement('input');
                hiddenField.type = 'hidden';
                hiddenField.name = 'hideMessage';
                hiddenField.value = 'true';
                document.forms[0].appendChild(hiddenField);
            }

            // Review Modal Functions
            function showReviewModal() {
                document.getElementById('review-modal').classList.remove('hidden');
                document.body.style.overflow = 'hidden';
            }

            function closeReviewModal(event) {
                // Prevent any default behavior and event bubbling
                if (event) {
                    event.preventDefault();
                    event.stopPropagation();
                }

                document.getElementById('review-modal').classList.add('hidden');
                document.body.style.overflow = 'auto';

                // Return false to prevent any form submission or page reload
                return false;
            }

            // Close modal when clicking outside
            window.onclick = function (event) {
                const modal = document.getElementById('review-modal');
                if (event.target === modal) {
                    closeReviewModal(event);
                }
            }

            // Handle page reload to hide message panel
            window.addEventListener('beforeunload', function () {
                closeMessage();
            });

            // Prevent form submission on Enter key in modal
            document.addEventListener('DOMContentLoaded', function () {
                const modal = document.getElementById('review-modal');
                if (modal) {
                    modal.addEventListener('keydown', function (event) {
                        if (event.key === 'Enter') {
                            event.preventDefault();
                            return false;
                        }
                    });
                }
            });
    </script>
</asp:Content>