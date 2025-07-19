<%@ Page Title="User Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="user-dashboard.aspx.cs" Inherits="Hope.user_dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- User Sidebar -->
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
            <a href="user-dashboard.aspx" class="flex items-center px-4 py-3 text-white bg-blue-600">
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

    <!-- Main Content -->
    <div class="admin-main-content bg-gray-50 min-h-screen">
        <div class="p-8">
            <!-- Mobile Menu Button -->
            <div class="md:hidden mb-4">
                <button onclick="toggleAdminSidebar()" class="bg-blue-600 text-white px-4 py-2 rounded-lg">
                    <i class="fas fa-bars mr-2"></i>Menu
                </button>
            </div>

            <h1 class="text-3xl font-bold text-gray-800 mb-8">My Dashboard</h1>
            
            <!-- Stats Grid -->
            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-10">
                <!-- Total Recipes -->
                <div class="bg-white rounded-2xl shadow-lg p-8 flex flex-col items-start transition-transform duration-200 hover:-translate-y-1 hover:shadow-xl">
                    <div class="flex items-center mb-4">
                        <span class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-blue-100 mr-4">
                            <i class="fas fa-book text-2xl text-blue-600"></i>
                        </span>
                        <h3 class="text-xl font-semibold text-gray-800">Total Recipes</h3>
                    </div>
                    <div class="ml-2">
                        <p class="text-sm text-gray-600 mb-2 flex flex-wrap items-center gap-2">
                            <span>Pending: <span class="font-bold text-yellow-600"><asp:Label ID="RecipePendingLabel" runat="server" Text="0"></asp:Label></span></span>
                            <span class="mx-1">|</span>
                            <span>Approved: <span class="font-bold text-green-600"><asp:Label ID="RecipeApprovedLabel" runat="server" Text="0"></asp:Label></span></span>
                            <span class="mx-1">|</span>
                            <span>Rejected: <span class="font-bold text-red-600"><asp:Label ID="RecipeRejectedLabel" runat="server" Text="0"></asp:Label></span></span>
                        </p>
                        <p class="text-4xl font-extrabold text-blue-600"><asp:Label ID="RecipeTotalLabel" runat="server" Text="0"></asp:Label></p>
                    </div>
                </div>

                <!-- Total Events -->
                <div class="bg-white rounded-2xl shadow-lg p-8 flex flex-col items-start transition-transform duration-200 hover:-translate-y-1 hover:shadow-xl">
                    <div class="flex items-center mb-4">
                        <span class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-purple-100 mr-4">
                            <i class="fas fa-calendar text-2xl text-purple-600"></i>
                        </span>
                        <h3 class="text-xl font-semibold text-gray-800">Total Events</h3>
                    </div>
                    <div class="ml-2">
                        <p class="text-sm text-gray-600 mb-2 flex flex-wrap items-center gap-2">
                            <span>Pending: <span class="font-bold text-yellow-600"><asp:Label ID="EventPendingLabel" runat="server" Text="0"></asp:Label></span></span>
                            <span class="mx-1">|</span>
                            <span>Approved: <span class="font-bold text-green-600"><asp:Label ID="EventApprovedLabel" runat="server" Text="0"></asp:Label></span></span>
                            <span class="mx-1">|</span>
                            <span>Rejected: <span class="font-bold text-red-600"><asp:Label ID="EventRejectedLabel" runat="server" Text="0"></asp:Label></span></span>
                        </p>
                        <p class="text-4xl font-extrabold text-purple-600"><asp:Label ID="EventTotalLabel" runat="server" Text="0"></asp:Label></p>
                    </div>
                </div>

                <!-- Bookmarks -->
                <div class="bg-white rounded-2xl shadow-lg p-8 flex flex-col items-start transition-transform duration-200 hover:-translate-y-1 hover:shadow-xl">
                    <div class="flex items-center mb-4">
                        <span class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-green-100 mr-4">
                            <i class="fas fa-bookmark text-2xl text-green-600"></i>
                        </span>
                        <h3 class="text-xl font-semibold text-gray-800">Bookmarks</h3>
                    </div>
                    <div class="ml-2">
                        <p class="text-4xl font-extrabold text-green-600"><asp:Label ID="BookmarkTotalLabel" runat="server" Text="0"></asp:Label></p>
                    </div>
                </div>

                <!-- Completed Recipe -->
                <div class="bg-white rounded-2xl shadow-lg p-8 flex flex-col items-start transition-transform duration-200 hover:-translate-y-1 hover:shadow-xl">
                    <div class="flex items-center mb-4">
                        <span class="inline-flex items-center justify-center w-12 h-12 rounded-full bg-blue-100 mr-4">
                            <i class="fas fa-check-circle text-2xl text-blue-600"></i>
                        </span>
                        <h3 class="text-xl font-semibold text-gray-800">Completed Recipe</h3>
                    </div>
                    <div class="ml-2">
                        <p class="text-4xl font-extrabold text-blue-600"><asp:Label ID="CompletedTotalLabel" runat="server" Text="0"></asp:Label></p>
                    </div>
                </div>
            </div>
             
            <!-- Charts -->
            <div class="chart-grid">
                <!-- Learning Progress Chart -->
                <div class="chart-card">
                    <h3 class="chart-title">My Learning Progress by Cuisine</h3>
                    <div class="chart-container">
                        <canvas id="userLearningChart" width="400" height="300"></canvas>
                    </div>
                </div>
            </div>
        </div>
    </div>

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

            // Render the learning progress chart for the user dashboard (same logic as admin)
            document.addEventListener('DOMContentLoaded', function () {
                if (window.userLearningProgress && Array.isArray(window.userLearningProgress)) {
                    const ctx = document.getElementById('userLearningChart');
                    if (ctx && typeof Chart !== 'undefined') {
                        // Order cuisines as in admin-dashboard
                        const cuisineOrder = ["Chinese", "Malay", "Indian", "Western", "Thai", "Vietnamese"];
                        const progressMap = {};
                        window.userLearningProgress.forEach(item => {
                            progressMap[item.CuisineName] = item.ProgressPercentage;
                        });
                        const labels = cuisineOrder;
                        const data = cuisineOrder.map(name => progressMap[name] !== undefined ? progressMap[name] : 0);

                        new Chart(ctx.getContext('2d'), {
                            type: 'bar',
                            data: {
                                labels: labels,
                                datasets: [{
                                    label: 'My Progress (%)',
                                    data: data,
                                    backgroundColor: '#14b8a6',
                                    borderRadius: 6,
                                    maxBarThickness: 38
                                }]
                            },
                            options: {
                                indexAxis: 'y',
                                responsive: true,
                                maintainAspectRatio: false,
                                plugins: {
                                    legend: {
                                        display: true,
                                        position: 'top',
                                        labels: {
                                            font: {
                                                size: 16
                                            }
                                        }
                                    },
                                    tooltip: {
                                        callbacks: {
                                            label: function (context) {
                                                return context.dataset.label + ': ' + context.parsed.x + '%';
                                            }
                                        }
                                    }
                                },
                                scales: {
                                    x: {
                                        beginAtZero: true,
                                        max: 100,
                                        grid: {
                                            color: "#e5e7eb"
                                        },
                                        ticks: {
                                            font: {
                                                size: 15
                                            },
                                            callback: function (value) {
                                                return value + '%';
                                            }
                                        }
                                    },
                                    y: {
                                        grid: {
                                            color: "#e5e7eb"
                                        },
                                        ticks: {
                                            font: {
                                                size: 16
                                            }
                                        }
                                    }
                                }
                            }
                        });
                    }
                }
            });
    </script>
</asp:Content>