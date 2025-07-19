<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddReviewData.aspx.cs" Inherits="FoodieCamp.TestDB.AddReviewData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="review_id" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="review_id" HeaderText="review_id" InsertVisible="False" ReadOnly="True" SortExpression="review_id" />
                    <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                    <asp:BoundField DataField="recipe_id" HeaderText="recipe_id" SortExpression="recipe_id" />
                    <asp:BoundField DataField="review_rating" HeaderText="review_rating" SortExpression="review_rating" />
                    <asp:BoundField DataField="review_comment" HeaderText="review_comment" SortExpression="review_comment" />
                    <asp:BoundField DataField="review_image" HeaderText="review_image" SortExpression="review_image" />
                    <asp:BoundField DataField="review_video" HeaderText="review_video" SortExpression="review_video" />
                    <asp:BoundField DataField="review_visibility" HeaderText="review_visibility" SortExpression="review_visibility" />
                    <asp:BoundField DataField="review_date" HeaderText="review_date" SortExpression="review_date" />
                </Columns>
            </asp:GridView>
        </div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [Review] WHERE [review_id] = @review_id" InsertCommand="INSERT INTO [Review] ([user_id], [recipe_id], [review_rating], [review_comment], [review_image], [review_video], [review_visibility], [review_date]) VALUES (@user_id, @recipe_id, @review_rating, @review_comment, @review_image, @review_video, @review_visibility, @review_date)" SelectCommand="SELECT * FROM [Review]" UpdateCommand="UPDATE [Review] SET [user_id] = @user_id, [recipe_id] = @recipe_id, [review_rating] = @review_rating, [review_comment] = @review_comment, [review_image] = @review_image, [review_video] = @review_video, [review_visibility] = @review_visibility, [review_date] = @review_date WHERE [review_id] = @review_id">
            <DeleteParameters>
                <asp:Parameter Name="review_id" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="recipe_id" Type="Int32" />
                <asp:Parameter Name="review_rating" Type="Int32" />
                <asp:Parameter Name="review_comment" Type="String" />
                <asp:Parameter Name="review_image" Type="String" />
                <asp:Parameter Name="review_video" Type="String" />
                <asp:Parameter Name="review_visibility" Type="String" />
                <asp:Parameter DbType="Date" Name="review_date" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="recipe_id" Type="Int32" />
                <asp:Parameter Name="review_rating" Type="Int32" />
                <asp:Parameter Name="review_comment" Type="String" />
                <asp:Parameter Name="review_image" Type="String" />
                <asp:Parameter Name="review_video" Type="String" />
                <asp:Parameter Name="review_visibility" Type="String" />
                <asp:Parameter DbType="Date" Name="review_date" />
                <asp:Parameter Name="review_id" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:DetailsView ID="DetailsView1" runat="server" AllowPaging="True" AutoGenerateRows="False" DataKeyNames="review_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="review_id" HeaderText="review_id" InsertVisible="False" ReadOnly="True" SortExpression="review_id" />
                <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                <asp:BoundField DataField="recipe_id" HeaderText="recipe_id" SortExpression="recipe_id" />
                <asp:BoundField DataField="review_rating" HeaderText="review_rating" SortExpression="review_rating" />
                <asp:BoundField DataField="review_comment" HeaderText="review_comment" SortExpression="review_comment" />
                <asp:BoundField DataField="review_image" HeaderText="review_image" SortExpression="review_image" />
                <asp:BoundField DataField="review_video" HeaderText="review_video" SortExpression="review_video" />
                <asp:BoundField DataField="review_visibility" HeaderText="review_visibility" SortExpression="review_visibility" />
                <asp:BoundField DataField="review_date" HeaderText="review_date" SortExpression="review_date" />
                <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" ShowInsertButton="True" />
            </Fields>
        </asp:DetailsView>
    </form>
        <div>
            <h3>Navigation Links</h3>
            <a href="AddBookmarkData.aspx">Bookmark</a><br />
            <a href="AddCuisineData.aspx">Cuisine</a><br />
            <a href="AddEnrollmentData.aspx">Enrollment</a><br />
            <a href="AddEventData.aspx">Event</a><br />
            <a href="AddInquiryData.aspx">Inquiry</a><br />
            <a href="AddNotificationData.aspx">Notification</a><br />
            <a href="AddProgressData.aspx">Progress</a><br />
            <a href="AddRecipeData.aspx">Recipe</a><br />
            <a href="AddReviewData.aspx">Review</a><br />
            <a href="AddUserData.aspx">User</a><br />
        </div>
</body>
</html>
