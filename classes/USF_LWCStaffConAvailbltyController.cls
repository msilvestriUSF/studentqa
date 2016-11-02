public with sharing class USF_LWCStaffConAvailbltyController{

    public Boolean includeMyEvents {get;set;}
    public list<calEvent> events {get;set;}
    public list<calEvent> slots {get;set;}
    public string selectedCenter {get;set;}
    public string selectedCourse {get;set;}
    public string selectedConsultant {get;set;}
    public string selectedSpecialty {get;set;}
    public string selectedCoach {get;set;}
    public string slotQueryString;
    public string slotFilterCondStr;
    public User currentUser;
    
    //This variable is used to toggle functionality
    public boolean isCasaStaff {get;set;}
    public boolean isLWCStaff {get;set;}
    public boolean isLWCFrontDesk {get;set;}
    public boolean isLWCConsultant {get;set;}

    public List<selectOption> centersList {get;set;}
    public List<selectOption> coursesList {get;set;}
    public List<selectOption> consultantsList {get;set;}
    public List<selectOption> specialtyList {get;set;}
    //The calendar plugin is expecting dates is a certain format. We can use this string to get it formated correctly
    String dtFormat = USF_Constant.USF_LWCSTAFFCONAVAILBLTYCONTROLLER_DATEFORMAT;
    TimeZone tz = UserInfo.getTimeZone();
    String timez = String.valueOf(tz);
    //Date todayDate = date.today();
    Datetime todayDate = System.now();   
    public string loggedInUserId {get;set;}
    
    Map<Id, String> specNameMap = new Map<Id, String>();
    set<id> validAvailabilities=new set<id>(); 
    //constructor
    public USF_LWCStaffConAvailbltyController() {
        
        selectedCoach=App_Config__c.getInstance('Default CASA Coach filter').Text_Value__c;
        isCasaStaff=false;
        isLWCStaff=false;
        isLWCFrontDesk = false;
        isLWCConsultant=false;
        slotFilterCondStr=USF_Constant.USF_EMPTY;
        //Default showing my events to on
        includeMyEvents = true;
        String usrProfileName = [select id, Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
        loggedInUserId = Userinfo.getUserId();
        //Modified by Vandana to remove permission set related functionality
        currentUser = [Select Id, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<Consultant__c> activeConsultants = USF_DBUtil.getActiveConsultantsByContactId(currentUser.ContactId);
        
                    
        if(usrProfileName.equalsIgnoreCase('casa staff')){
            isCasaStaff =true;
        }        
        else if(!activeConsultants.isEmpty()){
            isLWCConsultant =true;
        }
        else{
            isLWCStaff =true;
        }
        if(usrProfileName.equalsIgnoreCase('lwc front desk')){
             isLWCFrontDesk =true;
        }       
                   
        List<Account> acctList = new List<Account>();
        //acctList = [SELECT Id, Name FROM Account WHERE Center__c = true and ParentId =: system.label.LWC_Parent_Account_Id];
        acctList = USF_DBUtil.getCenters();
        centersList = new List<selectOption>();
        centersList.add(new selectOption('--None--', '--None--'));
        for (Account a : acctList) {
            centersList.add(new selectOption(a.Id, a.Name));
        }  

        //List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>();  --Commented by Manjunath for DFCT0011023 
        //List<Eligible_Tutor_Courses__c> courseOfferingList = new List<Eligible_Tutor_Courses__c>();   
        //courseOfferingList = [SELECT Id, Name FROM hed__Course_Offering__c WHERE Active__c = true AND LWC_Tutor__c = true];   --Commented by Manjunath for DFCT0011023 
        //courseOfferingList=[SELECT id,Course_Offering__r.name,Course_Offering__r.id from Eligible_Tutor_Courses__c where Contact__c=:currentUser.contactId] ;           
        //coursesList = new List<selectOption>();
        //coursesList.add(new selectOption('--None--', '--None--'));
        /*if(courseOfferingList.size()>0){
           /* for(hed__Course_Offering__c courseRec : courseOfferingList) {
                    coursesList.add(new selectOption(courseRec.Id, courseRec.Name));---Commented by Manjunath for DFCT0011023
            }  */ 
            
            /*for(Eligible_Tutor_Courses__c courseRec : courseOfferingList){
                coursesList.add(new selectOption(courseRec.Course_Offering__r.id, courseRec.Course_Offering__r.name));
            }           
        }  */
        
        //Modified by Vandana to remove 'LWC Consultant' profile
        List<User> conList = new List<User>();        
        /*List<String> allContactIds = new List<String>();
        for(Consultant__c con :[SELECT Id,Contact__c FROM Consultant__c WHERE Active__c = true]){
            allContactIds.add(con.Contact__c);
        }*/
        conList = [SELECT Id, Name FROM User WHERE ContactId IN (SELECT Contact__c FROM Consultant__c WHERE Active__c = true)];
        consultantsList = new List<selectOption>();
        consultantsList.add(new selectOption('--None--', '--None--'));
        if(conList.size()>0){
            for (User conRec : conList) {
                consultantsList.add(new selectOption(conRec.Id, conRec.Name));
            }              
        }
                
        /*conList = [SELECT Id, Name FROM User WHERE Profile.Name = 'LWC Consultant'];
        consultantsList = new List<selectOption>();
        consultantsList.add(new selectOption('--None--', '--None--'));
        if(conList.size()>0){
            for (User conRec : conList) {
                consultantsList.add(new selectOption(conRec.Id, conRec.Name));
            }              
        } */
        
        List<Specialty__c> spList = new List<Specialty__c>();        
        spList = [SELECT Id, Name FROM Specialty__c limit 10000];
        specialtyList = new List<selectOption>();
        specialtyList.add(new selectOption('--None--', '--None--'));
        if(spList.size()>0){
            for (Specialty__c spRec : spList) {
                specNameMap.put(spRec.Id, spRec.Name);
                specialtyList.add(new selectOption(spRec.Id, spRec.Name));
            }              
        }                      
    }

    public PageReference pageLoad() {
        List<Account> accounts = new List<Account>();
        events = new list<calEvent>();
        Map<Id,Account> accountsMap = new Map<Id,Account>();
        if(!isCasaStaff) {
            // Returns all Centers related to Learning & Writing Centers if the profile is not Casa Staff
            if(selectedCenter == null && String.isEmpty(selectedCenter)) {
                accounts = USF_DBUtil.getCenters();
            }
            else if(selectedCenter != null && !String.isEmpty(selectedCenter)){
                accounts = USF_DBUtil.getAccountsById(selectedCenter);
            }
        }
        else {
            accounts = USF_DBUtil.getAccounts(System.label.CASA_Center_Name);
        }
        if(accounts != null) {
            accountsMap = new Map<Id,Account>(accounts);
        }
        //String query = 'SELECT Id,';
        if(selectedCenter == NULL && selectedCourse == NULL && selectedConsultant == NULL) {
        //Get Booked Slots
        /*for(Counsellor_Availability__c bookedSlot: [select Id, Name, Start_Time__c, End_Time__c, Coach_Full_Name__c, Selected_Course__r.Name from Counsellor_Availability__c WHERE CapacityReached__c = true  and recordtype.name= 'LWC Slot']){
            DateTime startDT = bookedSlot.Start_Time__c;
            DateTime endDT = bookedSlot.End_Time__c;
            calEvent evnt = new calEvent();
            evnt.title = (bookedSlot.Selected_Course__r.Name == null?' ':bookedSlot.Selected_Course__r.Name) + ' ' + (bookedSlot.Coach_Full_Name__c == null?' ':bookedSlot.Coach_Full_Name__c);
            evnt.allDay = false;
            evnt.startString = startDT.format(dtFormat);
            evnt.endString = endDT.format(dtFormat);
            //Change the hard-coded URL below to the URL suiting community and move to custom label
            evnt.url = '/apex/USF_SlotDetailsConsultant?id=' + bookedSlot.Id;
            evnt.className = 'event-booked';
            events.add(evnt);
        }

        //Get Cancelled Slots
        for(Counsellor_Availability__c cancelledSlot: [select Id, Name, Start_Time__c, End_Time__c, Coach_Full_Name__c, Selected_Course__r.Name from Counsellor_Availability__c WHERE Status__c = 'Cancelled' and recordtype.name= 'LWC Slot']){
            DateTime startDT = cancelledSlot.Start_Time__c;
            DateTime endDT = cancelledSlot.End_Time__c;
            calEvent evnt = new calEvent();
            evnt.title = (cancelledSlot.Selected_Course__r.Name == null?' ':cancelledSlot.Selected_Course__r.Name) + ' ' + (cancelledSlot.Coach_Full_Name__c == null?' ':cancelledSlot.Coach_Full_Name__c);
            evnt.allDay = false;
            evnt.startString = startDT.format(dtFormat);
            evnt.endString = endDT.format(dtFormat);
            //Change the hard-coded URL below to the URL suiting community and move to custom label
            evnt.url = '/apex/USF_SlotDetailsConsultant?id=' + cancelledSlot.Id;
            evnt.className = 'event-cancelled';
            events.add(evnt);
        }*/

        //Get my Events if we have selected the correct option
            if(includeMyEvents){
            slotQueryString='select Id, Name, Start_Time__c,status__c, End_Time__c, Coach_Full_Name__c, Selected_Course__r.Name,Availability__r.Success_Center__r.BusinessHour__c,AppointmentType__c from Counsellor_Availability__c';
                
                //Keep Date filter to pick slots of today or greater than today
                if(isLWCStaff){
                    slotFilterCondStr=' where recordtype.name= \'LWC Slot\' and Start_Time__c >=:todayDate and (Status__c = \'Open\' or Status__c = \'Pending\' or Status__c = \'Confirmed\' or Status__c = \'Booked\') LIMIT 1000';
                }
                else if(isCasaStaff){
                    slotFilterCondStr=' where recordtype.name= \'CASA Slot\' and Start_Time__c >=:todayDate and Event_Conflict__c = false and Status__c != \'Cancelled\' LIMIT 1000';
                }
                else if(isLWCConsultant){
                    slotFilterCondStr=' where recordtype.name= \'LWC Slot\' and Start_Time__c >=:todayDate and (Status__c = \'Open\' or Status__c = \'Pending\' or Status__c = \'Confirmed\' or Status__c = \'Booked\') and Availability__r.Coach__c =:loggedInUserId LIMIT 1000';                   
                }
                String dropInAppointmentLabel = App_Config__c.getInstance('Dropin Appointment').Text_Value__c;
                Boolean isDropIn;
                List<Counsellor_Availability__c> slots = database.query(slotQueryString+slotFilterCondStr);
                 Map<Id,String> resultMap = new Map<Id,String>();
                  resultMap = USF_CenterRulesUtil.validateCoachAvailabilityCon(slots);    
                  for(Counsellor_Availability__c evnt: slots){
                    DateTime startDT = evnt.Start_Time__c;
                    DateTime endDT = evnt.End_Time__c;
                    calEvent myEvent = new calEvent();          
                    myEvent.title = (evnt.Selected_Course__r.Name == null?' ':evnt.Selected_Course__r.Name) + ' ' + (evnt.Coach_Full_Name__c == null?' ':evnt.Coach_Full_Name__c);
                    //myEvent.allDay = evnt.isAllDayEvent;
                    myEvent.allDay = false;
                    //myEvent.startString = startDT.format(dtFormat);
                    myEvent.endString = endDT.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');// as asked by Amit to change the dateTime format Nishit 
                    myEvent.startString = startDT.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'',timez);
                    //myEvent.endString= endDT.format(dtFormat,timez);﻿
                    //myEvent.endString=endDT.format(dtFormat,timez);
                    //Change the hard-coded URL below to the URL suiting community and move to custom label
                    if(isLWCStaff || isLWCConsultant){
                        if(evnt.status__c!=App_Config__c.getInstance('Booked Status').Text_Value__c)
                        myEvent.url = '/apex/USF_SlotDetailsConsultant?id=' + evnt.Id;
                    }
                    else if(isCasaStaff){
                        if(evnt.status__c!=App_Config__c.getInstance('Booked Status').Text_Value__c)
                        myEvent.url = '/apex/USF_SchedulingAppointment?sid=' + evnt.Id;
                   }
                    //myEvent.url = '/apex/USF_SlotDetailsConsultant?id=' + evnt.Id;
                     if(evnt.AppointmentType__c.equalsIgnoreCase(dropInAppointmentLabel)) {
                        myEvent.className = 'event-dropin';
                     }
                     else {
                        myEvent.className = 'event-'+evnt.status__c.tolowercase();
                     }
                    //if(BusinessHours.iswithin(accounts[0].BusinessHour__c,evnt.Start_Time__c) && BusinessHours.iswithin(accounts[0].BusinessHour__c,evnt.End_Time__c)) { // Nishit 
                    if(evnt.Availability__r.Success_Center__c!= null && BusinessHours.iswithin(accountsMap.get(evnt.Availability__r.Success_Center__c).BusinessHour__c,evnt.Start_Time__c) && BusinessHours.iswithin(accountsMap.get(evnt.Availability__r.Success_Center__c).BusinessHour__c,evnt.End_Time__c)) {
                        isDropIn = evnt.AppointmentType__c.equalsIgnoreCase(dropInAppointmentLabel);
                        Integer leadTime = Integer.valueOf(accountsMap.get(evnt.Availability__r.Success_Center__c).LeadTime__c);
                        if((isLWCFrontDesk || isLWCConsultant) && leadTime != null && !isDropIn) {
                            Integer leadTimeNeg = leadTime-2*(leadTime);
                            //added by suhan
                            String result = '';
                              if(resultMap.containsKey(evnt.Id)) {
                                  result = resultMap.get(evnt.Id);
                              }
                            if(leadTime != null && evnt.Start_Time__c.addHours(leadTimeNeg) >= System.now() && result=='') {
                                events.add(myEvent);
                            }
                        }else {
                            events.add(myEvent);
                        }
                    }
                    
                    
                }
            }
            system.debug('On Page Load No of Events-->'+ events.size());
        }
        else {

        }
        return null;
    }
    
    public PageReference filterSelection() {
        slots = new list<calEvent>();
        List<Counsellor_Availability__c> bookedSlots = new List<Counsellor_Availability__c>();
        List<Counsellor_Availability__c> cancelledSlots = new List<Counsellor_Availability__c>();
        List<Counsellor_Availability__c> openSlots = new List<Counsellor_Availability__c>();
        List<Counsellor_Availability__c> newOpenSlots = new List<Counsellor_Availability__c>();
        List<Account> accounts = new List<Account>();
        Map<String, List<Counsellor_Availability__c>> slotListMap = new Map<String, List<Counsellor_Availability__c>>();
       
        //Populate courses based on Consultant selection  - DFCT0011017
        coursesList = new List<selectOption>();
        coursesList.add(new selectOption('--None--', '--None--'));
        System.debug('selectedConsultant...'+selectedConsultant);
        if(isLWCConsultant){
               for(Eligible_Tutor_Courses__c courseRec : USF_DBUtil.getEligibleTutorCoursesByUser(currentUser.Id)){
                    coursesList.add(new selectOption(courseRec.Course_Offering__c, courseRec.Course_Offering__r.Name));
                }   
        } 
        else if(selectedConsultant != null && selectedConsultant != '--None--'){
               for(Eligible_Tutor_Courses__c courseRec : USF_DBUtil.getEligibleTutorCoursesByUser(selectedConsultant)){
                    coursesList.add(new selectOption(courseRec.Course_Offering__c, courseRec.Course_Offering__r.Name));
                }   
        } 
        else{
            for(hed__Course_Offering__c courseRec : [SELECT Id, Name FROM hed__Course_Offering__c WHERE Active__c = true AND LWC_Tutor__c = true]){
                coursesList.add(new selectOption(courseRec.Id, courseRec.Name));
            }   
        }
        
        /*if(!isCasaStaff) {
            accounts = [Select BusinessHour__c FROM Account where Name =: selectedCenter];
        }
        else {
            accounts = [Select BusinessHour__c FROM Account where Name =: System.label.CASA_Center_Name];
        }*/
        Map<Id,Account> accountsMap = new Map<Id,Account>();
        if(!isCasaStaff) {
            // Returns all Centers related to Learning & Writing Centers if the profile is not Casa Staff
            if(selectedCenter == null && String.isEmpty(selectedCenter)) {
                accounts = USF_DBUtil.getCenters();
            }
            else if(selectedCenter != null && !String.isEmpty(selectedCenter)){
                System.debug(selectedCenter+'selectedCenter...');
                accounts = USF_DBUtil.getAccountsById(selectedCenter);
            }
        }
        else {
            accounts = USF_DBUtil.getAccounts(System.label.CASA_Center_Name);
        }
        if(accounts != null) {
            accountsMap = new Map<Id,Account>(accounts);
        }
        System.debug('accountsMap...'+accountsMap);
        String query = 'SELECT Id, Name, Start_Time__c, End_Time__c,Coach_Full_Name__c, status__c,Selected_Course__r.Name,Availability__r.Success_Center__c,Availability__r.Success_Center__r.BusinessHour__c,AppointmentType__c FROM Counsellor_Availability__c ';
        
        /*String bookedQuery = query+' and CapacityReached__c = true ';       
        bookedQuery = buildQuery(bookedQuery);
        
        String cancelledQuery = query+' and (Status__c = \'Canceled by Consultant\' or Status__c = \'Cancelled by LWC Staff\')';
        cancelledQuery = buildQuery(cancelledQuery);*/
        String openQuery=USF_Constant.USF_EMPTY;
        
       //Added by Manjunath-Start
       if(isLWCStaff || isLWCConsultant){
            if(isLWCStaff)          
                openQuery = query+' WHERE recordtype.name= \'LWC Slot\' and Start_Time__c >=:todayDate and (Status__c = \'Open\' or Status__c = \'Pending\' or Status__c = \'Confirmed\' or Status__c = \'Booked\')  ';
            else
                openQuery = query+' WHERE recordtype.name= \'LWC Slot\' and Start_Time__c >=:todayDate and (Status__c = \'Open\' or Status__c = \'Pending\' or Status__c = \'Confirmed\' or Status__c = \'Booked\') and Availability__r.Coach__c =:loggedInUserId '; 
            Set<Id> specConIds = new Set<Id>();
            //Specialty Selection Logic
            if(selectedSpecialty != null && selectedSpecialty != '--None--') {
                List<Faculty_Specialty__c> facSpecRecsList = new List<Faculty_Specialty__c>();
                facSpecRecsList = [SELECT Id, Name, Consultant__c FROM Faculty_Specialty__c WHERE Specialty__c =: selectedSpecialty];
                if(facSpecRecsList.size()>0) {
                    for(Faculty_Specialty__c facSpecRec : facSpecRecsList){
                        specConIds.add(facSpecRec.Consultant__c);
                    }
                }
                if(specConIds.size()>0) {
                    openQuery += ' and Availability__r.Coach__c IN : specConIds';
               }                   
            }
            openQuery  = buildQuery(openQuery) + ' LIMIT 1000';
            System.debug('openQuery...'+openQuery);
            openSlots = database.query(openQuery);
            
          
       }
       else if(isCasaStaff){
           openQuery = query+' WHERE recordtype.name= \'CASA Slot\' and Start_Time__c >=:todayDate and Event_Conflict__c = false and Status__c != \'Cancelled\' ';          
           //Added by Manjunath-End
            System.debug('OpenQuery1: '+openQuery); 
            openQuery  = buildQuery(openQuery); 
            System.debug('OpenQuery: '+openQuery);             
            system.debug('Selected Center-->' + selectedCenter);                   
            //bookedSlots = database.query(bookedQuery);   
            //cancelledSlots = database.query(cancelledQuery);
            openSlots = database.query(openQuery +' LIMIT 1000');

        }
for(Counsellor_Availability__c slot : openSlots) {
        system.debug('slot: '+slot);
}
       /* if(bookedSlots != null)
            slotListMap.put('booked',bookedSlots); 
        if(cancelledSlots != null)
            slotListMap.put('cancelled',cancelledSlots);  */
        if(openSlots != null) {
            for(Counsellor_Availability__c slot : openSlots) {
                 //if(BusinessHours.iswithin(accounts[0].BusinessHour__c,slot.Start_Time__c) && BusinessHours.iswithin(accounts[0].BusinessHour__c,slot.End_Time__c)) {
                 System.debug('slot.Availability__r.Success_Center__c...'+slot.Availability__r.Success_Center__c);
                 System.debug('slot.Availability__r.Success_Center__c...'+accountsMap.get(slot.Availability__r.Success_Center__c));
                 if(slot.Availability__r.Success_Center__c!= null && BusinessHours.iswithin(accountsMap.get(slot.Availability__r.Success_Center__c).BusinessHour__c,slot.Start_Time__c) && BusinessHours.iswithin(accountsMap.get(slot.Availability__r.Success_Center__c).BusinessHour__c,slot.End_Time__c)) {
                     newOpenSLots.add(slot);
                 }
            }
            if(newOpenSLots.size() > 0) {
                slotListMap.put('open',newOpenSLots);
            }
             
        }
        events.clear();
        Map<Id,String> resultMap = new Map<Id,String>();
        if(newOpenSLots.size() > 0 ) {
            resultMap = USF_CenterRulesUtil.validateCoachAvailabilityCon(newOpenSLots);
        }
        else if(openSLots.size() > 0 ) {
            resultMap = USF_CenterRulesUtil.validateCoachAvailabilityCon(openSlots);
        }
        
        for(String s:slotListMap.keySet()) {
            for(Counsellor_Availability__c evnt:slotListMap.get(s)){
                DateTime startDT = evnt.Start_Time__c;
                DateTime endDT = evnt.End_Time__c;
                calEvent myEvent = new calEvent();          
                myEvent.title = (evnt.Selected_Course__r.Name == null?' ':evnt.Selected_Course__r.Name)+ ' ' + (evnt.Coach_Full_Name__c == null?' ':evnt.Coach_Full_Name__c);
                myEvent.allDay = false;
               // myEvent.endString = endDT.format(dtFormat);
               // myEvent.startString = startDT.format(dtFormat,timez);
                myEvent.endString = endDT.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');// as asked by Amit to change the dateTime format Nishit 
                myEvent.startString = startDT.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'',timez);
                            
                //Change the hard-coded URL below to the URL suiting community and move to custom label
                 if(isLWCStaff || isLWCConsultant){
                    if(selectedSpecialty != null){
                        if(evnt.status__c!=App_Config__c.getInstance('Booked Status').Text_Value__c)
                        myEvent.url = '/apex/USF_SlotDetailsConsultant?id=' + evnt.Id + '&selectedSpecialty=' + selectedSpecialty;
                   }        
                   else{
                        if(evnt.status__c!=App_Config__c.getInstance('Booked Status').Text_Value__c)
                        myEvent.url = '/apex/USF_SlotDetailsConsultant?id=' + evnt.Id;    
                   }    
                 }
                 else if(isCasaStaff){
                    if(evnt.status__c!=App_Config__c.getInstance('Booked Status').Text_Value__c)
                    myEvent.url = '/apex/USF_SchedulingAppointment?sid=' + evnt.Id;
                 }
                 String dropInAppointmentLabel = App_Config__c.getInstance('Dropin Appointment').Text_Value__c;
                 if(evnt.AppointmentType__c.equalsIgnoreCase(dropInAppointmentLabel)) {
                    myEvent.className = 'event-dropin';
                 }
                 else {
                    myEvent.className = 'event-'+evnt.status__c.tolowercase();
                 }
                 //if(BusinessHours.iswithin(accounts[0].BusinessHour__c,evnt.Start_Time__c) && BusinessHours.iswithin(accounts[0].BusinessHour__c,evnt.End_Time__c)) { // Nishit 
                    if(evnt.Availability__r.Success_Center__c!= null && BusinessHours.iswithin(accountsMap.get(evnt.Availability__r.Success_Center__c).BusinessHour__c,evnt.Start_Time__c) && BusinessHours.iswithin(accountsMap.get(evnt.Availability__r.Success_Center__c).BusinessHour__c,evnt.End_Time__c)) {
                        Integer leadTime = Integer.valueOf(accountsMap.get(evnt.Availability__r.Success_Center__c).LeadTime__c);
                        if((isLWCFrontDesk || isLWCConsultant) && leadTime != null) {
                            Integer leadTimeNeg = leadTime-2*(leadTime);
                          //added by suhan
                          //String result = USF_CenterRulesUtil.validateCoachAvailabilityCon(evnt.Id,evnt.Start_Time__c.date());
                          String result = '';
                          if(resultMap.containsKey(evnt.Id)) {
                              result = resultMap.get(evnt.Id);
                          }
                           if(leadTime != null && evnt.Start_Time__c.addHours(leadTimeNeg) >= System.now() && result=='') {
                                events.add(myEvent);
                            }
                        }else {
                            events.add(myEvent);
                        }
                    }
                //events.add(myEvent);
            }                                    
        }
        
        system.debug('Size of events-->'+ events.size());    
        return null;
    }
    
    public String buildQuery(String q) {
        if(selectedCenter != null && selectedCenter != '--None--'){
            if(selectedCourse != null && selectedCourse != '--None--'){
             validAvailabilities=retriveValidAvailabilties(selectedCourse);
            
                if(selectedConsultant != null && selectedConsultant != '--None--') {
                    q = q + ' and Availability__r.Success_Center__c =' + '\'' + selectedCenter + '\'' + ' and Selected_Course__c =' + '\'' + selectedCourse + '\'' + ' and Availability__r.Coach__c =' + '\'' + selectedConsultant + '\'';
                }
                else{
                    //q = q + ' and Availability__r.Success_Center__c ='  + '\'' + selectedCenter  + '\'' + ' and Selected_Course__c ='  + '\'' + selectedCourse  + '\'';
                    q = q + ' and Availability__r.Success_Center__c ='  + '\'' + selectedCenter  + '\' and (Selected_Course__c ='  + '\'' + selectedCourse  + '\' OR (Selected_Course__c=null and Availability__c in : validAvailabilities ))';
                }
            }
            else{
                if(selectedConsultant != null && selectedConsultant != '--None--') {
                    q = q + ' and Availability__r.Success_Center__c ='  + '\'' + selectedCenter  + '\'' + ' and Availability__r.Coach__c ='  + '\'' + selectedConsultant  + '\'';
                }
                else{
                    q = q + ' and Availability__r.Success_Center__c ='  + '\'' + selectedCenter  + '\'';
                }   
            }
        }
        else {
            if(selectedCourse != null  && selectedCourse != '--None--'){
                if(selectedConsultant != null && selectedConsultant != '--None--') {
                    q = q + ' and Selected_Course__c ='  + '\'' + selectedCourse +  '\'' + ' and Availability__r.Coach__c ='  + '\'' + selectedConsultant  + '\'';
                }
                else{
                   //Updated by Manjunath for defect-DFCT0011023-Start
                    q = q + ' and Selected_Course__c ='  + '\'' + selectedCourse  + '\' ';
                    //Updated by Manjunath for defect-DFCT0011023-End
                }
            }
            else{
                if(selectedConsultant != null  && selectedConsultant != '--None--') {
                    q = q + ' and Availability__r.Coach__c ='  + '\'' + selectedConsultant  + '\'';
                }
                else{
                    
                }   
            }
        }  
        
        //Added by Manjunath-Start
        
        if(selectedCoach!=null && selectedCoach!=App_Config__c.getInstance('Default CASA Coach filter').Text_Value__c){
        
        q = q + ' and Availability__r.Coach__c ='  + '\'' + selectedCoach+ '\'';
        
        }  
        
        //Added by Manjunath-End
        
        return q;            
    } 

    public string removeSpecialChars(String str){
        string lower = str.toLowerCase();
        string upper = str.toUpperCase();    
        string res;
        for(integer i=0; i<lower.length(); i++) {
            if(lower.charAt(i) != upper.charAt(i)) {
                res = res + str.charAt(i);
            }
        }
        return res.remove(' ');           
    }    
    
    public List<SelectOption> getCoachFilterValues(){  
        
  List<SelectOption> options = new List<SelectOption>();
  options.add(new SelectOption(App_Config__c.getInstance('Default CASA Coach filter').Text_Value__c,App_Config__c.getInstance('Default CASA Coach filter').Text_Value__c));
        
  try{
        
      List<User> coachRecords=[Select id,name from user where user_type__c='ASC' and isActive=true Order By Name ASC];
    
  if(coachRecords.size()>0){
    
        for(User userRec:coachRecords){
             options.add(new SelectOption(userRec.id,userRec.name));
        }
    
    }
  }
  catch(Exception e){
   
   }  
            
return options;
}

public set<id> retriveValidAvailabilties(String courseId){

   set<id> availabiltySet=new set<id>();
    
    for(Appointment_Course__c  appCourse:[Select Availability_Definition__c from Appointment_Course__c where Eligible_Tutor_Courses__r.Course_Offering__c =:courseId]){
    
    availabiltySet.add(appCourse.Availability_Definition__c);
    
    }

 return availabiltySet;

}
    
    //Added by Manjunath-End         

    //Class to hold calendar event data
    public class calEvent{
        public String title {get;set;}
        public Boolean allDay {get;set;}
        public String startString {get;private set;}
        public String endString {get;private set;}
        public String url {get;set;}
        public String className {get;set;}
    }

}