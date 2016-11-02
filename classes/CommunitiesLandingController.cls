/**
 * An apex page controller that takes the user to the right start page based on credentials or lack thereof
 */
public with sharing class CommunitiesLandingController {
    
    // Code we will invoke on page load.
    public PageReference forwardToStartPage() {
        String startUrl = System.currentPageReference().getParameters().get('startURL');
        string communityName=App_Config__c.getInstance('CommunityName').name__c;
        Network community=[select id from Network where name=:communityName limit 1];
        String communityLoginURL=Network.getLoginUrl(community.id);
        String communityBaseURL=communityLoginURL.substring(0,communityLoginURL.lastIndexOf('/'));
        String customHomePage = communityBaseURL;
        Id profileId=userinfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        User currentUser = [Select Id, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<Consultant__c> activeConsultants = USF_DBUtil.getActiveConsultantsByContactId(currentUser.ContactId);
        if(startUrl!=null){
        customHomePage=customHomePage+startUrl;
            return new PageReference(customHomePage); 
        }//Added by Vandana to remove permission set related functionality
        else if(!activeConsultants.isEmpty()){
        	System.debug('####Entered');
        	customHomePage=customHomePage+'/apex/USF_ConsultantDashboard';
            return new PageReference(customHomePage);
        }
        else if(profileName.equalsIgnoreCase(App_Config__c.getInstance('Student Profile Name').name__c)){
        	System.debug('####Student Profile');
            customHomePage=customHomePage+'/apex/USF_StudentDashboard';
            return new PageReference(customHomePage);
            
        }/*else if(profileName.equalsIgnoreCase(App_Config__c.getInstance('Consultant Profile Name').name__c)){
            customHomePage=customHomePage+'/apex/USF_ConsultantDashboard';
            return new PageReference(customHomePage);
        }*/        
        //Added by Manjunath-Start
        else if(profileName.equalsIgnoreCase(App_Config__c.getInstance('Faculty Profile Name').Text_Value__c)){
            customHomePage=customHomePage+'/apex/USF_FacultyDashBoard';
            return new PageReference(customHomePage);
            
        }
        
        //Added by Manjunath-End
        else{
                return Network.communitiesLanding();
        }
    }
    
    public CommunitiesLandingController() {}
}