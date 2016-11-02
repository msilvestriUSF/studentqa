trigger USF_EventTrigger on Event (before insert,before update, after insert, after update, before delete, after delete) {
    //Map<Id,List<Counsellor_Availability__c>> coachSpecificSlots = new Map<Id,List<Counsellor_Availability__c>>(); 
    List<Event> insertedEvents = new List<Event>();
    Set<Id> ownerIds = new Set<Id>();
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        for(Event e : Trigger.new) {
            insertedEvents.add(e);
            ownerIds.add(e.OwnerId);
        }
    }
    if(Trigger.isBefore && Trigger.isDelete) {
        for(Event e : Trigger.old) {
            insertedEvents.add(e);
            ownerIds.add(e.OwnerId);
        }
    }
        List<Counsellor_Availability__c> slots = [Select Id,Event_Conflict__c, Availability__r.Coach__c, Start_Time__c,End_Time__c 
                                                    FROM Counsellor_Availability__c 
                                                    where Availability__r.Coach__c in : ownerIds and Status__c != 'Booked'];
        for(Event e : insertedEvents) {
            system.debug('e: '+e);
            for(Counsellor_Availability__c sl : slots) {
                system.debug('sl: '+sl);
                if(sl.Availability__r.Coach__c == e.OwnerId) {
                    if((sl.Start_Time__c >= e.StartDateTime 
                        && sl.Start_Time__c <= e.EndDateTime) 
                                      || (sl.End_Time__c >= e.StartDateTime 
                                        && sl.End_Time__c <= e.EndDateTime)) {
                        if(Trigger.isBefore && Trigger.isDelete) {
                            sl.Event_Conflict__c = false;
                        }
                        else if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
                            sl.Event_Conflict__c = true;
                        }
                        
                    }
                }
            }   
        }
        if(slots.size() > 0) {
            /*for(Counsellor_Availability__c s : slots) {
                system.debug('slots: '+s.Event_Conflict__c);
            }*/
            
            Database.update(slots);
        }
        /*if((ca.Start_Time__c >= e.StartDateTime && ca.Start_Time__c <= e.EndDateTime) 
                                      || (ca.End_Time__c >= e.StartDateTime && ca.End_Time__c <= e.EndDateTime))*/
    
}