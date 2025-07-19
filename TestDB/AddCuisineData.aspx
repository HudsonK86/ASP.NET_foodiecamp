<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddCuisineData.aspx.cs" Inherits="FoodieCamp.TestDB.AddCuisineData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="cuisine_id" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="cuisine_id" HeaderText="cuisine_id" InsertVisible="False" ReadOnly="True" SortExpression="cuisine_id" />
                    <asp:BoundField DataField="cuisine_name" HeaderText="cuisine_name" SortExpression="cuisine_name" />
                    <asp:BoundField DataField="cuisine_image" HeaderText="cuisine_image" SortExpression="cuisine_image" />
                </Columns>
            </asp:GridView>
        </div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [Cuisine] WHERE [cuisine_id] = @cuisine_id" InsertCommand="INSERT INTO [Cuisine] ([cuisine_name], [cuisine_image]) VALUES (@cuisine_name, @cuisine_image)" SelectCommand="SELECT * FROM [Cuisine]" UpdateCommand="UPDATE [Cuisine] SET [cuisine_name] = @cuisine_name, [cuisine_image] = @cuisine_image WHERE [cuisine_id] = @cuisine_id">
            <DeleteParameters>
                <asp:Parameter Name="cuisine_id" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="cuisine_name" Type="String" />
                <asp:Parameter Name="cuisine_image" Type="String" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="cuisine_name" Type="String" />
                <asp:Parameter Name="cuisine_image" Type="String" />
                <asp:Parameter Name="cuisine_id" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:DetailsView ID="DetailsView1" runat="server" AllowPaging="True" AutoGenerateRows="False" DataKeyNames="cuisine_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="cuisine_id" HeaderText="cuisine_id" InsertVisible="False" ReadOnly="True" SortExpression="cuisine_id" />
                <asp:BoundField DataField="cuisine_name" HeaderText="cuisine_name" SortExpression="cuisine_name" />
                <asp:BoundField DataField="cuisine_image" HeaderText="cuisine_image" SortExpression="cuisine_image" />
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
