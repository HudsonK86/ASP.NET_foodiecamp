<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddInquiryData.aspx.cs" Inherits="FoodieCamp.TestDB.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="inquiry_id" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="inquiry_id" HeaderText="inquiry_id" InsertVisible="False" ReadOnly="True" SortExpression="inquiry_id" />
                    <asp:BoundField DataField="admin_id" HeaderText="admin_id" SortExpression="admin_id" />
                    <asp:BoundField DataField="full_name" HeaderText="full_name" SortExpression="full_name" />
                    <asp:BoundField DataField="email_address" HeaderText="email_address" SortExpression="email_address" />
                    <asp:BoundField DataField="subject" HeaderText="subject" SortExpression="subject" />
                    <asp:BoundField DataField="message" HeaderText="message" SortExpression="message" />
                    <asp:BoundField DataField="inquiry_status" HeaderText="inquiry_status" SortExpression="inquiry_status" />
                    <asp:BoundField DataField="submission_date" HeaderText="submission_date" SortExpression="submission_date" />
                </Columns>
            </asp:GridView>
        </div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [Inquiry] WHERE [inquiry_id] = @inquiry_id" InsertCommand="INSERT INTO [Inquiry] ([admin_id], [full_name], [email_address], [subject], [message], [inquiry_status], [submission_date]) VALUES (@admin_id, @full_name, @email_address, @subject, @message, @inquiry_status, @submission_date)" SelectCommand="SELECT * FROM [Inquiry]" UpdateCommand="UPDATE [Inquiry] SET [admin_id] = @admin_id, [full_name] = @full_name, [email_address] = @email_address, [subject] = @subject, [message] = @message, [inquiry_status] = @inquiry_status, [submission_date] = @submission_date WHERE [inquiry_id] = @inquiry_id">
            <DeleteParameters>
                <asp:Parameter Name="inquiry_id" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="admin_id" Type="Int32" />
                <asp:Parameter Name="full_name" Type="String" />
                <asp:Parameter Name="email_address" Type="String" />
                <asp:Parameter Name="subject" Type="String" />
                <asp:Parameter Name="message" Type="String" />
                <asp:Parameter Name="inquiry_status" Type="String" />
                <asp:Parameter DbType="Date" Name="submission_date" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="admin_id" Type="Int32" />
                <asp:Parameter Name="full_name" Type="String" />
                <asp:Parameter Name="email_address" Type="String" />
                <asp:Parameter Name="subject" Type="String" />
                <asp:Parameter Name="message" Type="String" />
                <asp:Parameter Name="inquiry_status" Type="String" />
                <asp:Parameter DbType="Date" Name="submission_date" />
                <asp:Parameter Name="inquiry_id" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:DetailsView ID="DetailsView1" runat="server" AllowPaging="True" AutoGenerateRows="False" DataKeyNames="inquiry_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="inquiry_id" HeaderText="inquiry_id" InsertVisible="False" ReadOnly="True" SortExpression="inquiry_id" />
                <asp:BoundField DataField="admin_id" HeaderText="admin_id" SortExpression="admin_id" />
                <asp:BoundField DataField="full_name" HeaderText="full_name" SortExpression="full_name" />
                <asp:BoundField DataField="email_address" HeaderText="email_address" SortExpression="email_address" />
                <asp:BoundField DataField="subject" HeaderText="subject" SortExpression="subject" />
                <asp:BoundField DataField="message" HeaderText="message" SortExpression="message" />
                <asp:BoundField DataField="inquiry_status" HeaderText="inquiry_status" SortExpression="inquiry_status" />
                <asp:BoundField DataField="submission_date" HeaderText="submission_date" SortExpression="submission_date" />
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
