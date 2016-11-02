//************************************************************************************
// Name             : USF_AvailabilityListExtn
// Description      : Controller for USF_AvailabilityList Visualforce page
// Created By       : Mohan
// Created Date     : 09/13/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 08/30/2016       Mohan       Created
// ************************************************************************************
public with sharing class USF_AvailabilityListExtn{
    
    //public List<Counselor_Availability_Definition__c> availabilityList {get;set;}
    public ApexPages.StandardSetController availabilityList;
    public List<Counsellor_Availability__c> slotList{get;set;}
    public Id currentAvailabilityId {get;set;}
    public Id currentSlotId {get;set;}
    public String newlocation {get;set;}
    public String newMaxStudents {get;set;}  
    public String newCenter {get;set;}
    public Map<Id,String> availabilityStartDateMap {get; set;}
    public Map<Id,String> availabilityEndDateMap {get; set;}
    public Map<Id,String> availabilityStartTimeMap {get; set;}
    public Map<Id,String> availabilityEndTimeMap {get; set;}
    public Map<Id,String> slotStartDateMap {get; set;}
    public Map<Id,String> slotEndDateMap {get; set;}
    public Map<Id,String> slotStartTimeMap {get; set;}
    public Map<Id,String> slotEndTimeMap {get; set;}
    public Map<Id,List<String>> availabilityCoursesMap {get; set;}
    public Boolean availabilityCoursesMore {get; set;}
    public Boolean availabilityCoursesNone {get; set;}
    public Integer pageSize{get;set;}
    public boolean showSlotsSection{get;set;}
    public Integer noOfRecords{get; set;}
    public Integer noOfAvailabilityRecords{get; set;}
    public String message {get;set;}
    public String learningCenter{get; set;}
    public String writingCenter{get; set;}
    public String speakingCenter{get; set;} 
    //Modified by Vandana - DFCT0011069
    public Boolean hasAppointments{get;set;}
    public Boolean isModificationSuccessful{get;set;}
    
    // Constructor to perform initializations
    public USF_AvailabilityListExtn(){
        pageSize=5;
        showSlotsSection=false;
        message='';
        availabilityList = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Name,Location__c,Success_Center__r.Name,Center_Text__c,TimeSlotDuration__c,TimeSlotDurationLWC__c,Max_Number_of_Students__c,Start_Date_Time__c,
                            End_Date_Time__c,Repeat__c,Monday__c,Tuesday__c,Wednesday__c,Thursday__c,Friday__c,Coach__c,AppointmentType__c
                            FROM Counselor_Availability_Definition__c where Coach__c=:UserInfo.getUserId() ORDER BY Start_Date_Time__c asc]));     
        slotStartDateMap = new Map<Id,String>();
        slotEndDateMap = new Map<Id,String>();
        slotStartTimeMap = new Map<Id,String>();
        slotEndTimeMap = new Map<Id,String>(); 
        availabilityStartDateMap = new Map<Id,String>();
        availabilityEndDateMap = new Map<Id,String>();  
        availabilityStartTimeMap = new Map<Id,String>();
        availabilityEndTimeMap = new Map<Id,String>(); 
        availabilityCoursesMore = false;
        availabilityCoursesNone = false;       
        availabilityList.setpageSize(pageSize);
        noOfRecords = availabilityList.getResultSize();
        learningCenter = App_Config__c.getInstance('Learning Center').Text_Value__c;
        writingCenter = App_Config__c.getInstance('Writing Center').Text_Value__c;
        speakingCenter = App_Config__c.getInstance('Speaking Center').Text_Value__c;  
        //Modified by Vandana - DFCT0011069
        hasAppointments = false;
        isModificationSuccessful = false;
    }
    
    //Get list of availabilities
    public List<Counselor_Availability_Definition__c> getAvailabilities() {
      // Populate dates Map
        availabilityStartDateMap = new Map<Id,String>();
        availabilityEndDateMap = new Map<Id,String>();  
        availabilityStartTimeMap = new Map<Id,String>();
        availabilityEndTimeMap = new Map<Id,String>(); 
     
     for(Counselor_Availability_Definition__c app : (List<Counselor_Availability_Definition__c>)availabilityList.getRecords()){
                if(app.Start_Date_Time__c!=null){
                 availabilityStartDateMap.put(app.Id,app.Start_Date_Time__c.format('EEEE, MMM d yyyy'));
                 availabilityStartTimeMap.put(app.Id,app.Start_Date_Time__c.format('hh:mma'));
                }
                if(app.End_Date_Time__c!=null){
                 availabilityEndDateMap.put(app.Id,app.End_Date_Time__c.format('EEEE, MMM d yyyy'));
                 availabilityEndTimeMap.put(app.Id,app.End_Date_Time__c.format('hh:mma'));
                }
         }
         
        return (List<Counselor_Availability_Definition__c>)availabilityList.getRecords();
    }
    
    //Pagination methods for Courses
    public Boolean hasNext {
        get {
            return availabilityList.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return availabilityList.getHasPrevious();
        }
        set;
    }
    public Integer pageNumber {
        get {
            return availabilityList.getPageNumber();
        }
        set;
    }
    public void first() { 
        currentAvailabilityId = null;
        availabilityList.first();     
    }
    public void last() {
        currentAvailabilityId = null;
        availabilityList.last();
    }
    public void previous() {
        currentAvailabilityId = null;
        availabilityList.previous();
    }
    public void next() {
        currentAvailabilityId = null;
        availabilityList.next();
    }
    
   // Method to view Slots 
    public List<Counsellor_Availability__c> getSlots(){
        showSlotsSection=true;
        slotStartDateMap = new Map<Id,String>();
        slotEndDateMap = new Map<Id,String>(); 
        slotStartTimeMap = new Map<Id,String>();
        slotEndTimeMap = new Map<Id,String>();
        availabilityCoursesMap = new Map<Id,List<String>>();
        List<String> courseList = new List<String>();
        availabilityCoursesMore = false;
        availabilityCoursesNone = false;
       try{
        if(currentAvailabilityId!=null){
           slotList=[SELECT Id,Availability__c,Name,Center__c,Coach_Full_Name__c,Availability__r.Success_Center__r.Name,Center_Text__c,Selected_Course__r.Name,Location__c,Capacity__c,
                        Selected_Course__c,Selected_Course__r.hed__Course__r.Name,Selected_Course__r.hed__Section_ID__c,
                        Selected_Course__r.hed__Course__r.Subject_Code__c,Selected_Course__r.hed__Course__r.Course_Number__c,Noofstudentsregistered__c,Number_Of_Seats_Booked__c,Start_Time__c,End_Time__c,CreatedBy.Name,createdDate,Status__c,Type__c
                        FROM Counsellor_Availability__c where 
                        Availability__c = :currentAvailabilityId];
            for(Counsellor_Availability__c app : slotList){               
                if(app.Start_Time__c != null){
                  slotStartDateMap.put(app.Id,app.Start_Time__c.format('EEEE, MMM d yyyy'));
                  slotStartTimeMap.put(app.Id,app.Start_Time__c.format('hh:mma'));
                }
                if(app.End_Time__c != null){
                  slotEndDateMap.put(app.Id,app.End_Time__c.format('EEEE, MMM d yyyy'));
                  slotEndTimeMap.put(app.Id,app.End_Time__c.format('hh:mma'));
                }
            }
            
                for(Appointment_Course__c appCourse:
                            [SELECT Id,Eligible_Tutor_Courses__c,Eligible_Tutor_Courses__r.Course_Offering__c,Eligible_Tutor_Courses__r.Course_Offering__r.hed__Course__r.Subject_Code__c,
                            Eligible_Tutor_Courses__r.Course_Offering__r.hed__Course__r.Course_Number__c,
                            Eligible_Tutor_Courses__r.Course_Offering__r.hed__Section_ID__c,Availability_Definition__c
                            FROM Appointment_Course__c where  Availability_Definition__c =:currentAvailabilityId]){
                    courseList.add(appCourse.Eligible_Tutor_Courses__r.Course_Offering__r.hed__Course__r.Subject_Code__c
                    +' '+appCourse.Eligible_Tutor_Courses__r.Course_Offering__r.hed__Course__r.Course_Number__c+
                    + ' ('+appCourse.Eligible_Tutor_Courses__r.Course_Offering__r.hed__Section_ID__c+')');
                }
                if(!courseList.isEmpty()){
                  availabilityCoursesMap.put(currentAvailabilityId,courseList);
                  if(courseList.size() > 1){
                     availabilityCoursesMore = true;
                  }
                     availabilityCoursesNone = true;    
                }
         }
         else{
            slotList.clear();
         }
        }       
        catch(Exception ex){
                    //Display the error message
                    System.debug('Exception:'+ ex.getMessage()+ex.getStackTraceString());
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        return slotList;    
    }
    
    //Get Location values
    public List<SelectOption> getLocation(){     
     /*   List<SelectOption> options = new List<SelectOption>();     
        //options.add(new SelectOption('0001','-Select-'));
        Schema.DescribeFieldResult fieldResult = Counselor_Availability_Definition__c.Location__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        options.add(new SelectOption(p.getValue(), p.getValue()));   
        return options; */
        
                Schema.sObjectType sobject_type = Counselor_Availability_Definition__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<selectOption> options = new List<selectOption>();
            List<Schema.PicklistEntry> pick_list_values = field_map.get('Location__c').getDescribe().getPickListValues();
            String casaLocations = App_Config__c.getInstance('CASA Locations').Text_Value__c;
            List<String> casaLocationsList;
            if(String.isNotBlank(casaLocations)) {
                casaLocationsList = casaLocations.split(';');
            }
            Set<String> casaLocationsSet;
            if(casaLocationsList != null) {
                casaLocationsSet = new Set<String>(casaLocationsList);
            }
            for (Schema.PicklistEntry a : pick_list_values) {
                if((casaLocationsSet != null && casaLocationsSet.contains(a.getLabel()))) {
                    continue;
                }
                else {
                    options.add(new selectOption(a.getLabel(), a.getValue()));
                }
            }
        return options;
    }
    
     // Get Writing location values
    public List<SelectOption> getWritingLocation(){     
        List<SelectOption> options = new List<SelectOption>();     
        options.add(new SelectOption(App_Config__c.getInstance('LWC Writing Center Location').Text_Value__c,
                    App_Config__c.getInstance('LWC Writing Center Location').Text_Value__c));   
        return options;
    }
    
   // Get Speaking location values
    public List<SelectOption> getSpeakingLocation(){     
        List<SelectOption> options = new List<SelectOption>();     
        options.add(new SelectOption(App_Config__c.getInstance('LWC Speaking Center Location').Text_Value__c,
                    App_Config__c.getInstance('LWC Speaking Center Location').Text_Value__c));   
        return options;
    }
    
    //Method to cancel Availability
    public void cancelAvailability(){   
        Counselor_Availability_Definition__c updateAvailability = new Counselor_Availability_Definition__c();
            try {                                                           
                if(currentAvailabilityId != null){
                    updateAvailability.Id = currentAvailabilityId; 
                    if(updateAvailability!=null){
                      delete updateAvailability;
                      message = 'Availability has been deleted successfully.';
                    } 
                 }    
                
               /* List<Counsellor_Availability__c> slotsWithoutAppointments = new List<Counsellor_Availability__c>();
                List<Counsellor_Availability__c> slotsWithAppointments = new List<Counsellor_Availability__c>();
                List<AppointmentContact__c> appointments = new List<AppointmentContact__c>();
                if(currentAvailabilityId != null){
                    for(Counsellor_Availability__c slot : [Select Id,Status__c,(Select id,status__c from Appointment_Contacts__r) FROM Counsellor_Availability__c 
                                                            WHERE Availability__c = :currentAvailabilityId]){                   
                       if(slot.Appointment_Contacts__r!=null && !slot.Appointment_Contacts__r.isEmpty()){   
                                slotsWithAppointments.add(slot);
                         }
                         else{
                            slotsWithoutAppointments.add(slot);
                         }
                     }
                    if(slotsWithoutAppointments != null && !slotsWithoutAppointments.isEmpty()){
                            delete slotsWithoutAppointments;
                            message = 'All the slots associated with the availability have been deleted successfully.';
                    }
                    if(slotsWithAppointments != null && !slotsWithAppointments.isEmpty()){
                            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'Please note that the slots which have atleast one associated appointment have not been deleted.'));
                            message = 'Please note that the slots which have atleast one appointment book have not been deleted.';
                    }
                }   */
            }   
            catch(Exception ex){
                // Display the error message
                System.debug('Exception:'+ex.getMessage());
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                message = ex.getMessage();
            }
    }
   // Update Slot location and max students
    public void modifySlot(){
        System.debug('Entered***'+currentSlotId);
       Counsellor_Availability__c updateSlot = new Counsellor_Availability__c();
            try {
                isModificationSuccessful = false;
                if(currentSlotId != null){
                    updateSlot.Id = currentSlotId; 
                    if(updateSlot.Location__c != newlocation || updateSlot.Capacity__c != Decimal.valueOf(newMaxStudents)){
                        if(updateSlot.Location__c != newlocation){
                            updateSlot.Location__c = newlocation;
                        }
                        if(updateSlot.Capacity__c != Decimal.valueOf(newMaxStudents)){
                            updateSlot.Capacity__c = Decimal.valueOf(newMaxStudents);
                        }
                        if(updateSlot!=null){
                          update updateSlot;
                          isModificationSuccessful = true;
                        }
                     }
                  }       
            }   
            catch(Exception ex){
                // Display the error message
                System.debug('Exception:'+ex.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }   
     } 
   
    // Method for deleting slected slot
    public void deleteSlot(){      
           Counsellor_Availability__c updateSlot = new Counsellor_Availability__c();
            try {                                                           
                if(currentSlotId != null){
                    updateSlot.Id = currentSlotId; 
                    if(updateSlot!=null){
                      delete updateSlot;
                    } 
                 }              
            }   
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));                
            } 
    }
        
     public void populateSlotDetails(){ 
           try{                                                
                if(currentSlotId != null){
                    Counsellor_Availability__c updateSlot = [SELECT ID ,Location__c,Capacity__c,Center_Text__c,(Select Id From Appointment_Contacts__r),Noofstudentsregistered__c FROM Counsellor_Availability__c 
                                                                      where Id = :currentSlotId LIMIT 1];  
                    newlocation = updateSlot.Location__c;
                    newMaxStudents = String.valueOf(updateSlot.Capacity__c);   
                    newCenter = updateSlot.Center_Text__c;
                    //Added by Vandana - DFCT0011069
                    /*if(!updateSlot.Appointment_Contacts__r.isEmpty()){
                        hasAppointments = true;
                    }*/
                    System.debug(':::Noofstudentsregistered__c: '+updateSlot.Noofstudentsregistered__c);
                    if(String.valueOf(updateSlot.Noofstudentsregistered__c)!='' && updateSlot.Noofstudentsregistered__c!=0 && updateSlot.Noofstudentsregistered__c>0){
                        hasAppointments = true;
                    }
                 }  
                 System.debug('***hasAppointments: '+hasAppointments);
            }   
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }   
     }
     
      public void refreshSlotList(){ 
           try {                                                
               getSlots();
            }   
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }   
     }
     
      public void refreshAvailabilityList(){ 
           try {           
               Integer previousPageNumber = pageNumber;
               availabilityList = new ApexPages.StandardSetController(Database.getQueryLocator([SELECT Id,Name,Location__c,Success_Center__r.Name,Center_Text__c,TimeSlotDuration__c,TimeSlotDurationLWC__c,Max_Number_of_Students__c,Start_Date_Time__c,
                            End_Date_Time__c,Repeat__c,Monday__c,Tuesday__c,Wednesday__c,Thursday__c,Friday__c,Coach__c,AppointmentType__c
                            FROM Counselor_Availability_Definition__c where Coach__c=:UserInfo.getUserId() ORDER BY Start_Date_Time__c asc]));     
              availabilityList.setpageSize(pageSize);
              availabilityList.setpageNumber(previousPageNumber);
              noOfRecords = availabilityList.getResultSize();                            
               
              // getAvailabilities();
            }   
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }   
     }
}