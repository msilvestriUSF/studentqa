public without sharing class USF_AppointmentSchedulerController {
/******************************************************************************************************************************************
Apex Class Name: USF_AppointmentSchedulerController
Version        : 1.0
Created Date   : 
Function       : 
Modification Date: 
Modification Log :  
_____________________________________________________________________________________________________________________________________________
* Developer                         Date                            Description
*---------------------------------------------------------------------------------------------------------------------------------------------
* R. Mukherjee                 08/02/2016                      Original version
* OTHER DEVS PLEASE ADD DETAILS HERE FOR IN BETWEEN DATES
* R. Mukherjee                 05/25/2016                      Added writing of CaToBook field to the Event
* R. Mukherjee                 05/27/2016                      Moved some functions to other files cleaned up formatting
TODO: Suggest removing debug code lines if no longer needed   187
**********************************************************************************************************************************************/
     public String tsbId {get;set;} //this holds the Application Timeslot Booked ID it is populated by the constructor from the URL param ?tsbId=
     public String result {get; set;}   //this is returned by the final booking function, it either notes success or failure 
     public List<Counsellor_Availability__c> caList {get; set;}  //holds the list of time slots for the day selected as Counselor Availability records  
     public Counselor_Availability_Definition__c atb {get ; set; } 
     public Id tdId; //id of the timeslot defanition associated with the Timeslot Booked
     public Date d {get; set;}
     public String courseOfferingId {get; set;}
     public String coachspecialty {get;set;} 
     public String dSelected {get; set;}
     public String appType {get;set;}
     public String ErrorMsgURL {get ; set;}
     public String firstLanguageValue {get ; set;}
     public String welcomeMessage {get;set;}
   
     public contact c {get;set;}
     public Boolean bool {get; set;}
     public String programApplying {get; set;}
     public WrapperClass wrappercls{ get; set; }
     public List<WrapperClass> wrapperList {get;set;}
     public String emptySlotsMessg {get;set;}
     public String validationError {get;set;}
     public String strikeValidationError {get;set;}
     public String leaveValidationError {get;set;}
     public String maxCASAApptError {get;set;}
     public String specialty {get;set;}
    
     public String emailToVerify {get; set;} //this is the email that the interviewee enters when setting an appointment
     public String skypeId{get;set;}
     public String fullName{get;set;}
     public String loggedInUserName{get;set;}
     public String additionalComments{get;set;}
     public String referrerpick{get;set;}
     public String referrername{get;set;}
     public Id caSelectedId {get; set;} //the Id of the timeslot they select from the list caList
     public String slotElementId {get;set;}
     public String caSelectedType {get;set;}
     public  List<Timeslot_Definition__c> timeSlotDefintionList {get ; set;}
     public static String appSlotBookId {get; set;} 
     public Date todayDate {get ;set;} // added
     public String todayDateShow {get ;set;}
     public map<String,List<Counsellor_Availability__c>> timslotMap = new map<String,List<Counsellor_Availability__c>>(); // keerti
     public Attachment attachment { 
        get {
          if (attachment == null)
            attachment = new Attachment();
          return attachment;
        }
        set;}
     public static string verifyContLeadEmail;
     public string eventAvail {get;set;}
     public String programInterviewing;
     public boolean isPermissionAssgined {get;set;}
    
    //Added by R. Mukherhee : 08/05/2016
    public String department {get;set;}
    public String depart{get;set;}
    public String course {get;set;}
    public String center{get; set;}
    public String meetingLocation {get;set;}
    public String firstLanguage{get;set;}
    public String groupAssignment{get;set;}
    
    //added  by suhan jain for first appointment starts here
    public string strGrade{get;set;}
    public string strHowKnow{get;set;}
    public string strMeetCon{get;set;}
    public string strHstudy{get;set;}
    public string strPrepare{get;set;}
    public string strPerformance{get;set;}
    public string strLearningStyl{get;set;}
    public string strAskils{get;set;}
    public string strTutorAssist{get;set;}
    
    public boolean boolNext{get;set;}
    public boolean boolNextTerm{get;set;}
    // first appointment form variables ends here
    
    public List<SelectOption> departmentLst {get;set;}
    public List<SelectOption> centerList {get;set;}
    public List<SelectOption> courseList {get;set;}
    public List<SelectOption> filteredCourseLst {get;set;}
    public List<SelectOption> specialtyLst {get;set;}
    public List<SelectOption> meetingLocationLst {get;set;}
    public List<SelectOption> firstLanguageList {get;set;}
    public List<SelectOption> groupAssignmentList {get;set;}

    public AppointmentContact__c appConRec {get; set;}
    public String appConRecId {get;set;}
    
    //Added by Vandana - To notify staff
    public String selectedFaculty{get;set;}
    public String selectedFacultyId{get;set;}
    public String allContactIds{get;set;}
    public List<Contact> allContacts{get;set;}
    public String contactToBeRemoved{get;set;}
    
    //Added by Vandana - DFCT0011016
    public String InsertFailedErrorMsg{get;set;}
    
    // Reason for Meeting multiselect picklist to checkbox conversion
    Public String[] reasons = new String[]{};
    
    public String[] getreasons() {
        return reasons;
    }

    public void setreasons(String[] reasons) {
        this.reasons = reasons;
    }
    
    public List<SelectOption> getReasonforPicklist()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =
     AppointmentContact__c.Reason_for_Meeting__c.getDescribe();
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    
    
    // Counstuctor used for querying the current date counselor availability slots.
    public USF_AppointmentSchedulerController() {
            
            boolNext= False; 
            boolNextTerm = False;
            firstLanguage = 'Yes';
            groupAssignment ='No';
            welcomeMessage = '';
            //added by suhan for first appointment
            isPermissionAssgined=USF_PermissionSetAssignmentUtli.getPermissionSetFlag();
            system.debug('Logged in User Name constructor '+ Userinfo.getFirstName());
            todayDate = Date.Today();                   
            //R. Mukherjee  : populate dynamic list
            departmentLst = new List<SelectOption>();
            departmentLst.add(new SelectOption('CASA','CASA'));
            departmentLst.add(new SelectOption('LWC','LWC'));
            
            centerList = new List<SelectOption>();
            centerList.add(new SelectOption('--None--','--None--'));
            centerList.add(new SelectOption('Learning','Learning'));
            centerList.add(new SelectOption('Writing','Writing'));
            centerList.add(new SelectOption('Speaking','Speaking'));
  
            filteredCourseLst = new List<SelectOption>();
            filteredCourseLst.add(new SelectOption('--None--','--None--'));
            specialtyLst = new List<SelectOption>();
            //specialtyLst.add(new SelectOption('--None--','--None--'));
            meetingLocationLst = new List<SelectOption>();
            /*meetingLocationLst.add(new SelectOption('In Person','In Person'));
            meetingLocationLst.add(new SelectOption('Online','Online'));
            meetingLocationLst.add(new SelectOption('Phone','Phone'));*/
            
            firstLanguageList = new List<SelectOption>();
            firstLanguageList.add(new SelectOption('Yes','Yes'));
            firstLanguageList.add(new SelectOption('No','No'));
            groupAssignmentList = new List<SelectOption>();
            groupAssignmentList.add(new SelectOption('No','No'));
            groupAssignmentList.add(new SelectOption('Yes','Yes'));
            groupAssignment = 'No';
            appConRecId = NULL;            
            depart = 'CASA';
            center = NULL;
            course = NULL;
            courseOfferingId = null;
            firstLanguageValue = null;
            coachspecialty = null;
            specialty = 'No Preference';
            meetingLocation = 'In Person';
            validationError = '';
            strikeValidationError = '';
            leaveValidationError = '';
            maxCASAApptError = '';
            loggedInUserName = UserInfo.getName();
            DateTime tdDt = todayDate;
            todayDateShow = tdDt.formatGMT('EEEEE MMMM d, YYYY');
            
            system.debug('caList in constructor' + caList);
            if(caList!= null) {
               system.debug(LoggingLevel.Error,'today date'+todayDateShow);
               wrapperCAList(caList);
            } else{
               result = 'No appointment available today' ;
               emptySlotsMessg = System.Label.Interview_Error_Empty_Slots_Messg;
            } 
            //Added by Vandana - To notify staff
            selectedFaculty = '';
            selectedFacultyId = '';
            allContactIds = '';
            allContacts = new List<Contact>();
            contactToBeRemoved = '';
            
            //Added By Vandana - DFCT0011016
            InsertFailedErrorMsg = '';
      }
    
    
      
   // Wrapper class created for storing the time slots in AM/ PM format
    private void wrapperCAList(List<Counsellor_Availability__c> caWrapperList){
     try{   
        String scheduledAppointmentLabel = App_Config__c.getInstance('Scheduled Appointment').Text_Value__c;
        String dropInAppointmentLabel = App_Config__c.getInstance('Dropin Appointment').Text_Value__c;
        String slotId ;
        wrapperList = new List<WrapperClass>();
        wrappercls = new WrapperClass();
        if(caWrapperList!= null && caWrapperList.size() != 0 ){
            for(Counsellor_Availability__c ca : caWrapperList) {  
                slotId = ca.Start_Time__c.format('h:mm a')+ca.End_Time__c.format('h:mm a');
                if(timslotMap.containsKey(slotId)){
                    timslotMap.get(slotId).add(ca);
                }else {
                    timslotMap.put(slotId, new List<Counsellor_Availability__c> { ca });
                }
            }
            
            if(timslotMap.values()!= null && !timslotMap.isEmpty()) {
                emptySlotsMessg='';
                for(String recid : timslotMap.keySet()){
                    system.debug(LoggingLevel.Error,'Key'+recid);
                    Boolean alreadyExist = false;
                    for(Counsellor_Availability__c cstAvail : timslotMap.get(recid)) {
                        if(!alreadyExist){
                            wrappercls = new WrapperClass();
                            wrappercls.startdate = cstAvail.Start_Time__c.format('h:mm a');
                            wrappercls.enddate = cstAvail.End_Time__c.format('h:mm a');
                            wrappercls.custName = cstAvail.Coach_First_Name__c+'  ' +cstAvail.Coach_Last_Name__c;
                            wrappercls.custAvailid = cstAvail.id;
                            wrappercls.capacity = cstAvail.Capacity__c;
                            wrappercls.location = cstAvail.Location__c;
                            //Added by Manjunath for defect DFCT0011076-Start
                            wrappercls.typeofAppoitment=cstAvail.AppointmentType__c;
                            //Added by Manjunath for defect DFCT0011076-End
                            
                            if(String.isNotBlank(cstAvail.AppointmentType__c) && cstAvail.AppointmentType__c.equalsIgnoreCase(dropInAppointmentLabel)) {
                                wrappercls.disabled = false;
                            }
                            else if(String.isBlank(cstAvail.AppointmentType__c) || (String.isNotBlank(cstAvail.AppointmentType__c) && cstAvail.AppointmentType__c.equalsIgnoreCase(scheduledAppointmentLabel))){
                                wrappercls.disabled = true;
                            }
                            wrapperList.add(wrappercls);
                            alreadyExist = true;
                        } 
                    }
                }
                timslotMap.clear();
            }
        }else{
            emptySlotsMessg = System.Label.Interview_Error_Empty_Slots_Messg;
            todayDateShow = '';  
            if(wrapperList!= null && wrapperList.size() != 0){
                wrapperList.clear();
            }
        }
        }
         catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
           } 
    }
    
    public void userClickControl(){
        if(depart == 'CASA'){
            center = '--None--';
            course = '--None--';
        }else {
          center = '--None--';
        }
    } 

    public void setCoursesOnClick() {
    try{ 
        allContacts = new List<Contact>();
        strikeValidationError = USF_CenterRulesUtil.validateStrikes(center);
        welcomeMessage = '';
        if(center == 'Learning') { // filter to be added after clarification 
           List<Account> accounts = [Select Welcome_Message__c FROM Account where Name = 'Learning Center'];
           system.debug('accLearning: '+accounts);
           if(accounts.size() > 0) {
                welcomeMessage = accounts[0].Welcome_Message__c;
                system.debug('welcomeMessage: '+welcomeMessage);
           }
           List<hed__Course_Enrollment__c> courseEnrollments = new List<hed__Course_Enrollment__c>(); 
           List<User> currentUsers = [Select Id,ContactId FROM User where Id =: UserInfo.getUserId()];
           if(currentUsers.size() > 0) {
              courseEnrollments = [Select Id,hed__Course_Offering__c,hed__Course_Offering__r.hed__Course__r.Name
                                                                FROM hed__Course_Enrollment__c 
                                                                where hed__Course_Offering__r.Active__c = true 
                                                                and Active__c = true
                                                                and hed__Contact__c =: currentUsers[0].ContactId];
              system.debug('courseEnrollments: '+courseEnrollments.size());                                                  
           }
          filteredCourseLst = new List<SelectOption>();
          filteredCourseLst.add(new SelectOption('--None--','--None--'));
          for(hed__Course_Enrollment__c crseEnrollement : courseEnrollments) {
            filteredCourseLst.add(new SelectOption(crseEnrollement.hed__Course_Offering__c,crseEnrollement.hed__Course_Offering__r.hed__Course__r.Name));
          } 
            meetingLocationLst = new List<SelectOption>();
            meetingLocationLst.add(new SelectOption('In Person','In Person'));
            meetingLocationLst.add(new SelectOption('Online','Online'));
            
        }
        else {
          filteredCourseLst = new List<SelectOption>();
          filteredCourseLst.add(new SelectOption('--None--','--None--'));
          if(center == 'Writing') {
            List<Account> accounts = [Select Welcome_Message__c FROM Account where Name = 'Writing Center'];
           system.debug('accLearning: '+accounts);
           if(accounts.size() > 0) {
                welcomeMessage = accounts[0].Welcome_Message__c;
                system.debug('welcomeMessage: '+welcomeMessage);
           }
            specialtyLst = new List<SelectOption>();
            specialtyLst.add(new SelectOption('No Preference','No Preference'));
            List<Specialty__c> specialties = [Select Id,Name FROM Specialty__c  order by Name asc];
            /*KeyValueStore__c kvStore = KeyValueStore__c.getOrgDefaults();
            system.debug('kvStore: '+kvStore);
            String[] specialtyValues = kvStore.Default_Values__c.split(';');*/
            for(Specialty__c specialty : specialties) {
              specialtyLst.add(new SelectOption(specialty.Id,specialty.Name));
            }
            meetingLocationLst = new List<SelectOption>();
            meetingLocationLst.add(new SelectOption('In Person','In Person'));
            meetingLocationLst.add(new SelectOption('Online','Online'));
            meetingLocationLst.add(new SelectOption('Phone','Phone'));      
          }
          if(center == 'Speaking') {
            List<Account> accounts = [Select Welcome_Message__c FROM Account where Name = 'Speaking Center'];
           system.debug('accLearning: '+accounts);
           if(accounts.size() > 0) {
                welcomeMessage = accounts[0].Welcome_Message__c;
                system.debug('welcomeMessage: '+welcomeMessage);
           }
            meetingLocationLst = new List<SelectOption>();
            meetingLocationLst.add(new SelectOption('In Person','In Person'));
          }
        }
      }
     catch(Exception ex){
                // Display the error message
                system.debug('ex.getMessage(): '+ex.getMessage());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
     }   
    }
    
    //this returns a list of records for an individual date 
    public void getTodaysCA() {
     system.debug('todaysCA: '+leaveValidationError);
      emptySlotsMessg='';
      if((center != '--None--' && center != '' && center != null && strikeValidationError == '') || depart == 'CASA') {
            if(d > =  todayDate ){
                system.debug('check111: '+depart +'d: '+ d + 'coId: '+courseOfferingId + 'cen: '+center+'sp: '+specialty + 'mL: '+meetingLocation);
                if(depart == 'CASA') {
                    maxCASAApptError = verifyStudentCASAMaxAppt();
                    if(maxCASAApptError == '') {
                        leaveValidationError = verifyCoachLeave();
                        if(leaveValidationError == '') {
                            caList = USF_AppointmentSchedulerUtil.fetchSlots(depart, d,courseOfferingId,center,specialty,meetingLocation);
                            wrapperCAList(caList);
                        }
                        else {
                                emptySlotsMessg = 'No slots available for this date, the coach is on leave.';
                        }
                    }
                    else {
                        emptySlotsMessg = 'No slots available for this date';
                    }
                }
                else {
                    caList = USF_AppointmentSchedulerUtil.fetchSlots(depart, d,courseOfferingId,center,specialty,meetingLocation);
                    wrapperCAList(caList);
                    if(caList == null || caList.size() == 0 && specialty != 'No Preference' && center == 'Writing') {
                        emptySlotsMessg += '\n'+' Try your search again using No Preference as a value for the above Specialty field.';
                    }
                    if(caList == null || caList.size() == 0 && courseOfferingId == '--None--' && center == 'Learning') {
                        emptySlotsMessg = ' Please complete the above fields';
                    }
                }
                system.debug('leaveValidationError::: '+leaveValidationError);
                system.debug('maxCASAApptError::: '+maxCASAApptError);
            }
            else {   
              emptySlotsMessg = System.Label.Interview_Error_select_past_date ;
              if(wrapperList!= null && wrapperList.size() != 0) {
                wrapperList.clear();
               }
            }
      }
      else if(depart == 'LWC' && strikeValidationError == ''){
         emptySlotsMessg = 'Please complete the above fields';
      }
      else if(depart == 'LWC' && strikeValidationError != '') {
         emptySlotsMessg = 'Strike Violation';
      }
      /*else if(depart == 'CASA' && leaveValidationError != '') {
         emptySlotsMessg = 'Coach is on leave';
      }
      else if(depart == 'CASA' && leaveValidationError == ''){
        emptySlotsMessg = '';
      }*/
    }

    public void verifyCenterRules() {
        validationError = USF_CenterRulesUtil.validateCenterRules(caSelectedId,center, d, courseOfferingId);
        system.debug('validationError: '+validationError);
    }

    public void verifyCASACoachLeave() {
        validationError = USF_CenterRulesUtil.validateCASACoachLeave('Student',caSelectedId);
        system.debug('validationError: '+validationError);
    }
    
    public String verifyCoachLeave() {
        system.debug('d99: '+d);
        leaveValidationError = USF_CenterRulesUtil.validateCoachLeave(d);
        system.debug('LeaveError:'+leaveValidationError);
        return leaveValidationError;
    }

    public String verifyStudentCASAMaxAppt() {
        maxCASAApptError = USF_CenterRulesUtil.validateMaxCASAAppt();
        return maxCASAApptError;
    }
    
    
    //This method is added by suhan for first appointment check
    public void checkFirstAppointment() {
    try{    
        System.debug('checkFirstAppointment entered');
        boolNextTerm = False;
        boolNext= False;
        User u = [select Id, ContactID from User where Id = :UserInfo.getUserId()];
        String learningString = '%'+System.Label.USF_LWCAppointmentLearningCenter+'%';
        String writingString = '%'+System.Label.USF_LWCAppointmentWritingCenter+'%';
        Date todayDate = Date.today();
        List<AppointmentContact__c> lstAppoint = new List<AppointmentContact__c>();
        List<AppointmentContact__c> lstAppointTerm = new List<AppointmentContact__c>();
        if(u.ContactID<> null){
        
            hed__Term__c term = [Select id,hed__Start_Date__c,hed__End_Date__c from hed__Term__c where 
            hed__Start_Date__c <= :todayDate AND hed__End_Date__c >= :todayDate LIMIT 1];
            
            lstAppoint = [Select ID, SelectedCourse__c from AppointmentContact__c 
            where SelectedCourse__c=:course AND Center__c LIKE :learningString
            AND Contact__c=:u.ContactID AND RecordType.DeveloperName=:System.Label.USF_LWCAppointmentRecordTypeName LIMIT 1];
            
            if(term!=null){
            lstAppointTerm = [Select ID from AppointmentContact__c where Contact__c=:u.ContactID AND 
            (Center__c LIKE :learningString OR Center__c LIKE :writingString) AND Start_Date__c >= :term.hed__Start_Date__c
            AND Start_Date__c <= :term.hed__End_Date__c
            AND RecordType.DeveloperName=:System.Label.USF_LWCAppointmentRecordTypeName LIMIT 1];
            }
            if(lstAppointTerm.isEmpty()){
                boolNextTerm = True;
                boolNext= True;
            }
            else{
                boolNextTerm= False; 
                if(lstAppoint.isEmpty()){
                    boolNext= True;
                }
                else{
                  boolNext= false;  
                }    
            }
        }
        system.debug('contactID'+u.ContactID);
        system.debug('lstAppointTerm'+lstAppointTerm);
        system.debug('lstAppoint'+lstAppoint);
        system.debug('boolNextTerm'+boolNextTerm);
        system.debug('boolNext'+boolNext);
        }
         catch(Exception ex){
                // Display the error message
                System.debug('Exception:'+ex.getMessage()+ex.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
           } 
    }
    
     //This method is added by suhan for first appointment check Writing
    public void checkFirstAppointmentWriting() {
    try{    
        System.debug('checkFirstAppointmentWriting entered');
        boolNextTerm= False;
        boolNext= False;  
        User u = [select Id, ContactID from User where Id = :UserInfo.getUserId()];
        String learningString = '%'+System.Label.USF_LWCAppointmentLearningCenter+'%';
        String writingString = '%'+System.Label.USF_LWCAppointmentWritingCenter+'%';
        Date todayDate = Date.today();
        List<AppointmentContact__c> lstAppointTerm = new List<AppointmentContact__c>();
        if(u.ContactID<> null){
            hed__Term__c term = [Select id,hed__Start_Date__c,hed__End_Date__c from hed__Term__c where 
            hed__Start_Date__c <= :todayDate AND hed__End_Date__c >= :todayDate LIMIT 1];
            if(term!=null){
                lstAppointTerm = [Select ID from AppointmentContact__c where Contact__c=:u.ContactID AND 
                (Center__c LIKE :learningString OR Center__c LIKE :writingString) AND Start_Date__c >= :term.hed__Start_Date__c
                AND Start_Date__c <= :term.hed__End_Date__c
                AND RecordType.DeveloperName=:System.Label.USF_LWCAppointmentRecordTypeName LIMIT 1];
            }
            if(lstAppointTerm.isEmpty()){
                boolNextTerm = True;
                boolNext= False;
            }  
        }
        system.debug('contactID'+u.ContactID);
        system.debug('lstAppointTerm'+lstAppointTerm);
        system.debug('boolNextTerm'+boolNextTerm);
        system.debug('boolNext'+boolNext);
    }
   catch(Exception ex){
      // Display the error message
       System.debug('Exception:'+ex.getMessage()+ex.getStackTraceString());
       ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
    } 
 }
    
    // Method used for Booking an Time slot for the Interview and create an Event 
    public PageReference BookOrReject() {
    try{
        System.debug('Entered...');
        String inviteeName;
        Id eventWhoIdContact;
        Id eventWhoIdLead;
        Id currentContactId = null;
        Id fakeContactId = null;
        if(true) { //to do: add profile filter (Student v Coach)
          Id userId = UserInfo.getUserId();
          User userRec = [Select Id,ContactId, Profile.Name from User where Id =: userId];
          system.debug('Logged in User Name bookorreject '+ Userinfo.getFirstName());
          if(userRec.Profile.Name == 'Student' || isPermissionAssgined){
            currentContactId = userRec.ContactId;
          }
          if(currentContactId == null) {
            Contact c  = [Select Id From Contact Limit 1]; // until we dont have community portal licenses
            fakeContactId = c.Id;
          }
        }
        system.debug('caSelectedId: '+caSelectedId);
        if(caSelectedId!=null && !String.isEmpty(caSelectedId)) {
            Counsellor_Availability__c caToBook = [SELECT Id, Name,Selected_Course__c,Selected_Meeting_Location__c, RecordType.Name,Start_Time__c, End_Time__c, CapacityReached__c, Number_Of_Seats_Booked__c, Availability__r.Max_Number_of_Students__c,
                                                          Status__c,Availability__r.Coach__c                                                          
                                                   FROM Counsellor_Availability__c 
                                                   WHERE Id = :caSelectedId];
            List<Account> accs = [Select Current_Term__c FROM Account where Name = 'University of San Francisco'];
            String currentTerm = '';
            if(accs.size() > 0) {
                currentTerm = accs[0].Current_Term__c;
            }

            
            if(caToBook.Availability__r.Coach__c != null){
               
            }else{
            //This should be changed later  
                verifyContLeadEmail = 'arshaik@deloitte.com';
                inviteeName = 'Test Contact';
                //eventWhoIdLead = '0032C000002I8EX';
            }
            Savepoint sp = Database.setSavepoint();
            if((caToBook.Status__c != 'Open' && caToBook.Status__c != NULL) || caToBook.CapacityReached__c == true){
                throw new BookingException(System.Label.Interview_Error_Slot_Booked);
            }
            //Creates the calendar event
            else{
                system.debug('inside else'+courseOfferingId);
                String formDetails;
                formDetails = 'Name: '+UserInfo.getName()+'\n';
                formDetails += 'Email: '+ UserInfo.getUserEmail() +'\n';
                formDetails += 'Phone Number: '+skypeId+'\n';  
                formDetails += 'Additional Notes: '+additionalComments;
                

                Event e = new Event();
                e.StartDateTime = caToBook.Start_Time__c;
                e.EndDateTime = caToBook.End_Time__c;
                e.Subject = 'Student Appointment ';
                e.Counselor_Availability__c = caToBook.Id; //5/25/2016 SCH
                // Added below If condition, As when the WhoId refers to a lead, we cannot assign WhatId 
                if(eventWhoIdLead != null){
                    //Who is the interviewee
                    e.WhoId = eventWhoIdLead;
                }else{
                    e.WhoId = eventWhoIdContact;
                    //What Id is the Object Event is assigned.
                    //Arshad --- Check with Vijay/Naya to understand to which WhatId this needs to be mapped
                    //e.whatId = '0032C000002I8EX';
                }
                //owner is the interviewer
                if(caToBook.Availability__r.Coach__c != NULL && caToBook.RecordType.Name == 'CASA Slot') {
                     e.OwnerId = caToBook.Availability__r.Coach__c;
                     e.Description = formDetails;
                     e.ShowAs = 'Free';
                }
                /*else {
                        e.OwnerId = '0052C000000QL96';//temporary
                }*/
                   
                e.IsReminderSet = true;
                e.ReminderDateTime =caToBook.Start_Time__c.addMinutes(-30);
                //updates the object records that track the booking -- Nishit commented out the code, we should use capacity reached and Noofstudentsregistered__c
                /*if(caToBook.Number_Of_Seats_Booked__c == null)
                  caToBook.Number_Of_Seats_Booked__c = 1;
                else  
                caToBook.Number_Of_Seats_Booked__c = caToBook.Number_Of_Seats_Booked__c + 1;
                
                if(caToBook.Number_Of_Seats_Booked__c == caToBook.Availability__r.Max_Number_of_Students__c) {
                    caToBook.HasBeen_Booked__c = true;
                    caToBook.Status__c = 'Pending';
                }*/
                
                
                    appConRec = new AppointmentContact__c();                    
                    appConRec.AppointmentSlot__c = caSelectedId;
                    appConRec.Notes__c = additionalComments;
                    appConRec.Preferred_Phone__c  = skypeId;
                    if(currentContactId != null && caSelectedId != null) 
                        appConRec.Contact__c = currentContactId;
                   else
                        appConRec.Contact__c = fakeContactId;
                    //appConRec.Description__c = formDetails;
                    if(formDetails!=null && formDetails.length()>255){     
                        appConRec.Description__c = formDetails.substring(0,254);
                    }
                    if(courseOfferingId == '--None--' || courseOfferingId == '') {
                        appConRec.SelectedCourse__c = null;
                    }
                    else {
                        appConRec.SelectedCourse__c = courseOfferingId;
                        if(caToBook.Selected_Course__c == null) {
                            caToBook.Selected_Course__c = courseOfferingId;
                        }
                    }
                    if(currentTerm != '') {
                        appConRec.Term__c = currentTerm;
                    }
                    System.debug('coachspecialtyTest :'+coachspecialty );
                    if(!String.isEmpty(coachspecialty) && coachspecialty != 'No Preference') {
                        appConRec.Coach_Specialty__c = coachspecialty;
                    }
                    if(caToBook.Selected_Meeting_Location__c == null) {
                        caToBook.Selected_Meeting_Location__c = meetingLocation;
                    }
                    if(caToBook.Selected_Meeting_Location__c == null) {
                        caToBook.Selected_Meeting_Location__c = meetingLocation;
                    }
                    appConRec.Group_Assignment__c = groupAssignment;
                    appConRec.FirstLanguage__c = firstLanguage;
                    System.debug('appConRec.FirstLanguage__c...'+appConRec.FirstLanguage__c);
                    appConRec.Status__c = 'Pending';
                    for(String meetingreason : Reasons){
                        if(appConRec.Reason_for_Meeting__c == null || appConRec.Reason_for_Meeting__c == '')
                            appConRec.Reason_for_Meeting__c = meetingreason + ';';
                        else
                            appConRec.Reason_for_Meeting__c = appConRec.Reason_for_Meeting__c + meetingreason + ';';
                    }
                    if(referrerpick != '' && referrerpick != null && referrerpick != 'None')
                        appConRec.Referred_By__c = referrerpick;
                    if(referrername != '' && referrername != null)
                        appConRec.Referrer_Name__c = referrername;
                        
                        appConRec.Contacts_To_Notify__c = allContactIds;
                        system.debug('APPOINTMENT::: '+appConRec);

                        //added by suhan and mohan for first appointment 09/07/2016
                    System.debug('firstappointmentvalues:'+depart+strAskils+strPerformance+strGrade);  
                    if(depart=='LWC'){
                         appConRec.LWC_AcademicSkills__c=strAskils;
                         appConRec.LWC_ContributeToPerformance__c=strPerformance;
                         appConRec.LWC_CurrentGradeofCourse__c=strGrade;
                         appConRec.LWC_HESITutee__c=strHowKnow;
                         appConRec.LWC_TutorTutee__c=strMeetCon;
                         appConRec.LWC_LearningStyles__c=strLearningStyl;
                         appConRec.LWC_HourStudy__c=strHstudy;
                         appConRec.LWC_TutorTuteeExpectation__c=strTutorAssist;
                         appConRec.LWC_MethodOfStudy__c=strPrepare;
                    }
                            //ends here
                    System.debug('additionalComments = '+additionalComments);
                    System.debug('appConRec.Notes__c = '+appConRec.Notes__c);
                    insert appConRec;
             

                appConRecId = appConRec.Id;
                System.debug('**appConRecId** '+appConRecId);
                // caToBook.Description__c = formDetails;
                atb = new Counselor_Availability_Definition__c(Id = caToBook.Availability__c);
                
                update caToBook;
                update atb;
                if(caToBook.RecordType.Name == 'LWC Slot') {
                    //insert e;    
                }
                //uploadAttachment(appConRec.Id);
                result = System.Label.Interview_Success_slot_booked_Msg; 
                
                
            }
                  
    } // check for EMail
    }
         catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                System.debug('Exception: '+ex.getMessage());
                if(ex.getTypeName() == 'DmlException'){
                    InsertFailedErrorMsg = ex.getDMLMessage(0);
                    result = ex.getDMLMessage(0);
                }else{
                    InsertFailedErrorMsg = ex.getMessage();
                    result = ex.getMessage();
                }
                System.debug('**result: '+result);
           }
        return null;
   } 
  
    public void uploadAttachment(String apptId) {
        attachment.OwnerId = UserInfo.getUserId();
        attachment.ParentId = apptId; // the record the file is attached to
        attachment.IsPrivate = false;
        system.debug('apptId: '+apptId);
        system.debug('attachmentName: '+attachment.Name);
        system.debug('attachment::: '+attachment.body);
        if(attachment.name != null) {
            try {
              insert attachment;
            } 
            catch (DMLException e) {
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading document'));
              //return null;
            } 
            finally {
              attachment = new Attachment(); 
            }
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Document uploaded successfully'));
            //return null;
        }
    }
   
  
 // Javascript remoting method used for creating an attachment 
 
 @RemoteAction
    public static String doUploadAttachment(String appTimeBookId, String attachmentBody, String attachmentName, String attachmentId, String fileType) {
        String attId;
        //system.debug('ARS- appConRecId ---->'+appConRecId);
        if(appTimeBookId != null && !String.isEmpty(appTimeBookId)) {
            attId =  createAttachment(appTimeBookId, attachmentBody,attachmentName,attachmentId,fileType);
            return attId;
         } else {
            return 'Id was null';
        }
    }  

    private static String createAttachment(String attachParentId,String attachBody, String attachName, String attachId, String filetyp){
       Attachment att = new Attachment();
       
       if(attachBody != null) {
              String newBody = '';
              if(att.Body != null) {
                newBody = EncodingUtil.base64Encode(att.Body);
                 
              }
              newBody += attachBody;
              att.Body = EncodingUtil.base64Decode(newBody);
              if(attachId == null) 
              {
                att.Name = attachName;
                att.parentId = attachParentId;
                att.ContentType = filetyp;
              }
              Savepoint sp = Database.setSavepoint(); 
              try{
                    insert att;
              }
              catch(DMLException de){
                Database.rollback(sp);
              }  
                return att.Id;
         } else {
                return 'Attachment Body was null';
         }
 }
 
 //Added by Vandana
 public void fetchContact(){
    System.debug('**selectedFaculty** '+selectedFaculty);
    System.debug('**selectedFacultyId**'+selectedFacultyId);
    if(!allContactIds.contains(selectedFacultyId)){
        Contact con = USF_DBUtil.getSelectedContact(selectedFacultyId);
        allContactIds = allContactIds + con.Id + ';';
        allContacts.add(con);
        System.debug('**allContacts**'+allContacts);
    }
 }
 
 public void removeContact(){
    for(Integer i=0; i<allContacts.size();i++){
        if(allContacts[i].Id == contactToBeRemoved){
            allContacts.remove(i);
            break;
        }
    }
    String str = contactToBeRemoved+';';
    System.debug('**contactToBeRemoved**'+str);
    allContactIds = allContactIds.replace(str,'');
    System.debug('**allContactIds**'+allContactIds);
 }

public void resetFirstAppointmentFlags(){
        boolNextTerm=False;
        boolNext= False;
}
}