trigger USF_AppointmentTrigger on AppointmentContact__c (after insert, after update, after delete, after undelete, before update) {
    Map<Id,Contact> updateStudents = new Map<Id,Contact>();
    Set<Id> updateStudentIds = new Set<Id>();
    Set<Id> updateSlots = new Set<Id>();
    List<Counsellor_Availability__c> studentsRegistered = new List<Counsellor_Availability__c>();
    List<Counsellor_Availability__c> slotsToUpdate = new List<Counsellor_Availability__c>();
    
    //Added by Vandana - DFCT0011016
    List<String> allContactIds = new List<String>();
    List<String> allSlotIds = new List<String>();
    List<AppointmentContact__c> existingAppointments= new List<AppointmentContact__c>();
    Boolean isDuplicate=false;
    
       if(Trigger.isBefore && (Trigger.isInsert ||Trigger.isUpdate) && USF_Constant.appointmentTriggerRecursion == false){
            System.debug('***Entered....');
            Id LWCRecordTypeId = Schema.SObjectType.AppointmentContact__c.getRecordTypeInfosByName().get('LWC Appointment').getRecordTypeId();
            System.debug('***LWCRecordTypeId: '+LWCRecordTypeId);
            for(AppointmentContact__c appt :Trigger.new){
                System.debug('appt.Id:::'+appt.Id);
                if(appt.recordTypeId == LWCRecordTypeId){
                    allContactIds.add(appt.Contact__c);
                    allSlotIds.add(appt.AppointmentSlot__c);
                }
            }
            
            existingAppointments=[SELECT Id,Contact__c,AppointmentSlot__c FROM AppointmentContact__c WHERE AppointmentSlot__c IN :allSlotIds AND Contact__c IN :allContactIds AND Id NOT IN :Trigger.new LIMIT 1000];
            
            for(AppointmentContact__c appt :Trigger.new){
                isDuplicate=false;
                for(AppointmentContact__c existingAppt : existingAppointments){
                    if(appt.Contact__c == existingAppt.Contact__c && appt.AppointmentSlot__c == existingAppt.AppointmentSlot__c){
                        System.debug('existingAppt:::'+existingAppt);
                       isDuplicate = true; 
                    }
                }
                
                if(isDuplicate == true){
                    appt.addError(Label.Duplicate_Appoinment_Error_Message);
                }
            }
            USF_Constant.appointmentTriggerRecursion = true;
        }
     //Added by Vandana - End
    
    // If we are inserting, updating, or undeleting, use the new ID values
        
        if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete))
        for(AppointmentContact__c appt :Trigger.new) {
            updateStudentIds.add(appt.Contact__c);
            updateSlots.add(appt.AppointmentSlot__c);
        }

      // If we are updating, some consultants might change, so include that as well as deletes
        if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isDelete))
            for(AppointmentContact__c appt:Trigger.old) {
                updateStudentIds.add(appt.Contact__c);
                updateSlots.add(appt.AppointmentSlot__c);
            }
