<%@ Page Title="Forgot Password" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="forgot-password.aspx.cs" Inherits="Hope.forgot_password" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8 pt-24">
        <div class="sm:mx-auto sm:w-full sm:max-w-md">
            <div class="text-center">
                <a href="home.aspx" class="inline-flex items-center mb-4">
                    <i class="fas fa-utensils text-4xl text-blue-600 mr-2"></i>
                    <span class="text-2xl font-bold text-gray-800">FoodieCamp</span>
                </a>
                <h2 class="text-3xl font-bold text-gray-900">Reset Your Password</h2>
                <p class="mt-2 text-sm text-gray-600">Enter your email and new password to reset your account</p>
            </div>
        </div>

        <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
            <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
                <asp:Panel ID="ForgotPasswordPanel" runat="server" DefaultButton="SendCodeButton">
                    <div class="space-y-6">
                        <!-- Validation Summary -->
                        <asp:ValidationSummary ID="ValidationSummary1" runat="server" 
                            CssClass="text-red-600 text-sm bg-red-50 p-3 rounded-md border border-red-200"
                            HeaderText="Please correct the following errors:" />

                        <!-- Success/Error Messages -->
                        <asp:Panel ID="MessagePanel" runat="server" Visible="false">
                            <asp:Label ID="MessageLabel" runat="server" CssClass="block text-sm font-medium p-3 rounded-md"></asp:Label>
                        </asp:Panel>

                        <!-- Email Address -->
                        <div>
                            <asp:Label ID="EmailLabel" runat="server" AssociatedControlID="EmailTextBox" 
                                CssClass="block text-sm font-medium text-gray-700">
                                <i class="fas fa-envelope mr-2 text-blue-600"></i>
                                Email Address
                            </asp:Label>
                            <div class="mt-1">
                                <asp:TextBox ID="EmailTextBox" runat="server" TextMode="Email" 
                                    placeholder="Enter your email address"
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="EmailRequired" runat="server" 
                                    ControlToValidate="EmailTextBox" 
                                    ErrorMessage="Email address is required." 
                                    Text="*" 
                                    CssClass="text-red-600" />
                                <asp:RegularExpressionValidator ID="EmailFormat" runat="server" 
                                    ControlToValidate="EmailTextBox" 
                                    ErrorMessage="Please enter a valid email address." 
                                    ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" 
                                    Text="*" 
                                    CssClass="text-red-600" />
                            </div>
                            <p class="mt-1 text-xs text-gray-500">Enter the email associated with your account</p>
                        </div>

                        <!-- New Password -->
                        <div>
                            <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="PasswordTextBox" 
                                CssClass="block text-sm font-medium text-gray-700">
                                <i class="fas fa-lock mr-2 text-blue-600"></i>
                                New Password
                            </asp:Label>
                            <div class="mt-1">
                                <asp:TextBox ID="PasswordTextBox" runat="server" TextMode="Password" 
                                    placeholder="Enter new password"
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" 
                                    ControlToValidate="PasswordTextBox" 
                                    ErrorMessage="New password is required." 
                                    Text="*" 
                                    CssClass="text-red-600" />
                                <asp:RegularExpressionValidator ID="PasswordLength" runat="server" 
                                    ControlToValidate="PasswordTextBox" 
                                    ErrorMessage="Password must be at least 8 characters long." 
                                    ValidationExpression=".{8,}" 
                                    Text="*" 
                                    CssClass="text-red-600" />
                            </div>
                            <p class="mt-1 text-xs text-gray-500">Must be at least 8 characters long</p>
                        </div>

                        <!-- Confirm Password -->
                        <div>
                            <asp:Label ID="ConfirmPasswordLabel" runat="server" AssociatedControlID="ConfirmPasswordTextBox" 
                                CssClass="block text-sm font-medium text-gray-700">
                                <i class="fas fa-lock mr-2 text-blue-600"></i>
                                Confirm New Password
                            </asp:Label>
                            <div class="mt-1">
                                <asp:TextBox ID="ConfirmPasswordTextBox" runat="server" TextMode="Password" 
                                    placeholder="Confirm new password"
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="ConfirmPasswordRequired" runat="server" 
                                    ControlToValidate="ConfirmPasswordTextBox" 
                                    ErrorMessage="Please confirm your new password." 
                                    Text="*" 
                                    CssClass="text-red-600" />
                                <asp:CompareValidator ID="PasswordCompare" runat="server" 
                                    ControlToValidate="ConfirmPasswordTextBox" 
                                    ControlToCompare="PasswordTextBox" 
                                    ErrorMessage="Password and confirmation password do not match." 
                                    Text="*" 
                                    CssClass="text-red-600" />
                            </div>
                            <p class="mt-1 text-xs text-gray-500">Re-enter your new password</p>
                        </div>

                        <!-- Submit Button -->
                        <div>
                            <asp:Button ID="SendCodeButton" runat="server" Text="Send Verification Code" 
                                OnClick="SendCodeButton_Click"
                                CssClass="w-full flex justify-center items-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-300" />
                        </div>

                        <!-- Back to Login -->
                        <div class="text-center">
                            <a href="login.aspx" class="text-blue-600 hover:text-blue-500 text-sm">
                                <i class="fas fa-arrow-left mr-1"></i>
                                Back to Login
                            </a>
                        </div>

                        <!-- Sign up link -->
                        <div class="text-center">
                            <p class="text-sm text-gray-600">
                                Don't have an account? 
                                <a href="register.aspx" class="text-blue-600 hover:text-blue-500">Sign up here</a>
                            </p>
                        </div>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </div>
</asp:Content>