/******************************************************************************************************************************************
Apex Class Name: USF_CoachAvailabilityUtils
Version        : 1.0
Created Date   : 30 JUL 2016
Function       : Utility methods to expand Coach availability definition recrods into sets of individual coach
    availability slot records
Modification Date : 
Modified By : Arshad 
Modification Log:   Nishit - Changed reference from Slot_Frequency__c to TimeSlotDuration__c formula field.

**********************************************************************************************************************************************/
public class USF_CoachAvailabilityUtils {

    /* Method name : createOnlyOnceAvailabilitySlots
     * Description : Takes a Coach Availability Definition Record and creates coach availability slot records for Repeat = "Only Once"
     * Return Type : Void
     * Paramater   : List<Id>
     */
    static String learningCenterLabel = App_Config__c.getInstance('Learning Center').Text_Value__c;
    static String writingCenterLabel = App_Config__c.getInstance('Writing Center').Text_Value__c;
    static String speakingCenterLabel = App_Config__c.getInstance('Speaking Center').Text_Value__c;
    static String CASALabel = App_Config__c.getInstance('CASA').Text_Value__c;
    static String CASASlotType = App_Config__c.getInstance('CASA Slot Type').Text_Value__c;
    static String LWCSlotType = App_Config__c.getInstance('LWC Slot Type').Text_Value__c;
    static String scheduledAppointmentLabel = App_Config__c.getInstance('Scheduled Appointment').Text_Value__c;
    static String dropInAppointmentLabel = App_Config__c.getInstance('Dropin Appointment').Text_Value__c;
    static String slotRecordType = '';
    static Map<Id,Account> successCenterMap;
    static Map<String,RecordType> recTypeMap;
    public static String pageInfoMessage{get;set;}
    /*public static void createOnlyOnceAvailabilitySlots(List<Counselor_Availability_Definition__c> nonRecurList){
        Account acc;
        Savepoint sp = Database.setSavepoint();
        if(nonRecurList != null && !nonRecurList.isEmpty()){
            List<Counsellor_Availability__c> counsolList = new List<Counsellor_Availability__c>();
            populateStaticValues(nonRecurList);
            //Added by Vandana - DFCT0010872 - start
            Counselor_Availability_Definition__c firstAvailability = nonRecurList[0];
            List<hed__Term__c> terms = USF_DBUtil.getTerm(firstAvailability.Start_Date_Time__c.date(),firstAvailability.End_Date_Time__c.date());
             String termId = '';
             if(terms.size() == 1) {
                termId = terms[0].id;
             }
             //Added by Vandana - DFCT0010872 - end
            for(Counselor_Availability_Definition__c nonRecurring : nonRecurList){
                acc=successCenterMap.get(nonRecurring.Success_Center__c);
                slotRecordType = getRecordType(acc);
                System.debug('nonRecurring...'+nonRecurring);
                Integer lengthMinutes;
                Double lengthMillisec;
                Double startTime;
                Double EndTime;
                Double StarEndTimeDiff;
                Datetime startDateTime;
                Datetime endDateTime;
                Set<DateTime> allStartTime;
                Map<Account,Set<DateTime>> beforeValidationMap;
                Map<Account,Map<String,Set<DateTime>>> aftervalidation_map;
                Map<String,Set<DateTime>> valid_invalid_map;
                Set<DateTime> valid_date_time;
                Set<DateTime> invalid_date_time;
                if(nonRecurring.AppointmentType__c == scheduledAppointmentLabel){
                    if(acc.Name.containsIgnoreCase(CASALabel)) {
                        lengthMinutes = Integer.valueOf(nonRecurring.TimeSlotDuration__c);
                    }
                    else {
                        lengthMinutes = Integer.valueOf(nonRecurring.TimeSlotDurationLWC__c);
                    }
                    lengthMillisec = (lengthMinutes*60000); //convert into Milliseconds
                    startTime = nonRecurring.Start_Date_Time__c.getTime();
                    EndTime = nonRecurring.End_Date_Time__c.getTime();
                    StarEndTimeDiff = EndTime - startTime;
                    startDateTime = nonRecurring.Start_Date_Time__c;
                    endDateTime = startDateTime.addMinutes(lengthMinutes);
                    //Added by Ritam on Aug,29,2016
                    allStartTime=new Set<DateTime>();
                    while(StarEndTimeDiff >= lengthMillisec){
                        allStartTime.add(startDateTime);
                        StarEndTimeDiff = StarEndTimeDiff-lengthMillisec;
                        startDateTime = endDateTime;
                        endDateTime = startDateTime.addMinutes(lengthMinutes); 
                    }
                    beforeValidationMap =new Map<Account,Set<DateTime>>()  ;
                    beforeValidationMap.put(acc,allStartTime);
                    aftervalidation_map =(new USF_DateTimeService()).getValidInvalidDateTimeMap_map(beforeValidationMap);
                    valid_invalid_map=aftervalidation_map.get(acc);
                    valid_date_time=valid_invalid_map.get('valid_date_time');
                    invalid_date_time=valid_invalid_map.get('invalid_date_time');
                    if(!valid_date_time.isEmpty()){
                       for(Datetime slotCreationDateTime:valid_date_time){
                           Counsellor_Availability__c counselor=new Counsellor_Availability__c(Start_Time__c = slotCreationDateTime, Location__c = nonRecurring.Location__c,
                            end_Time__c = slotCreationDateTime.addMinutes(lengthMinutes), Availability__c=nonRecurring.Id,RecordTypeId = slotRecordType,Type__c = nonRecurring.Meeting_Location__c);
                           System.debug('Counselor  :'+counselor);
                           if(nonRecurring.Consultant__c != null) {
                               counselor.Consultant__c = nonRecurring.Consultant__c;
                           }
                           counselor.Term__c = termId;
                           counsolList.add(counselor);
                       }
                    }
                    else if(valid_date_time.isEmpty()) {
                        nonRecurring.addError('There are no valid slots. Please check your calender');
                        return;
                    }
                    if(!invalid_date_time.isEmpty()) {
                        pageInfoMessage = 'There are slots not in Business hours or Working days in your input. Please check your Calendar.';
                    }
                }
                else if(nonRecurring.AppointmentType__c == dropInAppointmentLabel){
                    if(BusinessHours.iswithin(acc.BusinessHour__c,nonRecurring.Start_Date_Time__c) && BusinessHours.iswithin(acc.BusinessHour__c,nonRecurring.End_Date_Time__c)) {
                        Counsellor_Availability__c slot=new Counsellor_Availability__c();
                        slot.Start_Time__c = nonRecurring.Start_Date_Time__c;
                        slot.Location__c = nonRecurring.Location__c;
                        slot.end_Time__c = nonRecurring.End_Date_Time__c;
                        slot.Availability__c=nonRecurring.Id;
                        slot.RecordTypeId = slotRecordType;
                        slot.Type__c = nonRecurring.Meeting_Location__c;
                        if(nonRecurring.Consultant__c != null) {
                           slot.Consultant__c = nonRecurring.Consultant__c;
                        }
                        slot.Term__c = termId;
                        counsolList.add(slot);
                    }
                    else {
                        nonRecurring.addError('There are no valid slots. Please check your calender');
                    }
                }
            }
            try{
                System.debug('counsolList...'+counsolList);
                if(!counsolList.isEmpty()){
                    List<Counsellor_Availability__c> nonOverlappingSlots = validateOverlappingSlots(counsolList,nonRecurList);
                    System.debug('**nonOverlappingSlots**'+nonOverlappingSlots);
                    Boolean hasValidSlots = false;
                    if(!nonOverlappingSlots.isEmpty()){
                        System.debug('**nonOverlappingSlots2**'+nonOverlappingSlots);
                        insert nonOverlappingSlots;
                    }
                    
                    //if an availability does NOT have even one valid slot, throw an error.
                    for(Counselor_Availability_Definition__c nonRecurring : nonRecurList) {
                        hasValidSlots = false;
                        for(Counsellor_Availability__c validSlot : nonOverlappingSlots){
                            if(nonRecurring.Id == validSlot.Availability__c){
                                hasValidSlots = true;
                            }
                        }
                        
                        if(hasValidSlots == false){
                            nonRecurring.addError('You have overlapping slots.');
                        }
                    }
                    //insert counsolList;
                        
                }
                else {
                    for(Counselor_Availability_Definition__c nonRecurring : nonRecurList) {
                        nonRecurring.addError('There are no valid slots. Please check your calender');
                    }
                }
            }catch(DMLException dml){
                Database.rollback(sp);
            }catch(Exception e){
            }
        }
     }*/

