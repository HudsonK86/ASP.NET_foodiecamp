<%@ Page Title="OTP Verification" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="otp-verification.aspx.cs" Inherits="Hope.otp_verification" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script type="text/javascript">
        function moveToNext(current, nextFieldID) {
            // Only allow numeric input
            current.value = current.value.replace(/[^0-9]/g, '');

            if (current.value.length >= current.maxLength) {
                if (nextFieldID) {
                    document.getElementById(nextFieldID).focus();
                }
            }
        }

        function moveToPrev(current, event, prevFieldID) {
            if (event.key === 'Backspace' && current.value === '' && prevFieldID) {
                document.getElementById(prevFieldID).focus();
            }
        }

        function handlePaste(event) {
            event.preventDefault();
            const paste = (event.clipboardData || window.clipboardData).getData('text');
            const numbers = paste.replace(/[^0-9]/g, '').slice(0, 4);

            if (numbers.length > 0) {
                for (let i = 0; i < numbers.length && i < 4; i++) {
                    const field = document.getElementById('otp-' + (i + 1));
                    if (field) {
                        field.value = numbers[i];
                    }
                }
                // Focus on the next empty field or the last field
                const nextIndex = Math.min(numbers.length, 3);
                document.getElementById('otp-' + (nextIndex + 1)).focus();
            }
        }

        function resendCode() {
            document.getElementById('<%= ResendButton.ClientID %>').click();
        }

        // Auto-focus first input
        window.onload = function () {
            document.getElementById('otp-1').focus();
        };
    </script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="min-h-screen bg-gray-50 flex flex-col justify-center py-12 sm:px-6 lg:px-8 pt-24">
        <div class="sm:mx-auto sm:w-full sm:max-w-md">
            <div class="text-center">
                <a href="home.aspx" class="inline-flex items-center mb-4">
                    <i class="fas fa-utensils text-4xl text-blue-600 mr-2"></i>
                    <span class="text-2xl font-bold text-gray-800">FoodieCamp</span>
                </a>
                <h2 class="text-3xl font-bold text-gray-900">Enter Verification Code</h2>
                <p class="mt-2 text-sm text-gray-600">We've sent a 4-digit verification code to your email</p>
            </div>
        </div>

        <div class="mt-8 sm:mx-auto sm:w-full sm:max-w-md">
            <div class="bg-white py-8 px-4 shadow sm:rounded-lg sm:px-10">
                <!-- Message area for success/error messages -->
                <div id="messageContainer" class="mb-4"></div>
                
                <div class="space-y-6">
                    <!-- OTP Input Fields -->
                    <asp:Panel ID="OtpPanel" runat="server" DefaultButton="VerifyButton">
                        <div>
                            <label class="block text-sm font-medium text-gray-700 mb-4 text-center">
                                <i class="fas fa-key mr-2 text-blue-600"></i>
                                Enter 4-Digit Code
                            </label>
                            <div class="flex justify-center space-x-3">
                                <input type="text" maxlength="1" id="otp-1" name="otp-1" title="First digit of OTP code"
                                       class="w-14 h-14 text-center text-xl font-bold border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                       oninput="moveToNext(this, 'otp-2')" onkeydown="moveToPrev(this, event)" onpaste="handlePaste(event)">
                                <input type="text" maxlength="1" id="otp-2" name="otp-2" title="Second digit of OTP code"
                                       class="w-14 h-14 text-center text-xl font-bold border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                       oninput="moveToNext(this, 'otp-3')" onkeydown="moveToPrev(this, event, 'otp-1')" onpaste="handlePaste(event)">
                                <input type="text" maxlength="1" id="otp-3" name="otp-3" title="Third digit of OTP code"
                                       class="w-14 h-14 text-center text-xl font-bold border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                       oninput="moveToNext(this, 'otp-4')" onkeydown="moveToPrev(this, event, 'otp-2')" onpaste="handlePaste(event)">
                                <input type="text" maxlength="1" id="otp-4" name="otp-4" title="Fourth digit of OTP code"
                                       class="w-14 h-14 text-center text-xl font-bold border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500"
                                       oninput="moveToNext(this, null)" onkeydown="moveToPrev(this, event, 'otp-3')" onpaste="handlePaste(event)">
                            </div>
                            <p class="mt-3 text-xs text-gray-500 text-center">Enter the code sent to your email</p>
                        </div>

                        <!-- Submit Button -->
                        <div>
                            <asp:Button ID="VerifyButton" runat="server" Text="Verify Code" OnClick="VerifyButton_Click"
                                CssClass="w-full flex justify-center py-3 px-4 border border-transparent rounded-md shadow-sm text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-300" />
                        </div>
                    </asp:Panel>

                    <!-- Resend Code -->
                    <div class="text-center">
                        <p class="text-sm text-gray-600 mb-2">Didn't receive the code?</p>
                        <asp:Button ID="ResendButton" runat="server" Text="Resend Code" OnClick="ResendButton_Click"
                            CausesValidation="false"
                            CssClass="text-blue-600 hover:text-blue-500 text-sm font-medium bg-transparent border-none cursor-pointer" />
                    </div>

                    <!-- Back Link -->
                    <div class="text-center">
                        <a href="register.aspx" class="text-gray-600 hover:text-gray-800 text-sm">
                            <i class="fas fa-arrow-left mr-1"></i>
                            Back to Registration
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>