namespace Hope
{
    public partial class contact
    {
        protected global::System.Web.UI.WebControls.Panel MessagePanel;
        protected global::System.Web.UI.WebControls.Label MessageLabel;
        protected global::System.Web.UI.WebControls.ValidationSummary ValidationSummary1;
        protected global::System.Web.UI.WebControls.Panel ContactFormPanel;
        protected global::System.Web.UI.WebControls.TextBox FullName;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvFullName;
        protected global::System.Web.UI.WebControls.TextBox Email;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvEmail;
        protected global::System.Web.UI.WebControls.RegularExpressionValidator revEmail;
        protected global::System.Web.UI.WebControls.DropDownList Subject;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvSubject;
        protected global::System.Web.UI.WebControls.TextBox Message;
        protected global::System.Web.UI.WebControls.RequiredFieldValidator rfvMessage;
        protected global::System.Web.UI.WebControls.Button SendBtn;
    }
}