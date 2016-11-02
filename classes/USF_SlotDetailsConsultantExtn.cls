//************************************************************************************
// Name             : USF_SlotDetailsConsultantExtn
// Description      : Controller for USF_SlotDetailsConsultant Visualforce page
// Created By       : Mohan Kalagatla
// Created Date     : 08/25/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 08/25/2016       Mohan Kalagatla       Created
// ************************************************************************************
public without sharing class USF_SlotDetailsConsultantExtn {

ApexPages.StandardController stdController {get; set;}
public Id slotId {get; set;}
public Id updateAppointmentId {get;set;}
public String updateAction {get;set;}
public String slotDate {get;set;}
public String slotTime {get;set;}
public String newLocation{get;set;}
public String newMaxStudents {get;set;}    
public String newNotes {get;set;}   
public String newMeetingNotes {get;set;}    
public String cancel {get; set;}
public String complete {get; set;}    
public boolean isLWCConsultant{get;set;} 
public Boolean isPermissionAssgined{get;set;}
public String checkin{get;set;}

//Added by Vandana - DFCT0011049
public Boolean hasACheckedInStudent{get;set;}
// Place holder for colors based on status
    public String confirm {get;set;}
    public String pending {get;set;}
    //public String cancel {get;set;}
    public String missed {get;set;}
    public String prevpageName {get;set;}
    //public String checkin {get;set;}
    //public String complete {get; set;}
//Modified by Vandana - DFCT0011069
public Boolean hasAppointments{get;set;}
public Boolean isModificationSuccessful{get;set;}

    // Constructor to perform initializations
    public USF_SlotDetailsConsultantExtn(ApexPages.StandardController controller){ 
        stdController = controller;
        slotId = ((Counsellor_Availability__c)stdController.getRecord()).Id;        
        cancel = App_Config__c.getInstance('Cancel').Text_Value__c;
        complete = App_Config__c.getInstance('Complete').Text_Value__c;
        isLWCConsultant = false;
        prevpageName = ApexPages.currentPage().getHeaders().get('Referer');
        System.debug('prevpageName '+prevpageName);

        //isPermissionAssgined=USF_PermissionSetAssignmentUtli.getPermissionSetFlag();
        //Modified by Vandana to remove permission set related functionality
        User currentUser = [Select Id, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<Consultant__c> activeConsultants = USF_DBUtil.getActiveConsultantsByContactId(currentUser.ContactId);
         
        //String usrProfileName = [select id, Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;     
        if(!activeConsultants.isEmpty()){
            isPermissionAssgined = true;
            isLWCConsultant=true;
        }
        //Added by Vandana - DFCT0011049
        hasACheckedInStudent = false;
        checkin = App_Config__c.getInstance('Check').Text_Value__c;
        getAppointments();
        System.debug('##hasACheckedInStudent: '+hasACheckedInStudent);
        confirm = App_Config__c.getInstance('Confirm').Text_Value__c; 
        pending = App_Config__c.getInstance('Pending').Text_Value__c; 
        //cancel = App_Config__c.getInstance('Cancel').Text_Value__c; 
        missed = App_Config__c.getInstance('Missed').Text_Value__c; 
        //checkin = App_Config__c.getInstance('Check').Text_Value__c; 
        //complete = App_Config__c.getInstance('Complete').Text_Value__c;
        hasAppointments = false;
        isModificationSuccessful = false;
    }
    
    // Get Slot
     public USF_SlotDTO getSlotDTO(){
      Counsellor_Availability__c slot = [Select Id,Type__c,Name,Start_Time__c,Coach_Full_Name__c,Status__c,Notes__c,Center__c,Capacity__c,Noofstudentsregistered__c,Selected_Course__r.Name,
                 Location__c,AppointmentType__c from Counsellor_Availability__c where Id = :slotId LIMIT 1];
         
          USF_SlotDTO slotDTO =  new USF_SlotDTO(slot,slot.Start_Time__c.format('EEEE, MMM d yyyy'),slot.Start_Time__c.format('hh:mm a'));
          newLocation = slot.Location__c;
          newMaxStudents = String.valueOf(slot.Capacity__c);
          newNotes = slot.Notes__c;
          newMeetingNotes = slot.Notes__c;
          if(String.valueOf(slot.Noofstudentsregistered__c)!='' && slot.Noofstudentsregistered__c!=0 && slot.Noofstudentsregistered__c>0){
                hasAppointments = true;
          }
      return slotDTO;                
    }
        
    //Get List of Appointments
    public List<AppointmentContact__c> getAppointments(){
        List<AppointmentContact__c> appointmentList = new List<AppointmentContact__c>();
            if(slotId!=null){
                appointmentList = [SELECT Id,Status__c,Contact__r.Name,Contact__r.Preferred_Name__c,Contact__r.Academic_Success_Coach__c,Contact__r.CWID__c,
                                            Contact__r.Phone,Contact__r.Expected_Graduation_Term__r.Name,Contact__r.Email,Contact__r.Department,Contact__r.PhotoUrl,Contact__r.Photo__c,
                                            (SELECT Id,Name FROM Attachments)                  
                                    FROM  AppointmentContact__c 
                                    WHERE AppointmentSlot__c = :slotId
                                    ORDER BY Start_Time__c asc];
            }
            //Added by Vandana - DFCT0011049
            for(AppointmentContact__c appt:appointmentList){
                if(appt.status__c.containsIgnoreCase(App_Config__c.getInstance('Student Checkin by Consultant').Text_Value__c)){
                     hasACheckedInStudent = true;
                 }else{
                     continue;
                 }
            }
            
            return appointmentList;                
    }
    
    // Get Location picklist values   
     public List<SelectOption> getLocation(){     
        List<SelectOption> options = new List<SelectOption>();     
        //options.add(new SelectOption('0001','-Select-'));
        Schema.DescribeFieldResult fieldResult = Counselor_Availability_Definition__c.Location__c.getDescribe();
        if(fieldResult!=null){
        for(Schema.PicklistEntry p : fieldResult.getPicklistValues()){
        options.add(new SelectOption(p.getValue(), p.getValue()));   
        }
        }
        return options;
    }    
          
    // Update Appointment status
    public void updateAppointmentStatus(){                      
           try{
                AppointmentContact__c updateAppointment = new AppointmentContact__c();
                if(updateAppointmentId != null){                        
                  updateAppointment.id=updateAppointmentId;
                     if(updateAction =='Missed by Student'&& updateAppointment.Status__c != App_Config__c.getInstance('Missed By Student').Text_Value__c){
                        updateAppointment.Status__c = App_Config__c.getInstance('Missed By Student').Text_Value__c;
                     }
                     else if(updateAction =='Check In Student' && updateAppointment.Status__c != App_Config__c.getInstance('Student Checkin by Consultant').Text_Value__c){                       
                        updateAppointment.Status__c = App_Config__c.getInstance('Student Checkin by Consultant').Text_Value__c;
                     }
                      if(updateAppointment!=null){   
                        update updateAppointment;
                      }
                  }
            }   
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
    }
          
    // Update Slot status to Completed
    public void markCompleted(){   
          try{
             Counsellor_Availability__c slot = new Counsellor_Availability__c();
              if(slotId!=null){    
                    slot.id=slotId;
                    if(slot.Status__c != App_Config__c.getInstance('LWC Slot Complete Status').Text_Value__c){
                            slot.Status__c = App_Config__c.getInstance('LWC Slot Complete Status').Text_Value__c;  
                             if(slot.Notes__c != newNotes){
                                 slot.Notes__c = newNotes;      
                             } 
                        if(slot!=null){     
                          update slot;   
                        }  
                    }
            }
          }
          catch(Exception ex){
             // Display the error message
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));                          
          } 
    }
    
    // Save notes on Slot record
    public void saveNotes(){              
            try{             
               Counsellor_Availability__c slot = new Counsellor_Availability__c();
               if(slotId!=null){    
                    slot.id=slotId;
                    if(slot.Notes__c!=newMeetingNotes){
                        slot.Notes__c = newMeetingNotes; 
                        if(slot!=null){                     
                          update slot;
                        }
                    }
                 }
            }
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
    }
    
    // Update location and Max students on Slot record
    public void modifySlot()
    {
            try {
                isModificationSuccessful = false;
               Counsellor_Availability__c slot = new Counsellor_Availability__c();
               if(slotId!=null){    
                    slot.id=slotId;
                    if(slot.Location__c != newlocation || slot.Capacity__c != Decimal.valueOf(newMaxStudents)){
                        if(slot.Location__c != newlocation){
                            slot.Location__c = newlocation;
                        }
                        if(slot.Capacity__c != Decimal.valueOf(newMaxStudents)){
                            slot.Capacity__c = Decimal.valueOf(newMaxStudents);
                        }    
                        if(slot!=null){                
                         update slot;
                         isModificationSuccessful = true;
                        }
                    }
                 }
            }   
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }  
    }
   
   // Cancel Slot record
    public void cancelSlot() {
            try {
               Counsellor_Availability__c slot = new Counsellor_Availability__c();
               if(slotId!=null){    
                slot.id=slotId;
                if(slot!= null && slot.Status__c != App_Config__c.getInstance('Slot Cancelled Status').Text_Value__c){
                        slot.Status__c = App_Config__c.getInstance('Slot Cancelled Status').Text_Value__c;
                        if(slot!=null){
                          update slot;
                        }
                }
               }
            }     
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
    }
    
    public PageReference redirectBack() {
      PageReference retURL = new PageReference(prevpageName);
      retURL.setRedirect(true);
      return retURL;
    }
}