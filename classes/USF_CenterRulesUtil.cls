/*

Created By: Nishit Babaria 


*/
public without sharing class USF_CenterRulesUtil {
    String learningCenterLabel = App_Config__c.getInstance('Learning Center').Text_Value__c;
    String writingCenterLabel = App_Config__c.getInstance('Writing Center').Text_Value__c;
    String speakingCenterLabel= App_Config__c.getInstance('Speaking Center').Text_Value__c;
    Static Boolean isLimitReached;
    //added this map by suhan
    public static map<ID,Counsellor_Availability__c> mapslots =new map<ID,Counsellor_Availability__c>([Select Id,Start_Time__c,End_Time__c,Noofstudentsregistered__c,
                                                  Availability__r.Success_Center__r.AppointmentLength__c,StartDate__c,
                                                  Availability__r.Coach__c, 
                                                  Availability__r.Coach__r.Max_hours_in_a_row__c, 
                                                  Availability__r.Coach__r.Max_hours_in_a_week__c
                                                  FROM Counsellor_Availability__c ]);
    public USF_CenterRulesUtil() {
        
    }
    public static String validateStrikes(String center) {
        String result = '';
        List<Contact> currentContacts = new List<Contact>();
        List<Account> accounts = [Select Name,LeadTime__c,Student_Missed_Per_Center__c,Frequencyperday__c,Frequencyperweek__c,AppointmentLength__c 
                                  from Account 
                                  where Name =:center +' Center'];
        Id currentUserId = UserInfo.getUserId();
        system.debug('userId: '+currentUserId);
        List<User> users = [Select Id,ContactId FROM User where Id =: currentUserId];
        system.debug('users[0].ContactId: '+users[0].ContactId);
        if(users[0].ContactId != null) {
            currentContacts = [Select Id,No_of_strikes_in_Peer_Center__c,No_of_strikes_in_Writing_Center__c 
                                FROM Contact 
                                where Id =: users[0].ContactId];
        }
        if(center == 'Learning') {
            if(currentContacts[0].No_of_strikes_in_Peer_Center__c >= accounts[0].Student_Missed_Per_Center__c) {
                return System.Label.USF_Appointment_Strike_Policy;
            }
        }
        else if(center == 'Writing') {
            if(currentContacts[0].No_of_strikes_in_Writing_Center__c >= accounts[0].Student_Missed_Per_Center__c) {
                return System.Label.USF_Appointment_Strike_Policy;
            }
        }
        return '';
           

    }
    public static String validateCASACoachLeave(String currentUser, Id selectedSlotId) {
        List<Counsellor_Availability__c> slots = [Select Id,Start_Time__c,End_Time__c,Availability__r.Coach__r.Leave_Start_Time__c,Availability__r.Coach__r.Leave_End_Time__c 
                                                  FROM Counsellor_Availability__c 
                                                  Where Id =: selectedSlotId];
        if(slots.size() > 0) {//one pending case to confirm: if the leave is between the hours of the slot ?????
            if((slots[0].Start_Time__c >= slots[0].Availability__r.Coach__r.Leave_Start_Time__c 
              && slots[0].Start_Time__c <= slots[0].Availability__r.Coach__r.Leave_End_Time__c)
              || (slots[0].End_Time__c >= slots[0].Availability__r.Coach__r.Leave_Start_Time__c 
              && slots[0].End_Time__c <= slots[0].Availability__r.Coach__r.Leave_End_Time__c) ) {
              if(currentUser == 'Student') {
                return 'The coach is on leave, please contact the CASA Front Desk to book a slot';
              }
              else if(currentUser == 'CASA') {
                return 'The coach is on a leave during the time slot selected';
              }
            }
        }
        return '';

    }

    public static String validateCoachLeave(Date d) {
        List<User> users = [Select Id,ContactId From User where Id =: UserInfo.getUserId()];
        if(users.size() > 0) {
            List<Contact> students = [Select Id,AcademicSuccessCoach__c,AcademicSuccessCoach__r.Leave_Start_Time__c,AcademicSuccessCoach__r.Leave_End_Time__c 
                                        from Contact
                                        where Id =: users[0].ContactId];
            if(students.size() > 0) {
                if(students[0].AcademicSuccessCoach__r.Leave_Start_Time__c != null && students[0].AcademicSuccessCoach__r.Leave_End_Time__c != null) {
                    if(d >= (students[0].AcademicSuccessCoach__r.Leave_Start_Time__c.date()) 
                        && d <= (students[0].AcademicSuccessCoach__r.Leave_End_Time__c).date()) {
                        return 'The coach is on leave please contact the CASA Front Desk';
                    }
                }
            }

        }
        return '';
    }

    public static String validateMaxCASAAppt() {
        String casaCenterName = System.Label.CASA_Center_Name;
        hed__Term__c term = [Select Id FROM hed__Term__c where Active__c = true Limit 1];
        Id termId = null;
        if(term != null) {
            termId = term.Id;
        }
        List<User> users = [Select Id,ContactId From User where Id =: UserInfo.getUserId()];
        if(users.size() > 0 && termId != null && casaCenterName != '') {
            List<AppointmentContact__c> appts = [Select Id FROM AppointmentContact__c 
                                                    where Status__c in ('Pending','Confirmed') 
                                                    AND AppointmentSlot__r.Term__c =: termId 
                                                    AND Contact__c =: users[0].ContactId
                                                    AND AppointmentSlot__r.Center__c =: casaCenterName];
            if(appts.size() > 0) {
                return 'Our records show that you already have a pending or confirmed appointment with your academic success coach. Please call our front desk at 415.422.5050 for assistance.';
            }

        }
        return '';
    }
    
    public static String validateCenterRules(Id selectedSlotId, String center,Date selectedDate,String courseOfferingId) {
        String result = '';
        List<Contact> currentContacts = new List<Contact>();
        List<Account> accounts = [Select Name,LeadTime__c,Student_Missed_Per_Center__c,Frequencyperday__c,Frequencyperweek__c,AppointmentLength__c 
                                  from Account 
                                  where Name =:center +' Center'];
        Id currentUserId = UserInfo.getUserId();
        system.debug('userId: '+currentUserId);
        List<User> users = [Select Id,ContactId FROM User where Id =: currentUserId];
        system.debug('users[0].ContactId: '+users[0].ContactId);
        if(users[0].ContactId != null) {
            currentContacts = [Select Id,No_of_strikes_in_Peer_Center__c,No_of_strikes_in_Writing_Center__c 
                                FROM Contact 
                                where Id =: users[0].ContactId];
        }   




        if(center == 'Learning') {
            result = new USF_CenterRulesUtil().applyPeerCenterRules(currentContacts,accounts,users[0].ContactId,selectedDate,courseOfferingId,'Student');
      //result += new USF_CenterRulesUtil().validateCoachAvailability(selectedSlotId,selectedDate);
        }
        if(center == 'Speaking') {
            result = new USF_CenterRulesUtil().applySpeakingCenterRules(currentContacts,accounts);
        }
      if(center == 'Writing') {
            result = new USF_CenterRulesUtil().applyWritingCenterRules(currentContacts,accounts,users[0].ContactId,selectedDate,'Student');
        }
        
        return result;
    }
    
    
    public static String validateCenterRules(Id selectedSlotId, Id center,Date selectedDate,String courseOfferingId, String studentId) {
        String result = '';
        List<Contact> currentContacts = new List<Contact>();
        List<Account> accounts = [Select Name,LeadTime__c,Student_Missed_Per_Center__c,Frequencyperday__c,Frequencyperweek__c,AppointmentLength__c 
                                  from Account 
                                  where Id =:center];
                                  
        Id currentUserId = UserInfo.getUserId();
        system.debug('userId: '+currentUserId);
        system.debug('studentId: '+studentId);                                  
                                  
        if(studentId != null) {
            currentContacts = [Select Id,No_of_strikes_in_Peer_Center__c,No_of_strikes_in_Writing_Center__c 
                                FROM Contact 
                                where Id =: studentId];
        }                               
        else{
            List<User> users = [Select Id,ContactId FROM User where Id =: currentUserId];
            if(users[0].ContactId != null) {
                currentContacts = [Select Id,No_of_strikes_in_Peer_Center__c,No_of_strikes_in_Writing_Center__c 
                                    FROM Contact 
                                    where Id =: users[0].ContactId];
            }
        }   


        if(center == system.label.LWC_Learning_Center_Id) {
            if(studentId != null) {
            isLimitReached=false;
            validateTutoringRule(studentId,selectedSlotId);
                result = new USF_CenterRulesUtil().applyPeerCenterRules(currentContacts,accounts,studentId,selectedDate,courseOfferingId,'Consultant');
            }
                                
            //result += new USF_CenterRulesUtil().validateCoachAvailability(selectedSlotId,selectedDate);
        }
        if(center == system.label.LWC_Speaking_Center_Id) {
            result = new USF_CenterRulesUtil().applySpeakingCenterRules(currentContacts,accounts);
        }
        if(center == system.label.LWC_Writing_Center_Id) {
            if(studentId != null){
                result = new USF_CenterRulesUtil().applyWritingCenterRules(currentContacts,accounts,studentId,selectedDate,'Consultant');
            }
        }
        
        return result;
    } 
    //Arshad End - 09/15   
  
  public static String validateCoachAvailability(Id selectedSlotId,Date selectedDate) {
      List<Counsellor_Availability__c> slots = [Select Id,Start_Time__c,End_Time__c,Noofstudentsregistered__c,
                                                  Availability__r.Success_Center__r.AppointmentLength__c,
                                                  Availability__r.Coach__c, 
                                                  Availability__r.Coach__r.Max_hours_in_a_row__c, 
                                                  Availability__r.Coach__r.Max_hours_in_a_week__c
                                                  FROM Counsellor_Availability__c 
                                                  where Id =: selectedSlotId];
        Id coachId = slots[0].Availability__r.Coach__c;
        Decimal maxHoursWeek = slots[0].Availability__r.Coach__r.Max_hours_in_a_week__c;
        Decimal maxHoursRow = slots[0].Availability__r.Coach__r.Max_hours_in_a_row__c;
        Decimal currSlotTime = slots[0].Availability__r.Success_Center__r.AppointmentLength__c;
        Date weekEndDate = selectedDate.addDays(6);
        Date weekStartDate = selectedDate.addDays(-6);
        Decimal totalFutureMinutes = 0;
        Decimal totalPastMinutes = 0;
        if(slots[0].Noofstudentsregistered__c == 0) {
            List<Counsellor_Availability__c> futureSlots = [Select Id,Availability__r.Success_Center__r.AppointmentLength__c 
                                                                FROM Counsellor_Availability__c
                                                                Where Availability__r.Coach__c =: coachId
                                                                AND Id !=: selectedSlotId
                                                                And Noofstudentsregistered__c > 0
                                                                And StartDate__c <=: weekEndDate AND StartDate__c >: selectedDate];
            List<Counsellor_Availability__c> pastSlots = [Select Id,Availability__r.Success_Center__r.AppointmentLength__c 
                                                                FROM Counsellor_Availability__c
                                                                Where Availability__r.Coach__c =: coachId
                                                                AND Id !=: selectedSlotId
                                                                And Noofstudentsregistered__c > 0
                                                                And StartDate__c <: selectedDate AND StartDate__c >: weekStartDate];
            for(Counsellor_Availability__c futureSlot : futureSlots) {
                totalFutureMinutes += futureSlot.Availability__r.Success_Center__r.AppointmentLength__c;
            }
            for(Counsellor_Availability__c pastSlot : pastSlots) {
                totalPastMinutes += pastSlot.Availability__r.Success_Center__r.AppointmentLength__c;
            }
            if(maxHoursWeek != null && currSlotTime != null) {
                if((totalFutureMinutes + currSlotTime) > (maxHoursWeek * 60) || (totalPastMinutes + currSlotTime) > (maxHoursWeek * 60)) {
                  return 'Registration cannot be made since the coach is not available for the week';
                }
            }
            
        }
        

        List<Counsellor_Availability__c> allCoachSlots = [Select Id,Start_Time__c,End_Time__c,
                                                                Availability__r.Success_Center__r.AppointmentLength__c 
                                                                FROM Counsellor_Availability__c
                                                                Where Availability__r.Coach__c =: coachId
                                                                AND Id !=: selectedSlotId
                                                                And Noofstudentsregistered__c > 0
                                                                ORDER BY Start_Time__c asc];
        Boolean consecutive = false;
        DateTime junctionTime = null;
        Decimal totalRowMinutes = 0.0;
        List<USF_SlotWrapper> slotWrappers = new List<USF_SlotWrapper>();
        allCoachSlots.add(slots[0]);
        for(Counsellor_Availability__c coachSlot : allCoachSlots) {
            /*junctionTime = coachSlot.End_Time__c;
            if(coachSlot.Start_Time__c == junctionTime) {
               totalRowMinutes += coachSlot.Availability__r.Success_Center__r.AppointmentLength__c;
            }*/
            slotWrappers.add(new USF_SlotWrapper(coachSlot));
        }
        slotWrappers.sort();
        system.debug('slotWrappers: '+slotWrappers);
        
        for(USF_SlotWrapper coachSlot : slotWrappers) {
            
            if(coachSlot.startTime == junctionTime) {
               totalRowMinutes += coachSlot.appointmentLength;
               if(maxHoursRow != null) {
                  if(totalRowMinutes > (maxHoursRow * 60)) {
                    return 'Registration cannot be made since the coach is not available for consecutive sessions';
                }
               }
            }
            else if(coachSlot.startTime != junctionTime){
               totalRowMinutes = 0.0;
            }
            junctionTime = coachSlot.endTime;
            
        }
        return '';
  }

    private String applyPeerCenterRules(List<Contact> currentContacts, List<Account> accounts, Id contactID, Date selectedDate,String courseOfferingId,String context) {
        List<AppointmentContact__c> appts = new List<AppointmentContact__c>();
        String message = '';
        appts = [Select Id FROM AppointmentContact__c where Start_Date__c = : selectedDate
                       and Contact__c =:contactID 
                       and SelectedCourse__c =: courseOfferingId
                       and Status__c = 'Confirmed'
                       AND AppointmentSlot__r.Availability__r.Success_Center__r.Name = :learningCenterLabel];

           
            if(currentContacts[0].No_of_strikes_in_Peer_Center__c >= accounts[0].Student_Missed_Per_Center__c) {
                    //return System.Label.USF_Appointment_Strike_Policy+'<br/><br/>';
                    if(context == 'Consultant') {
                        message =message +System.Label.USF_Appointment_Strike_Policy+'<br/><br/>';
                    }
                    
            }
            
            if(context == 'Consultant') {
                    if(isLimitReached){
                        message=message+System.Label.USF_TutorSessionLimitMessage+'<br/><br/>';
                        isLimitReached=false;
                    }
            }
            
            if(appts.size() >= accounts[0].Frequencyperday__c) {
                //return System.Label.USF_Learning_Appointment_Frequency_Day_Restriction.replace('<frequencyInDays>',String.valueOf(accounts[0].Frequencyperday__c))+'<br/><br/>';
                //message=message+System.Label.USF_Learning_Appointment_Frequency_Day_Restriction.replace('<frequencyInDays>',String.valueOf(accounts[0].Frequencyperday__c))+'<br/><br/>';
                message = message + System.Label.USF_Appointment_Frequency_Restriction.replace('<frequency>',String.valueOf(accounts[0].Frequencyperday__c)).replace('<typeOfCenter>',App_Config__c.getInstance('Learning Center').Text_Value__c).replace('<interval>','days')+'<br/><br/>';
            }
            else {
                  /*List<AppointmentContact__c> weekAppts = new List<AppointmentContact__c>();                  
                        Integer currentWeek = Math.MOD(Math.FLOOR((date.parse('07/31/2016').daysBetween(selectedDate))/7).intValue(),52)+1;
                        weekAppts = [Select Id, Appointment_Week__c 
                                    FROM AppointmentContact__c 
                                    where Appointment_Week__c =: currentWeek
                                    AND Contact__c =: contactID
                                    AND Status__c in ('Pending','Confirmed')
                                    AND AppointmentSlot__r.Availability__r.Success_Center__r.Name LIKE '%Writing Center%'];*/
                                    
                    Date weekEndDate = selectedDate.addDays(6);
                    Date weekStartDate = selectedDate.addDays(-6);
                    List<AppointmentContact__c> futureAppts = [Select Id FROM AppointmentContact__c
                                                                Where Contact__c =: contactId
                                                                And Status__c = 'Confirmed'
                                                                And SelectedCourse__c =: courseOfferingId
                                                                And AppointmentSlot__r.Availability__r.Success_Center__r.Name = :learningCenterLabel
                                                                And Start_Date__c <=: weekEndDate AND Start_Date__c >: selectedDate];
                    List<AppointmentContact__c> pastAppts = [Select Id FROM AppointmentContact__c
                                                                Where Contact__c =: contactId
                                                                And Status__c = 'Confirmed'
                                                                And SelectedCourse__c =: courseOfferingId
                                                                And AppointmentSlot__r.Availability__r.Success_Center__r.Name = :learningCenterLabel
                                                                And Start_Date__c <: selectedDate AND Start_Date__c >=: weekStartDate];
                  
                  if((futureAppts.size() + 1) > accounts[0].Frequencyperweek__c || (pastAppts.size() + 1) > accounts[0].Frequencyperweek__c) {
                      //return System.Label.USF_Learning_Appointment_Frequency_Week_Restriction.replace('<frequencyPerWeek>',String.valueOf(accounts[0].Frequencyperweek__c))+'<br/><br/>' ;
                      //message=message+System.Label.USF_Learning_Appointment_Frequency_Week_Restriction.replace('<frequencyPerWeek>',String.valueOf(accounts[0].Frequencyperweek__c))+'<br/><br/>';
                      message = message + System.Label.USF_Appointment_Frequency_Restriction.replace('<frequency>',String.valueOf(accounts[0].Frequencyperweek__c)).replace('<typeOfCenter>',App_Config__c.getInstance('Learning Center').Text_Value__c).replace('<interval>','week')+'<br/><br/>';
                  }
            }
        if(String.isNotBlank(message))
            return message;
        else
        return '';
    }

    //Added by Manjunath for defect DFCT0011074-Start
    
    private static void validateTutoringRule(Id contactId,String selectedSlotId){
    
    List<Counsellor_Availability__c> selectedSlot=[SELECT id,Availability__r.Coach__c from Counsellor_Availability__c where id=:selectedSlotId];
    
    if(selectedSlot.size()>0){
   
        List<AppointmentContact__c> appts = new List<AppointmentContact__c>();
        
        appts = [Select Id FROM AppointmentContact__c 
                           WHERE Contact__c =:contactId
                           AND Status__c = 'Complete'
                           AND AppointmentSlot__r.Availability__r.Success_Center__r.Name =: App_Config__c.getInstance('Learning Center').Text_Value__c
                           AND AppointmentSlot__r.Availability__r.Coach__c=:selectedSlot[0].Availability__r.Coach__c
                           AND AppointmentSlot__r.Term__r.Active__c=true Limit 1000];
                           
        if(appts.size()>2)
        isLimitReached=true;
        else
        isLimitReached=false; 
        
        
     }   
    
    }
    
    //Added by Manjunath for defect DFCT0011074-End

    
    private String applySpeakingCenterRules(List<Contact> currentContacts,List<Account> accounts) {
        /*if(currentContacts[0].No_of_strikes_in_Speaking_Center__c >= accounts[0].Student_Missed_Per_Center__c) {
            //return System.Label.USF_Appointment_Strike_Policy;no strikes policy for speaking center -- Nishit 9/13/2016
        }*/
        return '';
    }

    private String applyWritingCenterRules(List<Contact> currentContacts, List<Account> accounts, Id contactID, Date selectedDate, String context) {
        List<AppointmentContact__c> appts = new List<AppointmentContact__c>();
        String message = '';
        appts = [Select Id,Appointment_Week__c FROM AppointmentContact__c where Start_Date__c = : selectedDate 
                        and Contact__c =: contactID 
                        and Status__c = 'Confirmed'
                        and AppointmentSlot__r.Availability__r.Success_Center__r.Name = :writingCenterLabel];
        system.debug('appts: '+appts);
        system.debug('accounts: '+accounts);
        if(currentContacts[0].No_of_strikes_in_Writing_Center__c >= accounts[0].Student_Missed_Per_Center__c) {
                    //return System.Label.USF_Appointment_Strike_Policy;
            if(context == 'Consultant') {
                message = message + System.Label.USF_Appointment_Strike_Policy+' <br/><br/>';
            }
            
        }
        if(appts.size() >= accounts[0].Frequencyperday__c) {
            //return System.Label.USF_Writing_Appointment_Frequency_Day_Restriction;
            message = message + System.Label.USF_Appointment_Frequency_Restriction.replace('<frequency>',String.valueOf(accounts[0].Frequencyperday__c)).replace('<typeOfCenter>',App_Config__c.getInstance('Writing Center').Text_Value__c).replace('<interval>','days')+'<br/><br/>';
        }
        else {
                    Date weekEndDate = selectedDate.addDays(6);
                    Date weekStartDate = selectedDate.addDays(-6);
                    List<AppointmentContact__c> futureAppts = [Select Id FROM AppointmentContact__c
                                                                Where Contact__c =: contactId
                                                                And Status__c = 'Confirmed'
                                                                And AppointmentSlot__r.Availability__r.Success_Center__r.Name = :writingCenterLabel
                                                                And Start_Date__c <=: weekEndDate AND Start_Date__c >: selectedDate];
                    List<AppointmentContact__c> pastAppts = [Select Id FROM AppointmentContact__c
                                                                Where Contact__c =: contactId
                                                                And Status__c = 'Confirmed'
                                                                And AppointmentSlot__r.Availability__r.Success_Center__r.Name = :writingCenterLabel
                                                                And Start_Date__c <: selectedDate AND Start_Date__c >=: weekStartDate];
                  
                  if((futureAppts.size() + 1) > accounts[0].Frequencyperweek__c || (pastAppts.size() + 1) > accounts[0].Frequencyperweek__c) {
                      //return System.Label.USF_Writing_Appointment_Frequency_Week_Restriction;
                      //message = message + System.Label.USF_Writing_Appointment_Frequency_Week_Restriction.replace('<frequencyInWeek>',String.valueOf(accounts[0].Frequencyperweek__c))+'<br/><br/>';
                      message = message + System.Label.USF_Appointment_Frequency_Restriction.replace('<frequency>',String.valueOf(accounts[0].Frequencyperweek__c)).replace('<typeOfCenter>',App_Config__c.getInstance('Writing Center').Text_Value__c).replace('<interval>','week')+'<br/><br/>';
                  }
        }
        if(String.isNotBlank(message))
            return message;
        else
        return '';
    }

    //added by suhan
    public static String validateCoachAvailabilityCon(Id selectedSlotId,Date selectedDate) {
        system.debug('mapsdatasrj'+mapslots);
        system.debug('selectedSlotId'+selectedSlotId);
      Counsellor_Availability__c slots =mapslots.get(selectedSlotId);
        Id coachId = slots.Availability__r.Coach__c;
        Decimal maxHoursWeek = slots.Availability__r.Coach__r.Max_hours_in_a_week__c;
        Decimal maxHoursRow = slots.Availability__r.Coach__r.Max_hours_in_a_row__c;
        Decimal currSlotTime = slots.Availability__r.Success_Center__r.AppointmentLength__c;
        Date weekEndDate = selectedDate.addDays(6);
        Date weekStartDate = selectedDate.addDays(-6);
        Decimal totalFutureMinutes = 0;
        Decimal totalPastMinutes = 0;
        if(slots.Noofstudentsregistered__c == 0) {
            List<Counsellor_Availability__c> futureSlots = [Select Id,Availability__r.Success_Center__r.AppointmentLength__c 
                                                                FROM Counsellor_Availability__c
                                                                Where Availability__r.Coach__c =: coachId
                                                                AND Id !=: selectedSlotId
                                                                And Noofstudentsregistered__c > 0
                                                                And StartDate__c <=: weekEndDate AND StartDate__c >: selectedDate];
            List<Counsellor_Availability__c> pastSlots = [Select Id,Availability__r.Success_Center__r.AppointmentLength__c 
                                                                FROM Counsellor_Availability__c
                                                                Where Availability__r.Coach__c =: coachId
                                                                AND Id !=: selectedSlotId
                                                                And Noofstudentsregistered__c > 0
                                                                And StartDate__c <: selectedDate AND StartDate__c >: weekStartDate];
            for(Counsellor_Availability__c futureSlot : futureSlots) {
                totalFutureMinutes += futureSlot.Availability__r.Success_Center__r.AppointmentLength__c;
            }
            for(Counsellor_Availability__c pastSlot : pastSlots) {
                totalPastMinutes += pastSlot.Availability__r.Success_Center__r.AppointmentLength__c;
            }
            if(maxHoursWeek != null && currSlotTime != null) {
                if((totalFutureMinutes + currSlotTime) > (maxHoursWeek * 60) || (totalPastMinutes + currSlotTime) > (maxHoursWeek * 60)) {
                  return 'Registration cannot be made since the coach is not available for the week';
                }
            }
            
        }
        

        List<Counsellor_Availability__c> allCoachSlots = [Select Id,Start_Time__c,End_Time__c,
                                                                Availability__r.Success_Center__r.AppointmentLength__c 
                                                                FROM Counsellor_Availability__c
                                                                Where Availability__r.Coach__c =: coachId
                                                                AND Id !=: selectedSlotId
                                                                And Noofstudentsregistered__c > 0
                                                                ORDER BY Start_Time__c asc];
        Boolean consecutive = false;
        DateTime junctionTime = null;
        Decimal totalRowMinutes = 0.0;
        List<USF_SlotWrapper> slotWrappers = new List<USF_SlotWrapper>();
        allCoachSlots.add(slots);
        for(Counsellor_Availability__c coachSlot : allCoachSlots) {
            /*junctionTime = coachSlot.End_Time__c;
            if(coachSlot.Start_Time__c == junctionTime) {
               totalRowMinutes += coachSlot.Availability__r.Success_Center__r.AppointmentLength__c;
            }*/
            slotWrappers.add(new USF_SlotWrapper(coachSlot));
        }
        slotWrappers.sort();
        system.debug('slotWrappers: '+slotWrappers);
        
        for(USF_SlotWrapper coachSlot : slotWrappers) {
            
            if(coachSlot.startTime == junctionTime) {
               totalRowMinutes += coachSlot.appointmentLength;
               if(maxHoursRow != null) {
                  if(totalRowMinutes > (maxHoursRow * 60)) {
                    return 'Registration cannot be made since the coach is not available for consecutive sessions';
                }
               }
            }
            else if(coachSlot.startTime != junctionTime){
               totalRowMinutes = 0.0;
            }
            junctionTime = coachSlot.endTime;
            
        }
        return '';
  }
  
  public static Map<Id,String> validateCoachAvailabilityCon(List<Counsellor_Availability__c> selectedSlots) {
    Counsellor_Availability__c slot;
    Map<Id,Decimal> futureSlotsPerCoach = new Map<Id,Decimal>();
    Map<Id,Decimal> pastSlotsPerCoach = new Map<Id,Decimal>();
    Map<Id,String> coachMap = new Map<Id,String>();
    Map<Id,List<Counsellor_Availability__c>> slotsPerCoach = new Map<Id,List<Counsellor_Availability__c>>();
    Set<Id> coaches = new Set<Id>();
    for(Counsellor_Availability__c selectedSlot : selectedSlots) {
        slot = mapslots.get(selectedSlot.Id);
        Id coachId = slot.Availability__r.Coach__c;
        Date selectedDate = slot.Start_Time__c.date();
        Decimal maxHoursWeek = slot.Availability__r.Coach__r.Max_hours_in_a_week__c;
        Decimal maxHoursRow = slot.Availability__r.Coach__r.Max_hours_in_a_row__c;
        Decimal currSlotTime = slot.Availability__r.Success_Center__r.AppointmentLength__c;
        Date weekEndDate = selectedDate.addDays(6);
        Date weekStartDate = selectedDate.addDays(-6);
        Decimal totalFutureMinutes = 0;
        Decimal totalPastMinutes = 0;
        if(slot.Noofstudentsregistered__c > 0) {
            if(slot.StartDate__c <= weekEndDate && slot.StartDate__c > selectedDate) {
                if(!futureSlotsPerCoach.containsKey(coachId)) {
                    futureSlotsPerCoach.put(coachId,0);
                }   
                totalFutureMinutes=futureSlotsPerCoach.get(coachId)+currSlotTime;
                futureSlotsPerCoach.put(coachId,totalFutureMinutes);
            }
            else if(slot.StartDate__c < selectedDate && slot.StartDate__c > weekStartDate) {
                if(!pastSlotsPerCoach.containsKey(coachId)) {
                    pastSlotsPerCoach.put(coachId,0);
                }
                totalPastMinutes=pastSlotsPerCoach.get(coachId)+currSlotTime;
                pastSlotsPerCoach.put(coachId,totalPastMinutes);
            }
            if(!slotsPerCoach.containsKey(coachId)) {
                slotsPerCoach.put(coachId,new List<Counsellor_Availability__c>());
            }
            slotsPerCoach.get(coachId).add(slot);
        }
        totalFutureMinutes = futureSlotsPerCoach.get(coachId);
        totalPastMinutes = pastSlotsPerCoach.get(coachId);
        if(totalFutureMinutes != null && totalPastMinutes != null) {
            if((totalFutureMinutes + currSlotTime) > (maxHoursWeek * 60) || (totalPastMinutes + currSlotTime) > (maxHoursWeek * 60)) {
              coachMap.put(slot.Id,'Registration cannot be made since the coach is not available for the week');
            }
        }
        DateTime junctionTime = null;
        Decimal totalRowMinutes = 0.0;
        List<USF_SlotWrapper> slotWrappers = new List<USF_SlotWrapper>();
        for(List<Counsellor_Availability__c> slotListPerCoach : slotsPerCoach.values()) {
            for(Counsellor_Availability__c coachSlot : slotListPerCoach) {
                slotWrappers.add(new USF_SlotWrapper(coachSlot));
            }
        }
        slotWrappers.sort();
        for(USF_SlotWrapper coachSlot : slotWrappers) {
            if(coachSlot.startTime == junctionTime) {
               totalRowMinutes += coachSlot.appointmentLength;
               if(maxHoursRow != null) {
                  if(totalRowMinutes > (maxHoursRow * 60)) {
                    coachMap.put(coachSlot.sl.Id,'Registration cannot be made since the coach is not available for consecutive sessions');
                }
               }
            }
            else if(coachSlot.startTime != junctionTime){
               totalRowMinutes = 0.0;
            }
            junctionTime = coachSlot.endTime;
        }
        if(coachMap.get(selectedSlot.Id) != '') {
            coachMap.put(selectedSlot.Id,'');
        }
    }
    return coachMap;
}
    
}