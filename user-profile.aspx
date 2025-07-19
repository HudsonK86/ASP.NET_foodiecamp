<%@ Page Title="User Profile" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="user-profile.aspx.cs" Inherits="Hope.user_profile" %>
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
            <a href="user-notification.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-bell mr-3"></i>
                Notification
            </a>
            <a href="user-profile.aspx" class="flex items-center px-4 py-3 text-white bg-blue-600">
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

    <!-- Main Content -->
    <div class="admin-main-content bg-gray-50 min-h-screen">
        <div class="p-8">
            <!-- Success/Error Message Panel -->
            <asp:Panel ID="MessagePanel" runat="server" Visible="false">
                <div class="flex items-center">
                    <asp:Label ID="MessageLabel" runat="server" CssClass="font-medium"></asp:Label>
                    <button type="button" onclick="this.parentElement.style.display='none'" class="ml-auto text-gray-600 hover:text-gray-800">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </asp:Panel>

            <!-- Profile Form -->
            <div class="max-w-4xl mx-auto bg-white rounded-lg shadow-md overflow-hidden">
                <div class="px-6 py-4 border-b border-gray-200">
                    <h2 class="text-xl font-bold text-gray-800">Profile Settings</h2>
                </div>

                <div class="p-6">
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                        <!-- Profile Image Section -->
                        <div class="md:col-span-2">
                            <label class="block text-sm font-medium text-gray-700 mb-2">Profile Image</label>
                            <div class="flex items-center space-x-6">
                                <div class="w-32 h-32 rounded-full overflow-hidden bg-gray-100">
                                    <asp:Image ID="CurrentProfileImage" runat="server" CssClass="w-full h-full object-cover" Visible="false" />
                                    <asp:Image ID="DefaultProfileImage" runat="server" CssClass="w-full h-full object-cover" ImageUrl="~/images/profiles/default-avatar.png" />
                                </div>
                                <div class="flex-1">
                                    <asp:FileUpload ID="ProfileImageUpload" runat="server" 
                                        CssClass="block w-full text-sm text-gray-500 file:mr-4 file:py-2 file:px-4 file:rounded-full file:border-0 file:text-sm file:font-semibold file:bg-blue-50 file:text-blue-700 hover:file:bg-blue-100"
                                        onchange="previewImage(this)" />
                                    <p class="mt-2 text-sm text-gray-500">
                                        Recommended: JPG, PNG, or GIF (Max. 2MB)
                                    </p>
                                </div>
                            </div>
                        </div>

                        <!-- Personal Information -->
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">First Name</label>
                            <asp:TextBox ID="FirstNameTextBox" runat="server" 
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="FirstNameRequired" runat="server" 
                                ControlToValidate="FirstNameTextBox"
                                ErrorMessage="First name is required"
                                Display="Dynamic"
                                CssClass="text-red-600 text-sm mt-1" />
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Last Name</label>
                            <asp:TextBox ID="LastNameTextBox" runat="server" 
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="LastNameRequired" runat="server" 
                                ControlToValidate="LastNameTextBox"
                                ErrorMessage="Last name is required"
                                Display="Dynamic"
                                CssClass="text-red-600 text-sm mt-1" />
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Email Address</label>
                            <asp:TextBox ID="EmailTextBox" runat="server" ReadOnly="true"
                                CssClass="w-full px-3 py-2 bg-gray-50 border border-gray-300 rounded-md shadow-sm text-gray-500" />
                            <p class="mt-1 text-sm text-gray-500">Contact support to change email address</p>
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Phone Number</label>
                            <asp:TextBox ID="PhoneTextBox" runat="server"
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="PhoneRequired" runat="server"
                                ControlToValidate="PhoneTextBox"
                                ErrorMessage="Phone number is required"
                                Display="Dynamic"
                                CssClass="text-red-600 text-sm mt-1" />
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Gender</label>
                            <asp:DropDownList ID="GenderDropDownList" runat="server" 
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                                <asp:ListItem Text="Select Gender" Value="" />
                                <asp:ListItem Text="Male" Value="Male" />
                                <asp:ListItem Text="Female" Value="Female" />
                                <asp:ListItem Text="Other" Value="Other" />
                            </asp:DropDownList>
                            <asp:RequiredFieldValidator ID="GenderRequired" runat="server" 
                                ControlToValidate="GenderDropDownList"
                                ErrorMessage="Please select your gender"
                                Display="Dynamic"
                                CssClass="text-red-600 text-sm mt-1" />
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Date of Birth</label>
                            <asp:TextBox ID="DateOfBirthTextBox" runat="server" TextMode="Date"
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="DateOfBirthRequired" runat="server" 
                                ControlToValidate="DateOfBirthTextBox"
                                ErrorMessage="Date of birth is required"
                                Display="Dynamic"
                                CssClass="text-red-600 text-sm mt-1" />
                        </div>

                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-2">Nationality</label>
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
                                ErrorMessage="Please select your nationality"
                                Display="Dynamic"
                                CssClass="text-red-600 text-sm mt-1" />
                        </div>
                    </div>

                    <!-- Save Button -->
                    <div class="mt-6 text-right">
                        <asp:Button ID="SaveButton" runat="server" Text="Save Changes" OnClick="SaveButton_Click"
                            CssClass="inline-flex justify-center py-2 px-4 border border-transparent shadow-sm text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500" />
                        <button type="button" class="inline-flex justify-center py-2 px-4 border border-blue-600 shadow-sm text-sm font-medium rounded-md text-blue-600 bg-white hover:bg-blue-50 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500"
                            onclick="showChangePasswordModal()">Change Password</button>
                    </div>

                    <!-- Change Password Modal -->
                    <div id="changePasswordModal" class="fixed inset-0 bg-black bg-opacity-40 items-center justify-center z-50 hidden">
                        <div class="bg-white rounded-lg shadow-lg max-w-md w-full p-6 relative">
                            <h3 class="text-lg font-bold text-gray-800 mb-4">Change Password</h3>
                            <asp:Panel ID="ChangePasswordMessagePanel" runat="server" Visible="false">
                                <asp:Label ID="ChangePasswordMessageLabel" runat="server" CssClass="block text-sm font-medium p-3 rounded-md"></asp:Label>
                            </asp:Panel>
                            <asp:TextBox ID="CurrentPasswordTextBox" runat="server" TextMode="Password" placeholder="Current Password"
                                autocomplete="new-password"
                                CssClass="w-full mb-3 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:TextBox ID="NewPasswordTextBox" runat="server" TextMode="Password" placeholder="New Password"
                                autocomplete="new-password"
                                CssClass="w-full mb-3 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:TextBox ID="ConfirmPasswordTextBox" runat="server" TextMode="Password" placeholder="Confirm New Password"
                                autocomplete="new-password"
                                CssClass="w-full mb-4 px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <div class="flex justify-end space-x-2">
                                <button type="button" class="px-4 py-2 rounded bg-gray-200 text-gray-700 hover:bg-gray-300" onclick="closeChangePasswordModal()">Cancel</button>
                                <asp:Button ID="ChangePasswordButton" runat="server" Text="Change Password" OnClick="ChangePasswordButton_Click"
                                    CssClass="px-4 py-2 rounded bg-blue-600 text-white hover:bg-blue-700" />
                            </div>
                            <button type="button" class="absolute top-2 right-2 text-gray-400 hover:text-gray-600" onclick="closeChangePasswordModal()">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        function showChangePasswordModal() {
            var modal = document.getElementById('changePasswordModal');
            modal.classList.remove('hidden');
            modal.classList.add('flex');
            document.body.style.overflow = 'hidden';

            // Clear all password fields when modal opens
            document.getElementById('<%= CurrentPasswordTextBox.ClientID %>').value = '';
            document.getElementById('<%= NewPasswordTextBox.ClientID %>').value = '';
            document.getElementById('<%= ConfirmPasswordTextBox.ClientID %>').value = '';

            // Hide any previous error messages
            var messagePanel = document.getElementById('<%= ChangePasswordMessagePanel.ClientID %>');
            if (messagePanel) {
                messagePanel.style.display = 'none';
            }
    function closeChangePasswordModal() {
        var modal = document.getElementById('changePasswordModal');
        modal.classList.add('hidden');
        modal.classList.remove('flex');
        document.body.style.overflow = 'auto';

        // Clear all password fields when modal closes
        document.getElementById('<%= CurrentPasswordTextBox.ClientID %>').value = '';
        document.getElementById('<%= NewPasswordTextBox.ClientID %>').value = '';
        document.getElementById('<%= ConfirmPasswordTextBox.ClientID %>').value = '';
    }
        document.getElementById('<%= ConfirmPasswordTextBox.ClientID %>').value = '';
    }
    
    function previewImage(input) {
        if (input.files && input.files[0]) {
            var reader = new FileReader();
            reader.onload = function (e) {
                document.getElementById('<%= CurrentProfileImage.ClientID %>').src = e.target.result;
            document.getElementById('<%= CurrentProfileImage.ClientID %>').style.display = 'block';
            document.getElementById('<%= DefaultProfileImage.ClientID %>').style.display = 'none';
                }
                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>
</asp:Content>