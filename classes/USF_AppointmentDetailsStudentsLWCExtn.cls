//************************************************************************************
// Name             : USF_AppointmentDetailsStudentsLWCExtn
// Description      : Controller for USF_AppointmentDetailsStudentsLWCE Visualforce page
// Created By       : Mohan Kalagatla
// Created Date     : 08/30/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 08/30/2016       Mohan Kalagatla       Created
// ************************************************************************************
//public with sharing class USF_AppointmentDetailsStudentsLWCExtn{
//Change it to with sharing once security model is in place
public without sharing class USF_AppointmentDetailsStudentsLWCExtn{
ApexPages.StandardController stdController {get; set;}
public Id appointmentId {get; set;}
public Boolean outsideLeadTime {get;set;}
public String cancel {get; set;}
public String complete {get; set;}
public String learningCenter{get; set;}
public String writingCenter{get; set;}
public Boolean isPermissionAssgined{get;set;}
//Added by Vandana - DFCT0010937
public List<Contact> contactsToNotify{get;set;}

    // Constructor to perform initializations
    public USF_AppointmentDetailsStudentsLWCExtn(ApexPages.StandardController controller){
        stdController = controller;
        appointmentId = ((AppointmentContact__c)stdController.getRecord()).Id;
        cancel = App_Config__c.getInstance('Cancel').Text_Value__c;
        complete = App_Config__c.getInstance('Complete').Text_Value__c;  
        learningCenter = App_Config__c.getInstance('Learning Center').Text_Value__c;
        writingCenter = App_Config__c.getInstance('Writing Center').Text_Value__c;    
        outsideLeadTime = true;
        isPermissionAssgined=USF_PermissionSetAssignmentUtli.getPermissionSetFlag(); 
        //Added by Vandana - DFCT0010937
        List<Contact> contactsToNotify = new List<Contact>();
    }
    
       // Get Appointment
    public USF_AppointmentDTO getAppDTO(){
         AppointmentContact__c appointment = [SELECT Id,Status__c,Contact__r.id,Date_Time__c,Notes__c,Preferred_Phone__c,Type__c,
                               Referred_By__c,Staff__c,Location__c,SelectedCourse__r.Name,Coach_Specialty__r.Name,
                               AppointmentSlot__r.Location__c,Reason_for_Meeting__c,Center__c,Contacts_To_Notify__c,(SELECT id,Name from Attachments)
                               FROM AppointmentContact__c WHERE Id=:appointmentId LIMIT 1]; 
         USF_AppointmentDTO appDTO = new USF_AppointmentDTO(appointment,appointment.Date_Time__c.format('M/d/yyyy'),appointment.Date_Time__c.format('h:mm a'));
         //Added by Vandana - DFCT0010937 - start
            List<String> allcontactIds = new List<String>();  
            if(!String.isBlank(appointment.Contacts_To_Notify__c)){
                allcontactIds = appointment.Contacts_To_Notify__c.split(';');
            } 
            if(!allcontactIds.isEmpty())
                contactsToNotify = [Select Full_Name_Email__c From Contact Where Id IN :allcontactIds];         
         //Added by Vandana - DFCT0010937 - end
         return appDTO;     
    }
        
    // Method to verify Cancellation lead time
    public void verifyLeadTime() {
    try{    
        List<AppointmentContact__c> appointments = [Select Id,Date_Time__c,
                                                    AppointmentSlot__r.Availability__r.Success_Center__r.LeadTime__c 
                                                    FROM AppointmentContact__c 
                                                    where Id =: appointmentId];
                                                    
        if(appointments.size() > 0) {
            Decimal leadTime = appointments[0].AppointmentSlot__r.Availability__r.Success_Center__r.LeadTime__c;
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
    
    // Cancellation of appointment
    public void cancelAppointment() {
    try {   
         List<AppointmentContact__c> appointments = USF_DBUtil.getAppointment(appointmentId);
            String centerId = appointments[0].AppointmentSlot__r.Availability__r.Success_Center__c;
            List<User> currentUsers = [Select Id, ContactId FROM User where Id =: UserInfo.getUserId()];
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
                appointments[0].Status__c = App_Config__c.getInstance('LWC Appointment CancelledbyStudent').Text_Value__c;
            }
            if(appointments.size() > 0) {
                update appointments[0];
            }
        }
        catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
    }
    
    // Cancel future appointments
    public void cancelFutureAppts(String centerId, Id contactId) {
     try{   
        List<AppointmentContact__c> apptsToBeCancelled = [Select Id FROM AppointmentContact__c 
                                                            where Contact__c =: contactId
                                                            and AppointmentSlot__r.Availability__r.Success_Center__c =: centerId
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