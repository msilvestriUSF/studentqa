//************************************************************************************
// Name             : USF_AppointmentDetailsStudentsCASAExtn
// Description      : Controller for USF_AppointmentDetailsStudentsCASA Visualforce page
// Created By       : Mohan Kalagatla
// Created Date     : 08/25/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 08/25/2016       Mohan Kalagatla       Created
// ************************************************************************************
//public with sharing class USF_AppointmentDetailsStudentsCASAExtn{
//Change it to with sharing once security model is in place
public with sharing class USF_AppointmentDetailsStudentsCASAExtn{
ApexPages.StandardController stdController {get; set;}
public Id appointmentId {get; set;}
public String cancel {get; set;}
public String complete {get; set;}
   // Constructor for initializations 
    public USF_AppointmentDetailsStudentsCASAExtn(ApexPages.StandardController controller){             
        stdController = controller;
        appointmentId = ((AppointmentContact__c)stdController.getRecord()).Id;
        cancel = App_Config__c.getInstance('Cancel').Text_Value__c;
        complete = App_Config__c.getInstance('Complete').Text_Value__c;             
    }
    
    // Get Appointment
    public USF_AppointmentDTO getAppDTO(){
         AppointmentContact__c appointment = [SELECT Id,Status__c,Contact__r.id,Date_Time__c,Notes__c,Preferred_Phone__c,Referred_By__c,Referrer_Name__c,Staff__c,Location__c,
                               AppointmentSlot__r.Location__c,Reason_for_Meeting__c,(SELECT id,Name from Attachments)
                               FROM AppointmentContact__c WHERE Id=:appointmentId LIMIT 1]; 
         USF_AppointmentDTO appDTO = new USF_AppointmentDTO(appointment,appointment.Date_Time__c.format('M/d/yyyy'),appointment.Date_Time__c.format('hh:mm a'));
         return appDTO;     
    }
    
    // Cancel Apointment status
    public void cancelAppointment(){
         try{             
               AppointmentContact__c appointment = new AppointmentContact__c();
               if(appointmentId!=null){
                appointment.id=appointmentId;
                if(appointment!=null && appointment.Status__c != App_Config__c.getInstance('CASA Appointment Cancelled Status').Text_Value__c){                
                    appointment.Status__c = App_Config__c.getInstance('CASA Appointment Cancelled Status').Text_Value__c;
                    update appointment;
                }
               }
            }
            catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }
    }
}