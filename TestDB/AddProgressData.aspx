<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddProgressData.aspx.cs" Inherits="FoodieCamp.TestDB.AddProgressData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="progress_id" DataSourceID="SqlDataSource1">
            <Columns>
                <asp:BoundField DataField="progress_id" HeaderText="progress_id" InsertVisible="False" ReadOnly="True" SortExpression="progress_id" />
                <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                <asp:BoundField DataField="recipe_id" HeaderText="recipe_id" SortExpression="recipe_id" />
                <asp:CheckBoxField DataField="is_completed" HeaderText="is_completed" SortExpression="is_completed" />
            </Columns>
        </asp:GridView>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [Progress] WHERE [progress_id] = @progress_id" InsertCommand="INSERT INTO [Progress] ([user_id], [recipe_id], [is_completed]) VALUES (@user_id, @recipe_id, @is_completed)" SelectCommand="SELECT * FROM [Progress]" UpdateCommand="UPDATE [Progress] SET [user_id] = @user_id, [recipe_id] = @recipe_id, [is_completed] = @is_completed WHERE [progress_id] = @progress_id">
            <DeleteParameters>
                <asp:Parameter Name="progress_id" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="recipe_id" Type="Int32" />
                <asp:Parameter Name="is_completed" Type="Boolean" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="recipe_id" Type="Int32" />
                <asp:Parameter Name="is_completed" Type="Boolean" />
                <asp:Parameter Name="progress_id" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:DetailsView ID="DetailsView1" runat="server" AllowPaging="True" AutoGenerateRows="False" DataKeyNames="progress_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="progress_id" HeaderText="progress_id" InsertVisible="False" ReadOnly="True" SortExpression="progress_id" />
                <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                <asp:BoundField DataField="recipe_id" HeaderText="recipe_id" SortExpression="recipe_id" />
                <asp:CheckBoxField DataField="is_completed" HeaderText="is_completed" SortExpression="is_completed" />
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
