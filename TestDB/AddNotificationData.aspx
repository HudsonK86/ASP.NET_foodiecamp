<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddNotificationData.aspx.cs" Inherits="FoodieCamp.TestDB.AddNotificationData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="notification_id" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="notification_id" HeaderText="notification_id" InsertVisible="False" ReadOnly="True" SortExpression="notification_id" />
                    <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                    <asp:BoundField DataField="notification_type" HeaderText="notification_type" SortExpression="notification_type" />
                    <asp:BoundField DataField="related_id" HeaderText="related_id" SortExpression="related_id" />
                    <asp:BoundField DataField="notification_message" HeaderText="notification_message" SortExpression="notification_message" />
                    <asp:BoundField DataField="notification_date" HeaderText="notification_date" SortExpression="notification_date" />
                    <asp:CheckBoxField DataField="is_read" HeaderText="is_read" SortExpression="is_read" />
                </Columns>
            </asp:GridView>
        </div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [Notification] WHERE [notification_id] = @notification_id" InsertCommand="INSERT INTO [Notification] ([user_id], [notification_type], [related_id], [notification_message], [notification_date], [is_read]) VALUES (@user_id, @notification_type, @related_id, @notification_message, @notification_date, @is_read)" SelectCommand="SELECT * FROM [Notification]" UpdateCommand="UPDATE [Notification] SET [user_id] = @user_id, [notification_type] = @notification_type, [related_id] = @related_id, [notification_message] = @notification_message, [notification_date] = @notification_date, [is_read] = @is_read WHERE [notification_id] = @notification_id">
            <DeleteParameters>
                <asp:Parameter Name="notification_id" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="notification_type" Type="String" />
                <asp:Parameter Name="related_id" Type="Int32" />
                <asp:Parameter Name="notification_message" Type="String" />
                <asp:Parameter DbType="Date" Name="notification_date" />
                <asp:Parameter Name="is_read" Type="Boolean" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="notification_type" Type="String" />
                <asp:Parameter Name="related_id" Type="Int32" />
                <asp:Parameter Name="notification_message" Type="String" />
                <asp:Parameter DbType="Date" Name="notification_date" />
                <asp:Parameter Name="is_read" Type="Boolean" />
                <asp:Parameter Name="notification_id" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:DetailsView ID="DetailsView1" runat="server" AllowPaging="True" AutoGenerateRows="False" DataKeyNames="notification_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="notification_id" HeaderText="notification_id" InsertVisible="False" ReadOnly="True" SortExpression="notification_id" />
                <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                <asp:BoundField DataField="notification_type" HeaderText="notification_type" SortExpression="notification_type" />
                <asp:BoundField DataField="related_id" HeaderText="related_id" SortExpression="related_id" />
                <asp:BoundField DataField="notification_message" HeaderText="notification_message" SortExpression="notification_message" />
                <asp:BoundField DataField="notification_date" HeaderText="notification_date" SortExpression="notification_date" />
                <asp:CheckBoxField DataField="is_read" HeaderText="is_read" SortExpression="is_read" />
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
