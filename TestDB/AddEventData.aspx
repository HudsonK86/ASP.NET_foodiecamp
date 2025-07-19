<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddEventData.aspx.cs" Inherits="FoodieCamp.TestDB.AddEventData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="event_id" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="event_id" HeaderText="event_id" InsertVisible="False" ReadOnly="True" SortExpression="event_id" />
                    <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                    <asp:BoundField DataField="event_title" HeaderText="event_title" SortExpression="event_title" />
                    <asp:BoundField DataField="event_description" HeaderText="event_description" SortExpression="event_description" />
                    <asp:BoundField DataField="event_image" HeaderText="event_image" SortExpression="event_image" />
                    <asp:BoundField DataField="event_type" HeaderText="event_type" SortExpression="event_type" />
                    <asp:BoundField DataField="cuisine_type" HeaderText="cuisine_type" SortExpression="cuisine_type" />
                    <asp:BoundField DataField="start_date" HeaderText="start_date" SortExpression="start_date" />
                    <asp:BoundField DataField="end_date" HeaderText="end_date" SortExpression="end_date" />
                    <asp:BoundField DataField="start_time" HeaderText="start_time" SortExpression="start_time" />
                    <asp:BoundField DataField="end_time" HeaderText="end_time" SortExpression="end_time" />
                    <asp:BoundField DataField="max_participant" HeaderText="max_participant" SortExpression="max_participant" />
                    <asp:BoundField DataField="location" HeaderText="location" SortExpression="location" />
                    <asp:BoundField DataField="learning_objective" HeaderText="learning_objective" SortExpression="learning_objective" />
                    <asp:BoundField DataField="included_item" HeaderText="included_item" SortExpression="included_item" />
                    <asp:BoundField DataField="requirement" HeaderText="requirement" SortExpression="requirement" />
                    <asp:BoundField DataField="event_status" HeaderText="event_status" SortExpression="event_status" />
                </Columns>
            </asp:GridView>
        </div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [Event] WHERE [event_id] = @event_id" InsertCommand="INSERT INTO [Event] ([user_id], [event_title], [event_description], [event_image], [event_type], [cuisine_type], [start_date], [end_date], [start_time], [end_time], [max_participant], [location], [learning_objective], [included_item], [requirement], [event_status]) VALUES (@user_id, @event_title, @event_description, @event_image, @event_type, @cuisine_type, @start_date, @end_date, @start_time, @end_time, @max_participant, @location, @learning_objective, @included_item, @requirement, @event_status)" SelectCommand="SELECT * FROM [Event]" UpdateCommand="UPDATE [Event] SET [user_id] = @user_id, [event_title] = @event_title, [event_description] = @event_description, [event_image] = @event_image, [event_type] = @event_type, [cuisine_type] = @cuisine_type, [start_date] = @start_date, [end_date] = @end_date, [start_time] = @start_time, [end_time] = @end_time, [max_participant] = @max_participant, [location] = @location, [learning_objective] = @learning_objective, [included_item] = @included_item, [requirement] = @requirement, [event_status] = @event_status WHERE [event_id] = @event_id">
            <DeleteParameters>
                <asp:Parameter Name="event_id" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="event_title" Type="String" />
                <asp:Parameter Name="event_description" Type="String" />
                <asp:Parameter Name="event_image" Type="String" />
                <asp:Parameter Name="event_type" Type="String" />
                <asp:Parameter Name="cuisine_type" Type="String" />
                <asp:Parameter DbType="Date" Name="start_date" />
                <asp:Parameter DbType="Date" Name="end_date" />
                <asp:Parameter DbType="Time" Name="start_time" />
                <asp:Parameter DbType="Time" Name="end_time" />
                <asp:Parameter Name="max_participant" Type="Int32" />
                <asp:Parameter Name="location" Type="String" />
                <asp:Parameter Name="learning_objective" Type="String" />
                <asp:Parameter Name="included_item" Type="String" />
                <asp:Parameter Name="requirement" Type="String" />
                <asp:Parameter Name="event_status" Type="String" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="event_title" Type="String" />
                <asp:Parameter Name="event_description" Type="String" />
                <asp:Parameter Name="event_image" Type="String" />
                <asp:Parameter Name="event_type" Type="String" />
                <asp:Parameter Name="cuisine_type" Type="String" />
                <asp:Parameter DbType="Date" Name="start_date" />
                <asp:Parameter DbType="Date" Name="end_date" />
                <asp:Parameter DbType="Time" Name="start_time" />
                <asp:Parameter DbType="Time" Name="end_time" />
                <asp:Parameter Name="max_participant" Type="Int32" />
                <asp:Parameter Name="location" Type="String" />
                <asp:Parameter Name="learning_objective" Type="String" />
                <asp:Parameter Name="included_item" Type="String" />
                <asp:Parameter Name="requirement" Type="String" />
                <asp:Parameter Name="event_status" Type="String" />
                <asp:Parameter Name="event_id" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:DetailsView ID="DetailsView1" runat="server" AllowPaging="True" AutoGenerateRows="False" DataKeyNames="event_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="event_id" HeaderText="event_id" InsertVisible="False" ReadOnly="True" SortExpression="event_id" />
                <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                <asp:BoundField DataField="event_title" HeaderText="event_title" SortExpression="event_title" />
                <asp:BoundField DataField="event_description" HeaderText="event_description" SortExpression="event_description" />
                <asp:BoundField DataField="event_image" HeaderText="event_image" SortExpression="event_image" />
                <asp:BoundField DataField="event_type" HeaderText="event_type" SortExpression="event_type" />
                <asp:BoundField DataField="cuisine_type" HeaderText="cuisine_type" SortExpression="cuisine_type" />
                <asp:BoundField DataField="start_date" HeaderText="start_date" SortExpression="start_date" />
                <asp:BoundField DataField="end_date" HeaderText="end_date" SortExpression="end_date" />
                <asp:BoundField DataField="start_time" HeaderText="start_time" SortExpression="start_time" />
                <asp:BoundField DataField="end_time" HeaderText="end_time" SortExpression="end_time" />
                <asp:BoundField DataField="max_participant" HeaderText="max_participant" SortExpression="max_participant" />
                <asp:BoundField DataField="location" HeaderText="location" SortExpression="location" />
                <asp:BoundField DataField="learning_objective" HeaderText="learning_objective" SortExpression="learning_objective" />
                <asp:BoundField DataField="included_item" HeaderText="included_item" SortExpression="included_item" />
                <asp:BoundField DataField="requirement" HeaderText="requirement" SortExpression="requirement" />
                <asp:BoundField DataField="event_status" HeaderText="event_status" SortExpression="event_status" />
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
