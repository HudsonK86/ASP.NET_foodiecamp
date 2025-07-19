<%@ Page Title="About Us" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="about.aspx.cs" Inherits="Hope.about" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="pt-16">
        <!-- Mission & Features -->
        <div class="py-16 bg-white">
            <div class="max-w-7xl mx-auto px-4">
                <div class="text-center mb-12">
                    <h1 class="text-4xl font-bold text-gray-800 mb-6">About FoodieCamp</h1>
                    <p class="text-xl text-gray-600 max-w-3xl mx-auto">
                        Our mission is to democratize culinary education by providing accessible, high-quality cooking instruction to food enthusiasts worldwide.
                    </p>
                </div>

                <div class="grid md:grid-cols-3 gap-8 mb-16">
                    <div class="text-center">
                        <i class="fas fa-book-open text-4xl text-blue-600 mb-4"></i>
                        <h3 class="text-xl font-semibold text-gray-800 mb-2">Sharing is Caring</h3>
                        <p class="text-gray-600">Learn how to cook from experienced and passionate food enthusiasts, taking your skills from beginner to expert.</p>
                    </div>
                    
                    <div class="text-center">
                        <i class="fas fa-users text-4xl text-blue-600 mb-4"></i>
                        <h3 class="text-xl font-semibold text-gray-800 mb-2">Community Learning</h3>
                        <p class="text-gray-600">Connect with fellow cooking enthusiasts, share recipes, and learn from each other's experiences.</p>
                    </div>
                    
                    <div class="text-center">
                        <i class="fas fa-globe text-4xl text-blue-600 mb-4"></i>
                        <h3 class="text-xl font-semibold text-gray-800 mb-2">Global Cuisines</h3>
                        <p class="text-gray-600">Explore authentic recipes from around the world and master diverse cooking techniques.</p>
                    </div>
                </div>

                <!-- About Content -->
                <div class="grid md:grid-cols-2 gap-12 items-center">
                    <div>
                        <img src="https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&h=400&fit=crop" alt="Cooking Together" class="rounded-xl shadow-lg">
                    </div>
                    <div>
                        <h2 class="text-3xl font-bold text-gray-800 mb-6">Why Choose FoodieCamp?</h2>
                        <p class="text-gray-600 mb-4">
                            Founded by passionate chefs and food educators, FoodieCamp brings together the best of traditional cooking wisdom and modern culinary innovation. Our platform offers structured learning paths, hands-on workshops, and a supportive community.
                        </p>
                        <p class="text-gray-600 mb-6">
                            Whether you're a complete beginner looking to master basic techniques or an experienced cook wanting to explore new cuisines, our comprehensive curriculum and expert instructors will guide you every step of the way.
                        </p>
                        <ul class="space-y-2 text-gray-600">
                            <li class="flex items-center">
                                <i class="fas fa-check text-green-500 mr-2"></i>
                                Interactive video lessons with step-by-step guidance
                            </li>
                            <li class="flex items-center">
                                <i class="fas fa-check text-green-500 mr-2"></i>
                                Live cooking workshops and Q&A sessions
                            </li>
                            <li class="flex items-center">
                                <i class="fas fa-check text-green-500 mr-2"></i>
                                Recipe sharing and community feedback
                            </li>
                            <li class="flex items-center">
                                <i class="fas fa-check text-green-500 mr-2"></i>
                                Progress tracking and skill development
                            </li>
                        </ul>
                    </div>
                </div>
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
</asp:Content>
