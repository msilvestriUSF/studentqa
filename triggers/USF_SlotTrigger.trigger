trigger USF_SlotTrigger on Counsellor_Availability__c (after insert, after update, after delete, after undelete) {
    
      Map<Id,Consultant__c> updateConsultants = new Map<Id,Consultant__c>();
      Map<Id,Contact> updateContacts = new Map<Id,Contact>();
      Set<Id> updateConsultantIds = new Set<Id>();
      
    //modified by Vandana to stop recursion
    if(!USF_Constant.slotTriggerRecursion){
      // If we are inserting, updating, or undeleting, use the new ID values
      if(Trigger.isInsert || Trigger.isUpdate || Trigger.isUndelete)
      for(Counsellor_Availability__c slot:Trigger.new)
        updateConsultantIds.add(slot.Consultant__c);
    
      // If we are updating, some consultants might change, so include that as well as deletes
      if(Trigger.isUpdate || Trigger.isDelete)
        for(Counsellor_Availability__c slot:Trigger.old)
          updateConsultantIds.add(slot.Consultant__c);
    
      // Do not create a record for null field
      updateConsultantIds.remove(null);
      /*List<Id> contactIds = new List<Id>();
      List<User> users = [Select Id,ContactId FROM User where Id in: updateConsultantIds And ContactId != null];
      for(User u : users) {
        contactIds.add(u.ContactId);
      }*/
      // Create in-memory copies for all consultants that will be affected
      for(Id consultantId :updateConsultantIds)
        updateConsultants.put(consultantId,new Consultant__c(id=consultantId,Appointments_completed_in_Learning_Ctr__c=0));

        Set<Id> contactIds = new Set<Id>();
        List<Consultant__c> consulantContacts = [Select Id, Contact__c FROM Consultant__c where Id in : updateConsultantIds];
        for(Consultant__c c : consulantContacts) {
          contactIds.add(c.Contact__c);
        }
        contactIds.remove(null);
        for(Id conId : contactIds)
        updateContacts.put(conId,new Contact(id=conId,Total_Tutoring_Hours__c=0));
      // Run an optimized query that looks for all consultants
      system.debug('updateConsultantIds: '+updateConsultantIds);
        if(updateConsultantIds.size() > 0) {
          Id termId = USF_DBUtil.getTermId();
          //for(Counsellor_Availability__c testing:[select id,Consultant__c,(Se)Status__c from Counsellor_Availability__c where Consultant__c in :updateConsultantIds and (Status__c='Complete' OR Status__c = 'Missed by Student') and Availability__r.Success_Center__r.Name = 'Learning Center']) {
        for(AppointmentContact__c testing : [Select Id,Status__c, AppointmentSlot__r.Term__c, AppointmentSlot__r.Consultant__c, AppointmentSlot__r.Consultant__r.Contact__c FROM AppointmentContact__c where AppointmentSlot__r.Consultant__c in : updateConsultantIds and (Status__c='Complete' OR Status__c = 'Missed by Student') and AppointmentSlot__r.Availability__r.Success_Center__r.Name = 'Learning Center']) {
        system.debug('testing: '+testing);
        if(testing.Status__c == 'Missed by Student') {
          if(testing.AppointmentSlot__r.Term__c == termId) {
              updateConsultants.get(testing.AppointmentSlot__r.Consultant__c).Appointments_completed_in_Learning_Ctr__c += 0.5;
          }
          updateContacts.get(testing.AppointmentSlot__r.Consultant__r.Contact__c).Total_Tutoring_Hours__c += 0.5;
        }
        else {
           if(testing.AppointmentSlot__r.Term__c == termId) {
                updateConsultants.get(testing.AppointmentSlot__r.Consultant__c).Appointments_completed_in_Learning_Ctr__c++;
           }
          
          updateContacts.get(testing.AppointmentSlot__r.Consultant__r.Contact__c).Total_Tutoring_Hours__c ++;
        } 
      }
    system.debug('updateConsultants: '+updateConsultants.values());
          // Update all the consultants with new values. 
        Database.update(updateConsultants.values()); 
        Database.update(updateContacts.values());
        }
        
        USF_Constant.slotTriggerRecursion = true;
    }
  
}