     /* Method name : createWeeklyAvailabilitySlots
     * Description : Takes a Coach Availability Definition Record and creates coach availability slot records for Repeat = "Weekly"
     * Return Type : Void
     * Paramater   : List<Id>
     */
     /*public static void createWeeklyAvailabilitySlots(List<Counselor_Availability_Definition__c> weeklyRecList) {
        Savepoint sp = Database.setSavepoint();
        Account acc;
        
        if(weeklyRecList != null && !weeklyRecList.isEmpty()){
            
            //Added by Vandana - DFCT0010872 - start
            Counselor_Availability_Definition__c firstAvailability = weeklyRecList[0];
            List<hed__Term__c> terms = USF_DBUtil.getTerm(firstAvailability.Start_Date_Time__c.date(),firstAvailability.End_Date_Time__c.date());
             String termId = '';
             if(terms.size() == 1) {
                termId = terms[0].id;
             }
            //Added by Vandana - DFCT0010872 - end
            List<Counsellor_Availability__c> counsolList = new List<Counsellor_Availability__c>();
            populateStaticValues(weeklyRecList);
            Set<String> daySet;
            DateTime startDateTime;
            Double lengthMillisec;
            Integer daysElapsed;
            Integer lengthMinutes;
            Set<DateTime> allStartTime;          
            Double startTime;
            DateTime currentendDayTime;
            Double EndTime;
            Double StarEndTimeDiff;
            Datetime endDateTime;
            Integer i;
            Map<Account,Set<DateTime>> beforeValidationMap;
            Map<Account,Map<String,Set<DateTime>>> aftervalidation_map;
            Map<String,Set<DateTime>> valid_invalid_map;
            Set<DateTime> valid_date_time;
            Set<DateTime> invalid_date_time;
            
            for(Counselor_Availability_Definition__c cad : weeklyRecList){
                acc=successCenterMap.get(cad.Success_Center__c);
                slotRecordType = getRecordType(acc);
                daySet = new Set<String>();   
                if(cad.Monday__c == true) daySet.add('Monday');
                if(cad.Tuesday__c == true) daySet.add('Tuesday');
                if(cad.Wednesday__c == true) daySet.add('Wednesday');
                if(cad.Thursday__c == true) daySet.add('Thursday');
                if(cad.Friday__c == true) daySet.add('Friday');
                if(cad.AppointmentType__c == scheduledAppointmentLabel){
                    startDateTime = cad.Start_Date_Time__c;
                    daysElapsed = 0;
                    if(acc.Name.containsIgnoreCase(CASALabel)) {
                        lengthMinutes = Integer.valueOf(cad.TimeSlotDuration__c);
                    }
                    else {
                        lengthMinutes = Integer.valueOf(cad.TimeSlotDurationLWC__c);
                    }
                     
                    allStartTime=new Set<Datetime>();
                    
                    while(startDateTime < cad.End_Date_Time__c){
                        for(string s : daySet){
                            if(StartDateTime.format('EEEE') == s){
                                lengthMillisec = (lengthMinutes*60000); //convert into Milliseconds
                                startTime = startDateTime.getTime();
                                currentendDayTime = DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), cad.End_Date_Time__c.hour(),cad.End_Date_Time__c.minute(),cad.End_Date_Time__c.second());
                                EndTime = currentendDayTime.getTime();
                                StarEndTimeDiff = EndTime - startTime;            
                                endDateTime = startDateTime.addMinutes(lengthMinutes);
                                i = 1; 
                                while(StarEndTimeDiff >= lengthMillisec){
                                    allStartTime.add(startDateTime);
                                    StarEndTimeDiff = StarEndTimeDiff-lengthMillisec;
                                    startDateTime = endDateTime; 
                                    endDateTime = startDateTime.addMinutes(lengthMinutes);
                                    i++; 
                                }
                            }
                        }
                        daysElapsed += 1;
                        startDateTime = cad.Start_Date_Time__c.addDays(daysElapsed); 
                    }
                    beforeValidationMap =new Map<Account,Set<DateTime>>()  ;
                    beforeValidationMap.put(acc,allStartTime);
                    aftervalidation_map =(new USF_DateTimeService()).getValidInvalidDateTimeMap_map(beforeValidationMap);
                    valid_invalid_map=aftervalidation_map.get(acc);
                    valid_date_time=valid_invalid_map.get(USF_Constant.VALID_DATE_TIME);
                    invalid_date_time=valid_invalid_map.get(USF_Constant.INVALID_DATE_TIME);
                    if(!valid_date_time.isEmpty()){
                       for(Datetime slotCreationDateTime:valid_date_time){
                           counsolList.add(new Counsellor_Availability__c(Start_Time__c = slotCreationDateTime, Location__c = cad.Location__c,
                                    end_Time__c = slotCreationDateTime.addMinutes(lengthMinutes), 
                                    Interviewer__c = cad.CreatedBy.Id, Availability__c=cad.Id,Consultant__c = cad.Consultant__c,Type__c = cad.Meeting_Location__c,Term__c = termId));
                       }
                    }
                    else if(valid_date_time.isEmpty()) {
                        cad.addError('There are no valid slots. Please check your calender');
                        return;
                    }
                    if(!invalid_date_time.isEmpty()) {
                        pageInfoMessage = 'There are slots not in Business hours or Working days in your input. Please check your Calendar.';
                    }
                }
                else if(cad.AppointmentType__c == dropInAppointmentLabel){
                    startDateTime = cad.Start_Date_Time__c;
                    currentendDayTime = DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), cad.End_Date_Time__c.hour(),cad.End_Date_Time__c.minute(),cad.End_Date_Time__c.second());
                    if(BusinessHours.iswithin(acc.BusinessHour__c,startDateTime) && BusinessHours.iswithin(acc.BusinessHour__c,currentendDayTime)) {
                        Counsellor_Availability__c slot;
                        while(startDateTime < cad.End_Date_Time__c){
                            if(daySet.contains(startDateTime.format('EEEE'))){
                                slot=new Counsellor_Availability__c();
                                slot.Start_Time__c = startDateTime;
                                slot.Location__c = cad.Location__c;
                                slot.end_Time__c = currentendDayTime;
                                slot.Availability__c=cad.Id;
                                slot.RecordTypeId = slotRecordType;
                                slot.Type__c = cad.Meeting_Location__c;
                                slot.Term__c = termId;
                                if(cad.Consultant__c != null) {
                                   slot.Consultant__c = cad.Consultant__c;
                                }
                                counsolList.add(slot);
                            }
                            startDateTime = startDateTime.addDays(1);
                            currentendDayTime = currentendDayTime.addDays(1);
                        }
                    }
                    else {
                        cad.addError('There are no valid slots. Please check your calender');
                    }
                }
                system.debug('counsolList   :'+counsolList+',   Size    :'+counsolList.size());
            }
            try{
                if(!counsolList.isEmpty()){
                    List<Counsellor_Availability__c> nonOverlappingSlots = validateOverlappingSlots(counsolList,weeklyRecList);
                    Boolean hasValidSlots = false;
                    if(!nonOverlappingSlots.isEmpty()){
                        insert nonOverlappingSlots;
                    }
                    
                    //if an availability does not have even one valid slot, throw an error.
                    for(Counselor_Availability_Definition__c rec : weeklyRecList) {
                        hasValidSlots = false;
                        for(Counsellor_Availability__c validSlot : nonOverlappingSlots){
                            if(rec.Id == validSlot.Availability__c){
                                hasValidSlots = true;
                            }
                        }
                        
                        if(hasValidSlots == false){
                            rec.addError('You have overlapping slots.');
                        }
                    }
                    //insert counsolList;
                }
            }catch(DMLException dml){
                Database.rollback(sp);
            }catch(Exception e){
            }
        } 
    }*/
    
