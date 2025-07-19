<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddEnrollmentData.aspx.cs" Inherits="FoodieCamp.TestDB.AddEnrollmentData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="enrollment_id" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="enrollment_id" HeaderText="enrollment_id" InsertVisible="False" ReadOnly="True" SortExpression="enrollment_id" />
                    <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                    <asp:BoundField DataField="event_id" HeaderText="event_id" SortExpression="event_id" />
                    <asp:BoundField DataField="enrollment_status" HeaderText="enrollment_status" SortExpression="enrollment_status" />
                </Columns>
            </asp:GridView>
        </div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [Enrollment] WHERE [enrollment_id] = @enrollment_id" InsertCommand="INSERT INTO [Enrollment] ([user_id], [event_id], [enrollment_status]) VALUES (@user_id, @event_id, @enrollment_status)" SelectCommand="SELECT * FROM [Enrollment]" UpdateCommand="UPDATE [Enrollment] SET [user_id] = @user_id, [event_id] = @event_id, [enrollment_status] = @enrollment_status WHERE [enrollment_id] = @enrollment_id">
            <DeleteParameters>
                <asp:Parameter Name="enrollment_id" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="event_id" Type="Int32" />
                <asp:Parameter Name="enrollment_status" Type="String" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="event_id" Type="Int32" />
                <asp:Parameter Name="enrollment_status" Type="String" />
                <asp:Parameter Name="enrollment_id" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:DetailsView ID="DetailsView1" runat="server" AutoGenerateRows="False" DataKeyNames="enrollment_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="enrollment_id" HeaderText="enrollment_id" InsertVisible="False" ReadOnly="True" SortExpression="enrollment_id" />
                <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                <asp:BoundField DataField="event_id" HeaderText="event_id" SortExpression="event_id" />
                <asp:BoundField DataField="enrollment_status" HeaderText="enrollment_status" SortExpression="enrollment_status" />
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
