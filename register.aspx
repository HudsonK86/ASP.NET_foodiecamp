<%@ Page Title="Register" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="register.aspx.cs" Inherits="Hope.register" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        function validateTermsCheckbox(sender, args) {
            // Get the checkbox control
            var checkbox = document.getElementById('<%= TermsCheckBox.ClientID %>');

            // Set validation result
            args.IsValid = checkbox.checked;
        }
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-8 sm:px-6 lg:px-8 pt-20">
        <div class="sm:mx-auto sm:w-full sm:max-w-lg">
            <div class="text-center">
                <a href="home.aspx" class="inline-flex items-center mb-6">
                    <i class="fas fa-utensils text-4xl text-blue-600 mr-2"></i>
                    <span class="text-2xl font-bold text-gray-800">FoodieCamp</span>
                </a>
                <h2 class="text-3xl font-bold text-gray-900 mb-2">Create Your Account</h2>
                <p class="text-sm text-gray-600 mb-6">Join our community of cooking enthusiasts</p>
            </div>
        </div>

        <div class="sm:mx-auto sm:w-full sm:max-w-lg">
            <div class="bg-white py-8 px-6 shadow-lg sm:rounded-lg sm:px-10">
                <div class="space-y-5">
                    <!-- Validation Summary -->
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" 
                        CssClass="text-red-600 text-sm bg-red-50 p-3 rounded-md border border-red-200"
                        HeaderText="Please correct the following errors:" />

                    <!-- Success/Error Messages -->
                    <asp:Panel ID="MessagePanel" runat="server" Visible="false">
                        <asp:Label ID="MessageLabel" runat="server" CssClass="block text-sm font-medium p-3 rounded-md"></asp:Label>
                    </asp:Panel>

                    <!-- First Name and Last Name Row -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <asp:Label ID="FirstNameLabel" runat="server" AssociatedControlID="FirstNameTextBox" 
                                CssClass="block text-sm font-medium text-gray-700 mb-1">First Name</asp:Label>
                            <asp:TextBox ID="FirstNameTextBox" runat="server" 
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="FirstNameRequired" runat="server" 
                                ControlToValidate="FirstNameTextBox" 
                                ErrorMessage="First name is required." 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                        </div>
                        
                        <div>
                            <asp:Label ID="LastNameLabel" runat="server" AssociatedControlID="LastNameTextBox" 
                                CssClass="block text-sm font-medium text-gray-700 mb-1">Last Name</asp:Label>
                            <asp:TextBox ID="LastNameTextBox" runat="server" 
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="LastNameRequired" runat="server" 
                                ControlToValidate="LastNameTextBox" 
                                ErrorMessage="Last name is required." 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                        </div>
                    </div>

                    <div>
                        <asp:Label ID="EmailLabel" runat="server" AssociatedControlID="EmailTextBox" 
                            CssClass="block text-sm font-medium text-gray-700 mb-1">
                            <i class="fas fa-envelope mr-2 text-blue-600"></i>
                            Email Address
                        </asp:Label>
                        <asp:TextBox ID="EmailTextBox" runat="server" TextMode="Email" 
                            placeholder="Enter your email address"
                            CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                        <div class="flex space-x-1">
                            <asp:RequiredFieldValidator ID="EmailRequired" runat="server" 
                                ControlToValidate="EmailTextBox" 
                                ErrorMessage="Email address is required." 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                            <asp:RegularExpressionValidator ID="EmailFormat" runat="server" 
                                ControlToValidate="EmailTextBox" 
                                ErrorMessage="Please enter a valid email address." 
                                ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                        </div>
                    </div>

                    <!-- Phone Number -->
                    <div>
                        <asp:Label ID="PhoneLabel" runat="server" AssociatedControlID="PhoneTextBox" 
                            CssClass="block text-sm font-medium text-gray-700 mb-1">
                            <i class="fas fa-phone mr-2 text-blue-600"></i>
                            Phone Number
                        </asp:Label>
                        <asp:TextBox ID="PhoneTextBox" runat="server" TextMode="Phone" 
                            placeholder="Enter your phone number"
                            CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                        <asp:RequiredFieldValidator ID="PhoneRequired" runat="server" 
                            ControlToValidate="PhoneTextBox" 
                            ErrorMessage="Phone number is required." 
                            Text="*" 
                            CssClass="text-red-600 text-sm" />
                        <p class="text-xs text-gray-500 mt-1">Enter your mobile phone number</p>
                    </div>

                    <!-- Password -->
                    <div>
                        <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="PasswordTextBox" 
                            CssClass="block text-sm font-medium text-gray-700 mb-1">
                            <i class="fas fa-lock mr-2 text-blue-600"></i>
                            Password
                        </asp:Label>
                        <asp:TextBox ID="PasswordTextBox" runat="server" TextMode="Password" 
                            placeholder="Enter your password"
                            CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                        <div class="flex space-x-1">
                            <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" 
                                ControlToValidate="PasswordTextBox" 
                                ErrorMessage="Password is required." 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                            <asp:RegularExpressionValidator ID="PasswordLength" runat="server" 
                                ControlToValidate="PasswordTextBox" 
                                ErrorMessage="Password must be at least 8 characters long." 
                                ValidationExpression=".{8,}" 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                        </div>
                        <p class="text-xs text-gray-500 mt-1">Must be at least 8 characters long</p>
                    </div>

                    <!-- Confirm Password -->
                    <div>
                        <asp:Label ID="ConfirmPasswordLabel" runat="server" AssociatedControlID="ConfirmPasswordTextBox" 
                            CssClass="block text-sm font-medium text-gray-700 mb-1">
                            <i class="fas fa-lock mr-2 text-blue-600"></i>
                            Confirm Password
                        </asp:Label>
                        <asp:TextBox ID="ConfirmPasswordTextBox" runat="server" TextMode="Password" 
                            placeholder="Confirm your password"
                            CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                        <div class="flex space-x-1">
                            <asp:RequiredFieldValidator ID="ConfirmPasswordRequired" runat="server" 
                                ControlToValidate="ConfirmPasswordTextBox" 
                                ErrorMessage="Please confirm your password." 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                            <asp:CompareValidator ID="PasswordCompare" runat="server" 
                                ControlToValidate="ConfirmPasswordTextBox" 
                                ControlToCompare="PasswordTextBox" 
                                ErrorMessage="Password and confirmation password do not match." 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                        </div>
                        <p class="text-xs text-gray-500 mt-1">Re-enter your password</p>
                    </div>

                    <!-- Gender and Date of Birth Row -->
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div>
                            <asp:Label ID="GenderLabel" runat="server" AssociatedControlID="GenderDropDownList" 
                                CssClass="block text-sm font-medium text-gray-700 mb-1">Gender</asp:Label>
                            <asp:DropDownList ID="GenderDropDownList" runat="server" 
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                                <asp:ListItem Text="Select Gender" Value="" />
                                <asp:ListItem Text="Male" Value="Male" />
                                <asp:ListItem Text="Female" Value="Female" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="GenderRequired" runat="server" 
                                ControlToValidate="GenderDropDownList" 
                                ErrorMessage="Please select your gender." 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                        </div>
                        
                        <div>
                            <asp:Label ID="DateOfBirthLabel" runat="server" AssociatedControlID="DateOfBirthTextBox" 
                                CssClass="block text-sm font-medium text-gray-700 mb-1">Date of Birth</asp:Label>
                            <asp:TextBox ID="DateOfBirthTextBox" runat="server" TextMode="Date" 
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="DateOfBirthRequired" runat="server" 
                                ControlToValidate="DateOfBirthTextBox" 
                                ErrorMessage="Date of birth is required." 
                                Text="*" 
                                CssClass="text-red-600 text-sm" />
                        </div>
                    </div>

                    <div>
                        <asp:Label ID="NationalityLabel" runat="server" AssociatedControlID="NationalityDropDownList" 
                            CssClass="block text-sm font-medium text-gray-700 mb-1">Nationality</asp:Label>
                        <asp:DropDownList ID="NationalityDropDownList" runat="server" 
                            CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                            <asp:ListItem Text="Select Nationality" Value="" />
                            <asp:ListItem Text="Afghan" Value="Afghan" />
                            <asp:ListItem Text="American" Value="American" />
                            <asp:ListItem Text="Australian" Value="Australian" />
                            <asp:ListItem Text="Bangladeshi" Value="Bangladeshi" />
                            <asp:ListItem Text="British" Value="British" />
                            <asp:ListItem Text="Canadian" Value="Canadian" />
                            <asp:ListItem Text="Chinese" Value="Chinese" />
                            <asp:ListItem Text="French" Value="French" />
                            <asp:ListItem Text="German" Value="German" />
                            <asp:ListItem Text="Indian" Value="Indian" />
                            <asp:ListItem Text="Indonesian" Value="Indonesian" />
                            <asp:ListItem Text="Italian" Value="Italian" />
                            <asp:ListItem Text="Japanese" Value="Japanese" />
                            <asp:ListItem Text="Malaysian" Value="Malaysian" />
                            <asp:ListItem Text="Mexican" Value="Mexican" />
                            <asp:ListItem Text="Pakistani" Value="Pakistani" />
                            <asp:ListItem Text="Philippine" Value="Philippine" />
                            <asp:ListItem Text="Singaporean" Value="Singaporean" />
                            <asp:ListItem Text="South Korean" Value="South-korean" />
                            <asp:ListItem Text="Spanish" Value="Spanish" />
                            <asp:ListItem Text="Thai" Value="Thai" />
                            <asp:ListItem Text="Vietnamese" Value="Vietnamese" />
                            <asp:ListItem Text="Other" Value="Other" />
                        </asp:DropDownList>
                        <asp:RequiredFieldValidator ID="NationalityRequired" runat="server" 
                            ControlToValidate="NationalityDropDownList" 
                            ErrorMessage="Please select your nationality." 
                            Text="*" 
                            CssClass="text-red-600 text-sm" />
                    </div>

                    <!-- Terms and Conditions -->
                    <div class="flex items-start space-x-3">
                        <div class="flex items-center h-5 mt-0.5">
                            <asp:CheckBox ID="TermsCheckBox" runat="server" 
                                CssClass="h-4 w-4 text-blue-600 focus:ring-blue-500 border-gray-300 rounded" />
                        </div>
                        <div class="text-sm">
                            <asp:Label ID="TermsLabel" runat="server" AssociatedControlID="TermsCheckBox" 
                                CssClass="text-gray-600">
                                I agree to the <a href="#" class="text-blue-600 hover:text-blue-500 underline">Terms and Conditions</a> and <a href="#" class="text-blue-600 hover:text-blue-500 underline">Privacy Policy</a>
                            </asp:Label>
                            <asp:CustomValidator ID="TermsRequired" runat="server" 
                                OnServerValidate="TermsRequired_ServerValidate"
                                ClientValidationFunction="validateTermsCheckbox"
                                ErrorMessage="You must agree to the terms and conditions." 
                                Text="*" 
                                CssClass="text-red-600 text-sm ml-1" />
                        </div>
                    </div>

                    <div class="pt-4">
                        <asp:Button ID="RegisterButton" runat="server" Text="Create Account" 
                            OnClick="RegisterButton_Click"
                            CssClass="w-full flex justify-center items-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-300 ease-in-out" />
                    </div>

                    <div class="text-center pt-2">
                        <a href="login.aspx" class="text-blue-600 hover:text-blue-500 text-sm font-medium">
                            Already have an account? Sign in
                        </a>
                    </div>

                    <div class="text-center">
                        <a href="home.aspx" class="text-gray-600 hover:text-gray-800 text-sm">
                            ← Back to Home
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>