     /* Method name : createDailyAvailabilitySlots
     * Description : Takes a Coach Availability Definition Record and creates coach availability slot records for Repeat = "Daily"
     * Return Type : Void
     * Paramater   : List<Id>
     */
     /*public static void createDailyAvailabilitySlots(List<Counselor_Availability_Definition__c> dailyRecList) {  
        Savepoint sp = Database.setSavepoint();
        Account acc;
        List<Counsellor_Availability__c> counsolList = new List<Counsellor_Availability__c>();
        DateTime startDateTime;
        DateTime endingDateTime;
        Integer daysElapsed;
        Integer lengthMinutes;
        double MaxNoSlot;
        Set<DateTime> allStartTime;
        Double lengthMillisec;
        Double startTime;
        DateTime currentendDayTime ;
        Double EndTime;
        Double StarEndTimeDiff;            
        Datetime endDateTime ;
        Map<Account,Set<DateTime>> beforeValidationMap;
        Map<Account,Map<String,Set<DateTime>>> aftervalidation_map;
        Map<String,Set<DateTime>> valid_invalid_map;
        Set<DateTime> valid_date_time;
        Set<DateTime> invalid_date_time;
        Counsellor_Availability__c slot;
        if(dailyRecList != null && !dailyRecList.isEmpty()){
            //Added by Vandana - DFCT0010872 - start
            Counselor_Availability_Definition__c firstAvailability = dailyRecList[0];
            List<hed__Term__c> terms = USF_DBUtil.getTerm(firstAvailability.Start_Date_Time__c.date(),firstAvailability.End_Date_Time__c.date());
             String termId = '';
             if(terms.size() == 1) {
                termId = terms[0].id;
             }
            //Added by Vandana - DFCT0010872 - end
             populateStaticValues(dailyRecList);
             for(Counselor_Availability_Definition__c cad : dailyRecList){
                acc=successCenterMap.get(cad.Success_Center__c);
                startDateTime = cad.Start_Date_Time__c;
                endingDateTime=cad.End_Date_Time__c;
                daysElapsed = 0;
                if(acc.Name.containsIgnoreCase(CASALabel)) {
                        lengthMinutes = Integer.valueOf(cad.TimeSlotDuration__c);
                }
                else {
                    lengthMinutes = Integer.valueOf(cad.TimeSlotDurationLWC__c);
                } 
                MaxNoSlot=cad.Max_No_Of_Slots__c;
                slotRecordType = getRecordType(acc);
                allStartTime=new Set<DateTime>();
                if(cad.AppointmentType__c == scheduledAppointmentLabel) {
                    while(startDateTime < cad.End_Date_Time__c){
                        lengthMillisec = (lengthMinutes*60000); //convert into Milliseconds
                        startTime = startDateTime.getTime();
                        currentendDayTime = DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), cad.End_Date_Time__c.hour(),cad.End_Date_Time__c.minute(),cad.End_Date_Time__c.second());
                        EndTime = currentendDayTime.getTime();
                        StarEndTimeDiff = EndTime - startTime;            
                        endDateTime = startDateTime.addMinutes(lengthMinutes);
                        while(StarEndTimeDiff >= lengthMillisec){
                            allStartTime.add(startDateTime);
                            StarEndTimeDiff = StarEndTimeDiff-lengthMillisec;
                            startDateTime = endDateTime; 
                            endDateTime = startDateTime.addMinutes(lengthMinutes);
                        }
                        daysElapsed += 1;
                        startDateTime = cad.Start_Date_Time__c.addDays(daysElapsed); 
                    }
                    beforeValidationMap =new Map<Account,Set<DateTime>>()  ;
                    beforeValidationMap.put(acc,allStartTime);
                    aftervalidation_map =(new USF_DateTimeService()).getValidInvalidDateTimeMap_map(beforeValidationMap);
                    valid_invalid_map=aftervalidation_map.get(acc);
                    valid_date_time=valid_invalid_map.get(USF_Constant.VALID_DATE_TIME);
                    invalid_date_time=valid_invalid_map.get(USF_Constant.INVALID_DATE_TIME);
                    if(!valid_date_time.isEmpty()){
                       for(Datetime slotCreationDateTime:valid_date_time){
                            counsolList.add(new Counsellor_Availability__c(Start_Time__c = slotCreationDateTime, Location__c = cad.Location__c,
                                    end_Time__c = slotCreationDateTime.addMinutes(lengthMinutes), Availability__c=cad.Id, RecordTypeId = slotRecordType,Consultant__c = cad.Consultant__c,Type__c = cad.Meeting_Location__c,Term__c = termId));   
                       }
                    }
                    else if(valid_date_time.isEmpty()) {
                        cad.addError('There are no valid slots. Please check your calender');
                        return;
                    }
                    if(!invalid_date_time.isEmpty()) {
                       pageInfoMessage = 'There are slots not in Business hours or Working days in your input. Please check your Calendar.';
                    }
                }
                else if(cad.AppointmentType__c == dropInAppointmentLabel){
                    currentendDayTime = DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), cad.End_Date_Time__c.hour(),cad.End_Date_Time__c.minute(),cad.End_Date_Time__c.second());
                    if(!(BusinessHours.iswithin(acc.BusinessHour__c,startDateTime)) || !(BusinessHours.iswithin(acc.BusinessHour__c,cad.End_Date_Time__c))) {
                        cad.addError('There are no valid slots. Please check your calender');
                        return;
                    }
                    slot=new Counsellor_Availability__c();
                    while(startDateTime < cad.End_Date_Time__c){
                        if(BusinessHours.iswithin(acc.BusinessHour__c,startDateTime)) {
                            slot=new Counsellor_Availability__c();
                            slot.Start_Time__c = startDateTime;
                            slot.Location__c = cad.Location__c;
                            slot.end_Time__c = currentendDayTime;
                            slot.Availability__c=cad.Id;
                            slot.RecordTypeId = slotRecordType;
                            slot.Consultant__c = cad.Consultant__c;
                            slot.Type__c = cad.Meeting_Location__c;
                            slot.Term__c = termId;
                            counsolList.add(slot);
                        }
                        startDateTime = startDateTime.addDays(1);
                        currentendDayTime = currentendDayTime.addDays(1);
                    }
                }
            }
        }
        try{
            if(!counsolList.isEmpty()){
                
                List<Counsellor_Availability__c> nonOverlappingSlots = validateOverlappingSlots(counsolList,dailyRecList);
                    Boolean hasValidSlots = false;
                    if(!nonOverlappingSlots.isEmpty()){
                        insert nonOverlappingSlots;
                    }
                    
                    //if an availability does not have even one valid slot, throw an error.
                    for(Counselor_Availability_Definition__c rec : dailyRecList) {
                        hasValidSlots = false;
                        for(Counsellor_Availability__c validSlot : nonOverlappingSlots){
                            if(rec.Id == validSlot.Availability__c){
                                hasValidSlots = true;
                            }
                        }
                        
                        if(hasValidSlots == false){
                            rec.addError('You have overlapping slots.');
                        }
                    }
                    //insert counsolList;
            }
        }
        catch(DMLException dml){
            Database.rollback(sp);
        }
        catch(Exception e){}            
     }*/
     
