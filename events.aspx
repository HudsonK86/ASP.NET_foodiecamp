<%@ Page Title="Events" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="events.aspx.cs" Inherits="Hope.events" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
   <div class="pt-16">
        <!-- Events Grid -->
         <div class="py-16 bg-white">
            <div class="max-w-7xl mx-auto px-4">
                <h1 class="text-4xl font-bold text-center text-gray-800 mb-12">Explore Events by Category</h1>
                
                <!-- Search and Filter Section -->
                <div class="bg-gray-50 rounded-lg p-6 mb-8">
                    <div class="grid grid-cols-1 md:grid-cols-4 gap-4 items-end">
                        <!-- Time Selector -->
                        <div>
                            <label for="TimeFilter" class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fas fa-clock mr-2 text-blue-600"></i>
                                Time
                            </label>
                            <asp:DropDownList ID="TimeFilter" runat="server"
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                                <asp:ListItem Value="all" Text="All" Selected="True" />
                                <asp:ListItem Value="upcoming" Text="Upcoming" />
                                <asp:ListItem Value="past" Text="Past" />
                            </asp:DropDownList>
                        </div>
                        <!-- Event Type Selector -->
                        <div>
                            <label for="EventTypeFilter" class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fas fa-tags mr-2 text-blue-600"></i>
                                Event Type
                            </label>
                            <asp:DropDownList ID="EventTypeFilter" runat="server"
                            CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                            AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                            <asp:ListItem Value="all" Text="All" Selected="True" />
                        </asp:DropDownList>
                        </div>
                        <!-- Search Bar -->
                        <div>
                            <label for="SearchBox" class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fas fa-search mr-2 text-blue-600"></i>
                                Search
                            </label>
                            <asp:TextBox ID="SearchBox" runat="server"
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                placeholder="Search events..."
                                AutoPostBack="true" OnTextChanged="Filter_Changed" />
                        </div>
                        <!-- Post Event Button -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">&nbsp;</label>
                            <% if (Session["UserId"] != null && (Session["UserRole"] == null || Session["UserRole"].ToString() == "User")) { %>
                                <a href="post-event.aspx" class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition duration-300 flex items-center justify-center">
                                    <i class="fas fa-plus mr-2"></i>
                                    Post Event
                                </a>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Events Grid -->
                <asp:Repeater ID="EventsRepeater" runat="server">
                    <HeaderTemplate>
                        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" id="events-grid">
                    </HeaderTemplate>
                    <ItemTemplate>
                        <div class="bg-white rounded-lg shadow-md overflow-hidden event-card mb-4">
                            <div class="relative">
                                <img src='<%# Eval("EventImageUrl") %>' alt='<%# Eval("EventTitle") %>' class="w-full h-48 object-cover" />
                                <div class="absolute top-2 right-2">
                                    <span class='<%# Eval("TimeBadgeClass") %> px-2 py-1 rounded-full text-xs font-medium'>
                                        <i class='<%# Eval("TimeBadgeIcon") %> mr-1'></i>
                                        <%# Eval("TimeLabel") %>
                                    </span>
                                </div>
                            </div>
                            <div class="p-4">
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
                                        <span class="participant-count"><%# Eval("ParticipantCount") %>/<%# Eval("MaxParticipant") %></span> participants
                                    </p>
                                </div>
                                <div class="flex space-x-2">
                                    <a href='event-detail.aspx?id=<%# Eval("EventId") %>' class="flex-1 bg-blue-600 hover:bg-blue-700 text-white text-sm py-2 px-3 rounded-lg text-center transition-colors">
                                        View Details
                                    </a>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate>
                        </div>
                    </FooterTemplate>
                </asp:Repeater>

                <!-- Pagination -->
                <asp:Panel ID="PaginationPanel" runat="server" CssClass="flex justify-center items-center space-x-2 mt-8" Visible="false">
                    <asp:Button ID="PrevPageButton" runat="server" Text="Previous" CssClass="px-4 py-2 bg-gray-300 rounded" OnClick="PrevPageButton_Click" />
                    <asp:Repeater ID="PageNumbersRepeater" runat="server" OnItemCommand="PageNumbersRepeater_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton runat="server"
                                CommandName="Page"
                                CommandArgument='<%# Container.DataItem %>'
                                Text='<%# (int)Container.DataItem + 1 %>'
                                CssClass='<%# (int)Container.DataItem == ((Hope.events)Page).PageIndex ? "bg-blue-600 text-white px-3 py-1 rounded" : "bg-gray-200 text-gray-700 px-3 py-1 rounded" %>' />
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Button ID="NextPageButton" runat="server" Text="Next" CssClass="px-4 py-2 bg-gray-300 rounded" OnClick="NextPageButton_Click" />
                </asp:Panel>
            </div>
        </div>

        <!-- Call to Action -->
        <div class="py-20 bg-gradient-to-r from-blue-600 to-blue-800 text-white">
            <div class="max-w-4xl mx-auto px-4 text-center">
                <h2 class="text-4xl font-bold mb-6">Ready to Start Your Culinary Journey?</h2>
                <p class="text-xl mb-8">Join thousands of cooking enthusiasts and learn from professional chefs around the world.</p>
                <a href="contact.aspx" class="bg-white text-blue-600 px-8 py-3 rounded-lg text-lg font-semibold hover:bg-gray-100 transition inline-block">
                    Contact Us
                </a>
            </div>
        </div>
    </div>
</asp:Content>
