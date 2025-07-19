<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AddRecipeData.aspx.cs" Inherits="FoodieCamp.TestDB.AddRecipeData" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
</head>
<body>
    <form id="form1" runat="server">
        <div>
            <asp:GridView ID="GridView1" runat="server" AutoGenerateColumns="False" DataKeyNames="recipe_id" DataSourceID="SqlDataSource1">
                <Columns>
                    <asp:BoundField DataField="recipe_id" HeaderText="recipe_id" InsertVisible="False" ReadOnly="True" SortExpression="recipe_id" />
                    <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                    <asp:BoundField DataField="cuisine_id" HeaderText="cuisine_id" SortExpression="cuisine_id" />
                    <asp:BoundField DataField="recipe_name" HeaderText="recipe_name" SortExpression="recipe_name" />
                    <asp:BoundField DataField="difficulty_level" HeaderText="difficulty_level" SortExpression="difficulty_level" />
                    <asp:BoundField DataField="cooking_time" HeaderText="cooking_time" SortExpression="cooking_time" />
                    <asp:BoundField DataField="servings" HeaderText="servings" SortExpression="servings" />
                    <asp:BoundField DataField="recipe_image" HeaderText="recipe_image" SortExpression="recipe_image" />
                    <asp:BoundField DataField="recipe_video" HeaderText="recipe_video" SortExpression="recipe_video" />
                    <asp:BoundField DataField="recipe_description" HeaderText="recipe_description" SortExpression="recipe_description" />
                    <asp:BoundField DataField="cooking_ingredient" HeaderText="cooking_ingredient" SortExpression="cooking_ingredient" />
                    <asp:BoundField DataField="cooking_instruction" HeaderText="cooking_instruction" SortExpression="cooking_instruction" />
                    <asp:BoundField DataField="calory" HeaderText="calory" SortExpression="calory" />
                    <asp:BoundField DataField="protein" HeaderText="protein" SortExpression="protein" />
                    <asp:BoundField DataField="carb" HeaderText="carb" SortExpression="carb" />
                    <asp:BoundField DataField="fat" HeaderText="fat" SortExpression="fat" />
                    <asp:BoundField DataField="recipe_status" HeaderText="recipe_status" SortExpression="recipe_status" />
                    <asp:BoundField DataField="recipe_visibility" HeaderText="recipe_visibility" SortExpression="recipe_visibility" />
                    <asp:BoundField DataField="date_created" HeaderText="date_created" SortExpression="date_created" />
                </Columns>
            </asp:GridView>
        </div>
        <asp:SqlDataSource ID="SqlDataSource1" runat="server" ConnectionString="<%$ ConnectionStrings:ConnectionString %>" DeleteCommand="DELETE FROM [Recipe] WHERE [recipe_id] = @recipe_id" InsertCommand="INSERT INTO [Recipe] ([user_id], [cuisine_id], [recipe_name], [difficulty_level], [cooking_time], [servings], [recipe_image], [recipe_video], [recipe_description], [cooking_ingredient], [cooking_instruction], [calory], [protein], [carb], [fat], [recipe_status], [recipe_visibility], [date_created]) VALUES (@user_id, @cuisine_id, @recipe_name, @difficulty_level, @cooking_time, @servings, @recipe_image, @recipe_video, @recipe_description, @cooking_ingredient, @cooking_instruction, @calory, @protein, @carb, @fat, @recipe_status, @recipe_visibility, @date_created)" SelectCommand="SELECT * FROM [Recipe]" UpdateCommand="UPDATE [Recipe] SET [user_id] = @user_id, [cuisine_id] = @cuisine_id, [recipe_name] = @recipe_name, [difficulty_level] = @difficulty_level, [cooking_time] = @cooking_time, [servings] = @servings, [recipe_image] = @recipe_image, [recipe_video] = @recipe_video, [recipe_description] = @recipe_description, [cooking_ingredient] = @cooking_ingredient, [cooking_instruction] = @cooking_instruction, [calory] = @calory, [protein] = @protein, [carb] = @carb, [fat] = @fat, [recipe_status] = @recipe_status, [recipe_visibility] = @recipe_visibility, [date_created] = @date_created WHERE [recipe_id] = @recipe_id">
            <DeleteParameters>
                <asp:Parameter Name="recipe_id" Type="Int32" />
            </DeleteParameters>
            <InsertParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="cuisine_id" Type="Int32" />
                <asp:Parameter Name="recipe_name" Type="String" />
                <asp:Parameter Name="difficulty_level" Type="String" />
                <asp:Parameter Name="cooking_time" Type="Int32" />
                <asp:Parameter Name="servings" Type="Int32" />
                <asp:Parameter Name="recipe_image" Type="String" />
                <asp:Parameter Name="recipe_video" Type="String" />
                <asp:Parameter Name="recipe_description" Type="String" />
                <asp:Parameter Name="cooking_ingredient" Type="String" />
                <asp:Parameter Name="cooking_instruction" Type="String" />
                <asp:Parameter Name="calory" Type="Int32" />
                <asp:Parameter Name="protein" Type="Int32" />
                <asp:Parameter Name="carb" Type="Int32" />
                <asp:Parameter Name="fat" Type="Int32" />
                <asp:Parameter Name="recipe_status" Type="String" />
                <asp:Parameter Name="recipe_visibility" Type="String" />
                <asp:Parameter DbType="Date" Name="date_created" />
            </InsertParameters>
            <UpdateParameters>
                <asp:Parameter Name="user_id" Type="Int32" />
                <asp:Parameter Name="cuisine_id" Type="Int32" />
                <asp:Parameter Name="recipe_name" Type="String" />
                <asp:Parameter Name="difficulty_level" Type="String" />
                <asp:Parameter Name="cooking_time" Type="Int32" />
                <asp:Parameter Name="servings" Type="Int32" />
                <asp:Parameter Name="recipe_image" Type="String" />
                <asp:Parameter Name="recipe_video" Type="String" />
                <asp:Parameter Name="recipe_description" Type="String" />
                <asp:Parameter Name="cooking_ingredient" Type="String" />
                <asp:Parameter Name="cooking_instruction" Type="String" />
                <asp:Parameter Name="calory" Type="Int32" />
                <asp:Parameter Name="protein" Type="Int32" />
                <asp:Parameter Name="carb" Type="Int32" />
                <asp:Parameter Name="fat" Type="Int32" />
                <asp:Parameter Name="recipe_status" Type="String" />
                <asp:Parameter Name="recipe_visibility" Type="String" />
                <asp:Parameter DbType="Date" Name="date_created" />
                <asp:Parameter Name="recipe_id" Type="Int32" />
            </UpdateParameters>
        </asp:SqlDataSource>
        <asp:DetailsView ID="DetailsView1" runat="server" AllowPaging="True" AutoGenerateRows="False" DataKeyNames="recipe_id" DataSourceID="SqlDataSource1" Height="50px" Width="125px">
            <Fields>
                <asp:BoundField DataField="recipe_id" HeaderText="recipe_id" InsertVisible="False" ReadOnly="True" SortExpression="recipe_id" />
                <asp:BoundField DataField="user_id" HeaderText="user_id" SortExpression="user_id" />
                <asp:BoundField DataField="cuisine_id" HeaderText="cuisine_id" SortExpression="cuisine_id" />
                <asp:BoundField DataField="recipe_name" HeaderText="recipe_name" SortExpression="recipe_name" />
                <asp:BoundField DataField="difficulty_level" HeaderText="difficulty_level" SortExpression="difficulty_level" />
                <asp:BoundField DataField="cooking_time" HeaderText="cooking_time" SortExpression="cooking_time" />
                <asp:BoundField DataField="servings" HeaderText="servings" SortExpression="servings" />
                <asp:BoundField DataField="recipe_image" HeaderText="recipe_image" SortExpression="recipe_image" />
                <asp:BoundField DataField="recipe_video" HeaderText="recipe_video" SortExpression="recipe_video" />
                <asp:BoundField DataField="recipe_description" HeaderText="recipe_description" SortExpression="recipe_description" />
                <asp:BoundField DataField="cooking_ingredient" HeaderText="cooking_ingredient" SortExpression="cooking_ingredient" />
                <asp:BoundField DataField="cooking_instruction" HeaderText="cooking_instruction" SortExpression="cooking_instruction" />
                <asp:BoundField DataField="calory" HeaderText="calory" SortExpression="calory" />
                <asp:BoundField DataField="protein" HeaderText="protein" SortExpression="protein" />
                <asp:BoundField DataField="carb" HeaderText="carb" SortExpression="carb" />
                <asp:BoundField DataField="fat" HeaderText="fat" SortExpression="fat" />
                <asp:BoundField DataField="recipe_status" HeaderText="recipe_status" SortExpression="recipe_status" />
                <asp:BoundField DataField="recipe_visibility" HeaderText="recipe_visibility" SortExpression="recipe_visibility" />
                <asp:BoundField DataField="date_created" HeaderText="date_created" SortExpression="date_created" />
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