     public static void populateStaticValues(List<Counselor_Availability_Definition__c> availabilityList) {
         List<Id> successCenters = new List<Id>();
         for(Counselor_Availability_Definition__c availablityRec : availabilityList) {
            successCenters.add(availablityRec.Success_Center__c);
         }
         List<Account>  successCenterList=[Select Id, Name, BusinessHour__c from Account where ID in :successCenters];
         successCenterMap = new Map<Id,Account>();
         for(Account acct: successCenterList) {
            successCenterMap.put(acct.Id,acct);
         }
         List<RecordType> recTypes = [Select id,Name from RecordType where sObjectType='Counsellor_Availability__c'];
         recTypeMap = new Map<String,RecordType>();
         for(RecordType recTypeEach : recTypes) {
            recTypeMap.put(recTypeEach.Name,recTypeEach);
         }
     }
     
     public static String getRecordType(Account acc) {
        String recType = '';
        if(acc.Name.containsIgnoreCase(CASALabel))
            recType = recTypeMap.get(CASASlotType).id;
        else if(acc.Name.containsIgnoreCase(learningCenterLabel) || acc.Name.containsIgnoreCase(writingCenterLabel) || acc.Name.containsIgnoreCase(speakingCenterLabel))
            recType = recTypeMap.get(LWCSlotType).id;
        return recType;
     }
     
