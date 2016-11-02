/**
 *  ClassName    : USFCreateCoachAvailibityRecords 
 *  Owner        : Arshad
 *  Created Date : 07/14/2016
 *  Description  : Trigger executes on after insert and creates coach availability records 
                   "within the time frame" specified and based on the duration of the appointment as 
                   specified in the "availability definition" 
 */ 
trigger USFCreateCoachAvailibityRecords on Counselor_Availability_Definition__c (before insert, before update,after insert, after update, before delete) {
   if(trigger.isBefore && trigger.isInsert){
      USFCreateCoachAvailabilityRecordsHandler.doBeforeInsert(trigger.new);  
   }
   if(trigger.isBefore && trigger.isUpdate){
      USFCreateCoachAvailabilityRecordsHandler.doBeforeUpdate(trigger.new, trigger.oldMap);  
   }
   if(trigger.isAfter && trigger.isInsert){
      USFCreateCoachAvailabilityRecordsHandler.doAfterInsert(trigger.new);  
   }
   if(trigger.isAfter && trigger.isUpdate){
      USFCreateCoachAvailabilityRecordsHandler.doAfterUpdate(trigger.new, trigger.oldMap);  
   }
   if(trigger.isDelete){
      USFCreateCoachAvailabilityRecordsHandler.doBeforeDelete(trigger.oldMap);  
   }   
}