<%@ Page Title="Post Event" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="post-event.aspx.cs" Inherits="Hope.post_event" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .input-validation-error { border-color: #f87171 !important; }
        .text-validation-error { color: #dc2626; font-size: 0.95rem; }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <main class="min-h-screen bg-gray-50 py-12 sm:px-6 lg:px-8 pt-24">
        <div class="max-w-4xl mx-auto">
            <!-- Header -->
            <div class="bg-white rounded-lg shadow-sm p-8 mb-8">
                <div class="text-center">
                    <i class="fas fa-calendar-plus text-5xl text-blue-600 mb-4"></i>
                    <h1 class="text-3xl font-bold text-gray-900 mb-2">Create New Event</h1>
                    <p class="text-gray-600">Share your culinary event with the FoodieCamp community</p>
                </div>
            </div>
            <!-- Success/Error Message -->
            <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="max-w-xl mx-auto mb-6">
                <div class="bg-green-50 border border-green-200 text-green-800 px-6 py-4 rounded-lg shadow-lg text-center">
                    <i class="fas fa-check-circle text-green-600 mr-2"></i>
                    <asp:Label ID="MessageLabel" runat="server" />
                </div>
            </asp:Panel>
            <asp:Panel ID="ErrorPanel" runat="server" Visible="false" CssClass="max-w-xl mx-auto mb-6">
                <div class="bg-red-50 border border-red-200 text-red-800 px-6 py-4 rounded-lg shadow-lg text-center">
                    <i class="fas fa-times-circle text-red-600 mr-2"></i>
                    <asp:Label ID="ErrorLabel" runat="server" />
                </div>
            </asp:Panel>
            <!-- Event Form -->
            <div class="bg-white shadow-lg rounded-lg overflow-hidden">
                <asp:Panel ID="FormPanel" runat="server" CssClass="p-8 space-y-8">
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="text-validation-error mb-4" />
                    <!-- Basic Information -->
                    <asp:Panel ID="BasicInfoPanel" runat="server">
                        <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                            <i class="fas fa-info-circle text-blue-600 mr-3"></i>
                            Basic Information
                        </h2>
                        <div class="grid grid-cols-1 gap-6">
                            <!-- Event Title -->
                            <div>
                                <label for="EventTitle" class="block text-sm font-medium text-gray-700 mb-2">
                                    Event Title *
                                </label>
                                <asp:TextBox ID="EventTitle" runat="server" MaxLength="100" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvEventTitle" runat="server" ControlToValidate="EventTitle" ErrorMessage="Event title is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <!-- Event Description -->
                            <div>
                                <label for="EventDescription" class="block text-sm font-medium text-gray-700 mb-2">
                                    Event Description *
                                </label>
                                <asp:TextBox ID="EventDescription" runat="server" TextMode="MultiLine" Rows="4" MaxLength="500" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvEventDescription" runat="server" ControlToValidate="EventDescription" ErrorMessage="Event description is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <!-- Event Image -->
                            <div>
                                <label for="EventImage" class="block text-sm font-medium text-gray-700 mb-2">
                                    Event Image *
                                </label>
                                <asp:FileUpload ID="EventImage" runat="server" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvEventImage" runat="server" ControlToValidate="EventImage" ErrorMessage="Event image is required." CssClass="text-validation-error" Display="Dynamic" />
                                <p class="text-xs text-gray-500">PNG, JPG, GIF up to 10MB</p>
                            </div>
                        </div>
                    </asp:Panel>
                    <!-- Event Details -->
                    <asp:Panel ID="EventDetailsPanel" runat="server">
                        <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                            <i class="fas fa-calendar-alt text-blue-600 mr-3"></i>
                            Event Details
                        </h2>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <!-- Event Type -->
                            <div>
                                <label for="EventType" class="block text-sm font-medium text-gray-700 mb-2">
                                    Event Type *
                                </label>
                                <asp:DropDownList ID="EventType" runat="server" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvEventType" runat="server" ControlToValidate="EventType" InitialValue="" ErrorMessage="Event type is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <!-- Cuisine Type -->
                            <div>
                                <label for="CuisineType" class="block text-sm font-medium text-gray-700 mb-2">
                                    Cuisine Type *
                                </label>
                                <asp:DropDownList ID="CuisineType" runat="server" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvCuisineType" runat="server" ControlToValidate="CuisineType" InitialValue="" ErrorMessage="Cuisine type is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <!-- Event Date -->
                            <div class="md:col-span-2">
                                <label for="StartDate" class="block text-sm font-medium text-gray-700 mb-2">
                                    Event Date *
                                </label>
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <asp:TextBox ID="StartDate" runat="server" TextMode="Date" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                        <asp:RequiredFieldValidator ID="rfvStartDate" runat="server" ControlToValidate="StartDate" ErrorMessage="Start date is required." CssClass="text-validation-error" Display="Dynamic" />
                                    </div>
                                    <div>
                                        <asp:TextBox ID="EndDate" runat="server" TextMode="Date" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                        <asp:RequiredFieldValidator ID="rfvEndDate" runat="server" ControlToValidate="EndDate" ErrorMessage="End date is required." CssClass="text-validation-error" Display="Dynamic" />
                                    </div>
                                </div>
                                <p class="text-xs text-gray-500 mt-1">Start date - End date (if single day, use same date for both)</p>
                            </div>
                            <!-- Event Time -->
                            <div>
                                <label for="StartTime" class="block text-sm font-medium text-gray-700 mb-2">
                                    Event Time *
                                </label>
                                <div class="grid grid-cols-2 gap-2">
                                    <div>
                                        <asp:TextBox ID="StartTime" runat="server" TextMode="Time" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                        <asp:RequiredFieldValidator ID="rfvStartTime" runat="server" ControlToValidate="StartTime" ErrorMessage="Start time is required." CssClass="text-validation-error" Display="Dynamic" />
                                    </div>
                                    <div>
                                        <asp:TextBox ID="EndTime" runat="server" TextMode="Time" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                        <asp:RequiredFieldValidator ID="rfvEndTime" runat="server" ControlToValidate="EndTime" ErrorMessage="End time is required." CssClass="text-validation-error" Display="Dynamic" />
                                    </div>
                                </div>
                                <p class="text-xs text-gray-500 mt-1">Start time - End time</p>
                            </div>
                            <!-- Max Participants -->
                            <div>
                                <label for="MaxParticipant" class="block text-sm font-medium text-gray-700 mb-2">
                                    Maximum Participants *
                                </label>
                                <asp:TextBox ID="MaxParticipant" runat="server" TextMode="Number" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvMaxParticipant" runat="server" ControlToValidate="MaxParticipant" ErrorMessage="Maximum participants is required." CssClass="text-validation-error" Display="Dynamic" />
                                <asp:RangeValidator ID="rvMaxParticipant" runat="server" ControlToValidate="MaxParticipant" MinimumValue="1" MaximumValue="200" Type="Integer" ErrorMessage="Enter a valid number (1-200)." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <!-- Location -->
                            <div class="md:col-span-2">
                                <label for="Location" class="block text-sm font-medium text-gray-700 mb-2">
                                    Location *
                                </label>
                                <asp:TextBox ID="Location" runat="server" MaxLength="255" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvLocation" runat="server" ControlToValidate="Location" ErrorMessage="Location is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                        </div>
                    </asp:Panel>
                    <!-- Event Content -->
                    <asp:Panel ID="EventContentPanel" runat="server">
                        <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                            <i class="fas fa-list-check text-blue-600 mr-3"></i>
                            Event Content
                        </h2>
                        <div class="grid grid-cols-1 gap-6">
                            <!-- What You'll Learn -->
                            <div>
                                <label for="LearningObjectives" class="block text-sm font-medium text-gray-700 mb-2">
                                    What You'll Learn *
                                </label>
                                <asp:TextBox ID="LearningObjectives" runat="server" TextMode="MultiLine" Rows="4" MaxLength="500" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvLearningObjectives" runat="server" ControlToValidate="LearningObjectives" ErrorMessage="Learning objectives are required." CssClass="text-validation-error" Display="Dynamic" />
                                <p class="text-sm text-gray-500 mt-1">Enter each learning objective on a separate line</p>
                            </div>
                            <!-- What's Included -->
                            <div>
                                <label for="IncludedItems" class="block text-sm font-medium text-gray-700 mb-2">
                                    What's Included *
                                </label>
                                <asp:TextBox ID="IncludedItems" runat="server" TextMode="MultiLine" Rows="4" MaxLength="500" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvIncludedItems" runat="server" ControlToValidate="IncludedItems" ErrorMessage="Included items are required." CssClass="text-validation-error" Display="Dynamic" />
                                <p class="text-sm text-gray-500 mt-1">Enter each included item on a separate line</p>
                            </div>
                            <!-- Requirements -->
                            <div>
                                <label for="Requirements" class="block text-sm font-medium text-gray-700 mb-2">
                                    Requirements *
                                </label>
                                <asp:TextBox ID="Requirements" runat="server" TextMode="MultiLine" Rows="4" MaxLength="500" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvRequirements" runat="server" ControlToValidate="Requirements" ErrorMessage="Requirements are required." CssClass="text-validation-error" Display="Dynamic" />
                                <p class="text-sm text-gray-500 mt-1">Enter each requirement on a separate line</p>
                            </div>
                        </div>
                    </asp:Panel>
                    <!-- Submit Button -->
                    <div class="flex flex-col sm:flex-row gap-4 justify-center pt-6">
                        <asp:Button ID="CancelBtn" runat="server" Text="Cancel" CssClass="px-8 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium" OnClick="CancelBtn_Click" CausesValidation="false" />
                        <asp:Button ID="PostEventBtn" runat="server" Text="Post Event" CssClass="px-8 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-medium" OnClick="PostEventBtn_Click" />
                    </div>
                </asp:Panel>
            </div>
        </div>
    </main>
</asp:Content>
