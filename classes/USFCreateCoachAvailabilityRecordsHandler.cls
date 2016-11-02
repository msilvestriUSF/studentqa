public class USFCreateCoachAvailabilityRecordsHandler {
    
    public static void doAfterInsert(List<Counselor_Availability_Definition__c> cadRecList){
        USF_CoachAvailabilityUtils.createAvailabilitySlots(cadRecList);
    }
    
    public static void doAfterUpdate(List<Counselor_Availability_Definition__c> cadRecList, Map<Id, Counselor_Availability_Definition__c> oldMap){
        USF_CoachAvailabilityUtils.updateAvailabilitySlots(cadRecList,oldMap);
    } 
     public static void doBeforeDelete(Map<Id, Counselor_Availability_Definition__c> cadRecMap) {
        List<Counsellor_Availability__c> slotsToDelete = [Select id,Availability__c from Counsellor_Availability__c where Availability__c IN :cadRecMap.keySet()];
        if(slotsToDelete != null && !slotsToDelete.isEmpty()) {
            Map<Id,Counsellor_Availability__c> slotsToDeleteMap = new Map<Id,Counsellor_Availability__c>(slotsToDelete);
            List<Database.DeleteResult> drList = Database.delete(slotsToDelete,false);
            List<Id> availabilityNotToDeleted = new List<Id>();
            Counsellor_Availability__c slotNotDeleted = new Counsellor_Availability__c();
            for(Database.DeleteResult dr : drList) {
                for(Database.Error err : dr.getErrors()) {
                    slotNotDeleted = slotsToDeleteMap.get(dr.getId());
                    if(slotNotDeleted != null && slotNotDeleted.Availability__c != null) {
                        availabilityNotToDeleted.add(slotNotDeleted.Availability__c);
                    }
                }
            }
            for(Id availabilityId: availabilityNotToDeleted) {
                cadRecMap.get(availabilityId).addError(App_Config__c.getInstance('Appointment Check Message').Text_Value__c);
            }
        }
     }
     
     public static void doBeforeInsert(List<Counselor_Availability_Definition__c> availabilityList) {
        assignConsultant(availabilityList[0]);
        validateMeetingType(availabilityList);
        //assignOwner(availabilityList);
     }
     
     public static void doBeforeUpdate(List<Counselor_Availability_Definition__c> availabilityList,Map<Id, Counselor_Availability_Definition__c> oldMap) {
        assignConsultant(availabilityList[0]);
        validateMeetingType(availabilityList);
        //assignOwner(availabilityList);
     }
     
     /*public static void assignOwner(List<Counselor_Availability_Definition__c> availabilityList){
        Map<Id,User> AvailabilityConsultantMap = new Map<Id,User>();
        List<Id> terms = getTermList(availabilityList);
        List<Id> centerIds = getCenterList(availabilityList);
        String contactId = [Select Id, ContactId FROM User where Id =: UserInfo.getUserId() LIMIT 1].ContactId;
        List<Consultant__c> consultantList = getConsultantList(terms,centerIds,contactId);
        Map<Id,hed__Term__c> termsMap = USF_DBUtil.getTerm(availabilityList);
        hed__Term__c term;
        Map<String,Consultant__c> consultantMap = getConsultantMap(consultantList);
        Map<Id,Id> userConsultantMap = getUserMap(consultantList);
        String consultantMapKey;
        Id consultantContactId;
        for(Counselor_Availability_Definition__c availability : availabilityList) {
            if(termsMap.containsKey(availability.Id)) {
                term = termsMap.get(availability.Id);
                consultantMapKey = term.Id+'_'+availability.Success_Center__c;
                if(consultantMap.containsKey(consultantMapKey)) {
                    consultantContactId = consultantMap.get(consultantMapKey).Contact__c;
                    if(userConsultantMap.containsKey(contactId)) {
                        availability.OwnerId = userConsultantMap.get(consultantContactId);
                    }
                }
            }
        }
     }*/
     
     /*
        Description : This method takes a list of Consultants as Parameter
        Return      : A Map with key as a combination of Consultants Term and Center and value as Consultant
     */
     /*public static Map<String,Consultant__c> getConsultantMap(List<Consultant__c> consultantList) {
        String consultantMapKey;
        Map<String,Consultant__c> consultantMap =  new Map<String,Consultant__c>();
        for(Consultant__c consultant : consultantList) {
            if(consultant.Term__c != null && consultant.Center__c != null) {
                consultantMapKey = consultant.Term__c+'_'+consultant.Center__c;
                consultantMap.put(consultantMapKey,consultant);
            }
        }
        return consultantMap;
     }*/
     
     /*
        Description : This method takes a list of Consultants as Parameter
        Return      : A Map with Key as Consultant Id and value as user id of that Consultant.
     */
     /*public static Map<Id,Id> getUserMap(List<Consultant__c> consultantList) {
        Map<Id,Id> userMap;
        List<Id> contactsList = new List<Id>();
        for(Consultant__c consultant : consultantList) {
            if(consultant.Contact__c != null) {
                contactsList.add(consultant.Contact__c);
            }
        }
        if(contactsList.size() > 0) {
            //List<User> userList = [Select id,ContactId from User where ContactId IN : contactsList];
            List<User> userList = USF_DBUtil.getUserList(contactsList);
            for(User userInstance : userList) {
                userMap.put(userInstance.ContactId,userInstance.Id);
            }
        }
        return userMap;
     }*/
     
     /*public static List<Id> getCenterList(List<Counselor_Availability_Definition__c> availabilityList) {
        List<Id> centerIds = new List<Id>();
        for(Counselor_Availability_Definition__c availability : availabilityList) {
            if(String.isNotBlank(availability.Success_Center__c)) {
                centerIds.add(availability.Success_Center__c);
            }
        }
        return centerIds;
     }
     
     public static List<Id> getTermList(List<Counselor_Availability_Definition__c> availabilityList) {
        List<Id> terms = new List<Id>();
        Map<Id,hed__Term__c> termsMap = USF_DBUtil.getTerm(availabilityList);
        if(termsMap != null && !termsMap.isEmpty()) {
            for(hed__Term__c term : termsMap.values()) {
                terms.add(term.Id);
            }
        }
        return terms;
     }
     
     public static List<Consultant__c> getConsultantList(List<Id> terms,List<Id> centerIds, String contactId) {
        List<Consultant__c> consultantList = new List<Consultant__c>();
        String consultantQuery = 'Select id,Center__c,Term__c,Contact__c from Consultant__c';
        if(terms != null && !terms.isEmpty()) {
            if(consultantQuery.containsIgnoreCase('where')) {
                consultantQuery +=' AND Term__c In : terms';
            }
            else {
                consultantQuery +=' where Term__c In : terms';
            }
        }
        if(centerIds != null && !centerIds.isEmpty()) {
            if(consultantQuery.containsIgnoreCase('where')) {
                consultantQuery +=' AND Center__c In : centerIds';
            }
            else {
                consultantQuery +=' where Center__c In : centerIds';
            }
        }
        if(contactId != null && String.isNotBlank(contactId)) {
            if(consultantQuery.containsIgnoreCase('where')) {
                consultantQuery +=' AND Contact__c = :contactId';
            }
            else {
                consultantQuery +=' where Contact__c = :contactId';
            }
        }
        for(Consultant__c consultant : Database.query(consultantQuery)) {
            consultantList.add(consultant);
        }
        return consultantList;
     }*/
     
     /*
        Description : This method takes a list of Availabilities as Parameter and validates whether
                      the center of each availability has the correct meeting types
        Return      : A Map with Key as Consultant Id and value as user id of that Consultant.
     */
     public static void validateMeetingType(List<Counselor_Availability_Definition__c> availabilityList) {
        List<Account> centersList = USF_DBUtil.getCenters();
        Id learningCenterId,speakingCenterId,writingCenterId;
        String meetingLocation;
        for(Account acct : centersList){
            if(acct.Name.contains(Label.USF_LWCAppointmentLearningCenter)){
                learningCenterId=acct.id;
            }
            if(acct.Name.contains(Label.USF_LWCAppointmentSpeakingCenter)){
                speakingCenterId=acct.id;
            }
            if(acct.Name.contains(Label.USF_LWCAppointmentWritingCenter)){
                writingCenterId=acct.id;
            }
        }
        for(Counselor_Availability_Definition__c availability : availabilityList) {
            meetingLocation = availability.Meeting_Location__c;
            Boolean bool = false;
            if(availability.Success_center__c == learningCenterId) {
                bool = true; 
            }
            if(availability.Success_center__c == learningCenterId && meetingLocation != null && meetingLocation.containsIgnoreCase(App_Config__c.getInstance('AvailabilityMeetingType_Phone').Text_Value__c)) {
                availability.addError('Learning center can have only In Person or Online as Meeting type');
            }
            else if(availability.Success_center__c == speakingCenterId && meetingLocation != null &&  !meetingLocation.equalsIgnoreCase(App_Config__c.getInstance('AvailabilityMeetingType_InPerson').Text_Value__c)) {
                availability.addError('Speaking center can have only Phone as Meeting type');
            }
        }
     }
     
     public static void assignConsultant(Counselor_Availability_Definition__c avlRec) {
         try {
             String contactId = USF_DBUtil.getUserContactId(avlRec.Coach__c);
             List<hed__Term__c> terms = USF_DBUtil.getTerm(avlRec.Start_Date_Time__c.date(),avlRec.End_Date_Time__c.date());
             String termId = '';
             if(terms.size() == 1) {
                termId = terms[0].id;
             }
             String centerId = avlRec.Success_Center__c;
             String consultantQuery = 'Select id from Consultant__c where Center__c =: centerId AND Contact__c =: contactId ';
             if(String.isNotBlank(termId)) {
                consultantQuery += 'AND Term__c =: termId';
             }
             consultantQuery += ' limit 1';
             List<Consultant__c> consultantList = Database.query(consultantQuery);
             if(!consultantList.isEmpty()) {
                if(consultantList[0].Id != null) {
                    avlRec.Consultant__c = consultantList[0].Id;
                }
             }
         }
         catch(Exception ex) {
             System.debug('Exception'+ex.getMessage());
         }
    }
}