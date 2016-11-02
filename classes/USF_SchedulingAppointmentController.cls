/************************************************************************************
// Name             : USF_SchedulingAppointmentController 
// Description      : Controller for USF_SchedulingAppointment Visualforce page
// Created By       : Manjunath Singh
// Created Date     : 09/14/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 09/14/2016       Manjunath Singh       Created
// ************************************************************************************/

public with sharing class USF_SchedulingAppointmentController {

    public String slotId;
    public String slotDate {get;set;}
    public String slotTime {get;set;} 
    public List<Counsellor_Availability__c> slots =new List<Counsellor_Availability__c>();
    public Counsellor_Availability__c selectedSlot {get;set;}
    public String selectedStudent {get;set;}
    public String selectedReferredBy {get;set;}
    public boolean showStudentDetails {get;set;}
    public List<Contact> selStudentDetails{get;set;}
    public AppointmentContact__c newAppointment {get;set;}
    public String message {get;set;}  
    public String selectedStudentId {get;set;} 
    public boolean isException {get;set;}
    
    //Constructor
    public USF_SchedulingAppointmentController(ApexPages.StandardController controller) {
        showStudentDetails =false;
        isException=false;
        selectedStudent='';
        message='';
        selectedReferredBy='None';
        selStudentDetails=new List<contact>();
        slots=new List<Counsellor_Availability__c>();
        slotId=Apexpages.currentPage().getParameters().get('sid');
        populateSlotInformation();  
        
        //Creating an appointment
        newAppointment =(AppointmentContact__c)controller.getRecord();
        Id devRecordTypeId = Schema.SObjectType.AppointmentContact__c.getRecordTypeInfosByName().get('CASA Appointment').getRecordTypeId();
        newAppointment.recordTypeid=devRecordTypeId;
        
        
    }
  
  
  public void populateSlotInformation(){
  
  try{
  
      slots=[SELECT Id, Name, Start_Time__c,End_Time__c,Availability__r.Coach__r.name,Location__c, Selected_Course__r.Name FROM Counsellor_Availability__c where id=:slotId];
     
      if(slots.size()!=0){
          selectedSlot=slots[0];
          if(selectedSlot.Start_Time__c != null){
                slotDate = selectedSlot.Start_Time__c.format('M/d/yyyy');
                slotTime = selectedSlot.Start_Time__c.format('h:mm a')+' - '+selectedSlot.End_Time__c.format('h:mm a');
            }  
      }
  
     }
  catch(Exception e){
  
   }
  
  
} 

    public void lookUpButtonAction(){

    if(selectedStudent!=null && selectedStudent!='' && selectedStudent.contains('(')){
        String whereClause='';
        if(selectedStudentId!=null && selectedStudentId!=''){
          whereClause=' WHERE Id=\''+String.escapeSingleQuotes(selectedStudentId)+'\'';
        }
        else{
          String cwid=selectedStudent.subString(selectedStudent.indexOf('(')+1, selectedStudent.lastIndexOf(')'));
          whereClause=' WHERE cwid__c=\''+String.escapeSingleQuotes(cwid)+'\'';
          
        }
        
        try{
        
        selStudentDetails=[Select id,name,PhotoUrl,Major__c,Preferred_Name__c,AcademicSuccessCoach__r.name,Phone,CWID__c,Email from contact whereClause LIMIT 1];
        selStudentDetails=Database.query('Select id,name,PhotoUrl,Major__c,Preferred_Name__c,AcademicSuccessCoach__r.name,Phone,CWID__c,Email from contact '+whereClause+' LIMIT 1');
            if(selStudentDetails.size()!=0){     
                showStudentDetails=true;              
            }
        
        }
        catch(Exception e){
        
        }

}

}

// Reason for Meeting multiselect picklist to checkbox conversion
    public String[] reasons = new String[]{};
    
    public String[] getreasons() {
        return reasons;
    }

    public void setreasons(String[] reasons) {
        this.reasons = reasons;
    }
    
    public List<SelectOption> getReasonforPicklist()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =
     AppointmentContact__c.Reason_for_Meeting__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    
    public List<SelectOption> getReferedByPicklist()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =
     AppointmentContact__c.Referred_By__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
       options.add(new SelectOption('None', 'None'));
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    
    public PageReference cancelAppointment() {
        return Page.USF_FrontDeskStaffDashboard;
    }
    
    public pageReference createAppointment(){
    
    //Added to check the coach leave period
    String leaveValidation = USF_CenterRulesUtil.validateCASACoachLeave('CASA',slotId);//added one more parameter so all messages get returned from centerRulesUtil class to maintain one source -- Nishit
    if(String.isBlank(leaveValidation)){
    
    //if(selectedReferredBy!=null){
        if(selectedReferredBy != 'None'){
            newAppointment.Referred_By__c=selectedReferredBy;
        }
        newAppointment.Contact__c=selStudentDetails[0].id;
        newAppointment.AppointmentSlot__c=slotId;
        newAppointment.status__c=App_Config__c.getInstance('CASA Appointment Confirmed Status').Text_Value__c;
    
    //}
    
        if(reasons!=null){
            for(String reason: reasons){
                        if(newAppointment.Reason_for_Meeting__c == null || newAppointment.Reason_for_Meeting__c== '')
                            newAppointment.Reason_for_Meeting__c= reason+ ';';

                         else
                            newAppointment.Reason_for_Meeting__c = newAppointment.Reason_for_Meeting__c+ reason + ';';
                    } 
         }
         
         try{
         
             insert newAppointment;
             message=App_Config__c.getInstance('Casa Appointment Submitted message').Text_Value__c;
         
         }
         catch(Exception e){
             isException=true;
             message='Error in submitting request'+e.getmessage();
         
         }
    return null;
    
    }else{
    
    //To-do: Change message string as required.
    message = leaveValidation;
    
    return null;
    }
    
    }
 

}