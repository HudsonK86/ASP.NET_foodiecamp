<%@ Page Title="Recipes" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="recipes.aspx.cs" Inherits="Hope.recipes" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="pt-16">
        <!-- Cuisine Grid -->
        <div class="py-16 bg-white">
            <div class="max-w-7xl mx-auto px-4">
                <h1 class="text-4xl font-bold text-center text-gray-800 mb-12">Explore Recipes by Cuisine</h1>
                
                <!-- Search and Filter Section -->
                <div class="bg-gray-50 rounded-lg p-6 mb-8">
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4 items-end">
                        <!-- Cuisine Selector -->
                        <div>
                            <label for="cuisine-select" class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fas fa-globe mr-2 text-blue-600"></i>
                                Select Cuisine
                            </label>
                            <asp:DropDownList ID="CuisineFilter" runat="server"
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed">
                            </asp:DropDownList>
                        </div>
                        
                        <!-- Search Bar -->
                        <div>
                            <label for="recipe-search" class="block text-sm font-medium text-gray-700 mb-2">
                                <i class="fas fa-search mr-2 text-blue-600"></i>
                                Search Recipes
                            </label>
                            <asp:TextBox ID="SearchBox" runat="server"
                                CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                placeholder="Search by recipe name, ingredient..."
                                AutoPostBack="true" OnTextChanged="Filter_Changed" />
                        </div>
                        
                        <!-- Post Recipe Button -->
                        <div>
                            <% if (Session["IsLoggedIn"] != null && (bool)Session["IsLoggedIn"]) { %>
                                <a href="post-recipe.aspx" class="w-full bg-blue-600 text-white py-2 px-4 rounded-md hover:bg-blue-700 transition duration-300 flex items-center justify-center">
                                    <i class="fas fa-plus mr-2"></i>
                                    Post Recipe
                                </a>
                            <% } %>
                        </div>
                    </div>
                </div>

                <!-- Recipes Grid -->
                 <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6" id="bookmarks-grid">
                    <asp:Repeater ID="RecipesRepeater" runat="server">
                        <ItemTemplate>
                            <div class="bg-white rounded-lg shadow-md overflow-hidden recipe-card mb-4">
                                <div class="relative">
                                    <img src='<%# Eval("RecipeImageUrl") %>' alt='<%# Eval("RecipeName") %>' class="w-full h-48 object-cover" />
                                    <%# ((bool)Eval("ShowBookmark") && (bool)Eval("IsBookmarked")) ? "<span class='bg-white bg-opacity-90 text-gray-700 px-2 py-1 rounded-full text-xs font-medium absolute top-2 right-2 flex items-center'><i class=\"fas fa-bookmark text-blue-600 mr-1\"></i>Bookmarked</span>" : "" %>
                                    <%# ((bool)Eval("ShowCompleted") && (bool)Eval("IsCompleted")) ? "<span class='bg-green-500 text-white px-2 py-1 rounded-full text-xs font-medium absolute top-2 left-2 flex items-center'><i class='fas fa-check mr-1'></i>Completed</span>" : "" %>
                                </div>
                                <div class="p-4">
                                    <h3 class="text-lg font-semibold text-gray-800 mb-2"><%# Eval("RecipeName") %></h3>
                                    <div class="flex items-center text-sm text-gray-600 mb-2">
                                        <i class="fas fa-user mr-2 text-blue-600"></i>
                                        <span>Posted by <%# Eval("PostedBy") %></span>
                                    </div>
                                    <div class="flex items-center text-sm text-gray-600 mb-3">
                                        <i class="fas fa-calendar mr-2 text-blue-600"></i>
                                        <span><%# Eval("DateCreated", "{0:MMMM dd, yyyy}") %></span>
                                    </div>
                                    <div class="flex items-center mb-4">
                                        <div class="flex text-yellow-400">
                                            <%# Eval("StarHtml") %>
                                        </div>
                                        <span class="ml-2 text-gray-600 text-sm"><%# Eval("AverageRatingText") %></span>
                                    </div>
                                    <div class="flex space-x-2">
                                        <a href='recipe-detail.aspx?id=<%# Eval("RecipeId") %>' class="w-full bg-blue-600 hover:bg-blue-700 text-white text-sm py-2 px-3 rounded-lg text-center transition-colors">
                                            View Recipe
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>

                <!-- Pagination -->
                <asp:Panel ID="PaginationPanel" runat="server" CssClass="flex justify-center items-center space-x-2 mt-8" Visible="false">
                    <asp:Button ID="PrevPageButton" runat="server" Text="Previous" CssClass="px-4 py-2 bg-gray-300 rounded" OnClick="PrevPageButton_Click" />
                    <asp:Repeater ID="PageNumbersRepeater" runat="server" OnItemCommand="PageNumbersRepeater_ItemCommand">
                        <ItemTemplate>
                            <asp:LinkButton runat="server"
                                CommandName="Page"
                                CommandArgument='<%# Container.DataItem %>'
                                Text='<%# (int)Container.DataItem + 1 %>'
                                CssClass='<%# (int)Container.DataItem == ((Hope.recipes)Page).PageIndex ? "bg-blue-600 text-white px-3 py-1 rounded" : "bg-gray-200 text-gray-700 px-3 py-1 rounded" %>' />
                        </ItemTemplate>
                    </asp:Repeater>
                    <asp:Button ID="NextPageButton" runat="server" Text="Next" CssClass="px-4 py-2 bg-gray-300 rounded" OnClick="NextPageButton_Click" />
                </asp:Panel>
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
    // Set cuisine filter from query string on page load
    window.addEventListener('DOMContentLoaded', function () {
        var urlParams = new URLSearchParams(window.location.search);
        var cuisine = urlParams.get('cuisine');
        if (cuisine) {
            var select = document.getElementById('cuisine-select');
            if (select) {
                select.value = cuisine;
            }
        }
    });
    </script>
</asp:Content>
