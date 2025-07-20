# FoodieCamp - Culinary Learning Platform

A comprehensive web-based platform for cooking enthusiasts to learn authentic recipes from around the world, join cooking events, and connect with a community of passionate food lovers.

## 🍳 Overview

FoodieCamp is an ASP.NET Web Forms application that provides a complete culinary learning experience. Users can explore recipes from various cuisines, register for cooking events, manage their profiles, and interact with other cooking enthusiasts.

## ✨ Features

### For Users
- **Recipe Discovery**: Browse recipes by cuisine type (Chinese, Indian, Malay, Vietnamese, Western, etc.)
- **Event Registration**: Join cooking events and workshops
- **User Dashboard**: Manage personal recipes, bookmarks, and event registrations
- **Profile Management**: Update personal information and preferences
- **Notifications**: Stay updated with event reminders and announcements
- **Recipe Bookmarking**: Save favorite recipes for later reference

### For Administrators
- **User Management**: Manage user accounts and profiles
- **Recipe Management**: Add, edit, and moderate recipes
- **Event Management**: Create and manage cooking events
- **Cuisine Management**: Add and manage different cuisine categories
- **Review System**: Moderate user reviews and ratings
- **Inquiry Management**: Handle user inquiries and support requests

## 🛠️ Technology Stack

- **Framework**: ASP.NET Web Forms (.NET Framework 4.8)
- **Database**: SQL Server (Azure SQL Database)
- **Authentication**: Custom authentication with BCrypt password hashing
- **Frontend**: HTML5, CSS3, JavaScript, Tailwind CSS
- **Icons**: Font Awesome
- **Development**: Visual Studio 2019/2022

## 📁 Project Structure

```
Hope/
├── App_Data/                 # Database files
├── css/                     # Stylesheets
├── images/                  # Static images
│   ├── cuisines/           # Cuisine category images
│   ├── events/             # Event images
│   ├── profiles/           # User profile images
│   ├── recipes/            # Recipe images
│   └── reviews/            # Review images
├── TestDB/                 # Database testing utilities
├── *.aspx                  # Web pages
├── *.aspx.cs               # Code-behind files
├── *.aspx.designer.cs      # Designer files
├── Site.Master             # Master page
├── Web.config              # Configuration file
└── Hope.csproj             # Project file
```

## 🚀 Getting Started

### Prerequisites

- Visual Studio 2019 or 2022
- .NET Framework 4.8
- SQL Server (or Azure SQL Database)
- IIS Express (included with Visual Studio)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd WAPP/Hope
   ```

2. **Database Setup**
   - The application uses Azure SQL Database
   - Update the connection string in `Web.config` with your database credentials
   - Run the database scripts in the `TestDB/` folder to populate initial data

3. **Open in Visual Studio**
   - Open `Hope.csproj` in Visual Studio
   - Restore NuGet packages if prompted
   - Build the solution

4. **Run the Application**
   - Press F5 or click "Start Debugging"
   - The application will open in your default browser

### Database Configuration

Update the connection string in `Web.config`:

```xml
<connectionStrings>
    <add name="ConnectionString"
         connectionString="Server=your-server;Database=your-database;User ID=your-username;Password=your-password;"
         providerName="System.Data.SqlClient" />
</connectionStrings>
```

## 📊 Database Schema

The application uses the following main entities:
- **Users**: User accounts and profiles
- **Recipes**: Cooking recipes with ingredients and instructions
- **Events**: Cooking events and workshops
- **Cuisines**: Recipe categories
- **Reviews**: User reviews and ratings
- **Bookmarks**: User-saved recipes
- **Notifications**: System notifications
- **Inquiries**: User support requests

## 🔐 Authentication & Security

- Custom authentication system
- BCrypt password hashing for secure password storage
- Session-based authentication
- Role-based access control (User/Admin)
- OTP verification for password reset

## 🎨 UI/UX Features

- Responsive design using Tailwind CSS
- Modern card-based layout
- Interactive hover effects
- Real-time notifications
- Image upload and management
- Search and filter functionality

## 📱 Pages Overview

### Public Pages
- `home.aspx` - Landing page with featured content
- `recipes.aspx` - Recipe browsing and search
- `events.aspx` - Event listing and registration
- `login.aspx` - User authentication
- `register.aspx` - User registration
- `contact.aspx` - Contact form

### User Pages
- `user-dashboard.aspx` - User dashboard
- `user-profile.aspx` - Profile management
- `user-recipe.aspx` - Personal recipes
- `user-event.aspx` - Registered events
- `user-bookmark.aspx` - Saved recipes
- `user-notification.aspx` - Notifications

### Admin Pages
- `admin-dashboard.aspx` - Admin dashboard
- `admin-user.aspx` - User management
- `admin-recipe.aspx` - Recipe management
- `admin-event.aspx` - Event management
- `admin-cuisine.aspx` - Cuisine management
- `admin-review.aspx` - Review moderation
- `admin-inquiry.aspx` - Inquiry management

## 🔧 Configuration

### Key Settings in Web.config
- Database connection string
- Authentication settings
- Compilation settings
- Default document configuration

### Environment Variables
- Database credentials (should be secured in production)
- Email settings (if implemented)
- File upload paths

## 🧪 Testing

The project includes test utilities in the `TestDB/` folder for:
- Adding sample user data
- Adding sample recipe data
- Adding sample event data
- Adding sample cuisine data
- Database connectivity testing

## 📈 Deployment

### Local Development
- Use IIS Express (included with Visual Studio)
- Debug mode for development

### Production Deployment
- Deploy to IIS server
- Configure production database
- Update connection strings
- Set up SSL certificates
- Configure proper security settings

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

- **Project Name**: FoodieCamp
- **Technology**: ASP.NET Web Forms
- **Purpose**: Culinary learning and community platform

## 📞 Support

For support and inquiries:
- Check the contact page in the application
- Review the documentation
- Submit issues through the repository

## 🔄 Version History

- **v1.0** - Initial release with core functionality
- User authentication and registration
- Recipe management system
- Event registration system
- Admin dashboard
- Responsive UI design

---

**Note**: This is a learning platform designed to help cooking enthusiasts discover recipes, join events, and connect with the culinary community. The application provides both user-facing features and comprehensive administrative tools for platform management. 
