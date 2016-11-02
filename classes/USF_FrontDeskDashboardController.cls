/************************************************************************************
// Name             : USF_FrontDeskDashboardController
// Description      : Controller for USF_FrontDeskStaffDashboard Visualforce page
// Created By       : Manjunath Singh
// Created Date     : 09/07/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 09/07/2016       Manjunath Singh       Created
// ************************************************************************************/

public with sharing class USF_FrontDeskDashboardController{

    public List<USF_AppointmentDTO> appDTOList {get;set;}
    public USF_AppointmentDTO latestCheckedAppDTO {get;set;}
    public Integer upcomingCount {get;set;}
    public Integer pendingCount {get;set;}
    public Integer completeCount {get;set;}
    public Integer delayedCount {get;set;}
    public List<AppointmentContact__c> latestCheckedApp = new list<AppointmentContact__c>();
    
    //Variables to hold the filter Selects-Start
    public String selectedTodayValue {get;set;}
    public String selectedStatusValue {get;set;}
    public String selectedCoachValue {get;set;}
    //Variables to hold the filter Selects-End
    
    //Variables to Build Dynamic SOQL-Start
    public String query {get;set;}
    public String statusfilterCondition {get;set;}
    public String dateCoachfilterCondition {get;set;}
    //Variables to Build Dynamic SOQL-End
    
    public String selectedRecordId {get;set;}
    public String selectedAction {get;set;}
    public String systemToday;
    
    //Constructor
    public USF_FrontDeskDashboardController(){
        
        statusfilterCondition='';
        selectedTodayValue=App_Config__c.getInstance('CASA Dashboard Next 7 days Value').Text_Value__c;
        selectedStatusValue=App_Config__c.getInstance('Default CASA status filter').Text_Value__c;
        selectedCoachValue=App_Config__c.getInstance('Default CASA Coach filter').Text_Value__c;
        dateCoachfilterCondition =' AND (Start_Date__c=NEXT_N_DAYS:7 OR Start_Date__c=TODAY)';
        
        query='Select Contact__r.name ,Staff__c,Contact__r.AcademicSuccessCoach__r.Name,Canceled_Date_Time__c,Start_Time__c,CWID__c,Date_Time__c,Reason_for_Meeting__c,Status__c,lastmodifieddate from AppointmentContact__c WHERE Recordtype.name=\'CASA Appointment\'';
             
    }
    
    /**************************************************************
    Description: This method is used to populate appointments table
    Return type: List<USF_AppointmentDTO>
    Parameters: None
    Created By: Manjunath Singh
    ***************************************************************/
    public List<USF_AppointmentDTO> getAppoinitmentRecords(){
    
        upcomingCount = 0;
        pendingCount = 0;
        completeCount = 0;
        delayedCount  =0;
        statusfilterCondition='';
        
        getLatestCheckedInStudent();
    
    
        appDTOList = new List<USF_AppointmentDTO>();
    
        DateTime now = DateTime.now();
     if(selectedTodayValue !=null && selectedTodayValue !=''){
        //Coomented 31 Oct
        /*System.debug('selectedTodayValue...'+selectedTodayValue);
        if(selectedTodayValue.containsIgnoreCase('NEXT_N_DAYS')){     
        //dateCoachfilterCondition =' AND (start_date__c='+selectedTodayValue+' OR Start_Date__c = TODAY) ';
            dateCoachfilterCondition =' AND (start_date__c ='+selectedTodayValue +' OR (start_date__c > :now))';
            System.debug('dateCoachfilterCondition...'+dateCoachfilterCondition);
        }
        else{
        dateCoachfilterCondition =' AND start_date__c='+selectedTodayValue+'';
        }*/
         /*if(selectedTodayValue.equalsIgnoreCase('today')){ 
            dateCoachfilterCondition =' AND start_date__c='+selectedTodayValue+'';
        }
        else{
            dateCoachfilterCondition =' AND start_date__c='+selectedTodayValue+' AND start_date__c!=TODAY';
        }*/
        if(selectedTodayValue.containsIgnoreCase('NEXT_N_DAYS')){
            dateCoachfilterCondition =' AND (AppointmentSlot__r.End_Time__c ='+selectedTodayValue +' OR (AppointmentSlot__r.End_Time__c > :now AND start_date__c = TODAY))';
        }
        else if(selectedTodayValue.containsIgnoreCase('TODAY')){
            dateCoachfilterCondition =' AND (AppointmentSlot__r.End_Time__c > :now AND start_date__c = TODAY)';
        }
        else if(selectedTodayValue.containsIgnoreCase('YESTERDAY')){
            dateCoachfilterCondition =' AND ((AppointmentSlot__r.End_Time__c <= :now AND start_date__c = TODAY) OR start_date__c = YESTERDAY)';
        }
        else if(selectedTodayValue.containsIgnoreCase('LAST_N_DAYS')){
            dateCoachfilterCondition =' AND ((AppointmentSlot__r.End_Time__c <= :now AND start_date__c = TODAY) OR (start_date__c <= YESTERDAY AND AppointmentSlot__r.End_Time__c ='+selectedTodayValue+')) ';
        }
        else{
            dateCoachfilterCondition =' AND AppointmentSlot__r.End_Time__c='+selectedTodayValue+'';
        }
     }
     
     if(selectedStatusValue!=null && selectedStatusValue!='All Appointments'){
     
     statusfilterCondition=' AND Status__c=\''+selectedStatusValue+'\'';
     
     }
       
     if(selectedCoachValue!=App_Config__c.getInstance('Default CASA Coach filter').Text_Value__c){
     
     //dateCoachfilterCondition +=' AND Contact__r.AcademicSuccessCoach__c=\''+selectedCoachValue+'\'';
     dateCoachfilterCondition +=' AND AppointmentSlot__r.Availability__r.Coach__c=\''+selectedCoachValue+'\'';
     
     }

     List<AppointmentContact__c> appointments=Database.query(query+dateCoachfilterCondition+statusfilterCondition+' ORDER BY Date_Time__c asc LIMIT 1000');
        
        if(appointments.size()>0){
        for(AppointmentContact__c app:appointments ){
            
            USF_AppointmentDTO appDTO = new USF_AppointmentDTO(app,app.Date_Time__c.format('EEEE, MMM d yyyy,hh:mm a'));
            appDTOList.add(appDTO);
            
            // Calculating the values for Summary 
            if(app.status__c == App_Config__c.getInstance('CASA Appointment Confirmed Status').Text_Value__c){
                upcomingCount = upcomingCount +1;
               
            }
            
            if(app.status__c == App_Config__c.getInstance('CASA Appointment Cancelled Status').Text_Value__c)   {
            completeCount +=1;
            }
            
            if(app.status__c == App_Config__c.getInstance('CASA Appointment Pending Status').Text_Value__c)   {
            pendingCount +=1;
            }
        }
     }
         return appDTOList;
    
    }
    
   /****************************************************************
    Description: This method is used to populate today filter values
    Return type: List<SelectOption>
    Parameters: None
    Created By: Manjunath Singh
    ***************************************************************/ 
    public List<SelectOption> getTodayFilterValues()
    {
       List<SelectOption> options = new List<SelectOption>();
            
          options.add(new SelectOption('TODAY','Today'));
          options.add(new SelectOption('TOMORROW','Tomorrow'));
          options.add(new SelectOption('YESTERDAY','Yesterday'));
          options.add(new SelectOption('LAST_N_DAYS:7','Last 7 days'));
          options.add(new SelectOption('NEXT_N_DAYS:7','Next 7 days'));
           
       return options;
    }
    
    /****************************************************************
    Description: This method is used to populate Casa Staff filter values
    Return type: List<SelectOption>
    Parameters: None
    Created By: Manjunath Singh
    ***************************************************************/ 
    public List<SelectOption> getCoachFilterValues(){  
        
      List<SelectOption> options = new List<SelectOption>();
      options.add(new SelectOption(App_Config__c.getInstance('Default CASA Coach filter').Text_Value__c,App_Config__c.getInstance('Default CASA Coach filter').Text_Value__c));
        
    try{
        
      List<User> coachRecords=[Select id,name from user where user_type__c= :App_Config__c.getInstance('ASC User type').Text_Value__c and isActive=true Order By name asc]; 
    
     if(coachRecords.size()>0){
    
        for(User userRec:coachRecords){
             options.add(new SelectOption(userRec.id,userRec.name));
            }
    
           }
        }
   catch(Exception e){
   
       }  
            
    return options;
    }
    
    /****************************************************************
    Description: This method is used to update the status on actions
    Return type: Void
    Parameters: None
    Created By: Manjunath Singh
    ***************************************************************/ 

    public void updateStatusField(){
    
    AppointmentContact__c appointment=new AppointmentContact__c();
    
    if((selectedRecordId!=null && selectedRecordId!='')){
        
        appointment.id=selectedRecordId;
        
        if(selectedAction==App_Config__c.getInstance('Checkin').Text_Value__c){
        appointment.Status__c=App_Config__c.getInstance('Student Checkin by Consultant').Text_Value__c;
        }  
        else if(selectedAction==App_Config__c.getInstance('Complete').Text_Value__c){ 
        appointment.Status__c=App_Config__c.getInstance('LWC Slot Complete Status').Text_Value__c;
        }     
       /* else if(selectedAction==App_Config__c.getInstance('Missed').Text_Value__c){
        appointment.Status__c=App_Config__c.getInstance('USF_CASAAppointmentMissedStatus').Text_Value__c;
        }*/
        else if(selectedAction==App_Config__c.getInstance('Confirm').Text_Value__c){
        appointment.Status__c=App_Config__c.getInstance('LWC Appointment Confirmed Status').Text_Value__c;
        }
        
        try{
        update appointment;
        }
       catch(Exception e){
        
        }
    }    
    
    }
    
    
    /********************************************************************
    Description: This method is used to get the latest checked in student
    Return type: Void
    Parameters: None
    Created By: Manjunath Singh
    ********************************************************************/  
    
    public void getLatestCheckedInStudent(){
    
    try{
    DateTime now = DateTime.now();
    latestCheckedApp=[SELECT id,Contact__r.name,Staff__c, Contact__r.AcademicSuccessCoach__r.Name,Canceled_Date_Time__c,Start_Time__c,CWID__c,Date_Time__c,
                      Reason_for_Meeting__c,Status__c,lastmodifieddate 
                      from AppointmentContact__c where status__c=:App_Config__c.getInstance('Student Checkin by Consultant').Text_Value__c and Recordtype.developername=:App_Config__c.getInstance('CASA Appointment RecordType').Text_Value__c and Date_Time__c > :now order by Date_Time__c asc limit 1];
     if(latestCheckedApp.size()!=0){
           latestCheckedAppDTO = new USF_AppointmentDTO(latestCheckedApp[0], latestCheckedApp[0].Date_Time__c.format('hh:mm a'));
     }
    }
    catch(Exception e){
    
    }
    }
    
    /********************************************************************
    Description: This method is used for cancel appointment functionality
    Return type: PageReference
    Parameters: None
    Created By: Manjunath Singh
    ********************************************************************/
    public PageReference cancelAppointment() {

         List<AppointmentContact__c> appointments = [Select Id,RecordTypeId,
                                                    AppointmentSlot__r.Availability__r.Success_Center__r.Student_Missed_Per_Center__c,
                                                    Strike__c,Center__c,Date_Time__c,
                                                    Status__c
                                                    FROM AppointmentContact__c 
                                                    where Id =: selectedRecordId and Recordtype.developername=:App_Config__c.getInstance('CASA Appointment RecordType').Text_Value__c];
                                                                                           
        try {
                if(appointments[0] !=null && appointments[0].Status__c != App_Config__c.getInstance('CASA Appointment Cancelled Status').Text_Value__c){
                   appointments[0].Status__c = App_Config__c.getInstance('CASA Appointment Cancelled Status').Text_Value__c;    
                    update appointments[0];
                  }
             }
         catch(Exception e){
        
         }  
         
         return null;  
 }
    
    /********************************************************************8***************
    Description: This method is used to get status drop down values based on Record type
    Return type: AppointmentContact__c
    Parameters: None
    Created By: Manjunath Singh
    *************************************************************************************/
    public AppointmentContact__c dummyAppointment
    {
        get
        {
            if(dummyAppointment==null)
                dummyAppointment= new AppointmentContact__c();
                dummyAppointment.status__c=App_Config__c.getInstance('Default CASA status filter').Text_Value__c;
            return dummyAppointment;
        }
        set;
    }

}