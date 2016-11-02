public class USF_LoginController {

    public string strUsername{get;set;} //username from login page
    public string strPassword{get;set;} //password from login page
    public pagereference login(){
           return site.login(strUsername,strPassword,''); //default home landing page will be handled from standard commmunity controller
    }
    
    public pagereference forgotPassword(){
        return new pageReference(site.getBaseUrl()+'/secur/forgotpassword.jsp');
    }
    
    
}