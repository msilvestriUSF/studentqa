/************************************************************************************
// Name             : USF_FDAppointmentDetailsController 
// Description      : Controller for USF_FDAppointmentDetails Visualforce page
// Created By       : Manjunath Singh
// Created Date     : 09/24/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 09/24/2016       Manjunath Singh       Created
// ************************************************************************************/
public class USF_FDAppointmentDetailsController {

    public String appointmentDate {get;set;}
    public String appointmentTime {get;set;} 
    public List<AppointmentContact__c> appointmentRecord{get;set;}
    public string appId {get;set;}


    public USF_FDAppointmentDetailsController(ApexPages.StandardController controller) {
    
    appointmentRecord=new List<AppointmentContact__c>();
    
    appId=Apexpages.currentPage().getParameters().get('appId');
    
    populateAppDetails();
    
    }
    
  /**********************************************************************
   Description: This method is used to populate appointments information
   Return type: Void
   Parameters: None
   Created By: Manjunath Singh
  ***********************************************************************/
    
    public void populateAppDetails(){
    
        try{
            
            appointmentRecord=[Select id,AppointmentSlot__r.Start_Time__c,Preferred_Phone__c,AppointmentSlot__r.Availability__r.Coach__r.name,Reason_for_Meeting__c,Location__c,
            Status__c,Contact__r.AcademicSuccessCoach__r.Name,Referred_By__c,Referrer_Name__c,Name from AppointmentContact__c where id=:appId];
            
            if(appointmentRecord.size()!=0){
                   
                  if(appointmentRecord[0].AppointmentSlot__r.Start_Time__c!= null){
                        appointmentDate = appointmentRecord[0].AppointmentSlot__r.Start_Time__c.format('M/d/yyyy');
                        appointmentTime = appointmentRecord[0].AppointmentSlot__r.Start_Time__c.format('hh:mm a');
        }
            }
        
        }
        catch(Exception e){
        
        
        }
    
    
    
    }
    
  /**********************************************************************
   Description: This method is used for cancel appointment functionality
   Return type: Void
   Parameters: None
   Created By: Manjunath Singh
  ***********************************************************************/
    
    public void cancelAppointment(){
    
    if(appointmentRecord[0].status__c!=App_Config__c.getInstance('CASA Appointment Cancelled Status').Text_Value__c){
    
    appointmentRecord[0].status__c=App_Config__c.getInstance('CASA Appointment Cancelled Status').Text_Value__c;
    
    try{
    
        update appointmentRecord[0];
    
    }
    catch(Exception e){
    
    }
   }
    
 }
    

}