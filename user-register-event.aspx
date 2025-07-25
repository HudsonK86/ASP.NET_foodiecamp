﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="user-register-event.aspx.cs" Inherits="Hope.user_register_event" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- User Sidebar (reuse from user-event.aspx) -->
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
            <a href="user-register-event.aspx" class="flex items-center px-4 py-3 text-white bg-blue-600">
                <i class="fas fa-calendar-check mr-3"></i>
                Event Registration
            </a>
            <a href="user-notification.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
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
        <div class="p-8 flex flex-col flex-1">
            <h1 class="text-3xl font-bold text-gray-800 mb-8">Registered Events</h1>

            <!-- Filter and Search -->
            <div class="bg-white rounded-lg shadow-md p-6 mb-8">
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                    <div>
                        <label for="TimeFilter" class="block text-sm font-medium text-gray-700 mb-2">Time</label>
                        <asp:DropDownList ID="TimeFilter" runat="server"
                            CssClass="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                            AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                            <asp:ListItem Value="all" Text="All" Selected="True" />
                            <asp:ListItem Value="upcoming" Text="Upcoming" />
                            <asp:ListItem Value="past" Text="Past" />
                        </asp:DropDownList>
                    </div>
                    <div class="md:col-span-2">
                        <label for="SearchBox" class="block text-sm font-medium text-gray-700 mb-2">Search Events</label>
                        <div class="relative">
                            <asp:TextBox ID="SearchBox" runat="server"
                                CssClass="w-full p-3 pl-10 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                placeholder="Search by event name..."
                                AutoPostBack="true" OnTextChanged="Filter_Changed" />
                            <i class="fas fa-search absolute left-3 top-1/2 transform -translate-y-1/2 text-gray-400"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Events Grid -->
            <div class="flex-1 flex flex-col">
                <asp:Repeater ID="EventsRepeater" runat="server" OnItemCommand="EventsRepeater_ItemCommand">
                    <HeaderTemplate>
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" id="events-grid">
                    </HeaderTemplate>
                    <ItemTemplate>
    <div class="bg-white rounded-lg shadow-md overflow-hidden event-card mb-4 flex flex-col h-full" style="min-height: 400px;">
        <div class="relative">
            <img src='<%# Eval("EventImageUrl") %>' alt='<%# Eval("EventTitle") %>' class="w-full h-48 object-cover" />
            <span class='<%# Eval("TimeBadgeClass") %> absolute top-2 right-2 px-2 py-1 rounded-full text-xs font-medium'>
                <%# Eval("TimeLabel") %>
            </span>
        </div>
        <div class="p-4 flex flex-col flex-1">
            <h3 class="event-title text-xl font-semibold text-gray-800 mb-3"><%# Eval("EventTitle") %></h3>
            <div class="event-details space-y-2 text-sm mb-4">
                <p class="event-date text-gray-600">
                    <i class="fas fa-calendar mr-2 text-blue-600"></i>
                    <span class="date-value"><%# Eval("DateRange") %></span>
                </p>
                <p class="event-time text-gray-600">
                    <i class="fas fa-clock mr-2 text-blue-600"></i>
                    <span class="time-value"><%# Eval("TimeRange") %></span>
                </p>
                <p class="event-chef text-gray-600">
                    <i class="fas fa-user mr-2 text-blue-600"></i>
                    <span class="chef-name">Posted by <%# Eval("PostedBy") %></span>
                </p>
                <p class="event-participants text-gray-600">
                    <i class="fas fa-users mr-2 text-blue-600"></i>
                    <span class="participants-value"><%# Eval("ParticipantCount") %>/<%# Eval("MaxParticipant") %></span> participants
                </p>
            </div>
            <div class="flex space-x-2 mt-auto">
                <asp:LinkButton runat="server"
                    CommandName="View"
                    CommandArgument='<%# Eval("EnrollmentId") %>'
                    CssClass="flex-1 bg-blue-600 hover:bg-blue-700 text-white text-sm py-2 px-3 rounded-lg text-center transition-colors">
                    View Details
                </asp:LinkButton>
                <asp:LinkButton runat="server"
                    CommandName="Cancel"
                    CommandArgument='<%# Eval("EnrollmentId") %>'
                    Visible='<%# Eval("IsUpcoming") %>'
                    CssClass="bg-red-600 hover:bg-red-700 text-white text-sm py-2 px-3 rounded-lg transition-colors flex items-center justify-center"
                    CausesValidation="false">
                    Cancel
                </asp:LinkButton>
            </div>
        </div>
    </div>
                    </ItemTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="PaginationPanel" runat="server" CssClass="flex justify-center items-center space-x-2 mt-8" Visible="false">
                <asp:Button ID="PrevPageButton" runat="server" Text="Previous" CssClass="px-4 py-2 bg-gray-300 rounded" OnClick="PrevPageButton_Click" />
                <asp:Repeater ID="PageNumbersRepeater" runat="server" OnItemCommand="PageNumbersRepeater_ItemCommand">
                    <ItemTemplate>
                        <asp:LinkButton runat="server"
                            CommandName="Page"
                            CommandArgument='<%# Container.DataItem %>'
                            Text='<%# (int)Container.DataItem + 1 %>'
                            CssClass='<%# (int)Container.DataItem == ((Hope.user_register_event)Page).PageIndex ? "bg-blue-600 text-white px-3 py-1 rounded" : "bg-gray-200 text-gray-700 px-3 py-1 rounded" %>' />
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Button ID="NextPageButton" runat="server" Text="Next" CssClass="px-4 py-2 bg-gray-300 rounded" OnClick="NextPageButton_Click" />
            </asp:Panel>
        </div>
    </div>
    <script type="text/javascript">
        function closeMessage() {
            var messagePanel = document.getElementById('<%= MessagePanel.ClientID %>');
            if (messagePanel) {
                messagePanel.style.display = 'none';
            }
        }
    </script>
</asp:Content>
