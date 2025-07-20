<%@ Page Title="Home" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="home.aspx.cs" Inherits="Hope.home" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="pt-16">
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

        <!-- Hero Section -->
        <div class="hero-bg py-20" style="background-color: #add8e670;">
            <div class="max-w-7xl mx-auto px-4 text-center">
                <h1 class="text-5xl font-bold text-gray-800 mb-6">Master the Art of Cooking</h1>
                <p class="text-xl text-gray-600 mb-8 max-w-2xl mx-auto">Learn authentic recipes from around the world with expert guidance and join our community of passionate food lovers.</p>
                <% if (Session["UserId"] == null) { %>
                    <a href="register.aspx" class="bg-blue-600 text-white px-8 py-3 rounded-lg text-lg font-semibold hover:bg-blue-700 transition inline-block">
                        Become a Member Now!
                    </a>
                <% } %>
            </div>
        </div>

        <!-- Cuisine Section -->
        <div class="py-16 bg-white">
            <div class="max-w-7xl mx-auto px-4">
                <h2 class="text-3xl font-bold text-center text-gray-800 mb-12">Explore World Cuisines</h2>
                <div class="grid md:grid-cols-3 gap-8" id="cuisine-container">
                    <!-- Dynamic Cuisine Cards from Database -->
                    <asp:Repeater ID="CuisineRepeater" runat="server">
                        <ItemTemplate>
                            <div class="cuisine-card bg-white rounded-xl shadow-lg card-hover transition-all duration-300" data-cuisine-id='<%# Eval("CuisineId") %>'>
                                <img src='<%# ResolveUrl(Eval("FullImagePath").ToString()) %>' 
                                     alt='<%# Eval("CuisineName") %> Cuisine' 
                                     class="cuisine-image w-full h-48 object-cover rounded-t-xl"
                                     onerror="this.src='https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&h=250&fit=crop';" />
                                <div class="p-6">
                                    <h3 class="cuisine-name text-xl font-semibold text-gray-800 mb-4 text-center"><%# Eval("CuisineName") %></h3>
                                    <a href='recipes.aspx?cuisine=<%# Eval("CuisineId") %>' 
                                       class="cuisine-link w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition block text-center">
                                        Learn More
                                    </a>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                    
                    <!-- Fallback message if no cuisines found -->
                    <asp:Panel ID="NoCuisinesPanel" runat="server" Visible="false" CssClass="col-span-3 text-center py-8">
                        <p class="text-gray-600 text-lg">No cuisines available at the moment. Please check back later!</p>
                    </asp:Panel>
                </div>
            </div>
        </div>

        <!-- Events Section -->
        <div class="py-16 bg-gray-50">
            <div class="max-w-7xl mx-auto px-4">
                <h2 class="text-3xl font-bold text-center text-gray-800 mb-12">Upcoming Events</h2>
                <div class="grid md:grid-cols-3 gap-8" id="events-container">
                    <asp:Repeater ID="HomeEventsRepeater" runat="server">
                        <ItemTemplate>
                            <div class="event-card bg-white rounded-xl shadow-lg card-hover transition-all duration-300 flex flex-col h-full relative" style="min-height: 400px;">
                                <img src='<%# Eval("EventImageUrl") %>' alt='<%# Eval("EventTitle") %>' class="event-image w-full h-40 object-cover rounded-t-xl" onerror="this.src='https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=400&h=250&fit=crop';" />
                                <div class="absolute top-2 right-2 z-10">
                                    <span class='<%# Eval("TimeBadgeClass") %> px-2 py-1 rounded-full text-xs font-medium'>
                                        <i class='<%# Eval("TimeBadgeIcon") %> mr-1'></i>
                                        <%# Eval("TimeLabel") %>
                                    </span>
                                </div>
                                <div class="p-6 flex flex-col flex-1">
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
                                    <div class="event-actions mt-auto">
                                        <a href='event-detail.aspx?id=<%# Eval("EventId") %>' class="event-link w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition block text-center">
                                            View Details
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- View All Events Button -->
                <div class="flex justify-center mt-10">
                    <a href="events.aspx"
                       class="inline-block bg-blue-600 hover:bg-blue-700 text-white font-semibold py-3 px-8 rounded-lg text-lg shadow transition">
                        Explore All Events
                    </a>
                </div>
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

    <script>
        // Auto-hide message after 5 seconds
        setTimeout(function () {
            closeMessage();
        }, 5000);

        function closeMessage() {
            const messagePanel = document.querySelector('[id*="MessagePanel"]');
            if (messagePanel) {
                messagePanel.style.display = 'none';
            }
        }
    </script>
</asp:Content>