if(!USF_Constant.slotTriggerRecursion) {
        if(Trigger.isBefore && Trigger.isUpdate) {
            Map<Id,AppointmentContact__c> apptOldMap = new Map<Id,AppointmentContact__c>();
            apptOldMap = Trigger.oldMap;
            for(AppointmentContact__c app : Trigger.new) {
                System.debug('appt: '+app);
                System.debug('old: '+apptOldMap.get(app.Id).Status__c);
                if(app.Status__c == 'Missed by Student' && apptOldMap.get(app.Id).Status__c != 'Missed by Student') {
                    if(app.Center__c == 'Learning Center' || app.Center__c == 'Writing Center') {
                        app.Strike__c = true;
                    }
                }
                if(apptOldMap.get(app.Id).Status__c == 'Missed by Student' && (app.Status__c != 'Missed by Student' || app.Status__c != 'Cancelled by Student')) {
                    if(app.Center__c == 'Learning Center' || app.Center__c == 'Writing Center') {
                        if(app.Strike__c == true) {
                            app.Strike__c = false;
                        }
                    }
                }

            }
        }
        
        USF_Constant.slotTriggerRecursion = true;
  }
        if(Trigger.isAfter) {
        if(!(Trigger.isInsert || Trigger.isDelete)){ //If condition Added by Vandana as OldMap doesnt exist for insert and Trigger.new doesnt exist for delete
            Set<Id> cancelledApptsSlots = new Set<Id>();
                Map<Id,AppointmentContact__c> apptsOldMap = new Map<Id,AppointmentContact__c>();
                apptsOldMap = Trigger.oldMap;
                for(AppointmentContact__c app : Trigger.new) {
                    System.debug('appt: '+app);
                    System.debug('old: '+apptsOldMap.get(app.Id).Status__c);
                    if(app.Status__c == 'Cancelled' && apptsOldMap.get(app.Id).Status__c != 'Cancelled') {
                        cancelledApptsSlots.add(app.AppointmentSlot__c);
                    }                    
                }
                if(cancelledApptsSlots.size() > 0) {
                    List<Event> eventsToBeDeleted = [Select Id FROM Event where WhatId in : cancelledApptsSlots];
                    system.debug('eventsDel: '+eventsToBeDeleted);
                    delete eventsToBeDeleted;
                }
            }
            // Do not create a record for null field
            updateStudentIds.remove(null);
            updateSlots.remove(null);
            /*List<Id> contactIds = new List<Id>();
            List<User> users = [Select Id,ContactId FROM User where Id in: updateStudentIds And ContactId != null];
            for(User u : users) {
                contactIds.add(u.ContactId);
            }*/
          // Create in-memory copies for all consultants that will be affected
            for(Id studentId :updateStudentIds)
                updateStudents.put(studentId,new Contact(id=studentId,No_of_strikes_in_Peer_Center__c=0, No_of_Strikes_in_Writing_Center__c=0));
          // Run an optimized query that looks for all consultants
            if(updateStudentIds.size() > 0) {
                for(AppointmentContact__c appointment :[select id,AppointmentSlot__r.Availability__r.Success_Center__r.Name,Contact__c,Strike__c from AppointmentContact__c where Contact__c in :updateStudentIds 
                    and Strike__c= true and Status__c in ('Cancelled by Student','Missed by Student') 
                    AND AppointmentSlot__r.Availability__r.Success_Center__r.Name in ('Learning Center','Writing Center') AND AppointmentSlot__r.Term__r.Active__c = true]) {
                if(appointment.AppointmentSlot__r.Availability__r.Success_Center__r.Name == 'Learning Center') {
                    updateStudents.get(appointment.Contact__c).No_of_strikes_in_Peer_Center__c += 1;
                }
                else if(appointment.AppointmentSlot__r.Availability__r.Success_Center__r.Name == 'Writing Center') {
                    updateStudents.get(appointment.Contact__c).No_of_Strikes_in_Writing_Center__c += 1;
                } 
            }
            for (Counsellor_Availability__c slot : [select Id, Name,DropinTotalUsedTime__c, AppointmentType__c,(select id,DropInUsedTime__c from Appointment_Contacts__r) from Counsellor_Availability__c where Id IN :updateSlots]) {
                Decimal dropInTimeUsedTotal = 0;
                if(slot.AppointmentType__c == App_Config__c.getInstance('Dropin Appointment').Text_Value__c) {
                    for(AppointmentContact__c appointment : slot.Appointment_Contacts__r) {
                        if(appointment.DropInUsedTime__c != null) {
                            dropInTimeUsedTotal += Double.valueOf(appointment.DropInUsedTime__c);
                        }
                    }
                }
                slot.DropinTotalUsedTime__c = dropInTimeUsedTotal;
                //slot.Noofstudentsregistered__c = slot.Appointment_Contacts__r.size();
                slotsToUpdate.add(slot);
            }
            for (Counsellor_Availability__c slot : [select Id, Name, Noofstudentsregistered__c, Capacity__c, Status__c, AppointmentType__c,(select id from Appointment_Contacts__r where Status__c in ('Checked-In','Pending','Confirmed','Student Checked-In','Needs Notes','Complete')) from Counsellor_Availability__c where Id IN :updateSlots]) {
                
                if(!slot.Appointment_Contacts__r.isEmpty())
                    slot.Noofstudentsregistered__c = slot.Appointment_Contacts__r.size();
                else
                    slot.Noofstudentsregistered__c = 0;
                    
                if(slot.Capacity__c != slot.Noofstudentsregistered__c && slot.Status__c == 'Booked') {
                    slot.Status__c = 'Open';
                }
                studentsRegistered.add(slot);
                //slotsToUpdate.add(slot);
            }

                // Update all the consultants with new values. 
                system.debug('updateStudents: '+updateStudents.values());
                Database.update(updateStudents.values());
                Database.update(slotsToUpdate);
                Database.update(studentsRegistered); 
            }
            
            }
       
            
}