<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="edit-event.aspx.cs" Inherits="Hope.edit_event" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <main class="min-h-screen bg-gray-50 py-12 sm:px-6 lg:px-8 pt-24">
        <div class="max-w-2xl mx-auto">
            <div class="bg-white shadow-lg rounded-lg overflow-hidden">
                <asp:Panel ID="FormPanel" runat="server" CssClass="p-8 space-y-8">
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="text-validation-error mb-4" />
                    <asp:Panel ID="EditEventPanel" runat="server">
                        <h2 class="text-2xl font-bold text-gray-900 mb-6 flex items-center">
                            <i class="fas fa-calendar-edit text-blue-600 mr-3"></i>
                            Edit Event Details
                        </h2>
                        <div class="grid grid-cols-1 gap-6">
                            <div>
                                <label for="StartDate" class="block text-sm font-medium text-gray-700 mb-2">Start Date
                                    *</label>
                                <asp:TextBox ID="StartDate" runat="server" TextMode="Date"
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md" />
                                <asp:RequiredFieldValidator ID="rfvStartDate" runat="server" ControlToValidate="StartDate"
                                    ErrorMessage="Start date is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <div>
                                <label for="EndDate" class="block text-sm font-medium text-gray-700 mb-2">End Date
                                    *</label>
                                <asp:TextBox ID="EndDate" runat="server" TextMode="Date"
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md" />
                                <asp:RequiredFieldValidator ID="rfvEndDate" runat="server" ControlToValidate="EndDate"
                                    ErrorMessage="End date is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <div>
                                <label for="StartTime" class="block text-sm font-medium text-gray-700 mb-2">Start Time
                                    *</label>
                                <asp:TextBox ID="StartTime" runat="server" TextMode="Time"
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md" />
                                <asp:RequiredFieldValidator ID="rfvStartTime" runat="server" ControlToValidate="StartTime"
                                    ErrorMessage="Start time is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <div>
                                <label for="EndTime" class="block text-sm font-medium text-gray-700 mb-2">End Time
                                    *</label>
                                <asp:TextBox ID="EndTime" runat="server" TextMode="Time"
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md" />
                                <asp:RequiredFieldValidator ID="rfvEndTime" runat="server" ControlToValidate="EndTime"
                                    ErrorMessage="End time is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <div>
                                <label for="Location" class="block text-sm font-medium text-gray-700 mb-2">Location
                                    *</label>
                                <asp:TextBox ID="Location" runat="server" MaxLength="255"
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md" />
                                <asp:RequiredFieldValidator ID="rfvLocation" runat="server" ControlToValidate="Location"
                                    ErrorMessage="Location is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                        </div>
                        <div class="flex flex-col sm:flex-row gap-4 justify-center pt-6">
                            <asp:Button ID="SaveBtn" runat="server" Text="Save Changes"
                                CssClass="px-8 py-3 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-medium"
                                OnClick="SaveBtn_Click" />
                            <a href="user-event.aspx"
                                class="px-8 py-3 border border-gray-300 rounded-lg text-gray-700 hover:bg-gray-50 transition font-medium text-center">Cancel</a>
                        </div>
                    </asp:Panel>
                </asp:Panel>
            </div>
        </div>
    </main>
</asp:Content>