     /*
        Description : This method takes a list of Availabilities as Parameter and validates whether
                      they have any overlapping slots or not
        Return      : true if there are no overlapping slots; and false if there are any overlapping slots
     */
     public static List<Counsellor_Availability__c> validateOverlappingSlotsForCoach(List<Counsellor_Availability__c> slotList, List<Counselor_Availability_Definition__c> allAvailabilityList) {

         Map<String,String> availabilityIdcoachIdMap = new Map<String,String>();
         Map<String,List<Counsellor_Availability__c>> coachIdSlotsMap = new Map<String,List<Counsellor_Availability__c>>();
         Set<String> overlappingAvailabilities = new Set<String>();
         List<Counsellor_Availability__c> validSlots = new List<Counsellor_Availability__c>();
         Set<Counsellor_Availability__c> overlappingSlots = new Set<Counsellor_Availability__c>();
         
         //populate availabilityIdcoachIdMap
         for(Counselor_Availability_Definition__c availability : allAvailabilityList){
             availabilityIdcoachIdMap.put(availability.Id,availability.Coach__c);
         }
         
         //populate coachIdSlotsMap
         for(Counsellor_Availability__c slot : slotList){
             if(coachIdSlotsMap.containskey(availabilityIdcoachIdMap.get(slot.Availability__c))){
                 coachIdSlotsMap.get(availabilityIdcoachIdMap.get(slot.Availability__c)).add(slot);
             }else{
                 coachIdSlotsMap.put(availabilityIdcoachIdMap.get(slot.Availability__c), new List<Counsellor_Availability__c>{slot});
             }
         }
         
         //find overlapping availabilities
         for(Counsellor_Availability__c existingSlot : [SELECT End_Time__c,Id,Slot_Date__c,Start_Time__c,Availability__c,Availability__r.Coach__c FROM Counsellor_Availability__c WHERE Availability__r.Coach__c IN :coachIdSlotsMap.keyset()]){
             for(Counsellor_Availability__c slot : coachIdSlotsMap.get(existingSlot.Availability__r.Coach__c)){
                 if((existingSlot.Start_Time__c >= slot.Start_Time__c && existingSlot.End_Time__c <= slot.End_Time__c) || (slot.Start_Time__c >= existingSlot.Start_Time__c && slot.End_Time__c <= existingSlot.End_Time__c) || (existingSlot.Start_Time__c > slot.Start_Time__c && existingSlot.Start_Time__c < slot.End_Time__c) || (existingSlot.End_Time__c > slot.Start_Time__c && existingSlot.End_Time__c < slot.End_Time__c)){
                    System.debug('***current slot****'+slot);
                    System.debug('***existingSlot**'+existingSlot);
                    overlappingSlots.add(slot);
                 }
             }
         }
         
         for(Counsellor_Availability__c slot :slotList) {
             if(!overlappingSlots.contains(slot)) {
                 validSlots.add(slot);
             }
         }
         
         System.debug('overlappingSlots****: '+overlappingSlots);
         System.debug('**validSlots**'+validSlots);
         return validSlots;
         
     }
     
