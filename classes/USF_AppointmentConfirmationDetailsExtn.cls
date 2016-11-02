//************************************************************************************
// Name             : USF_AppointmentConfirmationDetailsExtn
// Description      : Controller for USF_AppointmentConfirmationDetails Visualforce page
// Created By       : Mohan Kalagatla
// Created Date     : 09/13/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 08/30/2016       Mohan Kalagatla      Created
// ************************************************************************************
public without sharing class USF_AppointmentConfirmationDetailsExtn{
    public String slotStartValue;
    public Id objectID{get;set;}
        
    // Constructor to perform initializations
    public String getslotStartValue(){
        if(objectID!=null){
            AppointmentContact__c appointment = [SELECT Id,AppointmentSlot__r.Start_Time__c,Contact__c from AppointmentContact__c WHERE Id = :objectID LIMIT 1];
                if(appointment !=null){
                    User student = [Select Id,TimeZoneSidKey from User where ContactId = :appointment.Contact__c LIMIT 1] ;
                    if(student!=null){
                     slotStartValue = appointment.AppointmentSlot__r.Start_Time__c.format('M/d/yy',student.TimeZoneSidKey)+' at '+appointment.AppointmentSlot__r.Start_Time__c.format('hh:mm a',student.TimeZoneSidKey);
                    }
                }
        }
        return slotStartValue;
    }
}