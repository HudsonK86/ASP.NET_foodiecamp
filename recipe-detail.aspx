<%@ Page Title="Recipe Detail" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="recipe-detail.aspx.cs" Inherits="Hope.recipe_detail" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .video-container {
            position: relative;
            width: 100%;
            aspect-ratio: 16/9;
            background: #000;
            border-radius: 1rem;
            overflow: hidden;
        }
        .video-container iframe {
            position: absolute;
            top: 0; left: 0;
            width: 100%; height: 100%;
            border-radius: 1rem;
        }
        .review-card { transition: box-shadow 0.2s; }
        .review-card:hover { box-shadow: 0 4px 24px rgba(0,0,0,0.08); }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <% if (Recipe != null) { %>
    <div class="bg-white rounded-2xl shadow-2xl overflow-hidden max-w-4xl mx-auto my-12">
        <!-- Recipe Header Image -->
        <img src="<%= Recipe.RecipeImage %>" 
            alt="<%= Recipe.RecipeName %>" 
            class="w-full h-72 object-cover object-center mt-6 rounded-t-2xl" 
            style="border-top-left-radius: 1rem; border-top-right-radius: 1rem;">
        <div class="p-8">
            <!-- Basic Information -->
            <div class="border-b border-gray-200 pb-8 mb-8">
                <div class="flex flex-col md:flex-row md:justify-between md:items-center mb-6 gap-4">
                    <div>
                        <h1 class="text-4xl font-extrabold text-gray-900 mb-2 tracking-tight"><%= Recipe.RecipeName %></h1>
                        <div class="flex flex-wrap items-center gap-6 text-base text-gray-600 mb-2">
                            <div class="flex items-center">
                                <div class="flex text-yellow-400 mr-2">
                                    <%= GetStarHtml(AverageRating) %>
                                </div>
                                <span class="font-medium"><%= AverageRating.ToString("0.0") %> (<%= ReviewCount %> reviews)</span>
                            </div>
                            <span class="flex items-center">
                                <i class="fas fa-user mr-2 text-blue-600"></i>
                                <span class="font-medium">By <%= Recipe.PostedBy %></span>
                            </span>
                            <span class="flex items-center">
                                <i class="fas fa-calendar mr-2 text-blue-600"></i>
                                <span><%= Recipe.DateCreated.ToString("MMM dd, yyyy") %></span>
                            </span>
                        </div>
                    </div>
                </div>
                <!-- Recipe Details Grid -->
                <div class="grid grid-cols-2 md:grid-cols-4 gap-6 mt-6">
                    <div class="text-center">
                        <div class="bg-blue-50 rounded-xl p-4 shadow-sm">
                            <i class="fas fa-globe text-2xl text-blue-600 mb-2"></i>
                            <p class="text-xs font-medium text-gray-500">Cuisine</p>
                            <p class="text-lg font-semibold text-gray-900"><%= Recipe.CuisineName %></p>
                        </div>
                    </div>
                    <div class="text-center">
                        <div class="bg-green-50 rounded-xl p-4 shadow-sm">
                            <i class="fas fa-chart-line text-2xl text-green-600 mb-2"></i>
                            <p class="text-xs font-medium text-gray-500">Difficulty</p>
                            <p class="text-lg font-semibold text-gray-900"><%= Recipe.DifficultyLevel %></p>
                        </div>
                    </div>
                    <div class="text-center">
                        <div class="bg-orange-50 rounded-xl p-4 shadow-sm">
                            <i class="fas fa-clock text-2xl text-orange-600 mb-2"></i>
                            <p class="text-xs font-medium text-gray-500">Cooking Time</p>
                            <p class="text-lg font-semibold text-gray-900"><%= Recipe.CookingTime %> mins</p>
                        </div>
                    </div>
                    <div class="text-center">
                        <div class="bg-purple-50 rounded-xl p-4 shadow-sm">
                            <i class="fas fa-users text-2xl text-purple-600 mb-2"></i>
                            <p class="text-xs font-medium text-gray-500">Servings</p>
                            <p class="text-lg font-semibold text-gray-900"><%= Recipe.Servings %> people</p>
                        </div>
                    </div>
                </div>
            </div>
            <!-- Description -->
            <div class="border-b border-gray-200 pb-8 mb-8">
                <h2 class="text-2xl font-bold text-gray-900 mb-4 flex items-center">
                    <i class="fas fa-align-left mr-2 text-blue-600"></i>
                    Description
                </h2>
                <p class="text-gray-700 leading-relaxed text-lg"><%= Recipe.RecipeDescription %></p>
            </div>
            <!-- Ingredients -->
            <div class="border-b border-gray-200 pb-8 mb-8">
                <h2 class="text-2xl font-bold text-gray-900 mb-4 flex items-center">
                    <i class="fas fa-list-ul mr-2 text-blue-600"></i>
                    Ingredients
                </h2>
                <div class="bg-gray-50 rounded-xl p-6">
                    <div class="text-gray-800 text-base" style="white-space: pre-line;">
                        <%= Recipe.CookingIngredient %>
                    </div>
                </div>
            </div>
            <!-- Instructions -->
            <div class="border-b border-gray-200 pb-8 mb-8">
                <h2 class="text-2xl font-bold text-gray-900 mb-4 flex items-center">
                    <i class="fas fa-list-ol mr-2 text-blue-600"></i>
                    Cooking Instructions
                </h2>
                <div class="text-gray-800 text-base" style="white-space: pre-line;">
                    <%= Recipe.CookingInstruction %>
                </div>
            </div>
            <!-- Nutrition Information -->
            <div class="border-b border-gray-200 pb-8 mb-8">
                <h2 class="text-2xl font-bold text-gray-900 mb-4 flex items-center">
                    <i class="fas fa-heartbeat mr-2 text-blue-600"></i>
                    Nutrition Information (Per Serving)
                </h2>
                <div class="grid grid-cols-2 md:grid-cols-4 gap-6">
                    <div class="text-center bg-red-50 rounded-xl p-4">
                        <i class="fas fa-fire text-2xl text-red-600 mb-2"></i>
                        <p class="text-xs font-medium text-gray-500">Calories</p>
                        <p class="text-2xl font-bold text-gray-900"><%= Recipe.Calory.HasValue ? Recipe.Calory.Value.ToString() : "-" %></p>
                    </div>
                    <div class="text-center bg-blue-50 rounded-xl p-4">
                        <i class="fas fa-dumbbell text-2xl text-blue-600 mb-2"></i>
                        <p class="text-xs font-medium text-gray-500">Protein</p>
                        <p class="text-2xl font-bold text-gray-900"><%= Recipe.Protein.HasValue ? Recipe.Protein.Value.ToString() + "g" : "-" %></p>
                    </div>
                    <div class="text-center bg-yellow-50 rounded-xl p-4">
                        <i class="fas fa-bread-slice text-2xl text-yellow-600 mb-2"></i>
                        <p class="text-xs font-medium text-gray-500">Carbs</p>
                        <p class="text-2xl font-bold text-gray-900"><%= Recipe.Carb.HasValue ? Recipe.Carb.Value.ToString() + "g" : "-" %></p>
                    </div>
                    <div class="text-center bg-green-50 rounded-xl p-4">
                        <i class="fas fa-leaf text-2xl text-green-600 mb-2"></i>
                        <p class="text-xs font-medium text-gray-500">Fat</p>
                        <p class="text-2xl font-bold text-gray-900"><%= Recipe.Fat.HasValue ? Recipe.Fat.Value.ToString() + "g" : "-" %></p>
                    </div>
                </div>
            </div>
            <!-- YouTube Video -->
            <% if (!string.IsNullOrEmpty(Recipe.RecipeVideo)) { %>
            <div class="border-b border-gray-200 pb-8 mb-8">
                <h2 class="text-2xl font-bold text-gray-900 mb-4 flex items-center">
                    <i class="fab fa-youtube mr-2 text-red-600"></i>
                    <span class="flex-1">Video Tutorial</span>
                </h2>
                <div class="bg-gray-100 rounded-xl p-6">
                    <div class="video-container">
                        <iframe 
                            src="<%= GetYouTubeEmbedUrl(Recipe.RecipeVideo) %>"
                            title="<%= Recipe.RecipeName %> Video Tutorial"
                            frameborder="0"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share"
                            allowfullscreen>
                        </iframe>
                    </div>
                </div>
            </div>
            <% } %>
            
            <!-- Action Buttons -->
            <% if (Session["UserId"] != null && (Session["UserRole"] == null || Session["UserRole"].ToString() == "User")) { %>
                <div class="flex flex-col md:flex-row gap-4 mb-8">
                    <asp:Button ID="CompletedBtn" runat="server"
                        CssClass='<%# IsCompleted ? "flex-1 bg-gray-400 text-white py-3 px-6 rounded-lg hover:bg-gray-500 transition duration-300 flex items-center justify-center" : "flex-1 bg-green-600 text-white py-3 px-6 rounded-lg hover:bg-green-700 transition duration-300 flex items-center justify-center" %>'
                        Text='<%# IsCompleted ? "Mark as Incompleted" : "Mark as Completed" %>'
                        OnClick="CompletedBtn_Click"
                        UseSubmitBehavior="false" />
                    <asp:Button ID="BookmarkBtn" runat="server"
                        CssClass='<%# IsBookmarked ? "flex-1 bg-yellow-500 text-white py-3 px-6 rounded-lg hover:bg-yellow-600 transition duration-300 flex items-center justify-center" : "flex-1 bg-blue-600 text-white py-3 px-6 rounded-lg hover:bg-blue-700 transition duration-300 flex items-center justify-center" %>'
                        Text='<%# IsBookmarked ? "Remove Bookmark" : "Bookmark" %>'
                        OnClick="BookmarkBtn_Click"
                        UseSubmitBehavior="false" />
                </div>
            <% } %>
            
            <!-- Review Form (if logged in) -->
            <% if (Session["UserId"] != null) { %>
            <asp:UpdatePanel ID="ReviewUpdatePanel" runat="server" UpdateMode="Conditional">
                <ContentTemplate>
                    <div class="bg-white border border-gray-200 rounded-lg p-6 mb-6">
                        <h3 class="text-lg font-semibold text-gray-900 mb-4">
                            <i class="fas fa-edit mr-2 text-blue-600"></i>
                            Write a Review
                        </h3>
                        <asp:Panel runat="server" ID="ReviewPanel">
                            <!-- Star Rating -->
                            <div>
                                <label class="block text-sm font-medium text-gray-700 mb-2">Your Rating</label>
                                <div class="flex items-center space-x-1" id="star-rating-js">
                                    <% for (int i = 1; i <= 5; i++) { %>
                                        <span class="star-rating text-2xl text-gray-300 cursor-pointer" data-value="<%= i %>">
                                            <i class="fas fa-star"></i>
                                        </span>
                                    <% } %>
                                    <span id="rating-text" class="ml-3 text-sm text-gray-600">Click to rate</span>
                                </div>
                                <asp:TextBox ID="ReviewRating" runat="server" CssClass="hidden" />
                            </div>
                            <!-- Comment -->
                            <div class="mt-4">
                                <label for="ReviewComment" class="block text-sm font-medium text-gray-700 mb-2">Your Review</label>
                                <asp:TextBox ID="ReviewComment" runat="server" TextMode="MultiLine" Rows="4"
                                    CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-blue-500 focus:border-blue-500" />
                            </div>
                            <!-- Media Upload -->
                            <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-4">
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">
                                        <i class="fas fa-camera mr-1 text-blue-600"></i>
                                        Add Photos (Optional)
                                    </label>
                                    <asp:FileUpload ID="ReviewPhoto" runat="server" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm" />
                                </div>
                                <div>
                                    <label class="block text-sm font-medium text-gray-700 mb-2">
                                        <i class="fas fa-video mr-1 text-red-600"></i>
                                        Add Videos (Optional)
                                    </label>
                                    <asp:FileUpload ID="ReviewVideo" runat="server" CssClass="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm" />
                                </div>
                            </div>
                            <div class="flex items-center justify-end pt-4 gap-4">
                                <span id="reviewErrorClient" class="text-red-600 font-semibold" style="display:none"></span>
                                <asp:Label ID="ReviewError" runat="server" CssClass="text-red-600 font-semibold" Visible="false"></asp:Label>
                                <asp:Button ID="SubmitReviewBtn" runat="server" Text="Submit Review"
                                    CssClass="bg-blue-600 text-white px-6 py-2 rounded-md hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500 transition duration-300 flex items-center"
                                    OnClick="SubmitReviewBtn_Click" />
                            </div>
                        </asp:Panel>
                    </div>
                </ContentTemplate>
                <Triggers>
                    <asp:PostBackTrigger ControlID="SubmitReviewBtn" />
                </Triggers>
            </asp:UpdatePanel>
            <% } else { %>
                <div class="bg-yellow-50 border border-yellow-200 text-yellow-800 rounded-lg p-6 mb-6 text-center">
                    <i class="fas fa-sign-in-alt mr-2"></i>
                    Please <a href="login.aspx?returnUrl=<%= Server.UrlEncode(Request.RawUrl) %>" class="text-blue-600 underline">log in</a> to write a review.
                </div>
            <% } %>
            <!-- Review Stats and List -->
            <div class="bg-gray-50 rounded-lg p-6 mb-6">
                <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-8">
                    <div class="flex items-center gap-4 min-w-[180px]">
                        <span class="text-5xl font-extrabold text-gray-900"><%= AverageRating.ToString("0.0") %></span>
                        <div>
                            <div class="flex text-yellow-400 text-2xl mb-1"><%= GetStarHtml(AverageRating) %></div>
                            <p class="text-base text-gray-600 font-medium">Based on <%= ReviewCount %> reviews</p>
                        </div>
                    </div>
                    <div class="flex-1">
                        <%
                            int[] starCounts = new int[5];
                            foreach (var review in Reviews) { starCounts[review.Rating - 1]++; }
                            int total = ReviewCount > 0 ? ReviewCount : 1;
                        %>
                        <% for (int i = 5; i >= 1; i--) { %>
                        <div class="flex items-center mb-2">
                            <span class="text-base text-gray-600 w-8 text-right"><%= i %>★</span>
                            <div class="flex-1 mx-3 h-2 bg-gray-200 rounded-full overflow-hidden">
                                <div class="h-2 bg-yellow-400 rounded-full transition-all duration-300"
                                    style='width: <%= (total > 0) ? (starCounts[i-1] * 100 / total) : 0 %>%;'></div>
                            </div>
                            <span class="text-base text-gray-600 w-8 text-left"><%= starCounts[i-1] %></span>
                        </div>
                        <% } %>
                    </div>
                </div>
            </div>
            <asp:Repeater ID="ReviewRepeater" runat="server">
                <ItemTemplate>
                    <div class="review-card border border-gray-100 rounded-xl p-6 bg-white flex items-start gap-4 mb-4">
                        <img src='<%# Eval("ReviewerImage") %>' alt='<%# Eval("ReviewerName") %>' class="w-14 h-14 rounded-full object-cover border border-gray-200" />
                        <div class="flex-1">
                            <div class="flex items-center gap-2 mb-1">
                                <h4 class="font-semibold text-gray-900"><%# Eval("ReviewerName") %></h4>
                                <span class="flex text-yellow-400 text-base ml-2"><%# GetStarHtml(Eval("Rating")) %></span>
                                <span class="text-xs text-gray-500 ml-2"><%# Eval("ReviewDate", "{0:MMM dd, yyyy}") %></span>
                            </div>
                            <p class="text-gray-700 text-base mb-2"><%# Eval("Comment") %></p>
                            <div class="flex gap-4 mt-2">
                                <%# !string.IsNullOrEmpty(Eval("ReviewImage") as string) ? $"<a href='images/reviews/{Eval("ReviewImage")}' class='review-media-link' data-type='image'><img src='images/reviews/{Eval("ReviewImage")}' alt='Review Image' class='rounded-lg w-32 h-32 object-cover border border-gray-200 hover:shadow-lg transition' style='cursor:pointer;'></a>" : "" %>
                                <%# !string.IsNullOrEmpty(Eval("ReviewVideo") as string) ? $"<a href='images/reviews/{Eval("ReviewVideo")}' class='review-media-link' data-type='video'><video class='rounded-lg w-32 h-32 object-cover border border-gray-200 hover:shadow-lg transition' style='cursor:pointer;' preload='metadata'><source src='images/reviews/{Eval("ReviewVideo")}' />Your browser does not support the video tag.</video></a>" : "" %>
                            </div>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
            <asp:Panel runat="server" ID="NoReviewsPanel" Visible="false">
                <div class="text-gray-500 text-center py-8">No reviews yet.</div>
            </asp:Panel>
        </div>
    </div>
    <% } else { %>
        <div class="text-center text-gray-500 py-16 text-xl">Recipe not found.</div>
    <% } %>
    <!-- Modal for image/video preview -->
    <div id="mediaModal" class="fixed inset-0 bg-black bg-opacity-60 flex items-center justify-center z-50" style="display: none;">
        <div class="relative bg-white rounded-lg shadow-lg p-4 max-w-2xl w-full flex flex-col items-center">
            <button id="closeModalBtn" class="absolute top-2 right-2 text-gray-500 hover:text-gray-800 text-2xl">&times;</button>
            <div id="modalContent"></div>
        </div>
    </div>
    <script>
        document.addEventListener('DOMContentLoaded', function () {
            const stars = document.querySelectorAll('.star-rating');
            const ratingInput = document.getElementById('<%= ReviewRating.ClientID %>');
            const ratingText = document.getElementById('rating-text');
            let selected = 0;

            function updateStars(rating) {
                stars.forEach((star, idx) => {
                    if (idx < rating) {
                        star.classList.remove('text-gray-300');
                        star.classList.add('text-yellow-400');
                    } else {
                        star.classList.remove('text-yellow-400');
                        star.classList.add('text-gray-300');
                    }
                });
                ratingInput.value = rating;
                if (ratingText) {
                    ratingText.textContent = rating > 0 ? `You rated ${rating} star${rating > 1 ? 's' : ''}` : 'Click to rate';
                }
            }

            stars.forEach((star, idx) => {
                star.addEventListener('click', function (e) {
                    e.preventDefault();
                    selected = idx + 1;
                    updateStars(selected);
                });
                star.addEventListener('mouseenter', function () {
                    updateStars(idx + 1);
                });
                star.addEventListener('mouseleave', function () {
                    updateStars(selected);
                });
            });

            // Modal logic
            const modal = document.getElementById('mediaModal');
            const modalContent = document.getElementById('modalContent');
            const closeModalBtn = document.getElementById('closeModalBtn');

            // Open modal for image/video
            document.querySelectorAll('.review-media-link').forEach(function(link) {
                link.addEventListener('click', function(e) {
                    e.preventDefault();
                    const type = this.dataset.type;
                    const src = this.getAttribute('href');
                    if (type === 'image') {
                        modalContent.innerHTML = `<img src="${src}" class="max-h-[70vh] max-w-full rounded-lg" />`;
                    } else if (type === 'video') {
                        modalContent.innerHTML = `<video src="${src}" controls autoplay class="max-h-[70vh] max-w-full rounded-lg"></video>`;
                    }
                    modal.style.display = 'flex';
                });
            });

            closeModalBtn.addEventListener('click', function() {
                modal.style.display = 'none';
                modalContent.innerHTML = '';
            });

            // Close modal on background click
            modal.addEventListener('click', function(e) {
                if (e.target === modal) {
                    modal.style.display = 'none';
                    modalContent.innerHTML = '';
                }
            });

            // Client-side validation for review form
            var submitBtn = document.getElementById('<%= SubmitReviewBtn.ClientID %>');
            var ratingInput2 = document.getElementById('<%= ReviewRating.ClientID %>');
            var commentInput = document.getElementById('<%= ReviewComment.ClientID %>');
            var errorSpan = document.getElementById('reviewErrorClient');

            if (submitBtn) {
                submitBtn.onclick = function (e) {
                    var rating = parseInt(ratingInput2.value, 10) || 0;
                    var comment = commentInput.value.trim();
                    errorSpan.style.display = "none";
                    errorSpan.textContent = "";

                    if (rating < 1 || rating > 5) {
                        errorSpan.textContent = "Please select a star rating.";
                        errorSpan.style.display = "block";
                        e.preventDefault();
                        return false;
                    }
                    if (!comment) {
                        errorSpan.textContent = "Please enter your review.";
                        errorSpan.style.display = "block";
                        e.preventDefault();
                        return false;
                    }
                    // Allow submit
                    return true;
                };
            }
        });
    </script>
</asp:Content>