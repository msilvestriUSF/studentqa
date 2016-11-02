/******************************************************************************************************************************************
Apex Class Name: USF_AppointmentSchedulerUtil
Version        : 1.0
Created Date   : 5 AUG 2016
Function       : Utility methods to move complex functionallity out of USF_AppointmentSchedulerController in the interest of keeping that lightweight
                    and in line with good coding practices
Modification Log : modified the code at line no 27, 31, 39-42 as part of the Interview enhancements
_____________________________________________________________________________________________________________________________________________
* Developer                         Date                            Description
*---------------------------------------------------------------------------------------------------------------------------------------------
* Ritam Mukherjee                   08/04/2016                      Original version
* Ritam Mukherjee                   08/05/2016                      Tested that page is working using this class instead of code in page
                                                        Note this also standardizes query for caList where date was being compared twice
                                                        56 67 188

**********************************************************************************************************************************************/
public without sharing class USF_AppointmentSchedulerUtil {
    /* Method name : CreateCAList
     * Description : Creates and returns a list of Counselor Availability objects
     * Return Type : List<Counselor_Availability__c>
     * Paramater   : Id, Date, Date
     */
    public static List<Counsellor_Availability__c> fetchSlots(String department,Date d,String courseOfferingId,String center,String specialty,String meetingLocation){    
        //center += ' Center';

        system.debug('Center::: '+center);
        system.debug('Specialty::: '+specialty);
        List<Counsellor_Availability__c> caList = new List<Counsellor_Availability__c>();
        List<Counsellor_Availability__c> caList1 = new List<Counsellor_Availability__c>();
        List<Counsellor_Availability__c> specialtySlots = new List<Counsellor_Availability__c>();
        List<Counsellor_Availability__c> caList2 = new List<Counsellor_Availability__c>();
        List<Event> eventTimes = new List<Event>();
        List<Account> accounts = new List<Account>();
        List<Account> casaAccounts = new List<Account>();
        String learningCenterName = System.Label.LWC_Learning_Center_Name;
        String writingCenterName = System.Label.LWC_Writing_Center_Name;
        String speakingCenterName = System.Label.LWC_Speaking_Center_Name;
        String casaCenterName = System.Label.CASA_Center_Name;
        String selectedCenter = '';
        system.debug('speakingCenterName: '+speakingCenterName);
        List<Contact> contactsList = new List<Contact>();
        if(center == 'Learning') {
            accounts = [Select Name,LeadTime__c,BusinessHour__c,Student_Missed_Per_Center__c,Frequencyperday__c,Frequencyperweek__c,AppointmentLength__c 
                                  from Account 
                                  where Name =: learningCenterName];
            selectedCenter = learningCenterName;
        }
        else if(center == 'Writing') {
           accounts = [Select Name,LeadTime__c,BusinessHour__c,Student_Missed_Per_Center__c,Frequencyperday__c,Frequencyperweek__c,AppointmentLength__c 
                                  from Account 
                                  where Name =: writingCenterName];
          selectedCenter = writingCenterName;
        }
        else if(center == 'Speaking') {
           accounts = [Select Name,LeadTime__c,BusinessHour__c,Student_Missed_Per_Center__c,Frequencyperday__c,Frequencyperweek__c,AppointmentLength__c 
                                  from Account 
                                  where Name =: speakingCenterName];
           selectedCenter = speakingCenterName;
        }
        else {
            casaAccounts = [Select Name,BusinessHour__c,Appointments_visible_for_number_of_days__c,LeadTime__c,Student_Missed_Per_Center__c,Frequencyperday__c,Frequencyperweek__c,AppointmentLength__c 
                                  from Account 
                                  where Name =: casaCenterName];
        }
         
        system.debug('accounts::::: '+accounts);
        Id currentUserId = UserInfo.getUserId();
        system.debug('userId: '+currentUserId);
        List<User> users = [Select Id,ContactId FROM User where Id =: currentUserId];
        if(users.size() > 0) {
            contactsList = [Select Id, AcademicSuccessCoach__c, AcademicSuccessCoach__r.FirstName, AcademicSuccessCoach__r.LastName 
                             FROM Contact 
                             where Id =: users[0].ContactId];
            
        }
        //system.debug('contactsList: '+contactsList[0].AcademicSuccessCoach__r.FirstName+contactsList[0].AcademicSuccessCoach__r.LastName);
        Long timeNow = DateTime.now().getTime();
        if(department == 'CASA' || (department == 'LWC' && (courseOfferingId == null || courseOfferingId == '--None--') && center != 'Learning')) {
            List<AppointmentContact__c> appts = new List<AppointmentContact__c>();
            List<AppointmentContact__c> weekAppts = new List<AppointmentContact__c>();
            Map<Id,Id> coachUserIdMap = new Map<Id,Id>();
            Set<Id> filteredCoachIds = new Set<Id>();
            if(department == 'CASA') {
                if(d <= System.today().addDays(Integer.valueOf(casaAccounts[0].Appointments_visible_for_number_of_days__c)) && contactsList.size() > 0) {
                  caList1 = [SELECT Id,Location__c,Event_Conflict__c,CreatedDate,Capacity__c, CapacityReached__c,Coach_First_Name__c,Coach_Last_Name__c,
                                Start_Time__c,End_Time__c,AppointmentType__c,Availability__r.Coach__c,
                                Availability__r.Coach__r.ContactId,
                                Availability__r.Success_Center__r.Name,
                                (Select Id,StartDateTime,EndDateTime FROM Events)
                                FROM Counsellor_Availability__c
                                WHERE RecordType.Name = 'CASA Slot'
                                AND Availability__r.Coach__c =: contactsList[0].AcademicSuccessCoach__c
                                AND Status__c = 'Open'
                                AND Start_Time__c >=: System.now()
                                AND DAY_Only(convertTimezone(Start_Time__c)) = :d AND
                                CapacityReached__c = false order by Start_Time__c asc];
                                system.debug('CoachID: '+contactsList[0].AcademicSuccessCoach__c);
                  //List<Event> eventTimes1 = [Select Id, OwnerId,StartDateTime, EndDateTime FROM Event];
                  //System.debug('eventTimes: '+eventTimes1);
                  /*for(Counsellor_Availability__c sl : caList1) {
                    system.debug('Events: '+sl.Events.size());
                    if(sl.Events.size() > 0) {
                      eventTimes.add(sl.Events[0]);  
                    }
                  }*/

                }
            }
            else if(department == 'LWC') {

              caList1 = [SELECT Id,Location__c,Event_Conflict__c,CreatedDate,Capacity__c, CapacityReached__c,Coach_First_Name__c,Coach_Last_Name__c,
                                                          Start_Time__c,End_Time__c,AppointmentType__c,Availability__r.Coach__c,
                                                          Availability__r.Coach__r.ContactId,
                                                          Availability__r.Success_Center__r.Name
                                                   FROM Counsellor_Availability__c
                                                   WHERE Availability__r.Success_Center__r.Name =: selectedCenter
                                                   AND Status__c = 'Open'
                                                   AND Start_Time__c >=: System.now()
                                                   AND Availability__r.Meeting_Location__c INCLUDES (:meetingLocation)
                                                   AND (Selected_Meeting_Location__c = null OR Selected_Meeting_Location__c =: meetingLocation)
                                                   AND   DAY_Only(convertTimezone(Start_Time__c)) = :d AND
                                                         CapacityReached__c = false order by Start_Time__c asc];
                          system.debug('caList1LWC: '+caList1);
            }

              
                                                         
                      /*for(Counsellor_Availability__c slot : caList1) {
                          //coachContactIds.add(slot.Availability__r.Coach__r.ContactId);
                          coachUserIdMap.put(slot.Availability__r.Coach__r.ContactId,slot.Availability__r.Coach__c);
                      }

                      List<Contact> filteredContactIds = [Select Id,Specialty__c FROM Contact 
                                                          where Id in : coachUserIdMap.values() 
                                                          and Specialty__c 
                                                          INCLUDES (:specialty)];
                      for(Contact filteredContactId : filteredContactIds) {
                         filteredCoachIds.add(coachUserIdMap.get(filteredContactId.Id));
                      }

                      system.debug('caList1::: '+caList1);
                      for(Counsellor_Availability__c cAvail : caList1) {
                        if(filteredCoachIds.contains(cAvail.Availability__r.Coach__c)) {
                          specialtySlots.add(cAvail);
                        }
                      }*/
                      List<Faculty_Specialty__c> facSpecs = new List<Faculty_Specialty__c>();
                      if(specialty == 'No Preference') {
                        facSpecs = [Select Id,Consultant__c,Specialty__c 
                                       FROM Faculty_Specialty__c];
                      }
                      else {
                        facSpecs = [Select Id,Consultant__c,Specialty__c 
                                       FROM Faculty_Specialty__c where Specialty__c =: specialty];
                      }
                      
                      Set<Id> consultantIds = new Set<Id>();
                      for(Faculty_Specialty__c fs : facSpecs) {
                          consultantIds.add(fs.Consultant__c);
                      }
                      for(Counsellor_Availability__c ca : caList1) {
                          Long milliseconds = ca.Start_Time__c.getTime() - timeNow;
                          
                          
                          if(accounts.size() > 0) {
                              if(milliseconds/(1000 * 60) > (accounts[0].LeadTime__c * 60)) {
                                  if(ca.CapacityReached__c == false) {
                                      if(center == 'Writing' && specialty != 'No Preference') {
                                        if(consultantIds.contains(ca.Availability__r.Coach__c)) {
                                              if(BusinessHours.iswithin(accounts[0].BusinessHour__c,ca.Start_Time__c) && BusinessHours.iswithin(accounts[0].BusinessHour__c,ca.End_Time__c)) {
                                                    caList.add(ca);
                                              }
                                              
                                        }
                                      }
                                      else {
                                        if(BusinessHours.iswithin(accounts[0].BusinessHour__c,ca.Start_Time__c) && BusinessHours.iswithin(accounts[0].BusinessHour__c,ca.End_Time__c)) {
                                              caList.add(ca);
                                        }
                                       
                                      }
                                  }
                              }
                          }
                          else {
                              if(ca.CapacityReached__c == false) {
                                
                                //system.debug('cap: '+ca.Coach_First_Name__c + ' '+ca.Coach_Last_Name__c);
                                Boolean conflict = false;
                                if(department == 'CASA' && contactsList.size() > 0) {
                                  /*for(Event e : eventTimes) {
                                    if((ca.Start_Time__c >= e.StartDateTime && ca.Start_Time__c <= e.EndDateTime) 
                                      || (ca.End_Time__c >= e.StartDateTime && ca.End_Time__c <= e.EndDateTime)) {
                                      system.debug('Slot: '+ca.Id+' conflicts with the event: '+e.Id);
                                      conflict = true;
                                    }
                                  }*/
                                  /*if(conflict == false) {
                                    caList.add(ca);
                                  }*/
                                  if(ca.Event_Conflict__c == false){
                                    system.debug('Time: '+casaAccounts[0].BusinessHour__c);
                                    system.debug('isWithin: '+BusinessHours.iswithin(casaAccounts[0].BusinessHour__c,ca.Start_Time__c));
                                      if(BusinessHours.iswithin(casaAccounts[0].BusinessHour__c,ca.Start_Time__c) && BusinessHours.iswithin(casaAccounts[0].BusinessHour__c,ca.End_Time__c)){
                                        caList.add(ca);
                                      }
                                      
                                  }

                                }
                                system.debug('caList:::: '+caList);
                              }
                          }
                      }
                    }
            

        
        if(department == 'LWC' && courseOfferingId != '--None--' && center == 'Learning') {
            List<Appointment_Course__c> apptCourses = [Select Id,Availability_Definition__c,
                                                      Eligible_Tutor_Courses__r.Course_Offering__c 
                                                      FROM Appointment_Course__c
                                                      WHERE Eligible_Tutor_Courses__r.Course_Offering__c 
                                                      =: courseOfferingId 
                                                      AND Availability_Definition__r.Success_Center__r.Name =: selectedCenter];
            Set<Id> availDefnIds = new Set<Id>();
            for(Appointment_Course__c appCrs : apptCourses) {
                availDefnIds.add(appCrs.Availability_Definition__c);
            }
            /*List<AppointmentContact__c> appts = new List<AppointmentContact__c>();
            if(users.size() > 0) {
              appts = [Select Id FROM AppointmentContact__c where Start_Date__c = : d 
                       and Contact__c =: users[0].ContactId 
                       and SelectedCourse__c =: courseOfferingId
                       and Status__c = 'Confirmed'
                       AND AppointmentSlot__r.Availability__r.Success_Center__r.Name LIKE '%Peer Center%'];

            }
            
            if(appts.size() > accounts[0].Frequencyperday__c - 1) {
                return null;
            }
            else {
                  List<AppointmentContact__c> weekAppts = new List<AppointmentContact__c>();                  
                        Integer currentWeek = Math.MOD(Math.FLOOR((date.parse('07/31/2016').daysBetween(d))/7).intValue(),52)+1;
                        
                        weekAppts = [Select Id, Appointment_Week__c 
                                    FROM AppointmentContact__c 
                                    where Appointment_Week__c =: currentWeek
                                    AND Contact__c =: users[0].ContactId
                                    AND Status__c in ('Pending','Confirmed')
                                    AND AppointmentSlot__r.Availability__r.Success_Center__r.Name LIKE '%Writing Center%'];
                  
                  
                  if(weekAppts.size() > accounts[0].Frequencyperweek__c - 1) {
                      return null;
                  }*/
                  if(meetingLocation != null && meetingLocation == 'Online') {
                     caList2 = [Select Id,Location__c,Capacity__c, CapacityReached__c,Coach_First_Name__c,Coach_Last_Name__c,
                                Start_Time__c,End_Time__c,AppointmentType__c,
                                Availability__r.Success_Center__r.Name
                                FROM Counsellor_Availability__c
                                WHERE  Availability__c in : availDefnIds AND Status__c = 'Open' 
                                AND Start_Time__c >=: System.now() AND
                                DAY_Only(convertTimezone(Start_Time__c)) = :d AND
                                (Selected_Meeting_Location__c = null OR Selected_Meeting_Location__c =: meetingLocation) AND
                                (Selected_Course__c = null OR Selected_Course__c =: courseOfferingId) AND
                                CapacityReached__c = false order by Start_Time__c asc];
                  }
                  else if(meetingLocation != null && meetingLocation == 'In Person') {
                      caList2 = [Select Id,Location__c,Capacity__c, CapacityReached__c,Coach_First_Name__c,Coach_Last_Name__c,
                                Start_Time__c,End_Time__c,AppointmentType__c,
                                Availability__r.Success_Center__r.Name
                                FROM Counsellor_Availability__c
                                WHERE  Availability__c in : availDefnIds AND Status__c = 'Open' AND 
                                Start_Time__c >=: System.now() AND 
                                DAY_Only(convertTimezone(Start_Time__c)) = :d AND
                                Availability__r.Meeting_Location__c INCLUDES (:meetingLocation)
                                AND (Selected_Meeting_Location__c = null OR Selected_Meeting_Location__c =: meetingLocation) AND
                                (Selected_Course__c = null OR Selected_Course__c =: courseOfferingId) AND
                                CapacityReached__c = false order by Start_Time__c asc];
                  }
                  
                  for(Counsellor_Availability__c ca : caList2) {
                      Long milliseconds = ca.Start_Time__c.getTime() - timeNow;
                      if(accounts.size() > 0) {
                          if(milliseconds/3600000 > accounts[0].LeadTime__c) {
                              if(ca.CapacityReached__c == false) {
                                if(BusinessHours.iswithin(accounts[0].BusinessHour__c,ca.Start_Time__c) && BusinessHours.iswithin(accounts[0].BusinessHour__c,ca.End_Time__c)){
                                      String result = USF_CenterRulesUtil.validateCoachAvailability(ca.Id,d);
                                      if(result == ''){
                                        caList.add(ca);
                                      }
                                      
                                }
                                
                              }
                          }
                      }
                      else {
                          if(ca.CapacityReached__c == false) {
                             caList.add(ca);
                          }
                      }
                  } 
            //}
                                                    

        }
           system.debug('caListFinal: '+caList);                                     
        return caList;
        }
        }