<%@ Page Title="Event Detail" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="event-detail.aspx.cs" Inherits="Hope.event_detail" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <main class="pt-16">
        <!-- Success Message at Top -->
        <% if (!string.IsNullOrEmpty(SuccessMessage)) { %>
            <div id="event-success-message" class="max-w-2xl mx-auto mt-4">
                <div class="bg-green-50 border border-green-200 text-green-800 px-6 py-4 rounded-lg shadow-lg text-center">
                    <i class="fas fa-check-circle text-green-600 mr-2"></i>
                    <%= SuccessMessage %>
                </div>
            </div>
            <script>
                setTimeout(function() {
                    var msg = document.getElementById('event-success-message');
                    if (msg) msg.style.display = 'none';
                }, 3000);
            </script>
        <% } %>
        <% if (Event != null) { %>
        <!-- Event Hero Section -->
        <div class="bg-white">
            <div class="max-w-7xl mx-auto px-4 py-8">
                <div class="grid lg:grid-cols-2 gap-8">
                    <!-- Event Image -->
                    <div>
                        <img src="<%= Event.EventImageUrl %>" alt="Event Image" class="w-full h-96 object-cover rounded-xl shadow-lg">
                    </div>
                    <!-- Event Info -->
                    <div class="space-y-6">
                        <div>
                            <h1 class="text-4xl font-bold text-gray-800 mb-4"><%= Event.EventTitle %></h1>
                            <p class="text-lg text-gray-600 leading-relaxed"><%= Event.EventDescription %></p>
                        </div>
                        <!-- Event Details Grid -->
                        <div class="grid grid-cols-2 gap-4">
                            <div class="bg-gray-50 p-4 rounded-lg">
                                <div class="flex items-center mb-2">
                                    <i class="fas fa-calendar text-blue-600 mr-2"></i>
                                    <span class="font-semibold text-gray-800">Event Type</span>
                                </div>
                                <p class="text-gray-600"><%= Event.EventType %></p>
                            </div>
                            <div class="bg-gray-50 p-4 rounded-lg">
                                <div class="flex items-center mb-2">
                                    <i class="fas fa-globe text-blue-600 mr-2"></i>
                                    <span class="font-semibold text-gray-800">Cuisine Type</span>
                                </div>
                                <p class="text-gray-600"><%= Event.CuisineType %></p>
                            </div>
                            <div class="bg-gray-50 p-4 rounded-lg">
                                <div class="flex items-center mb-2">
                                    <i class="fas fa-calendar text-blue-600 mr-2"></i>
                                    <span class="font-semibold text-gray-800">Date</span>
                                </div>
                                <p class="text-gray-600"><%= Event.DateRange %></p>
                            </div>
                            <div class="bg-gray-50 p-4 rounded-lg">
                                <div class="flex items-center mb-2">
                                    <i class="fas fa-clock text-blue-600 mr-2"></i>
                                    <span class="font-semibold text-gray-800">Time</span>
                                </div>
                                <p class="text-gray-600"><%= Event.TimeRange %></p>
                            </div>
                            <div class="bg-gray-50 p-4 rounded-lg">
                                <div class="flex items-center mb-2">
                                    <i class="fas fa-users text-blue-600 mr-2"></i>
                                    <span class="font-semibold text-gray-800">Maximum Participants</span>
                                </div>
                                <p class="text-gray-600"><%= Event.MaxParticipant %> participants</p>
                            </div>
                            <div class="bg-gray-50 p-4 rounded-lg">
                                <div class="flex items-center mb-2">
                                    <i class="fas fa-map-marker-alt text-blue-600 mr-2"></i>
                                    <span class="font-semibold text-gray-800">Location</span>
                                </div>
                                <p class="text-gray-600"><%= Event.Location %></p>
                            </div>
                            <div class="bg-gray-50 p-4 rounded-lg">
                                <div class="flex items-center mb-2">
                                    <i class="fas fa-user text-blue-600 mr-2"></i>
                                    <span class="font-semibold text-gray-800">Organizer</span>
                                </div>
                                <p class="text-gray-600"><%= Event.Organizer %></p>
                            </div>
                            <div class="bg-gray-50 p-4 rounded-lg">
                                <div class="flex items-center mb-2">
                                    <i class="fas fa-phone text-blue-600 mr-2"></i>
                                    <span class="font-semibold text-gray-800">Contact</span>
                                </div>
                                <p class="text-gray-600"><%= Event.Contact %></p>
                            </div>
                        </div>
                        <!-- Registration Button -->
                        <div class="pt-4">
                            <% if (!IsPastEvent) { %>
                                <%
                                    var isUser = Session["UserId"] != null && (Session["UserRole"] == null || Session["UserRole"].ToString() == "User");
                                    var isAdmin = Session["UserRole"] != null && Session["UserRole"].ToString() == "Admin";
                                    var isLoggedIn = Session["UserId"] != null;
                                    var isOwner = false;
                                    if (Event != null && Session["UserId"] != null)
                                    {
                                        isOwner = Event.UserId == Convert.ToInt32(Session["UserId"]);
                                    }
                                %>
                                <% if (isAdmin) { %>
                                    <%-- Do not display any registration/cancel button for admin --%>
                                <% } else if (isOwner) { %>
                                    <p class="text-sm text-gray-500 mt-2 text-center">
                                        <span><%= SpotsRemaining %></span> spots remaining
                                    </p>
                                <% } else if (isUser) { %>
                                    <% if (ShowRegisterButton) { %>
                                        <asp:Button ID="RegisterBtn" runat="server"
                                            CssClass="w-full bg-blue-600 text-white py-3 px-6 rounded-lg text-lg font-semibold hover:bg-blue-700 transition duration-300 transform hover:scale-105"
                                            Text="Register for Event"
                                            OnClick="RegisterBtn_Click" />
                                        <p class="text-sm text-gray-500 mt-2 text-center">
                                            <span><%= SpotsRemaining %></span> spots remaining
                                        </p>
                                    <% } else if (ShowCancelButton) { %>
                                        <asp:Button ID="CancelBtn" runat="server"
                                            CssClass="w-full bg-red-600 text-white py-3 px-6 rounded-lg text-lg font-semibold hover:bg-red-700 transition duration-300 transform hover:scale-105"
                                            Text="Cancel Registration"
                                            OnClick="CancelBtn_Click" />
                                        <p class="text-sm text-gray-500 mt-2 text-center">
                                            You are registered for this event.
                                        </p>
                                    <% } else { %>
                                        <p class="text-sm text-gray-500 mt-2 text-center">
                                            Registration closed or full.
                                        </p>
                                    <% } %>
                                <% } else { %>
                                    <div class="flex flex-col items-center justify-center mt-2">
                                        <a href="login.aspx?returnUrl=<%= Server.UrlEncode(Request.RawUrl) %>"
                                           class="w-full bg-blue-600 text-white py-3 px-6 rounded-lg text-lg font-semibold hover:bg-blue-700 transition duration-300 transform hover:scale-105 text-center">
                                            <i class="fas fa-sign-in-alt mr-2"></i>
                                            Login to register
                                        </a>
                                    </div>
                                <% } %>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        <!-- Event Details Section -->
        <div class="py-16 bg-gray-50">
            <div class="max-w-7xl mx-auto px-4">
                <div class="grid lg:grid-cols-3 gap-8">
                    <!-- What You'll Learn -->
                    <div class="bg-white p-6 rounded-xl shadow-lg">
                        <h3 class="text-2xl font-bold text-gray-800 mb-4">
                            <i class="fas fa-lightbulb text-yellow-500 mr-2"></i>
                            What You'll Learn
                        </h3>
                        <div class="text-gray-600" style="white-space:pre-line">
        <%= string.Join("\n", Event.LearningObjectives) %>
    </div>
                    </div>
                    <!-- What's Included -->
                    <div class="bg-white p-6 rounded-xl shadow-lg">
                        <h3 class="text-2xl font-bold text-gray-800 mb-4">
                            <i class="fas fa-box-open text-blue-500 mr-2"></i>
                            What's Included
                        </h3>
                        <div class="text-gray-600" style="white-space:pre-line">
        <%= string.Join("\n", Event.IncludedItems) %>
    </div>
                    </div>
                    <!-- Requirements -->
                    <div class="bg-white p-6 rounded-xl shadow-lg">
                        <h3 class="text-2xl font-bold text-gray-800 mb-4">
                            <i class="fas fa-info-circle text-orange-500 mr-2"></i>
                            Requirements
                        </h3>
                        <div class="text-gray-600" style="white-space:pre-line">
        <%= string.Join("\n", Event.Requirements) %>
    </div>
                    </div>
                </div>
            </div>
        </div>
        <% } else { %>
            <div class="text-center text-gray-500 py-16 text-xl">Event not found.</div>
        <% } %>
    </main>
</asp:Content>