     public static List<Counsellor_Availability__c> createSlots(List<Counselor_Availability_Definition__c> availabilityList) {
        Account acc;
        List<Counsellor_Availability__c> slotList = new List<Counsellor_Availability__c>();
        populateStaticValues(availabilityList);
        Integer slotDuration ;
        Boolean isValidSlot = true;
        Boolean hasInvalidSlots = false;
        Counsellor_Availability__c slot;
        List<Counsellor_Availability__c> counsolList = new List<Counsellor_Availability__c>();
        //Added by Vandana - DFCT0010872 - start
        if(availabilityList.size() > 0) {
            Counselor_Availability_Definition__c firstAvailability = availabilityList[0];
            List<hed__Term__c> terms = USF_DBUtil.getTerm(firstAvailability.Start_Date_Time__c.date(),firstAvailability.End_Date_Time__c.date());
            String termId = '';
            Integer daysElapsed = 0;
            DateTime startDateTime;
            DateTime endingDateTime;
            DateTime currentendDayTime;
            if(terms.size() == 1) {
                termId = terms[0].id;
            }
            for(Counselor_Availability_Definition__c availability : availabilityList) {
                acc=successCenterMap.get(availability.Success_Center__c);
                if(acc.Name.containsIgnoreCase(CASALabel)) {
                    slotDuration = Integer.valueOf(availability.TimeSlotDuration__c);
                }
                else {
                    slotDuration = Integer.valueOf(availability.TimeSlotDurationLWC__c);
                }
                slotRecordType = getRecordType(acc);
                startDateTime = availability.Start_Date_Time__c;
                endingDateTime = availability.End_Date_Time__c;
                if(availability.AppointmentType__c == scheduledAppointmentLabel) {
                    currentendDayTime = startDateTime.addMinutes(slotDuration);
                }
                else if(availability.AppointmentType__c == dropInAppointmentLabel) {
                    currentendDayTime = DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), availability.End_Date_Time__c.hour(),availability.End_Date_Time__c.minute(),availability.End_Date_Time__c.second());
                }
                Set<String> daySet = new Set<String>();   
                if(availability.Repeat__c == 'Weekly') {
                    if(availability.Monday__c == true) daySet.add('Monday');
                    if(availability.Tuesday__c == true) daySet.add('Tuesday');
                    if(availability.Wednesday__c == true) daySet.add('Wednesday');
                    if(availability.Thursday__c == true) daySet.add('Thursday');
                    if(availability.Friday__c == true) daySet.add('Friday');
                }
                Set<DateTime> dateTimeSet = new Set<DateTime>();
                Boolean currentEndTimeCheck ;
                while(startDateTime < endingDateTime){
                    isValidSlot = BusinessHours.iswithin(acc.BusinessHour__c,startDateTime) && BusinessHours.iswithin(acc.BusinessHour__c,currentendDayTime.addMinutes(-1));
                    if(availability.Repeat__c == 'Weekly' && !daySet.contains(startDateTime.format('EEEE'))) {
                        startDateTime = startDateTime.addDays(1);
                        currentEndTimeCheck = (currentendDayTime.Time() <= endingDateTime.Time());
                        if(availability.AppointmentType__c == scheduledAppointmentLabel && currentEndTimeCheck) {
                            currentendDayTime = startDateTime.addMinutes(slotDuration);
                            
                        }
                        if(availability.AppointmentType__c == dropInAppointmentLabel && currentEndTimeCheck) {
                            currentendDayTime = DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), availability.End_Date_Time__c.hour(),availability.End_Date_Time__c.minute(),availability.End_Date_Time__c.second());
                        }
                        continue;
                    }else if(isValidSlot) {
                        if(!dateTimeSet.contains(startDateTime)) {
                            slot=new Counsellor_Availability__c();
                            slot.Start_Time__c = startDateTime;
                            slot.Location__c = availability.Location__c;
                            slot.end_Time__c = currentendDayTime;
                            slot.Availability__c=availability.Id;
                            slot.RecordTypeId = slotRecordType;
                            slot.Consultant__c = availability.Consultant__c;
                            slot.Type__c = availability.Meeting_Location__c;
                            slot.Term__c = termId;
                            slotList.add(slot);
                        }
                        dateTimeSet.add(startDateTime);
                    }else if(!isValidSlot) {
                        hasInvalidSlots = true;
                        dateTimeSet.add(startDateTime);
                    }
                    if(availability.AppointmentType__c == scheduledAppointmentLabel && currentendDayTime.Time() < endingDateTime.Time()) {
                        startDateTime = startDateTime.addMinutes(slotDuration);
                        currentendDayTime = startDateTime.addMinutes(slotDuration);
                    }
                    else if(availability.AppointmentType__c == scheduledAppointmentLabel && !(currentendDayTime.Time() < endingDateTime.Time())) {
                        startDateTime = availability.Start_Date_Time__c.addDays(++daysElapsed);
                        currentendDayTime = startDateTime.addMinutes(slotDuration);
                    }
                    else if(availability.AppointmentType__c == dropInAppointmentLabel) {
                        startDateTime = availability.Start_Date_Time__c.addDays(++daysElapsed);
                        currentendDayTime = DateTime.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day(), availability.End_Date_Time__c.hour(),availability.End_Date_Time__c.minute(),availability.End_Date_Time__c.second());
                    }
                }
                if(slotList.isEmpty()) {
                    availability.addError('There are no valid slots. Please check your calender');
                    return null;
                }
                if(hasInvalidSlots) {
                    pageInfoMessage = 'There are slots not in Business hours or Working days in your input. Please check your Calendar.';
                }
            }
        }
        return slotList;
     }
     
     public static void createAvailabilitySlots(List<Counselor_Availability_Definition__c> availabilityList) {
        List<Counsellor_Availability__c> slotList = createSlots(availabilityList);
        System.debug('slotList...'+slotList);
        List<Counsellor_Availability__c> validSlots;
        Boolean hasValidSlots = false;
        if(slotList != null) {
            validSlots = validateOverlappingSlotsForCoach(slotList,availabilityList);
            if(validSlots != null && validSlots.size() > 0) {
                insert validSlots;
            }
            //if an availability does NOT have even one valid slot, throw an error.
            for(Counselor_Availability_Definition__c availability: availabilityList) {
                hasValidSlots = false;
                for(Counsellor_Availability__c validSlot : validSlots){
                    if(availability.Id == validSlot.Availability__c){
                        hasValidSlots = true;
                    }
                }
                if(hasValidSlots == false){
                    availability.addError('You have overlapping slots.');
                }
            }
        }
     }
     
     public static void updateAvailabilitySlots(List<Counselor_Availability_Definition__c> availabilityList, Map<Id, Counselor_Availability_Definition__c> oldMap) {
        List<Id> availabilityListToBeUpdatedIds = new List<Id>();
        List<Counsellor_Availability__c> slotsToDelete = new List<Counsellor_Availability__c> ();
        List<Counsellor_Availability__c> slotsList = new List<Counsellor_Availability__c> ();
        List<Counselor_Availability_Definition__c> availabilityListToBeUpdated = new List<Counselor_Availability_Definition__c>();
        Counselor_Availability_Definition__c oldavailability;
        for(Counselor_Availability_Definition__c availability : availabilityList){
            oldavailability = new Counselor_Availability_Definition__c();
            oldavailability = oldMap.get(availability.Id);
            if(oldavailability.Start_Date_Time__c != availability.Start_Date_Time__c ||
               oldavailability.End_Date_Time__c != availability.End_Date_Time__c ||
               oldavailability.Repeat__c != availability.Repeat__c ||
               oldavailability.Monday__c != availability.Monday__c ||
               oldavailability.Tuesday__c != availability.Tuesday__c ||
               oldavailability.Wednesday__c != availability.Wednesday__c ||
               oldavailability.Thursday__c != availability.Thursday__c ||
               oldavailability.Friday__c != availability.Friday__c ||
               oldavailability.Max_Number_of_Students__c != availability.Max_Number_of_Students__c) {
                   availabilityListToBeUpdated.add(availability);
                   availabilityListToBeUpdatedIds.add(availability.Id);
               }
        }
        if(availabilityListToBeUpdatedIds.size() > 0) {
            slotsList = [Select id,NoofStudentsRegistered__c from Counsellor_Availability__c where Availability__c IN : availabilityListToBeUpdatedIds];
            if(slotsList != null) {
                for(Counsellor_Availability__c slot : slotsList) {
                    if(slot.NoofStudentsRegistered__c == null || slot.NoofStudentsRegistered__c == 0) {
                        slotsToDelete.add(slot);
                    }
                    else {
                        pageInfoMessage = 'An availability slot was not modified because it has an associated appointment.This message should be displayed on the Portal.';
                    }
                }
            }
            System.debug('slotsToDelete...'+slotsToDelete);
            if(slotsToDelete.size() > 0) {
                delete slotsToDelete;
            }
        }
        createAvailabilitySlots(availabilityListToBeUpdated);
     }
}