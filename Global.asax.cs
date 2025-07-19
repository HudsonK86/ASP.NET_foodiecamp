using System;
using System.Web;
using System.Web.UI;

namespace Hope
{
    public class Global : System.Web.HttpApplication
    {
        protected void Application_Start(object sender, EventArgs e)
        {
            // Register jQuery for unobtrusive validation
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery",
                new ScriptResourceDefinition
                {
                    Path = "https://code.jquery.com/jquery-3.6.0.min.js",
                    DebugPath = "https://code.jquery.com/jquery-3.6.0.js",
                    CdnPath = "https://code.jquery.com/jquery-3.6.0.min.js",
                    CdnDebugPath = "https://code.jquery.com/jquery-3.6.0.js"
                });
        }
    }
}