<%@ Page Title="Post Recipe" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="post-recipe.aspx.cs" Inherits="Hope.post_recipe" %>
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
            <div class="text-center mb-8">
                <h1 class="text-4xl font-bold text-gray-900 mb-4">Share Your Recipe</h1>
                <p class="text-lg text-gray-600">Share your culinary creation with the FoodieCamp community</p>
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
            <!-- Post Recipe Form -->
            <div class="bg-white shadow-lg rounded-lg overflow-hidden">
                <asp:Panel ID="FormPanel" runat="server" CssClass="p-8 space-y-8">
                    <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="text-validation-error mb-4" />
                    <asp:Panel ID="BasicInfoPanel" runat="server">
                        <h2 class="text-2xl font-semibold text-gray-900 mb-6">
                            <i class="fas fa-info-circle mr-2 text-blue-600"></i>
                            Basic Information
                        </h2>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <!-- Recipe Name -->
                            <div class="md:col-span-2">
                                <label for="RecipeName" class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fas fa-utensils mr-2 text-blue-600"></i>
                                    Recipe Name
                                </label>
                                <asp:TextBox ID="RecipeName" runat="server" MaxLength="100" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvRecipeName" runat="server" ControlToValidate="RecipeName" ErrorMessage="Recipe name is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <!-- Cuisine Type -->
                            <div>
                                <label for="CuisineType" class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fas fa-globe mr-2 text-blue-600"></i>
                                    Cuisine Type
                                </label>
                                <asp:DropDownList ID="CuisineType" runat="server" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvCuisineType" runat="server" ControlToValidate="CuisineType" InitialValue="" ErrorMessage="Cuisine type is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <!-- Difficulty Level -->
                            <div>
                                <label for="Difficulty" class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fas fa-chart-line mr-2 text-blue-600"></i>
                                    Difficulty Level
                                </label>
                                <asp:DropDownList ID="Difficulty" runat="server" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500">
                                    <asp:ListItem Value="" Text="Select Difficulty" />
                                    <asp:ListItem Value="Easy" Text="Easy" />
                                    <asp:ListItem Value="Medium" Text="Medium" />
                                    <asp:ListItem Value="Hard" Text="Hard" />
                                </asp:DropDownList>
                                <asp:RequiredFieldValidator ID="rfvDifficulty" runat="server" ControlToValidate="Difficulty" InitialValue="" ErrorMessage="Difficulty is required." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <!-- Cooking Time -->
                            <div>
                                <label for="CookingTime" class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fas fa-clock mr-2 text-blue-600"></i>
                                    Cooking Time (minutes)
                                </label>
                                <asp:TextBox ID="CookingTime" runat="server" TextMode="Number" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvCookingTime" runat="server" ControlToValidate="CookingTime" ErrorMessage="Cooking time is required." CssClass="text-validation-error" Display="Dynamic" />
                                <asp:RangeValidator ID="rvCookingTime" runat="server" ControlToValidate="CookingTime" MinimumValue="1" MaximumValue="1000" Type="Integer" ErrorMessage="Enter a valid cooking time." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                            <!-- Servings -->
                            <div>
                                <label for="Servings" class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fas fa-users mr-2 text-blue-600"></i>
                                    Servings
                                </label>
                                <asp:TextBox ID="Servings" runat="server" TextMode="Number" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvServings" runat="server" ControlToValidate="Servings" ErrorMessage="Servings is required." CssClass="text-validation-error" Display="Dynamic" />
                                <asp:RangeValidator ID="rvServings" runat="server" ControlToValidate="Servings" MinimumValue="1" MaximumValue="100" Type="Integer" ErrorMessage="Enter a valid servings number." CssClass="text-validation-error" Display="Dynamic" />
                            </div>
                        </div>
                    </asp:Panel>
                    <!-- Media -->
                    <asp:Panel ID="MediaPanel" runat="server">
                        <h2 class="text-2xl font-semibold text-gray-900 mb-6">
                            <i class="fas fa-image mr-2 text-blue-600"></i>
                            Media
                        </h2>
                        <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                            <!-- Recipe Image -->
                            <div>
                                <label for="RecipeImage" class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fas fa-camera mr-2 text-blue-600"></i>
                                    Recipe Image
                                </label>
                                <asp:FileUpload ID="RecipeImage" runat="server" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RequiredFieldValidator ID="rfvRecipeImage" runat="server" ControlToValidate="RecipeImage" ErrorMessage="Recipe image is required." CssClass="text-validation-error" Display="Dynamic" />
                                <p class="mt-2 text-sm text-gray-500">Upload an appetizing photo of your dish</p>
                            </div>
                            <!-- YouTube Video Link -->
                            <div>
                                <label for="RecipeVideo" class="block text-sm font-medium text-gray-700 mb-2">
                                    <i class="fab fa-youtube mr-2 text-red-600"></i>
                                    YouTube Video Link (Optional)
                                </label>
                                <asp:TextBox ID="RecipeVideo" runat="server" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                                <asp:RegularExpressionValidator ID="revRecipeVideo" runat="server" ControlToValidate="RecipeVideo" ValidationExpression="^(https?\:\/\/)?(www\.youtube\.com|youtu\.?be)\/.+$" ErrorMessage="Enter a valid YouTube URL." CssClass="text-validation-error" Display="Dynamic" EnableClientScript="true" />
                                <p class="mt-2 text-sm text-gray-500">Share a cooking video to help others follow along</p>
                            </div>
                        </div>
                    </asp:Panel>
                    <!-- Description -->
                    <asp:Panel ID="DescriptionPanel" runat="server">
                        <h2 class="text-2xl font-semibold text-gray-900 mb-6">
                            <i class="fas fa-align-left mr-2 text-blue-600"></i>
                            Description
                        </h2>
                        <div>
                            <label for="RecipeDescription" class="block text-sm font-medium text-gray-700 mb-2">
                                Recipe Description
                            </label>
                            <asp:TextBox ID="RecipeDescription" runat="server" TextMode="MultiLine" Rows="4" MaxLength="2000" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="rfvRecipeDescription" runat="server" ControlToValidate="RecipeDescription" ErrorMessage="Description is required." CssClass="text-validation-error" Display="Dynamic" />
                        </div>
                    </asp:Panel>
                    <!-- Ingredients -->
                    <asp:Panel ID="IngredientsPanel" runat="server">
                        <h2 class="text-2xl font-semibold text-gray-900 mb-6">
                            <i class="fas fa-list-ul mr-2 text-blue-600"></i>
                            Ingredients
                        </h2>
                        <div>
                            <label for="CookingIngredient" class="block text-sm font-medium text-gray-700 mb-2">
                                Ingredients List
                            </label>
                            <asp:TextBox ID="CookingIngredient" runat="server" TextMode="MultiLine" Rows="8" MaxLength="2000" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="rfvCookingIngredient" runat="server" ControlToValidate="CookingIngredient" ErrorMessage="Ingredients are required." CssClass="text-validation-error" Display="Dynamic" />
                            <p class="mt-2 text-sm text-gray-500">List each ingredient on a separate line with measurements</p>
                        </div>
                    </asp:Panel>
                    <!-- Instructions -->
                    <asp:Panel ID="InstructionsPanel" runat="server">
                        <h2 class="text-2xl font-semibold text-gray-900 mb-6">
                            <i class="fas fa-list-ol mr-2 text-blue-600"></i>
                            Cooking Instructions
                        </h2>
                        <div>
                            <label for="CookingInstruction" class="block text-sm font-medium text-gray-700 mb-2">
                                Step-by-Step Instructions
                            </label>
                            <asp:TextBox ID="CookingInstruction" runat="server" TextMode="MultiLine" Rows="10" MaxLength="2000" CssClass="w-full px-4 py-3 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            <asp:RequiredFieldValidator ID="rfvCookingInstruction" runat="server" ControlToValidate="CookingInstruction" ErrorMessage="Instructions are required." CssClass="text-validation-error" Display="Dynamic" />
                            <p class="mt-2 text-sm text-gray-500">Number each step clearly for easy following</p>
                        </div>
                    </asp:Panel>
                    <!-- Nutrition Information (Optional) -->
                    <asp:Panel ID="NutritionPanel" runat="server">
                        <h2 class="text-2xl font-semibold text-gray-900 mb-6">
                            <i class="fas fa-heartbeat mr-2 text-blue-600"></i>
                            Nutrition Information (Optional)
                        </h2>
                        <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                            <div>
                                <label for="Calory" class="block text-sm font-medium text-gray-700 mb-2">Calories</label>
                                <asp:TextBox ID="Calory" runat="server" TextMode="Number" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            </div>
                            <div>
                                <label for="Protein" class="block text-sm font-medium text-gray-700 mb-2">Protein (g)</label>
                                <asp:TextBox ID="Protein" runat="server" TextMode="Number" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            </div>
                            <div>
                                <label for="Carb" class="block text-sm font-medium text-gray-700 mb-2">Carbs (g)</label>
                                <asp:TextBox ID="Carb" runat="server" TextMode="Number" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            </div>
                            <div>
                                <label for="Fat" class="block text-sm font-medium text-gray-700 mb-2">Fat (g)</label>
                                <asp:TextBox ID="Fat" runat="server" TextMode="Number" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            </div>
                        </div>
                    </asp:Panel>
                    <!-- Submit Buttons -->
                    <div class="flex flex-col md:flex-row gap-4 pt-6">
                        <asp:Button ID="PublishBtn" runat="server" Text="Publish Recipe"
                            CssClass="flex-1 bg-blue-600 text-white py-3 px-6 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-300 flex items-center justify-center"
                            OnClick="PublishBtn_Click" />
                        <a href="user-recipe.aspx" class="flex-1 bg-gray-200 text-gray-700 py-3 px-6 rounded-md hover:bg-gray-300 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-gray-500 transition duration-300 flex items-center justify-center">
                            <i class="fas fa-times mr-2"></i>
                            Cancel
                        </a>
                    </div>
                </asp:Panel>
            </div>
        </div>
    </main>
</asp:Content>
