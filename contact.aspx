<%@ Page Title="Contact Us" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="contact.aspx.cs" Inherits="Hope.contact" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="pt-16">
        <!-- Top Center Message Panel -->
        <asp:Panel ID="MessagePanel" runat="server" Visible="false" CssClass="fixed top-20 left-1/2 transform -translate-x-1/2 z-50">
            <div id="msgBox" class="bg-green-50 border border-green-200 text-green-800 px-6 py-4 rounded-lg shadow-lg max-w-md mx-auto flex items-center">
                <i class="fas fa-check-circle text-green-600 mr-3"></i>
                <asp:Label ID="MessageLabel" runat="server" CssClass="font-medium"></asp:Label>
                <button type="button" onclick="closeMessage()" class="ml-4 text-green-600 hover:text-green-800">
                    <i class="fas fa-times"></i>
                </button>
            </div>
        </asp:Panel>

        <main>
            <div class="py-16 bg-white">
                <div class="max-w-7xl mx-auto px-4">
                    <h1 class="text-4xl font-bold text-center text-gray-800 mb-12">Get in Touch</h1>
                    <div class="grid md:grid-cols-2 gap-12 items-center">
                        <!-- Contact Image -->
                        <div>
                            <img src="https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=600&h=400&fit=crop" alt="Contact Us" class="rounded-xl shadow-lg">
                            <div class="mt-8 space-y-4">
                                <div class="flex items-center">
                                    <i class="fas fa-envelope text-blue-600 text-xl mr-4"></i>
                                    <div>
                                        <h3 class="font-semibold text-gray-800">Email</h3>
                                        <p class="text-gray-600">hello@foodiecamp.com</p>
                                    </div>
                                </div>
                                <div class="flex items-center">
                                    <i class="fas fa-phone text-blue-600 text-xl mr-4"></i>
                                    <div>
                                        <h3 class="font-semibold text-gray-800">Phone</h3>
                                        <p class="text-gray-600">+1 (555) 123-4567</p>
                                    </div>
                                </div>
                                <div class="flex items-center">
                                    <i class="fas fa-map-marker-alt text-blue-600 text-xl mr-4"></i>
                                    <div>
                                        <h3 class="font-semibold text-gray-800">Address</h3>
                                        <p class="text-gray-600">123 Culinary Street, Food City, FC 12345</p>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <!-- Contact Form -->
                        <div>
                            <asp:ValidationSummary ID="ValidationSummary1" runat="server" CssClass="text-red-600 mb-2" />
                            <asp:Panel ID="ContactFormPanel" runat="server">
                                <div class="space-y-6">
                                    <div>
                                        <label for="FullName" class="block text-sm font-medium text-gray-700 mb-2">Full Name</label>
                                        <asp:TextBox ID="FullName" runat="server" CssClass="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" MaxLength="100" />
                                        <asp:RequiredFieldValidator ID="rfvFullName" runat="server" ControlToValidate="FullName" ErrorMessage="Full name is required." CssClass="text-red-600" Display="Dynamic" />
                                    </div>
                                    <div>
                                        <label for="Email" class="block text-sm font-medium text-gray-700 mb-2">Email Address</label>
                                        <asp:TextBox ID="Email" runat="server" CssClass="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" MaxLength="100" />
                                        <asp:RequiredFieldValidator ID="rfvEmail" runat="server" ControlToValidate="Email" ErrorMessage="Email is required." CssClass="text-red-600" Display="Dynamic" />
                                        <asp:RegularExpressionValidator ID="revEmail" runat="server" ControlToValidate="Email" ErrorMessage="Invalid email format." CssClass="text-red-600" Display="Dynamic" ValidationExpression="^[^@\s]+@[^@\s]+\.[^@\s]+$" />
                                    </div>
                                    <div>
                                        <label for="Subject" class="block text-sm font-medium text-gray-700 mb-2">Subject</label>
                                        <asp:DropDownList ID="Subject" runat="server" CssClass="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent">
                                            <asp:ListItem Value="">Select a category</asp:ListItem>
                                            <asp:ListItem Value="General">General Inquiry</asp:ListItem>
                                            <asp:ListItem Value="Technical">Technical Support</asp:ListItem>
                                            <asp:ListItem Value="Partnership">Partnership</asp:ListItem>
                                            <asp:ListItem Value="Feedback">Feedback</asp:ListItem>
                                        </asp:DropDownList>
                                        <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="Subject" InitialValue="" ErrorMessage="Subject is required." CssClass="text-red-600" Display="Dynamic" />
                                    </div>
                                    <div>
                                        <label for="Message" class="block text-sm font-medium text-gray-700 mb-2">Message</label>
                                        <asp:TextBox ID="Message" runat="server" TextMode="MultiLine" Rows="5" MaxLength="500" CssClass="w-full px-4 py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent" />
                                        <asp:RequiredFieldValidator ID="rfvMessage" runat="server" ControlToValidate="Message" ErrorMessage="Message is required." CssClass="text-red-600" Display="Dynamic" />
                                    </div>
                                    <asp:Button ID="SendBtn" runat="server" Text="Send Message" CssClass="w-full bg-blue-600 text-white py-3 px-6 rounded-lg hover:bg-blue-700 transition font-semibold" OnClick="SendBtn_Click" />
                                </div>
                            </asp:Panel>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
    <script>
        function closeMessage() {
            var panel = document.querySelector('[id$="MessagePanel"]');
            if (panel) panel.style.display = 'none';
        }
        // Auto-hide after 3 seconds
        window.addEventListener('DOMContentLoaded', function () {
            var panel = document.querySelector('[id$="MessagePanel"]');
            if (panel && panel.style.display !== 'none') {
                setTimeout(closeMessage, 3000);
            }
        });
    </script>
</asp:Content>