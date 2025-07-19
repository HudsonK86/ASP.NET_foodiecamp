<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddBookmarkData.aspx.cs" Inherits="FoodieCamp.TestDB.AddBookmark" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="bookmark_id" DataSourceID="SqlDataSource1">
            <Columns>
                <asp:BoundField DataField="bookmark_id" HeaderText="bookmark_id" InsertVisible="False" ReadOnly="True" SortExpression="bookmark_id" />
                <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                <asp:BoundField DataField="recipe_id" HeaderText="recipe_id" SortExpression="recipe_id" />
                <asp:BoundField DataField="bookmark_status" HeaderText="bookmark_status" SortExpression="bookmark_status" />
            </Columns>
        </asp:GridView>
        <div>
            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [Bookmark] WHERE [bookmark_id] = @bookmark_id" InsertCommand="INSERT INTO [Bookmark] ([user_id], [recipe_id], [bookmark_status]) VALUES (@user_id, @recipe_id, @bookmark_status)" SelectCommand="SELECT * FROM [Bookmark]" UpdateCommand="UPDATE [Bookmark] SET [user_id] = @user_id, [recipe_id] = @recipe_id, [bookmark_status] = @bookmark_status WHERE [bookmark_id] = @bookmark_id">
                <DeleteParameters>
                    <asp:Parameter Name="bookmark_id" Type="Int32" />
                </DeleteParameters>
                <InsertParameters>
                    <asp:Parameter Name="user_id" Type="Int32" />
                    <asp:Parameter Name="recipe_id" Type="Int32" />
                    <asp:Parameter Name="bookmark_status" Type="String" />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="user_id" Type="Int32" />
                    <asp:Parameter Name="recipe_id" Type="Int32" />
                    <asp:Parameter Name="bookmark_status" Type="String" />
                    <asp:Parameter Name="bookmark_id" Type="Int32" />
                </UpdateParameters>
            </asp:SqlDataSource>
        </div>
        <asp:DetailsView ID="DetailsView1" runat="server" AllowPaging="True" AutoGenerateRows="False" DataKeyNames="bookmark_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="bookmark_id" HeaderText="bookmark_id" InsertVisible="False" ReadOnly="True" SortExpression="bookmark_id" />
                <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                <asp:BoundField DataField="recipe_id" HeaderText="recipe_id" SortExpression="recipe_id" />
                <asp:BoundField DataField="bookmark_status" HeaderText="bookmark_status" SortExpression="bookmark_status" />
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
