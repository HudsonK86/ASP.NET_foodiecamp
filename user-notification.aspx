<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="user-notification.aspx.cs" Inherits="Hope.user_notification" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- User Sidebar (reuse from user-recipe.aspx) -->
    <div class="admin-sidebar bg-white shadow-lg fixed left-0 top-16 z-40">
        <div class="p-4 border-b">
            <div class="flex items-center">
                <asp:Image ID="UserProfileImage" runat="server"
                    ImageUrl="https://via.placeholder.com/80x80"
                    AlternateText="User Profile"
                    CssClass="w-20 h-20 rounded-full mr-4 object-cover" />
                <div>
                    <asp:Label ID="UserNameLabel" runat="server"
                        Text="User"
                        CssClass="text-lg font-bold text-gray-800 block"></asp:Label>
                    <span class="text-sm text-gray-600">User</span>
                </div>
            </div>
        </div>
        <nav class="mt-4">
            <a href="user-dashboard.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-tachometer-alt mr-3"></i>
                Dashboard
            </a>
            <a href="user-recipe.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-book mr-3"></i>
                My Recipe
            </a>
            <a href="user-bookmark.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-bookmark mr-3"></i>
                My Bookmark
            </a>
            <a href="user-event.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-calendar mr-3"></i>
                My Event
            </a>
            <a href="user-register-event.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-calendar-check mr-3"></i>
                Event Registration
            </a>
            <a href="user-notification.aspx" class="flex items-center px-4 py-3 text-white bg-blue-600">
                <i class="fas fa-bell mr-3"></i>
                Notification
            </a>
            <a href="user-profile.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-cog mr-3"></i>
                Profile
            </a>
        </nav>
        <div class="absolute bottom-4 left-4 right-4">
            <asp:LinkButton ID="UserLogoutButton" runat="server" OnClick="UserLogoutButton_Click"
                CssClass="flex items-center justify-center w-full px-4 py-3 text-white bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors">
                <i class="fas fa-sign-out-alt mr-2"></i>
                Logout
            </asp:LinkButton>
        </div>
    </div>

    <div class="admin-main-content bg-gray-50 min-h-screen flex flex-col">
        <div class="p-8 flex flex-col flex-1">
            <h1 class="text-3xl font-bold text-gray-800 mb-8">Notifications</h1>

            <!-- Filter and Search -->
            <div class="bg-white rounded-lg shadow-md p-6 mb-8">
                <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div>
                        <label for="ReadFilter" class="block text-sm font-medium text-gray-700 mb-2">Read Status</label>
                        <asp:DropDownList ID="ReadFilter" runat="server"
                            CssClass="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                            AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                            <asp:ListItem Value="all" Text="All" Selected="True" />
                            <asp:ListItem Value="read" Text="Read" />
                            <asp:ListItem Value="unread" Text="Unread" />
                        </asp:DropDownList>
                    </div>
                    <div>
                        <label for="TypeFilter" class="block text-sm font-medium text-gray-700 mb-2">Type</label>
                        <asp:DropDownList ID="TypeFilter" runat="server"
                            CssClass="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                            AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                            <asp:ListItem Value="all" Text="All" Selected="True" />
                            <asp:ListItem Value="recipe" Text="Recipe" />
                            <asp:ListItem Value="event" Text="Event" />
                        </asp:DropDownList>
                    </div>
                    <div class="md:col-span-2">
                        <label for="SearchBox" class="block text-sm font-medium text-gray-700 mb-2">Search Notifications</label>
                        <div class="relative">
                            <asp:TextBox ID="SearchBox" runat="server"
                                CssClass="w-full p-3 pl-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                placeholder="Search by message..."
                                AutoPostBack="true" OnTextChanged="Filter_Changed" />
                            <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Notification List -->
            <div class="flex-1 flex flex-col">
                <asp:Repeater ID="NotificationRepeater" runat="server" OnItemCommand="NotificationRepeater_ItemCommand">
                    <HeaderTemplate>
                        <div class="divide-y divide-gray-200" id="notification-list">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="flex items-center justify-between py-4 px-2 bg-white hover:bg-blue-50 transition-colors">
                            <div class="flex-1">
                                <div class="flex items-center space-x-2">
                                    <span class='<%# (bool)Eval("IsRead") ? "bg-gray-300 text-gray-700" : "bg-blue-500 text-white" %> px-2 py-1 rounded-full text-xs font-medium'>
                                        <%# (bool)Eval("IsRead") ? "Read" : "Unread" %>
                                    </span>
                                    <span class='px-2 py-1 rounded-full text-xs font-medium <%# GetTypeBadgeClass(Eval("NotificationType")) %>'>
                                        <%# Eval("NotificationType") %>
                                    </span>
                                    <span class="text-xs text-gray-500"><%# Eval("NotificationDate", "{0:MMM dd, yyyy}") %></span>
                                </div>
                                <div class="mt-2 text-gray-800 font-medium"><%# Eval("NotificationMessage") %></div>
                            </div>
                            <div class="flex space-x-2 ml-4">
                                <asp:LinkButton runat="server"
                                    CommandName="View"
                                    CommandArgument='<%# Eval("NotificationId") %>'
                                    CssClass="bg-blue-600 hover:bg-blue-700 text-white text-sm py-2 px-3 rounded-lg transition-colors flex items-center justify-center">
                                    View
                                </asp:LinkButton>
                                <asp:LinkButton runat="server"
                                    CommandName="MarkRead"
                                    CommandArgument='<%# Eval("NotificationId") %>'
                                    Visible='<%# !(bool)Eval("IsRead") %>'
                                    CssClass="bg-green-600 hover:bg-green-700 text-white text-sm py-2 px-3 rounded-lg transition-colors flex items-center justify-center"
                                    CausesValidation="false">
                                    Mark as Read
                                </asp:LinkButton>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>
            </div>
        </div>

        <!-- Paging Controls -->
        <asp:Panel ID="PaginationPanel" runat="server" CssClass="flex justify-center items-center space-x-2 mt-8 mb-12" Visible="false">
            <asp:Button ID="PrevPageButton" runat="server" Text="Previous" CssClass="px-4 py-2 bg-gray-300 rounded" OnClick="PrevPageButton_Click" />
            <asp:Repeater ID="PageNumbersRepeater" runat="server" OnItemCommand="PageNumbersRepeater_ItemCommand">
                <ItemTemplate>
                    <asp:LinkButton runat="server"
                        CommandName="Page"
                        CommandArgument='<%# Container.DataItem %>'
                        Text='<%# (int)Container.DataItem + 1 %>'
                        CssClass='<%# (int)Container.DataItem == ((Hope.user_notification)Page).PageIndex ? "bg-blue-600 text-white px-3 py-1 rounded" : "bg-gray-200 text-gray-700 px-3 py-1 rounded" %>' />
                </ItemTemplate>
            </asp:Repeater>
            <asp:Button ID="NextPageButton" runat="server" Text="Next" CssClass="px-4 py-2 bg-gray-300 rounded" OnClick="NextPageButton_Click" />
        </asp:Panel>
    </div>
</asp:Content>
