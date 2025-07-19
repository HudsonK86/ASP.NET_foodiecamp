<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="admin-cuisine.aspx.cs" Inherits="Hope.admin_cuisine" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            z-index: 1000;
        }

        .modal-content {
            position: fixed;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            background: white;
            padding: 2rem;
            border-radius: 0.5rem;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.3);
            max-width: 600px; 
            width: 90%;
            z-index: 1001;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- Main Page Success Message Panel -->
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
    
    <!-- Admin Sidebar -->
    <div class="admin-sidebar bg-white shadow-lg fixed left-0 top-16 z-40">
        <div class="p-4 border-b">
            <div class="flex items-center">
                <asp:Image ID="AdminProfileImage" runat="server" 
                    ImageUrl="https://via.placeholder.com/80x80" 
                    AlternateText="Admin Profile"
                    CssClass="w-20 h-20 rounded-full mr-4 object-cover" />
                <div>
                    <asp:Label ID="AdminNameLabel" runat="server" 
                        Text="Admin" 
                        CssClass="text-lg font-bold text-gray-800 block"></asp:Label>
                    <span class="text-sm text-gray-600">Administrator</span>
                </div>
            </div>
        </div>
        <nav class="mt-4">
            <a href="admin-dashboard.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-tachometer-alt mr-3"></i>
                Dashboard
            </a>
            <a href="admin-cuisine.aspx" class="flex items-center px-4 py-3 text-white bg-blue-600">
                <i class="fas fa-utensils mr-3"></i>
                Cuisine
            </a>
            <a href="admin-recipe.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-book mr-3"></i>
                Recipe
            </a>
            <a href="admin-review.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-star mr-3"></i>
                Review
            </a>
            <a href="admin-event.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-calendar mr-3"></i>
                Event
            </a>
            <a href="admin-user.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-users mr-3"></i>
                User
            </a>
            <a href="admin-inquiry.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-envelope mr-3"></i>
                Inquiry
            </a>
            <a href="admin-profile.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
                <i class="fas fa-cog mr-3"></i>
                Profile
            </a>
        </nav>
        <div class="absolute bottom-4 left-4 right-4">
            <asp:LinkButton ID="AdminLogoutButton" runat="server" OnClick="AdminLogoutButton_Click"
                CssClass="flex items-center justify-center w-full px-4 py-3 text-white bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors">
                <i class="fas fa-sign-out-alt mr-2"></i>
                Logout
            </asp:LinkButton>
        </div>
    </div>

    <!-- Main Content -->
    <div class="admin-main-content bg-gray-50 min-h-screen">
        <div class="p-8">
            <!-- Mobile Menu Button -->
            <div class="md:hidden mb-4">
                <button onclick="toggleAdminSidebar()" class="bg-blue-600 text-white px-4 py-2 rounded-lg">
                    <i class="fas fa-bars mr-2"></i>Menu
                </button>
            </div>

            <h1 class="text-3xl font-bold text-gray-800 mb-8">Manage Cuisines</h1>
    
            <!-- Cuisine Section -->
            <div class="py-16 bg-white">
                <div class="max-w-7xl mx-auto px-4">
                    <div class="grid md:grid-cols-3 gap-8" id="cuisine-container">
                        <!-- Dynamic Cuisine Cards from Database -->
                        <asp:Repeater ID="CuisineRepeater" runat="server">
                            <ItemTemplate>
                                <div class="cuisine-card bg-white rounded-xl shadow-lg card-hover transition-all duration-300">
                                    <img src='<%# ResolveUrl(Eval("FullImagePath").ToString()) %>' 
                                         alt='<%# Eval("CuisineName") %> Cuisine' 
                                         class="cuisine-image w-full h-48 object-cover rounded-t-xl"
                                         onerror="this.src='https://images.unsplash.com/photo-1565557623262-b51c2513a641?w=400&h=250&fit=crop';" />
                                    <div class="p-6">
                                        <h3 class="cuisine-name text-xl font-semibold text-gray-800 mb-4 text-center"><%# Eval("CuisineName") %></h3>
                                        <!-- CHANGED: Use ASP.NET Button instead of HTML button -->
                                        <asp:Button ID="EditButton" runat="server" 
                                            Text="Edit" 
                                            CssClass="w-full bg-blue-600 text-white py-2 rounded-lg hover:bg-blue-700 transition"
                                            CommandName="Edit"
                                            CommandArgument='<%# Eval("CuisineId") %>'
                                            OnCommand="EditButton_Command" />
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
        </div>
    </div>

    <!-- Simple Modal Panel -->
    <asp:Panel ID="EditModal" runat="server" Visible="false" CssClass="modal-overlay">
        <div class="modal-content">
            <h2 class="text-2xl font-bold text-gray-800 mb-4">Edit Cuisine Picture</h2>
               
            <!-- Modal Error Message Panel -->
            <asp:Panel ID="ModalErrorPanel" runat="server" Visible="false" CssClass="mb-4">
                <div class="bg-red-50 border border-red-200 text-red-800 px-4 py-3 rounded-lg">
                    <div class="flex items-center">
                        <i class="fas fa-exclamation-triangle text-red-600 mr-3"></i>
                        <asp:Label ID="ModalErrorLabel" runat="server" CssClass="font-medium"></asp:Label>
                    </div>
                </div>
            </asp:Panel>

            <!-- Current Cuisine Info -->
            <div class="text-center mb-6">
                <h3 class="text-lg font-semibold mb-4">
                    <asp:Label ID="ModalCuisineName" runat="server" Text="" CssClass="bg-blue-500 text-white px-3 py-1 rounded"></asp:Label>
                </h3>
                <!-- Made image much bigger: was w-32 h-20, now w-64 h-40 -->
                <asp:Image ID="ModalCurrentImage" runat="server" 
                    CssClass="w-64 h-40 object-cover rounded-lg border-2 border-gray-300 shadow-md" />
            </div>
    
            <!-- File Upload -->
            <div class="mb-6">
                <label class="block text-sm font-medium text-gray-700 mb-2">Upload New Picture</label>
                <asp:FileUpload ID="CuisineFileUpload" runat="server" 
                    CssClass="w-full p-2 border border-gray-300 rounded" 
                    accept="image/*"
                    onchange="previewImage(this)" />
                <p class="text-xs text-gray-500 mt-1">Supported formats: JPG, PNG, GIF (Max: 10MB)</p>
            </div>
    
            <!-- Buttons -->
            <div class="flex justify-end space-x-3">
                <asp:Button ID="CancelButton" runat="server" 
                    Text="Cancel" 
                    CssClass="px-6 py-2 border border-gray-300 rounded-md text-gray-700 hover:bg-gray-50 transition"
                    OnClick="CancelButton_Click" />
                <asp:Button ID="SaveButton" runat="server" 
                    Text="Save Changes" 
                    CssClass="px-6 py-2 bg-blue-600 text-white rounded-md hover:bg-blue-700 transition"
                    OnClick="SaveButton_Click" />
            </div>
    
            <!-- Hidden field to store cuisine ID -->
            <asp:HiddenField ID="SelectedCuisineId" runat="server" />
        </div>
    </asp:Panel>

    <script>
        function toggleAdminSidebar() {
            const sidebar = document.querySelector('.admin-sidebar');
            sidebar.classList.toggle('mobile-open');
        }

        // Close sidebar when clicking outside on mobile
        document.addEventListener('click', function (event) {
            const sidebar = document.querySelector('.admin-sidebar');
            const menuButton = event.target.closest('button');

            if (!sidebar.contains(event.target) && !menuButton) {
                sidebar.classList.remove('mobile-open');
            }
        });

        // Image preview function
        function previewImage(input) {
            if (input.files && input.files[0]) {
                const reader = new FileReader();

                reader.onload = function (e) {
                    // Find the modal image and update it with the new selected image
                    const modalImage = document.querySelector('[id*="ModalCurrentImage"]');
                    if (modalImage) {
                        modalImage.src = e.target.result;
                        // Add a subtle animation to show the change
                        modalImage.style.opacity = '0.5';
                        setTimeout(() => {
                            modalImage.style.opacity = '1';
                        }, 100);
                    }
                };

                reader.readAsDataURL(input.files[0]);
            }
        }
    </script>  
</asp:Content>
