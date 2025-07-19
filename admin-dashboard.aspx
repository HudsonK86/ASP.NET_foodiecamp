<%@ Page Title="Admin Dashboard" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="admin-dashboard.aspx.cs" Inherits="Hope.admin_dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
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
            <a href="admin-dashboard.aspx" class="flex items-center px-4 py-3 text-white bg-blue-600">
                <i class="fas fa-tachometer-alt mr-3"></i>
                Dashboard
            </a>
            <a href="admin-cuisine.aspx" class="flex items-center px-4 py-3 text-gray-700 hover:bg-blue-50 hover:text-blue-600">
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

            <!-- Add these hidden fields -->
            <asp:HiddenField ID="UserBlockedHidden" runat="server" Value="0" />
            <asp:HiddenField ID="UserActiveHidden" runat="server" Value="0" />
            <asp:HiddenField ID="UserInactiveHidden" runat="server" Value="0" />
            <asp:HiddenField ID="CuisineProgressHidden" runat="server" Value="[]" />
            <asp:HiddenField ID="CuisineRatingsHidden" runat="server" Value="[]" />
            
            <h1 class="text-3xl font-bold text-gray-800 mb-8">Admin Dashboard</h1>
            
            <!-- Basic Analytics -->
            <div class="analytics-grid">
                <!-- Total Recipes -->
                <div class="analytics-card">
                    <i class="fas fa-book icon text-green-600"></i>
                    <div class="content">
                        <h3 class="title">Total Recipes</h3>
                        <p class="subtitle">
                            Pending: <asp:Label ID="RecipePendingLabel" runat="server" Text="0"></asp:Label> | 
                            Approved: <asp:Label ID="RecipeApprovedLabel" runat="server" Text="0"></asp:Label> | 
                            Rejected: <asp:Label ID="RecipeRejectedLabel" runat="server" Text="0"></asp:Label>
                        </p>
                        <p class="value text-green-600">
                            <asp:Label ID="RecipeTotalLabel" runat="server" Text="0"></asp:Label>
                        </p>
                    </div>
                </div>

                <!-- Total Events -->
                <div class="analytics-card">
                    <i class="fas fa-calendar icon text-purple-600"></i>
                    <div class="content">
                        <h3 class="title">Total Events</h3>
                        <p class="subtitle">
                            Pending: <asp:Label ID="EventPendingLabel" runat="server" Text="0"></asp:Label> | 
                            Approved: <asp:Label ID="EventApprovedLabel" runat="server" Text="0"></asp:Label> | 
                            Rejected: <asp:Label ID="EventRejectedLabel" runat="server" Text="0"></asp:Label>
                        </p>
                        <p class="value text-purple-600">
                            <asp:Label ID="EventTotalLabel" runat="server" Text="0"></asp:Label>
                        </p>
                    </div>
                </div>

                <!-- Total Inquiries -->
                <div class="analytics-card">
                    <i class="fas fa-envelope icon text-red-600"></i>
                    <div class="content">
                        <h3 class="title">Total Inquiries</h3>
                        <p class="subtitle">
                            Pending: <asp:Label ID="InquiryPendingLabel" runat="server" Text="0"></asp:Label> | 
                            Solved: <asp:Label ID="InquirySolvedLabel" runat="server" Text="0"></asp:Label>
                        </p>
                        <p class="value text-red-600">
                            <asp:Label ID="InquiryTotalLabel" runat="server" Text="0"></asp:Label>
                        </p>
                    </div>
                </div>
            </div>
           
            <!-- Charts -->
            <div class="chart-grid">
                <!-- User Status Pie Chart -->
                <div class="chart-card">
                    <h3 class="chart-title">User Status Distribution</h3>
                    <div class="chart-container">
                        <canvas id="userStatusChart" width="300" height="300"></canvas>
                    </div>
                </div>
                
                <!-- Cuisine Learning Progress -->
                <div class="chart-card">
                    <h3 class="chart-title">Cuisine Learning Progress</h3>
                    <div class="chart-container">
                        <canvas id="cuisineProgressChart" width="400" height="300"></canvas>
                    </div>
                </div>
            </div>

            <!-- Overall Cuisine Ratings -->
            <div class="full-width-chart">
                <h3 class="chart-title">Overall Cuisine Ratings</h3>
                <div class="chart-container">
                    <canvas id="cuisineRatingsChart" width="800" height="400"></canvas>
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

        // Initialize charts when page loads
        document.addEventListener('DOMContentLoaded', function () {
            initializeUserStatusChart();
            initializeCuisineProgressChart();
            initializeCuisineRatingsChart();
        });

        function initializeUserStatusChart() {
            // Get user statistics from hidden fields
            const blockedUsers = parseInt(document.getElementById('<%= UserBlockedHidden.ClientID %>').value) || 0;
            const activeUsers = parseInt(document.getElementById('<%= UserActiveHidden.ClientID %>').value) || 0;
            const inactiveUsers = parseInt(document.getElementById('<%= UserInactiveHidden.ClientID %>').value) || 0;

            // Check if Chart.js is loaded
            if (typeof Chart === 'undefined') {
                console.error('Chart.js is not loaded');
                document.getElementById('userStatusChart').parentElement.innerHTML = '<p class="text-red-500">Chart.js library not found</p>';
                return;
            }

            const ctx = document.getElementById('userStatusChart');
            if (!ctx) {
                console.error('Canvas element not found');
                return;
            }

            try {
                new Chart(ctx.getContext('2d'), {
                    type: 'pie',
                    data: {
                        labels: ['Active Users', 'Inactive Users', 'Blocked Users'],
                        datasets: [{
                            data: [activeUsers, inactiveUsers, blockedUsers],
                            backgroundColor: [
                                '#10B981', // Green for active
                                '#F59E0B', // Yellow for inactive
                                '#EF4444'  // Red for blocked
                            ],
                            borderColor: [
                                '#059669',
                                '#D97706',
                                '#DC2626'
                            ],
                            borderWidth: 2
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'bottom',
                                labels: {
                                    padding: 20,
                                    usePointStyle: true
                                }
                            },
                            tooltip: {
                                callbacks: {
                                    label: function (context) {
                                        const total = context.dataset.data.reduce((a, b) => a + b, 0);
                                        const percentage = total > 0 ? ((context.parsed * 100) / total).toFixed(1) : 0;
                                        return context.label + ': ' + context.parsed + ' (' + percentage + '%)';
                                    }
                                }
                            }
                        }
                    }
                });
            } catch (error) {
                console.error('Error creating pie chart:', error);
                document.getElementById('userStatusChart').parentElement.innerHTML = '<p class="text-red-500">Error loading chart</p>';
            }
        }

        function initializeCuisineProgressChart() {
            // Get cuisine progress data from hidden field
            let cuisineData = [];
            try {
                const progressData = document.getElementById('<%= CuisineProgressHidden.ClientID %>').value;
                cuisineData = JSON.parse(progressData);
            } catch (error) {
                console.error('Error parsing cuisine progress data:', error);
                cuisineData = [];
            }

            if (!cuisineData || cuisineData.length === 0) {
                document.getElementById('cuisineProgressChart').parentElement.innerHTML = '<p class="text-gray-500">No cuisine data available</p>';
                return;
            }

            const ctx = document.getElementById('cuisineProgressChart');
            if (!ctx) {
                console.error('Cuisine progress canvas element not found');
                return;
            }

            const labels = cuisineData.map(item => item.CuisineName);
            const data = cuisineData.map(item => item.ProgressPercentage);

            try {
                new Chart(ctx.getContext('2d'), {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Completion Rate (%)',
                            data: data,
                            backgroundColor: '#3B82F6',
                            borderColor: '#2563EB',
                            borderWidth: 1
                        }]
                    },
                    options: {
                        indexAxis: 'y', // This makes it a horizontal bar chart
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            x: {
                                beginAtZero: true,
                                max: 100,
                                ticks: {
                                    callback: function (value) {
                                        return value + '%';
                                    }
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: function (context) {
                                        return context.parsed.x.toFixed(1) + '%';
                                    }
                                }
                            }
                        }
                    }
                });
            } catch (error) {
                console.error('Error creating cuisine progress chart:', error);
                document.getElementById('cuisineProgressChart').parentElement.innerHTML = '<p class="text-red-500">Error loading chart</p>';
            }
        }

        function initializeCuisineRatingsChart() {
            // Get cuisine ratings data from hidden field
            let cuisineRatings = [];
            try {
                const ratingsData = document.getElementById('<%= CuisineRatingsHidden.ClientID %>').value;
                cuisineRatings = JSON.parse(ratingsData);
            } catch (error) {
                console.error('Error parsing cuisine ratings data:', error);
                cuisineRatings = [];
            }

            if (!cuisineRatings || cuisineRatings.length === 0) {
                document.getElementById('cuisineRatingsChart').parentElement.innerHTML = '<p class="text-gray-500">No cuisine ratings available</p>';
                return;
            }

            const ctx = document.getElementById('cuisineRatingsChart');
            if (!ctx) {
                console.error('Cuisine ratings canvas element not found');
                return;
            }

            const labels = cuisineRatings.map(item => item.CuisineName);
            const data = cuisineRatings.map(item => item.AverageRating);

            // Generate colors for each bar (similar to your image)
            const colors = [
                '#8B5CF6', // Purple
                '#3B82F6', // Blue
                '#10B981', // Green
                '#F59E0B', // Yellow
                '#EF4444', // Red
                '#6366F1'  // Indigo
            ];

            try {
                new Chart(ctx.getContext('2d'), {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                            label: 'Average Rating',
                            data: data,
                            backgroundColor: colors.slice(0, labels.length),
                            borderColor: colors.slice(0, labels.length).map(color => color.replace('F6', 'E5')),
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        scales: {
                            y: {
                                beginAtZero: true,
                                max: 5,
                                ticks: {
                                    stepSize: 0.5,
                                    callback: function (value) {
                                        return value.toFixed(1);
                                    }
                                },
                                title: {
                                    display: true,
                                    text: 'Rating (1-5 stars)'
                                }
                            },
                            x: {
                                title: {
                                    display: true,
                                    text: 'Cuisine Types'
                                }
                            }
                        },
                        plugins: {
                            legend: {
                                display: false
                            },
                            tooltip: {
                                callbacks: {
                                    label: function (context) {
                                        return 'Average Rating: ' + context.parsed.y.toFixed(1) + ' stars';
                                    }
                                }
                            }
                        }
                    }
                });
            } catch (error) {
                console.error('Error creating cuisine ratings chart:', error);
                document.getElementById('cuisineRatingsChart').parentElement.innerHTML = '<p class="text-red-500">Error loading chart</p>';
            }
        }
    </script>
</asp:Content>