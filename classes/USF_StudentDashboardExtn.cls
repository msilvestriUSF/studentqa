//************************************************************************************
// Name             : USF_StudentDashboardExtn
// Description      : Controller for USF_StudentDashboard Visualforce page
// Created By       : Mohan Kalagatla
// Created Date     : 08/30/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 08/30/2016       Mohan Kalagatla       Created
// ************************************************************************************
//public with sharing class USF_StudentDashboardExtn{
//Change it to with sharing once security model is in place
public without sharing class USF_StudentDashboardExtn{
ApexPages.StandardController stdController {get; set;}
public Id contactId {get; set;}
public String cwid {get;set;}
public Contact contactRecord {get; set;}
public Id currentAppointmentId {get; set;}
public Boolean outsideLeadTime {get;set;}
public Id CASARecordTypeId {get; set;}
public Id LWCRecordTypeId {get; set;}
public List<hed__Course_Offering__c> coursesList{get; set;}
public String learningCenter{get; set;}
public String writingCenter{get; set;}
public String cancel {get; set;}
public String complete {get; set;}

//These variables are used for dashboard 
public Boolean isPermissionAssgined {get;set;}
public String userId {get; set;}

    // Constructor to perform initializations
    public USF_StudentDashboardExtn(ApexPages.StandardController controller){
      try{
            String usrProfileName = [select id, Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;     
            userId = UserInfo.getUserId();
            isPermissionAssgined =USF_PermissionSetAssignmentUtli.getPermissionSetFlag();         
            stdController = controller;
            Id loggedInUserContactId = [Select Id, ContactId FROM User where Id =: UserInfo.getUserId() LIMIT 1].ContactId;
            If(loggedInUserContactId != null){
            contactId = loggedInUserContactId;
            }
            else{
            contactId = ((Contact)stdController.getRecord()).Id;
            }
            
            contactRecord = [SELECT Id,Name,Photo__c,PhotoUrl,Department,CWID__c,Special_Advisor__c,AcademicSuccessCoach__c,
                             AcademicSuccessCoach__r.Department,AcademicSuccessCoach__r.Name,AcademicSuccessCoach__r.Email,
                             AcademicSuccessCoach__r.Phone
                             FROM Contact WHERE Id = :contactId LIMIT 1];  
            if(contactRecord != null) {
                cwid = contactRecord.CWID__c;
            }
            CASARecordTypeId = [SELECT Id,DeveloperName,SobjectType FROM RecordType WHERE SobjectType ='AppointmentContact__c' 
                            AND DeveloperName = :App_Config__c.getInstance('CASA Appointment RecordType').Text_Value__c LIMIT 1].Id;   
            LWCRecordTypeId = [SELECT Id,DeveloperName,SobjectType FROM RecordType WHERE SobjectType ='AppointmentContact__c' 
                            AND DeveloperName= :App_Config__c.getInstance('LWC Appointment RecordType').Text_Value__c LIMIT 1].Id;
                            
            learningCenter = App_Config__c.getInstance('Learning Center').Text_Value__c;
            writingCenter = App_Config__c.getInstance('Writing Center').Text_Value__c;
            cancel = App_Config__c.getInstance('Cancel').Text_Value__c;
            complete = App_Config__c.getInstance('Complete').Text_Value__c;
                       
            //Fetch courses for current term        
            Date todayDate = Date.today();
            List<hed__Term__c> termsList = USF_DBUtil.getTerm(todayDate,todayDate);
            if(!termsList.isEmpty()){
                hed__Term__c term = termsList[0];
                //coursesList = USF_DBUtil.getCoursesByTerm(term.Id); 
                coursesList = USF_DBUtil.getCoursesByContact(loggedInUserContactId);
                System.debug('**coursesList: '+coursesList);
            }
            outsideLeadTime = true;
        }
         catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
           } 
    }
    
    //Get appointments
    public List<USF_AppointmentDTO> getappDTOList(){
        List<USF_AppointmentDTO> appDTOList = new List<USF_AppointmentDTO>();
        List<AppointmentContact__c> appointments = [SELECT Id,Name,RecordTypeId,AppointmentSlot__r.Start_Time__c,AppointmentSlot__r.End_Time__c,Staff__c,Location__c,Description__c,Date_Time__c,Status__c,Notes__c,SelectedCourse__r.Name,
                            Center__c,Reason_for_Meeting__c,Coach_Specialty__r.Name
                            FROM AppointmentContact__c
                            WHERE Contact__c = :contactId AND Date_Time__c > :System.now() ORDER BY Date_Time__c ASC];  
        
            if(appointments!=null && !appointments.isEmpty()){
                for(AppointmentContact__c app:appointments ){
                    //USF_AppointmentDTO appDTO = new USF_AppointmentDTO(app,app.Date_Time__c.format('EEEE,d MMM yy, h:mm a')); // DFCT0010899 
                    //Added by Vandana - DFCT0010943
                    String dateStr = app.Date_Time__c.format('MMMM d (EEE)')+'<br>'+app.AppointmentSlot__r.Start_Time__c.format('h:mm a')+' - '+app.AppointmentSlot__r.End_Time__c.format('h:mm a');
                    USF_AppointmentDTO appDTO = new USF_AppointmentDTO(app,dateStr.toUpperCase());
                    appDTOList.add(appDTO);
                } 
            }
            return appDTOList;
      }     
      
      // Method to verify lead time of cancellation 
      public void verifyLeadTime() {
        try{
        List<AppointmentContact__c> appointments = [Select Id,Date_Time__c,AppointmentSlot__c,AppointmentSlot__r.Availability__c,AppointmentSlot__r.Availability__r.Success_Center__c,
                                                    AppointmentSlot__r.Availability__r.Success_Center__r.LeadTime__c 
                                                    FROM AppointmentContact__c 
                                                    where Id =: currentAppointmentId];
        if(appointments.size() > 0) {
            Decimal leadTime = appointments[0].AppointmentSlot__r.Availability__r.Success_Center__r.LeadTime__c;
            System.debug('appointments[0]'+appointments[0]);
            System.debug('appointments[0].AppointmentSlot__c'+appointments[0].AppointmentSlot__c);
            System.debug('appointments[0].AppointmentSlot__r.Availability__c'+appointments[0].AppointmentSlot__r.Availability__c);
            System.debug('appointments[0].AppointmentSlot__r.Availability__r.Success_Center__c'+appointments[0].AppointmentSlot__r.Availability__r.Success_Center__c);
            Long timeNow = DateTime.now().getTime();//time since January 1,1970 GMT 
            Long appointmentTime = appointments[0].Date_Time__c.getTime();
            //Long myDate = Datetime.newInstance(2016, 8, 29, 14, 52, 0).getTime();
            Long milliseconds = appointmentTime - timeNow;
            Long minutes = milliseconds / (1000 * 60);
            if(minutes < (leadTime * 60)) {
                outsideLeadTime = false;
                //return outsideLeadTime;
            }
            else {
                outsideLeadTime = true;
                //return outsideLeadTime;
            }
        } 
        }
        catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }     
    }
    
    // Cancel appointment
    public void cancelAppointment() {
    try {
        List<AppointmentContact__c> appointments = USF_DBUtil.getAppointment(currentAppointmentId);
        system.debug('appointments: '+appointments);
            if(appointments!=null && !appointments.isEmpty()){
                if(appointments[0] !=null && appointments[0].RecordTypeId == CASARecordTypeId && appointments[0].Status__c != App_Config__c.getInstance('CASA Appointment Cancelled Status').Text_Value__c){
                    appointments[0].Status__c = App_Config__c.getInstance('CASA Appointment Cancelled Status').Text_Value__c;    
                    update appointments[0];
                }
                else if(appointments[0]!=null && appointments[0].RecordTypeId == LWCRecordTypeId && appointments[0].Status__c != App_Config__c.getInstance('LWC Appointment CancelledbyStudent').Text_Value__c){
                    String centerId = appointments[0].AppointmentSlot__r.Availability__r.Success_Center__c;
                    List<User> currentUsers = [Select Id, ContactId FROM User where Id =: UserInfo.getUserId()];
                    system.debug('outsideLeadTime: '+outsideLeadTime);
                    if(outsideLeadTime == false) {
                        List<Profile> profiles = [Select Id,Name FROM Profile where Id =: UserInfo.getProfileId()];
                        if(profiles.size() > 0) {
                            if(profiles[0].Name == App_Config__c.getInstance('Student Profile').Text_Value__c || isPermissionAssgined){
                                if(appointments.size() > 0) {
                                    appointments[0].Status__c = App_Config__c.getInstance('LWC Appointment CancelledbyStudent').Text_Value__c;
                                    appointments[0].Strike__c = true;
                                    if(currentUsers[0].ContactId != null) {
                                        List<Contact> contacts = [Select Id,
                                                                    No_of_strikes_in_Writing_Center__c,
                                                                    No_of_strikes_in_Peer_Center__c 
                                                                    FROM Contact 
                                                                    where Id =: currentUsers[0].ContactId];
                                        if(appointments[0].Center__c.contains(App_Config__c.getInstance('Learning Center').Text_Value__c)) {
                                            if(contacts[0].No_of_strikes_in_Peer_Center__c >= 
                                               appointments[0].AppointmentSlot__r.Availability__r.Success_Center__r.Student_Missed_Per_Center__c) {
                                                cancelFutureAppts(centerId,currentUsers[0].ContactId);
                                            }
                                        }
                                        else if(appointments[0].Center__c.contains(App_Config__c.getInstance('Speaking Center').Text_Value__c)) {
                                            /*if(contacts[0].No_of_strikes_in_Speaking_Center__c >= 
                                               appointments[0].AppointmentSlot__r.Availability__r.Success_Center__r.Student_Missed_Per_Center__c) {
                                                cancelFutureAppts(centerId,currentUsers[0].ContactId);
                                            }*/
                                        }
                                        else if(appointments[0].Center__c.contains(App_Config__c.getInstance('Writing Center').Text_Value__c)) {
                                            if(contacts[0].No_of_strikes_in_Writing_Center__c >= 
                                               appointments[0].AppointmentSlot__r.Availability__r.Success_Center__r.Student_Missed_Per_Center__c) {
                                                cancelFutureAppts(centerId,currentUsers[0].ContactId);
                                            }
                                        }
                                    }
                                }
                            }
                            else{
                                if(appointments.size() > 0) {
                                    appointments[0].Status__c = App_Config__c.getInstance('LWC Appointment CancelledbyStudent').Text_Value__c;
                                }
                            }
                        }
                    }
                    else {
                        system.debug('appointmentsELSE: '+appointments[0]);
                        appointments[0].Status__c = App_Config__c.getInstance('LWC Appointment CancelledbyStudent').Text_Value__c;
                    }
                    if(appointments.size() > 0) {
                        update appointments[0];
                    }
                }
                }
        }   
        catch(Exception ex){
            // Display the error message
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    // Method to cancel future appointments
    public void cancelFutureAppts(String centerId, Id contactId) {
    try{
        List<AppointmentContact__c> apptsToBeCancelled = [Select Id FROM AppointmentContact__c 
                                                            where Contact__c =:contactId
                                                            and AppointmentSlot__r.Availability__r.Success_Center__c =:centerId
                                                            And Status__c = :App_Config__c.getInstance('LWC Appointment Confirmed Status').Text_Value__c];
            if(apptsToBeCancelled.size() > 0) {
                for(AppointmentContact__c ac : apptsToBeCancelled) {
                    ac.Status__c = App_Config__c.getInstance('LWC Appointment CancelledbyStudent').Text_Value__c;
                }
                update apptsToBeCancelled;
            }
        }
        catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    } 
    
      
}