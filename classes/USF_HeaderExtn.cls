//************************************************************************************
// Name             : USF_HeaderExtn
// Description      : Controller for USF_Header Visualforce component
// Created By       : Mohan
// Created Date     : 09/16/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 09/16/2016       Mohan       Created
// ************************************************************************************
public with sharing class USF_HeaderExtn{

    public User loggedinUser {get; set;}
    public Decimal hoursInRow {get; set;}
    public Decimal hoursInWeek {get; set;}
    public String zoomDetails {get; set;}
    public String usrProfileName {get; set;}
    //Toggle functionality
    public Boolean isPermissionAssgined {get;set;}
    public String linkValue {get;set;}
    public String pageLink{get;set;}
    public Contact con{get;set;}
    
    public Boolean isStudentProfile {get; set;}
    public Boolean isDashboardPage {get; set;}
    
    Id userId {get; set;}
   
    //Controller for initilizations
    public USF_HeaderExtn(){   
        userId = Userinfo.getUserId();
        loggedinUser = [select id,Name,Max_hours_in_a_row__c,Max_hours_in_a_week__c,Zoom_Details__c from User where id = :userId];   
        hoursInRow = loggedinUser.Max_hours_in_a_row__c;
        hoursInWeek = loggedinUser.Max_hours_in_a_week__c;
        zoomDetails = loggedinUser.Zoom_Details__c;
        usrProfileName = [select id, Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;  
        //isStudentProfile = usrProfileName.equalsignorecase(App_Config__c.getInstance('Student Profile').Text_Value__c)?true:false;
        isStudentProfile = false;
        isPermissionAssgined = false;
        isDashboardPage = false;
            //isPermissionAssgined=USF_PermissionSetAssignmentUtli.getPermissionSetFlag();
             //Manjunath added for toggle dashboard functionality--Start
             //Modified by Vandana to remove permission set related functionality
             User currentUser = [Select Id, ContactId,AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
           Boolean isStudent = false;
           Boolean isFaculty = false;
           if(currentUser != null && currentUser.ContactId != null) {
              List<Contact> currentContact = [Select Id,Name,Photo__c,Faculty__c,CWID__c,Student__c FROM Contact where Id =:currentUser.ContactId];
              isStudent = currentContact[0].Student__c;
              isFaculty = currentContact[0].Faculty__c;
              con = currentContact[0];
           }
           
             List<Consultant__c> activeConsultants = USF_DBUtil.getActiveConsultantsByContactId(currentUser.ContactId);
             if(!activeConsultants.isEmpty()){
              system.debug('activeConsultants: '+activeConsultants);
                isPermissionAssgined = true;
                if((ApexPages.currentPage().getUrl().contains(App_Config__c.getInstance('Student Dashboard Page').Text_Value__c) ||
                   ApexPages.currentPage().getUrl().contains('USF_AppointmentScheduler') ||
                   ApexPages.currentPage().getUrl().contains('USF_ModifyLWCAppointment') ||
                   ApexPages.currentPage().getUrl().contains('USF_ModifyLWCAppointmentConfirmation') ||
                   ApexPages.currentPage().getUrl().contains('USF_TutorTuteeConfirmation') ||
                   ApexPages.currentPage().getUrl().contains('USF_TutorRequest') ||
                   ApexPages.currentPage().getUrl().contains('USF_AppointmentDetailsStudentsCASA') ||
                   ApexPages.currentPage().getUrl().contains('USF_AppointmentDetailsStudentsLWC')) && (!ApexPages.currentPage().getParameters().keyset().contains('details'))){
                    linkValue=App_Config__c.getInstance('Switch To Consultant View').Text_Value__c;
                    pageLink=App_Config__c.getInstance('LWC Consultant Dashboard').Text_Value__c;
                    isDashboardPage = true;
                }else if(ApexPages.currentPage().getUrl().contains(App_Config__c.getInstance('Consultant Dashboard Page').Text_Value__c) ||
                         ApexPages.currentPage().getUrl().contains('USF_AvailabilityCalendar') ||
                         ApexPages.currentPage().getUrl().contains('USF_AvailabilityList') ||
                         ApexPages.currentPage().getUrl().contains('USF_SetAvailability') ||
                         ApexPages.currentPage().getUrl().contains('USF_SlotDetailsConsultant')){
                    system.debug('Consultant Page');
                    if(isFaculty && !isStudent) {
                      linkValue=App_Config__c.getInstance('Switch To Faculty View').Text_Value__c;
                      pageLink=App_Config__c.getInstance('Faculty Dashboard').Text_Value__c;
                    }
                    else {
                        linkValue=App_Config__c.getInstance('Switch To Student View').Text_Value__c;
                        pageLink=App_Config__c.getInstance('Student Dashboard').Text_Value__c;
                    }
                    
                    isDashboardPage = true;
                }
                else if(ApexPages.currentPage().getParameters().keyset().contains('details') && ApexPages.currentPage().getUrl().contains('USF_AppointmentDetailsStudentsLWC')) {
                    linkValue=App_Config__c.getInstance('Switch To Student View').Text_Value__c;
                      pageLink=App_Config__c.getInstance('Student Dashboard').Text_Value__c;
                }
                else if(ApexPages.currentPage().getUrl().contains(App_Config__c.getInstance('Faculty Dashboard').Text_Value__c)){
                    system.debug('fac Dash'+App_Config__c.getInstance('Faculty Dashboard').Text_Value__c);
                    linkValue=App_Config__c.getInstance('Switch To Consultant View').Text_Value__c;
                    pageLink=App_Config__c.getInstance('LWC Consultant Dashboard').Text_Value__c;
                    system.debug(linkValue +'>>> '+pageLink);
                    isDashboardPage = true;
                }
             }else if(usrProfileName == App_Config__c.getInstance('Student Profile').Text_Value__c){
                isStudentProfile = true;
                if(ApexPages.currentPage().getUrl().contains(App_Config__c.getInstance('Student Dashboard Page').Text_Value__c)){
                    linkValue=App_Config__c.getInstance('Switch To Consultant View').Text_Value__c;
                    pageLink=App_Config__c.getInstance('LWC Consultant Dashboard').Text_Value__c;
                    isDashboardPage = true;
                }else if(ApexPages.currentPage().getUrl().contains(App_Config__c.getInstance('Consultant Dashboard Page').Text_Value__c)){
                   linkValue=App_Config__c.getInstance('Switch To Student View').Text_Value__c;
                   pageLink=App_Config__c.getInstance('Student Dashboard').Text_Value__c;
                   isDashboardPage = true;
                }
              }
             /*if(isPermissionAssgined){
                linkValue='';
              if(usrProfileName == App_Config__c.getInstance('Consultant Profile Name').Text_Value__c){
                  if(ApexPages.currentPage().getUrl().contains(App_Config__c.getInstance('Student Dashboard Page').Text_Value__c)){
                    linkValue=App_Config__c.getInstance('Switch To Consultant View').Text_Value__c;
                    pageLink=App_Config__c.getInstance('LWC Consultant Dashboard').Text_Value__c;
                    }
                    else if(ApexPages.currentPage().getUrl().contains(App_Config__c.getInstance('Consultant Dashboard Page').Text_Value__c)){
                    linkValue=App_Config__c.getInstance('Switch To Student View').Text_Value__c;
                    pageLink=App_Config__c.getInstance('Student Dashboard').Text_Value__c;
                    }
                }
                else if(usrProfileName == App_Config__c.getInstance('Student Profile').Text_Value__c){
                    if(ApexPages.currentPage().getUrl().contains(App_Config__c.getInstance('Student Dashboard Page').Text_Value__c)){
                        linkValue=App_Config__c.getInstance('Switch To Consultant View').Text_Value__c;
                        pageLink=App_Config__c.getInstance('LWC Consultant Dashboard').Text_Value__c;
                       }
                       else if(ApexPages.currentPage().getUrl().contains(App_Config__c.getInstance('Consultant Dashboard Page').Text_Value__c)){
                       linkValue=App_Config__c.getInstance('Switch To Student View').Text_Value__c;
                       pageLink=App_Config__c.getInstance('Student Dashboard').Text_Value__c;
                       }
                }
              }*/
            //Manjunath added for toggle dashboard functionality--End
    }
    
    // Method to update User details
    public void updateUserDetails(){
        try{
            user usr = [select id,Name,Max_hours_in_a_row__c,Max_hours_in_a_week__c,Zoom_Details__c from User where id = :Userinfo.getUserId()]; 
            if(hoursInRow!=null){
                usr.Max_hours_in_a_row__c = hoursInRow; 
            }
            if(hoursInWeek!=null){
                usr.Max_hours_in_a_week__c = hoursInWeek; 
            }
            if(zoomDetails!=null){
                usr.Zoom_Details__c = zoomDetails; 
            }
            if(usr!=null){
                update usr;
            }
        }catch(Exception ex){
            // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
       // Method to update User details
    public PageReference signOut(){
        return new pagereference(site.getBaseUrl()+'/secur/logout.jsp');
    }
}