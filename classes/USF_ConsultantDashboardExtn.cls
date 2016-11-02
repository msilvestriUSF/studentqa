//************************************************************************************
// Name             : USF_ConsultantDashboardExtn
// Description      : Controller for USF_ConsultantDashboard Visualforce page
// Created By       : Mohan
// Created Date     : 08/30/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 08/30/2016       Mohan       Created
// ************************************************************************************
public with sharing class USF_ConsultantDashboardExtn{

    public List<USF_SlotDTO> slotDTOList {get;set;}    
    public String newLocation {get;set;}
    public Decimal newMaxStudents {get;set;}  
    public String newNotes {get;set;} 
    public String newCenter {get;set;}
    public Id currentSlotId {get; set;}
    public String userId {get; set;}
    public String LWCSlotRecordType {get; set;}
    public String selectedAppId {get;set;}
    public String selectedAction {get;set;}
    public String slotOpenStatus {get;set;}
    public Id LWCSlotRecordTypeId {get; set;}
    public String learningCenter{get; set;}
    public String writingCenter{get; set;}
    public String speakingCenter{get; set;}
    public Boolean outsideLeadTime {get;set;} 
  
    // Place holder for metric  values  
    public Integer upcomingCount {get;set;}
    public Integer missedCount {get;set;}
    public Integer cancelCount {get;set;}
    public Integer checkedCount {get;set;}
    
    // Place holder for colors based on status
    public String confirm {get;set;}
    public String pending {get;set;}
    public String cancel {get;set;}
    public String missed {get;set;}
    public String checkin {get;set;}
    public String complete {get; set;}
    
    //Variables to hold the filter Selects-Start
    public String todayValue {get;set;}
    public String selectedTodayValue {get;set;}
    public String selectedStatusValue {get;set;}
    public String selectedConsultantValue {get;set;}
    
    //Variables to Build Dynamic SOQL-Start
    public String query {get;set;}
    public String statusFilterCondition {get;set;}
    public String dateFilterCondition {get;set;}
    
    //Boolean flags to toggle logged-in user
    public boolean isLWCStaff{get;set;}
    public boolean isLWCConsultant{get;set;}   
    public Boolean isPermissionAssgined{get;set;}
    
    /*Vandana -- DFCT0011014 -- 
      As a Consultant I should not be able to Mark Complete until after the start time of an appointment and 
      only if the appointment is checked-in by a Consultant and at least one student 
      (group appointments need at least 1 student to check-in) */
      
    public Map<String,Boolean> slotIdStudentCheckedInMap{get;set;}
    public Map<String,Boolean> slotIdStudentConfirmedMap{get;set;}
    
    //This variable is being used for upcoming appointments
    // public USF_SlotDTO upcomingAppointmentDTO{get;set;}
    // public List<Counsellor_Availability__c> upcomingAppointment;
     
    //Controller for initilizations
    public USF_ConsultantDashboardExtn(){
        String usrProfileName = [select id, Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;     
        userId = UserInfo.getUserId();
        //isPermissionAssgined=USF_PermissionSetAssignmentUtli.getPermissionSetFlag();
        
        //Initialize variables
        slotOpenStatus = App_Config__c.getInstance('Slot Open Status').Text_Value__c;
        LWCSlotRecordType = App_Config__c.getInstance('LWC Slot Record type').Text_Value__c;
        confirm = App_Config__c.getInstance('Confirm').Text_Value__c; 
        pending = App_Config__c.getInstance('Pending').Text_Value__c; 
        cancel = App_Config__c.getInstance('Cancel').Text_Value__c; 
        missed = App_Config__c.getInstance('Missed').Text_Value__c; 
        checkin = App_Config__c.getInstance('Check').Text_Value__c; 
        complete = App_Config__c.getInstance('Complete').Text_Value__c;
        selectedTodayValue=App_Config__c.getInstance('Default LWC Date filter').Text_Value__c;
        todayValue = 'Today';
        selectedStatusValue = App_Config__c.getInstance('Default LWC status filter').Text_Value__c;
        selectedConsultantValue = App_Config__c.getInstance('Default LWC Consultant filter').Text_Value__c; 
        learningCenter = App_Config__c.getInstance('Learning Center').Text_Value__c;
        writingCenter = App_Config__c.getInstance('Writing Center').Text_Value__c;
        speakingCenter = App_Config__c.getInstance('Speaking Center').Text_Value__c;           
        upcomingCount = 0;
        missedCount = 0;
        cancelCount  = 0;   
        checkedCount = 0;
        statusFilterCondition='';
        dateFilterCondition ='';
        isLWCConsultant = false;
        isLWCStaff = false;
        outsideLeadTime = false;
        //upcomingAppointment=new List<Counsellor_Availability__c>();
        
        //Added by Vandana
        slotIdStudentCheckedInMap = new Map<String,Boolean>();
        slotIdStudentConfirmedMap = new Map<String,Boolean>();
            
        //Added By Manjunath-Start        
        LWCSlotRecordTypeId = [SELECT Id,DeveloperName,SobjectType FROM RecordType WHERE SobjectType ='Counsellor_Availability__c' 
                            AND DeveloperName= :LWCSlotRecordType LIMIT 1].Id;          
        query='SELECT ID ,(Select id,Name,Contact_Name__c,contact__r.name,contact__r.cwid__c,status__c,Date_Time__c from Appointment_Contacts__r order by status__c asc, createddate desc),Center__c,Coach_Full_Name__c,Selected_Course__r.Name,Location__c,Capacity__c,Noofstudentsregistered__c,Number_Of_Seats_Booked__c,StartDate__c,Start_Time__c,End_Time__c,CreatedBy.Name,createdDate,Status__c,Notes__c  FROM Counsellor_Availability__c WHERE Recordtype.Developername= :LWCSlotRecordType';
        //Added By Manjunath-End
        //Modified by Vandana to remove permission set related functionality
        User currentUser = [Select Id, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        
        List<Consultant__c> activeConsultants = USF_DBUtil.getActiveConsultantsByContactId(currentUser.ContactId);
        if(!activeConsultants.isEmpty()){
            isPermissionAssgined = true;
            //Added By Manjunath-Start
            query+=' AND Availability__r.Coach__c=:userId ';
            //Added By Manjunath-End
            isLWCConsultant=true;
        }
        else{
            //Commented By Manjunath-Start
            //query='SELECT ID ,Center__c,Coach_Full_Name__c,Selected_Course__r.Name,Location__c,Capacity__c,Noofstudentsregistered__c,Number_Of_Seats_Booked__c,StartDate__c,Start_Time__c,CreatedBy.Name,createdDate,Status__c,Notes__c FROM Counsellor_Availability__c WHERE Recordtype.Developername=:LWCSlotRecordType AND';       
            //query+=' AND ';
            //Commentd By Manjunath-End
            isLWCStaff =true;
            System.debug('isLWCStaff =true;');
        }               
    }
    
    // Get populated Slots
    public List<USF_SlotDTO> getSlots(){    
        upcomingCount = 0;
        missedCount = 0;
        cancelCount  = 0;   
        checkedCount = 0;  
        statusfilterCondition='';
        //Getting the upcoming appointments
        // getUpComingAppointments();
        slotDTOList = new List<USF_SlotDTO>(); 
        
          //added by Vandana
         slotIdStudentCheckedInMap = new Map<String,Boolean>();
         slotIdStudentConfirmedMap = new Map<String,Boolean>();
         Boolean hasACheckedInStudent = false;
         Boolean hasAConfirmedStudent = false;
         DateTime now = DateTime.now();
        if(selectedTodayValue !=null && selectedTodayValue !=''){
            if(selectedTodayValue.containsIgnoreCase('NEXT_N_DAYS')){
             //dateFilterCondition =' AND (Start_Time__c ='+selectedTodayValue +' OR Start_Time__c ='+todayValue +') ';
             dateFilterCondition =' AND (End_Time__c ='+selectedTodayValue +' OR (End_Time__c > :now AND StartDate__c = TODAY))';
            }
            else if(selectedTodayValue.containsIgnoreCase('TODAY')){
             dateFilterCondition =' AND (End_Time__c > :now AND StartDate__c = TODAY)';
            }
            else if(selectedTodayValue.containsIgnoreCase('YESTERDAY')){
             dateFilterCondition =' AND ((End_Time__c <= :now AND StartDate__c = TODAY) OR StartDate__c = YESTERDAY)';
             System.debug('dateFilterCondition...'+dateFilterCondition);
            }
            else if(selectedTodayValue.containsIgnoreCase('LAST_N_DAYS')){
             dateFilterCondition =' AND ((End_Time__c <= :now AND StartDate__c = TODAY) OR (StartDate__c <= YESTERDAY AND End_Time__c ='+selectedTodayValue+')) ';
            }
            else if(selectedTodayValue == 'Current Term') {
                Id termId = USF_DBUtil.getTermId();
                if(termId != null) {
                    dateFilterCondition = ' AND Term__c ='+'\''+termId+'\'';
                }
                
            }
            else{
             dateFilterCondition =' AND Start_Time__c ='+selectedTodayValue +'';
            }
            
        }
        if(selectedStatusValue !=null && selectedStatusValue!=''){
            if(selectedStatusValue == App_Config__c.getInstance('Default LWC status filter').Text_Value__c){       
                //statusfilterCondition=' AND Status__c != :slotOpenStatus';     
            }  
            else{
               statusfilterCondition=' AND Status__c=\''+selectedStatusValue+'\'';     
            }
        }        
        if(selectedConsultantValue !=null && selectedConsultantValue !=App_Config__c.getInstance('Default LWC Consultant filter').Text_Value__c && isLWCStaff){     
            statusfilterCondition=' AND Availability__r.Coach__c=\''+selectedConsultantValue+'\'';     
        }
        
        system.debug('Final query --> ' + query+dateFilterCondition+statusFilterCondition+' ORDER BY Start_Time__c ASC LIMIT 1000' );
                    
        List<Counsellor_Availability__c> slotRecords = Database.query(query+dateFilterCondition+statusFilterCondition+' ORDER BY Start_Time__c ASC LIMIT 1000');
        //List<Counsellor_Availability__c> slotRecords = USF_DBUtil.getSlotsFromQuery(query+dateFilterCondition+statusFilterCondition+' ORDER BY Start_Time__c ASC LIMIT 1000',userId);
        List<Counsellor_Availability__c> filteredSlotRecords = new List<Counsellor_Availability__c>();
        system.debug('slotRecords: '+slotRecords);
        If(slotRecords.size()>0){
            USF_SlotDTO slotDTO;
            for(Counsellor_Availability__c slot : slotRecords ){ 
                if(selectedStatusValue == App_Config__c.getInstance('Default LWC status filter').Text_Value__c) {
               
                    if(slot.Appointment_Contacts__r.size() > 0) {
                     
                        slotDTO = new USF_SlotDTO(slot,slot.Start_Time__c.format('EEEE, MMM d yyyy'),slot.Start_Time__c.format('hh:mm a')+' - '+ slot.End_Time__c.format('hh:mm a'));
                        slotDTOList.add(slotDTO);
                        filteredSlotRecords.add(slot);
                    }
                }
                else {
                 
                  slotDTO = new USF_SlotDTO(slot,slot.Start_Time__c.format('EEEE, MMM d yyyy'),slot.Start_Time__c.format('hh:mm a')+' - '+slot.End_Time__c.format('hh:mm a'));
                  slotDTOList.add(slotDTO);
                  filteredSlotRecords.add(slot);
                }
                
                //added by Vandana
                hasACheckedInStudent = false;
                hasAConfirmedStudent = false;
                 for(AppointmentContact__c appt: slot.Appointment_Contacts__r){
                     if(appt.status__c.containsIgnoreCase(App_Config__c.getInstance('Student Checkin by Consultant').Text_Value__c)){
                         hasACheckedInStudent = true;
                     }
                     else if(appt.status__c.containsIgnoreCase(App_Config__c.getInstance('LWC Appointment Confirmed Status').Text_Value__c)){
                         hasAConfirmedStudent = true;
                     }
                     else{
                         continue;
                     }
                 }
                 slotIdStudentCheckedInMap.put(slot.Id,hasACheckedInStudent);
                 slotIdStudentConfirmedMap.put(slot.Id,hasAConfirmedStudent);
            }   
            
            System.debug('***slotIdStudentCheckedInMap***'+slotIdStudentCheckedInMap);
            System.debug('***slotIdStudentConfirmedMap***'+slotIdStudentConfirmedMap);
            for(Counsellor_Availability__c slt : filteredSlotRecords) {
                    // Calculating the values for Summary 
                    /*if(slt.Start_Time__c > System.now() && slt.Start_Time__c.date() == System.today() && slt.status__c == App_Config__c.getInstance('LWC Slot Confirmed Status').Text_Value__c){
                    upcomingCount = upcomingCount +1;
                    } 
                    if(slt.status__c == App_Config__c.getInstance('LWC Slot Confirmed Status').Text_Value__c){
                    upcomingCount +=1;
                    } */
                    if(slotIdStudentConfirmedMap.get(slt.Id)){
                    upcomingCount +=1;
                    }
                    if(slt.status__c == App_Config__c.getInstance('Slot Cancelled Status').Text_Value__c){
                    cancelCount +=1;
                    }
                    if(slt.status__c == App_Config__c.getInstance('LWC Slot Consultant Checked-In Status').Text_Value__c){
                    checkedCount +=1;
                    }
                    if(slt.status__c == App_Config__c.getInstance('LWC Slot Missed by Consultant Status').Text_Value__c){
                    missedCount +=1;
                    }
            }
            
         }  
         system.debug('DTOSize:'+slotDTOList.size()); 
         
        return slotDTOList;
    }
    
    // Get Date filter values
    public List<SelectOption> getTodayFilterValues(){
       List<SelectOption> options = new List<SelectOption>();            
          options.add(new SelectOption('TODAY','Today'));
          options.add(new SelectOption('YESTERDAY','Yesterday'));
          options.add(new SelectOption('LAST_N_DAYS:7','Last 7 days'));
          options.add(new SelectOption('NEXT_N_DAYS:7','Next 7 days'));   
          options.add(new SelectOption('Current Term','Current Term'));         
       return options;
    }
    
    // Get Status filter values
    public List<SelectOption> getStatusValues(){
       List<SelectOption> options = new List<SelectOption>();        
       options.add(new SelectOption('Status','Status'));
       Schema.DescribeFieldResult fieldResult =Counsellor_Availability__c.Status__c.getDescribe();       
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
       for( Schema.PicklistEntry f : ple) {
          options.add(new SelectOption(f.getValue(), f.getValue()));
       }       
       return options;
    }
    
    // Get Consultant filter values
    public List<SelectOption> getConsultantValues(){
       List<User> conList = new List<User>();     
       //Modified by Vandana to remove 'LWC Consultant' profile
        conList = new List<User>(); 
        conList = [SELECT Id, Name FROM User WHERE ContactId IN (SELECT Contact__c FROM Consultant__c WHERE Active__c = true)];
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('Consultant','Consultant'));
        if(conList.size()>0){
            for (User conRec : conList) {
                options.add(new selectOption(conRec.Id, conRec.Name));
            }              
        }   
       /*conList = [SELECT Id, Name FROM User WHERE Profile.Name = :App_Config__c.getInstance('Consultant Profile Name').Text_Value__c];   
       //List<User> permissionSetAssigneesList = USF_PermissionSetAssignmentUtli.getPermissionSetAssignees(App_Config__c.getInstance('USF_StudentConsultantSwitch').Text_Value__c);
       List<SelectOption> options = new List<SelectOption>();        
       options.add(new SelectOption('Consultant','Consultant'));
       for(User conRec : conList) {
          options.add(new SelectOption(conRec.Id, conRec.Name));
       }       */
       return options;
    }
    
    // Get location values
    public List<SelectOption> getLocation(){     
     /*
        List<SelectOption> options = new List<SelectOption>();     
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
    
    // Update Slot location and max students
    public void modifySlot(){
           try {
                Counsellor_Availability__c updateSlot = new Counsellor_Availability__c();                                                           
                if(currentSlotId != null){
                    updateSlot.Id = currentSlotId; 
                     if(updateSlot.Location__c != newLocation || updateSlot.Capacity__c != newMaxStudents){
                        if(updateSlot.Location__c != newLocation){
                            updateSlot.Location__c = newLocation;
                        }
                        if(updateSlot.Capacity__c != newMaxStudents){
                            updateSlot.Capacity__c = newMaxStudents;
                        }
                        if(updateSlot!=null){
                          update updateSlot;
                        }
                     }
                 }       
            }   
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }      
    } 
    
    // Update Slot status to Cancelled status
    public void cancelAppointment(){    
        try {        
                Counsellor_Availability__c updateSlot = new Counsellor_Availability__c();    
                if(currentSlotId != null){
                        updateSlot.Id = currentSlotId;  
                        if(updateSlot.Status__c != App_Config__c.getInstance('Slot Cancelled Status').Text_Value__c){
                                updateSlot.Status__c = App_Config__c.getInstance('Slot Cancelled Status').Text_Value__c;
                                if(updateSlot!=null){
                                   update updateSlot;
                                }
                        }
                 }
            }           
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));                
            }
    }
                   
    // Update Slot status to completed status
    public void markCompleted(){ 
       try {
                Counsellor_Availability__c updateSlot = new Counsellor_Availability__c();   
                if(currentSlotId != null){
                        updateSlot.Id = currentSlotId;  
                        if(updateSlot.Status__c != App_Config__c.getInstance('LWC Slot Complete Status').Text_Value__c){
                                updateSlot.Status__c = App_Config__c.getInstance('LWC Slot Complete Status').Text_Value__c; 
                                     if(updateSlot.Notes__c != newNotes){
                                        if(updateSlot!=null){
                                           updateSlot.Notes__c = newNotes;    
                                        }  
                                     } 
                                     update updateSlot; 
                        }
                }
            }
        catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));                 
            }  
      }
    
    // Update Slot status to Checked In status
    public void checkIn(){
            Counsellor_Availability__c updateSlot = new Counsellor_Availability__c();    
            try {
                if(currentSlotId != null){
                        updateSlot.Id = currentSlotId;                                                          
                        if(updateSlot.Status__c != App_Config__c.getInstance('LWC Slot Consultant Checked-In Status').Text_Value__c){
                                updateSlot.Status__c = App_Config__c.getInstance('LWC Slot Consultant Checked-In Status').Text_Value__c; 
                                if(updateSlot!=null){  
                                   update updateSlot;
                                }
                        } 
                }
            }
            catch(Exception ex){ 
            // Display the error message    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));   
            }    
    }
    
    // Dummy Slot record
     public Counsellor_Availability__c dummyAppointment{
        get{
            if(dummyAppointment==null)
                dummyAppointment= new Counsellor_Availability__c();
                 dummyAppointment.RecordTypeId = LWCSlotRecordTypeId;
                 dummyAppointment.status__c=App_Config__c.getInstance('Default LWC status filter').Text_Value__c;
            return dummyAppointment;
        }
        set;
    }
     
     // Method to populate slot details
     public void populateSlotDetails(){ 
           try {                                                
                if(currentSlotId != null){
                    Counsellor_Availability__c updateSlot = [SELECT ID ,Location__c,Capacity__c,Center__c,Notes__c FROM Counsellor_Availability__c 
                                                                      where Id = :currentSlotId LIMIT 1];  
                    newlocation = updateSlot.Location__c;
                    newMaxStudents = updateSlot.Capacity__c; 
                    newNotes = updateSlot.Notes__c;  
                    newCenter = updateSlot.Center__c;
                 }       
            }   
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }   
     }
    
    // Method to update status of Appointment 
    public void updateStatusField(){   
    try{ 
        AppointmentContact__c appointment=new AppointmentContact__c();    
        if((selectedAppId !=null && selectedAppId !='')){        
            appointment.id=selectedAppId ;        
            if(selectedAction=='Checkin'){
                appointment.Status__c=App_Config__c.getInstance('Student Checkin by Consultant').Text_Value__c;
            }  
            else if(selectedAction=='Cancel'){
                appointment.Status__c=App_Config__c.getInstance('LWC Appointment CancelledbyStudent').Text_Value__c;
            }        
            if(appointment!=null){
               update appointment;
            }
        }
      } 
      catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
      }
    }   
    
    public USF_SlotDTO getUpcomingAppointmentDTO(){  
        USF_SlotDTO upcomingAppointmentDTO;  
        try{
            DateTime now = DateTime.now();
              List<Counsellor_Availability__c> upcomingAppointment=Database.query(query+' AND (Start_Time__c > :now AND StartDate__c = TODAY) AND status__c = \'Confirmed\' ORDER BY Start_Time__c ASC LIMIT 1');
              //List<Counsellor_Availability__c> upcomingAppointment= USF_DBUtil.getSlotsFromQuery(query+' AND (Start_Time__c > :now AND StartDate__c = TODAY) AND status__c = \'Confirmed\' ORDER BY Start_Time__c ASC LIMIT 1',userId);
             if(upcomingAppointment.size()!=0){
                   upcomingAppointmentDTO= new USF_SlotDTO(upcomingAppointment[0], upcomingAppointment[0].Start_Time__c.format('hh:mm a'));
             }
        }
        catch(Exception ex){
                  // Display the error message
                  ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()+ex.getStackTraceString()));
        }
        return upcomingAppointmentDTO;
    }
    
    // Method to verify lead time of cancellation 
      public void verifyLeadTime() {
        try{
        List<AppointmentContact__c> appointments = [Select Id,Date_Time__c,
                                                    AppointmentSlot__r.Availability__r.Success_Center__c 
                                                    FROM AppointmentContact__c 
                                                    where Id =: selectedAppId];
        if(appointments.size() > 0) {
            Decimal leadTime = USF_DBUtil.getLeadTime(appointments[0].AppointmentSlot__r.Availability__r.Success_Center__c);
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

}