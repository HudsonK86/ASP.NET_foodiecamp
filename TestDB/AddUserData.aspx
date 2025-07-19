<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddUserData.aspx.cs" Inherits="FoodieCamp.TestDB.TestNewTable" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="user_id" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="user_id" HeaderText="user_id" InsertVisible="False" ReadOnly="True" SortExpression="user_id" />
                    <asp:BoundField DataField="firstname" HeaderText="firstname" SortExpression="firstname" />
                    <asp:BoundField DataField="lastname" HeaderText="lastname" SortExpression="lastname" />
                    <asp:BoundField DataField="gender" HeaderText="gender" SortExpression="gender" />
                    <asp:BoundField DataField="date_of_birth" HeaderText="date_of_birth" SortExpression="date_of_birth" />
                    <asp:BoundField DataField="nationality" HeaderText="nationality" SortExpression="nationality" />
                    <asp:BoundField DataField="email" HeaderText="email" SortExpression="email" />
                    <asp:BoundField DataField="phone_number" HeaderText="phone_number" SortExpression="phone_number" />
                    <asp:BoundField DataField="password" HeaderText="password" SortExpression="password" />
                    <asp:BoundField DataField="profile_image" HeaderText="profile_image" SortExpression="profile_image" />
                    <asp:BoundField DataField="user_role" HeaderText="user_role" SortExpression="user_role" />
                    <asp:CheckBoxField DataField="is_activated" HeaderText="is_activated" SortExpression="is_activated" />
                    <asp:BoundField DataField="registered_date" HeaderText="registered_date" SortExpression="registered_date" />
                    <asp:BoundField DataField="last_login_date" HeaderText="last_login_date" SortExpression="last_login_date" />
                </Columns>
            </asp:GridView>
            <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [User] WHERE [user_id] = @user_id" InsertCommand="INSERT INTO [User] ([firstname], [lastname], [gender], [date_of_birth], [nationality], [email], [phone_number], [password], [profile_image], [user_role], [is_activated], [registered_date], [last_login_date]) VALUES (@firstname, @lastname, @gender, @date_of_birth, @nationality, @email, @phone_number, @password, @profile_image, @user_role, @is_activated, @registered_date, @last_login_date)" ProviderName="<%$ ConnectionStrings:ConnectionString.ProviderName %>" SelectCommand="SELECT * FROM [User]" UpdateCommand="UPDATE [User] SET [firstname] = @firstname, [lastname] = @lastname, [gender] = @gender, [date_of_birth] = @date_of_birth, [nationality] = @nationality, [email] = @email, [phone_number] = @phone_number, [password] = @password, [profile_image] = @profile_image, [user_role] = @user_role, [is_activated] = @is_activated, [registered_date] = @registered_date, [last_login_date] = @last_login_date WHERE [user_id] = @user_id">
                <DeleteParameters>
                    <asp:Parameter Name="user_id" Type="Int32" />
                </DeleteParameters>
                <InsertParameters>
                    <asp:Parameter Name="firstname" Type="String" />
                    <asp:Parameter Name="lastname" Type="String" />
                    <asp:Parameter Name="gender" Type="String" />
                    <asp:Parameter DbType="Date" Name="date_of_birth" />
                    <asp:Parameter Name="nationality" Type="String" />
                    <asp:Parameter Name="email" Type="String" />
                    <asp:Parameter Name="phone_number" Type="String" />
                    <asp:Parameter Name="password" Type="String" />
                    <asp:Parameter Name="profile_image" Type="String" />
                    <asp:Parameter Name="user_role" Type="String" />
                    <asp:Parameter Name="is_activated" Type="Boolean" />
                    <asp:Parameter DbType="Date" Name="registered_date" />
                    <asp:Parameter DbType="Date" Name="last_login_date" />
                </InsertParameters>
                <UpdateParameters>
                    <asp:Parameter Name="firstname" Type="String" />
                    <asp:Parameter Name="lastname" Type="String" />
                    <asp:Parameter Name="gender" Type="String" />
                    <asp:Parameter DbType="Date" Name="date_of_birth" />
                    <asp:Parameter Name="nationality" Type="String" />
                    <asp:Parameter Name="email" Type="String" />
                    <asp:Parameter Name="phone_number" Type="String" />
                    <asp:Parameter Name="password" Type="String" />
                    <asp:Parameter Name="profile_image" Type="String" />
                    <asp:Parameter Name="user_role" Type="String" />
                    <asp:Parameter Name="is_activated" Type="Boolean" />
                    <asp:Parameter DbType="Date" Name="registered_date" />
                    <asp:Parameter DbType="Date" Name="last_login_date" />
                    <asp:Parameter Name="user_id" Type="Int32" />
                </UpdateParameters>
            </asp:SqlDataSource>
        </div>
        <asp:DetailsView ID="DetailsView1" runat="server" AllowPaging="True" AutoGenerateRows="False" DataKeyNames="user_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="user_id" HeaderText="user_id" InsertVisible="False" ReadOnly="True" SortExpression="user_id" />
                <asp:BoundField DataField="firstname" HeaderText="firstname" SortExpression="firstname" />
                <asp:BoundField DataField="lastname" HeaderText="lastname" SortExpression="lastname" />
                <asp:BoundField DataField="gender" HeaderText="gender" SortExpression="gender" />
                <asp:BoundField DataField="date_of_birth" HeaderText="date_of_birth" SortExpression="date_of_birth" />
                <asp:BoundField DataField="nationality" HeaderText="nationality" SortExpression="nationality" />
                <asp:BoundField DataField="email" HeaderText="email" SortExpression="email" />
                <asp:BoundField DataField="phone_number" HeaderText="phone_number" SortExpression="phone_number" />
                <asp:BoundField DataField="password" HeaderText="password" SortExpression="password" />
                <asp:BoundField DataField="profile_image" HeaderText="profile_image" SortExpression="profile_image" />
                <asp:BoundField DataField="user_role" HeaderText="user_role" SortExpression="user_role" />
                <asp:CheckBoxField DataField="is_activated" HeaderText="is_activated" SortExpression="is_activated" />
                <asp:BoundField DataField="registered_date" HeaderText="registered_date" SortExpression="registered_date" />
                <asp:BoundField DataField="last_login_date" HeaderText="last_login_date" SortExpression="last_login_date" />
                <asp:CommandField ShowDeleteButton="True" ShowEditButton="True" ShowInsertButton="True" />
            </Fields>
        </asp:DetailsView>
        s</form>

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
