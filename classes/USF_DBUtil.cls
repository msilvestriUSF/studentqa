/*
Created: 09/26/2016 - Nishit Babaria 

This class will include all queries to by-pass the security settings and return the respective results.


*/
public without sharing class USF_DBUtil {
    public USF_DBUtil() {}
    public static List<hed__Term__c> getTerm(Date startDate, Date endDate) {
        List<hed__Term__c> currentTerms = new List<hed__Term__c>();
        for(hed__Term__c currentTerm : [SELECT Id, Name,hed__Start_Date__c,hed__End_Date__c FROM hed__Term__c WHERE hed__Start_Date__c <= :startDate AND hed__End_Date__c >=: endDate]) {
            currentTerms.add(currentTerm);
        }
        return currentTerms;
    }
    
    public static Id getTermId() {
        hed__Term__c term = [Select Id FROM hed__Term__c where Active__c = true Limit 1];
        Id termId = null;
        if(term != null) {
            termId = term.Id;
        }
        return termId;
    }
    public static Map<Id,hed__Term__c> getTerm(List<Counselor_Availability_Definition__c> availabilityList) {
        List<hed__Term__c> currentTerms = new List<hed__Term__c>();
        Map<Id,hed__Term__c> termMap = new Map<Id,hed__Term__c>();
        List<Date> minMaxDates = getStartAndEndDateForTermQuery(availabilityList);
        Date startDate;
        Date endDate;
        if(minMaxDates.size() == 2) {
            startDate = minMaxDates[0];
            endDate = minMaxDates[0];
            List<hed__Term__c> terms = getTerm(startDate,endDate);
            for(Counselor_Availability_Definition__c cad : availabilityList) {
                for(hed__Term__c term : terms) {
                    if((term.hed__Start_Date__c <= (cad.Start_Date_Time__c.date()) && term.hed__End_Date__c > cad.End_Date_Time__c.date())) {
                        termMap.put(cad.Id,term);
                    }
                }
            }
        }
        return termMap;
    }
    
    public static List<Date> getStartAndEndDateForTermQuery(List<Counselor_Availability_Definition__c> availabilityList) {
        List<Date> startDateList = new List<Date>();
        List<Date> endDateList = new List<Date>();
        List<Date> minMaxDates = new List<Date>();
        for(Counselor_Availability_Definition__c cad : availabilityList) {
            startDateList.add(cad.Start_Date_Time__c.date());
            endDateList.add(cad.End_Date_Time__c.date());
        }
        startDateList.sort();
        endDateList.sort();
        // Minimum start Date
        if(startDateList.size() > 0) {
            minMaxDates.add(startDateList.get(0));
        }
        // Maximum end Date
        if(endDateList.size() > 0) {
            minMaxDates.add(endDateList.get(endDateList.size()-1));
        }
        return minMaxDates;
    }
    
    public static List<hed__Course_Offering__c> getCoursesByTerm(String termId) {
        List<hed__Course_Offering__c> coursesList = new List<hed__Course_Offering__c>();
        for(hed__Course_Offering__c course : [SELECT Id,Name,hed__Start_Date__c,hed__Faculty__r.Name,Schedule__c,
        hed__Course__r.Subject_Code__c,hed__Course__r.Course_Number__c,hed__Section_ID__c FROM hed__Course_Offering__c WHERE hed__Term__c=:termId ORDER BY hed__Start_Date__c ASC]) {
            coursesList.add(course);
        }
        return coursesList;
    }
    
    public static List<Document> getDocumentsByFolderId(String folderId) {
        List<Document> documentsList = new List<Document>();
        for(Document doc : [SELECT Description,DeveloperName,FolderId,Id,Name FROM Document WHERE FolderId =:folderId]) {
            documentsList.add(doc);
        }
        return documentsList;
    }
    
    public static String getFolderIdByFolderName(String FolderName) {
        String folderId = [SELECT Id FROM Folder WHERE Name =:FolderName LIMIT 1].Id;
        return folderId;
    }
    
    public static String validateCenterRules(Id selectedSlotId, Id center,Date selectedDate,String courseOfferingId, String studentId) {
        return USF_CenterRulesUtil.validateCenterRules(selectedSlotId, center, selectedDate,courseOfferingId, studentId);
    }
    
    public static List<Account> getLWCCenters() {
         List<Account> acctList = new List<Account>();
         acctList = [SELECT Id, Name FROM Account WHERE Center__c = true and ParentId =:system.label.LWC_Parent_Account_Id];
         return acctList;
    }
    public static Counsellor_Availability__c getSlotRecord(Id slotId) {
         Counsellor_Availability__c slotRec = new Counsellor_Availability__c();
         slotRec = [SELECT Id, Start_Time__c, Status__c, Availability__c,Availability__r.Success_Center__r.LeadTime__c,Availability__r.Success_Center__r.Name, Availability__r.Success_Center__c, Noofstudentsregistered__c, Selected_Course__c,AppointmentType__c,Selected_Course__r.Name,(Select id from Appointment_Contacts__r) FROM Counsellor_Availability__c WHERE Id =:slotId];
         return slotRec;
    }
    
    
    /********************************************************************************
    Description: This method is used to populate select Course table in Faculty flow
    Return type: ApexPages.StandardSetController
    Parameters: Id
    Created By: Manjunath Singh
    *********************************************************************************/
    
    public static ApexPages.StandardSetController getCourseOfferings(Id contactId){ 
    ApexPages.StandardSetController coursesRecords;
    
    coursesRecords= new ApexPages.StandardSetController(Database.getQueryLocator(
                [SELECT id,name,hed__Course__r.name,hed__Section_ID__c FROM hed__Course_Offering__c WHERE hed__Faculty__c=:contactId and Current_Term__c=true LIMIT 10000])
                );
                
     return coursesRecords;
    
    }
    
     /********************************************************************************
    Description: This method is used to populate select student table in Faculty flow
    Return type: ApexPages.StandardSetController
    Parameters: String
    Created By: Manjunath Singh
    *********************************************************************************/
    
    public static ApexPages.StandardSetController getStudentsForCourseOffering(String courseOfferingId){ 
    ApexPages.StandardSetController studentRecords;
    
    studentRecords= new ApexPages.StandardSetController(Database.getQueryLocator(
                [SELECT id,name,lastname,firstname,AcademicSuccessCoach__r.name,CWID__c FROM contact WHERE Student__c=true
                AND ID in(SELECT hed__Contact__c FROM hed__Course_Enrollment__c WHERE hed__Course_Offering__c=:courseOfferingId) ORDER BY lastname LIMIT 10000])
                );
                
     return studentRecords;
    
    }
    
    /********************************************************************************
    Description: This method is used to get the selected Course offering info
    Return type: List<hed__Course_Offering__c>
    Parameters: String
    Created By: Manjunath Singh
    *********************************************************************************/
    
    public static List<hed__Course_Offering__c> getCourseOfferingInfo(String courseOfferingId){ 
    List<hed__Course_Offering__c> courseOffering;
    
    courseOffering=[SELECT id,hed__Course__r.name,hed__Section_ID__c,hed__Course__r.Course_Number__c from hed__Course_Offering__c where id=:courseOfferingId LIMIT 1];
                
     return courseOffering;
    
    }
    
    /********************************************************************************
    Description: This method is used to Insert the EAP report
    Return type: Void
    Parameters: Case
    Created By: Manjunath Singh
    *********************************************************************************/
    
    public static void insertEAPReport(Case eapReport){ 
    
        Database.insert(eapReport);
    
    }
    
     
    /********************************************************************************
    Description: This class is used wrap case records
    Created By: Manjunath Singh
    *********************************************************************************/
  /*  public class caseDTO{
    
    public Case eapRecord {get;set;}
    public String contactLastName {get;set;}
    public String contactFirstName {get;set;}
    public String ascName {get;set;}
    public String courseName{get;set;}
    public String sectionId{get;set;}
    
    public caseDTO(Case eapRecord,String contactLastName,String contactFirstName,String ascName,String courseName,String sectionId){
        this.eapRecord=eapRecord;
        this.contactLastName=contactLastName;
        this.contactFirstName=contactFirstName;
        this.ascName=ascName;
        this.courseName=courseName;
        this.sectionId=sectionId;
    }
    
    }*/
    public static Contact getSelectedContact(String selectedStudentId) {
        Contact contactRec = [select ID, Name,Academic_Standing__c,CWID__c,ASC_Email__c,MobilePhone,Email,Department from Contact where id=:selectedStudentId limit 1];
        return contactRec;
    }
    
    public static void insertRecord(SObject sobjectInstance){ 
        Database.insert(sobjectInstance);
    }
    public static void updateRecord(SObject sobjectInstance){ 
        Database.update(sobjectInstance);
    }
    public static void upsertRecord(SObject sobjectInstance){ 
        Database.upsert(sobjectInstance);
    }
    /********************************************************************************
    Description: This method is used to return the appointment based on the appointment id passed
    Return type: List<AppointmentContact__c>
    Parameters: Id
    Created By: Vandana
    *********************************************************************************/
    
    public static List<AppointmentContact__c> getAppointment(String currentAppointmentId) {
         List<AppointmentContact__c> appointments = new List<AppointmentContact__c>();
         appointments = [Select Id,RecordTypeId,AppointmentSlot__r.Availability__r.Success_Center__r.Student_Missed_Per_Center__c,Strike__c,Center__c,Date_Time__c,Status__c FROM AppointmentContact__c where Id =:currentAppointmentId LIMIT 1];
         return appointments;
    }
    
    /********************************************************************************
    Description: This method is used to return list of active consultants based on the contact id passed
    Return type: List<Consultant__c>
    Parameters: Id
    Created By: Vandana
    *********************************************************************************/
    public static List<Consultant__c> getActiveConsultantsByContactId(String contactId){
        List<Consultant__c> activeConsultantList = new List<Consultant__c>();
        if(!String.isBlank(contactId))
            activeConsultantList = [SELECT Id FROM Consultant__c WHERE Active__c = true AND Contact__c = :contactId AND Term__r.hed__Start_Date__c <= TODAY AND Term__r.hed__End_Date__c >= TODAY];
        return activeConsultantList;
    }
    
   /********************************************************************************
    Description: This method is used to return list of eligible tutor courses based on the contact id passed
    Return type: List<Eligible_Tutor_Courses__c>
    Parameters: Id
    Created By: Vandana
    *********************************************************************************/
    public static List<Eligible_Tutor_Courses__c> getEligibleTutorCoursesByContact(String contactId){
        List<Eligible_Tutor_Courses__c> eligibleTutorCourses = new List<Eligible_Tutor_Courses__c>();
        eligibleTutorCourses = [SELECT Id, Course_Offering__r.Name, Course_Offering__r.hed__Section_ID__c, Course_Offering__r.hed__Course__r.Subject_Code__c, Course_Offering__r.hed__Course__r.Course_Number__c FROM Eligible_Tutor_Courses__c WHERE Contact__c =: contactId];
        return eligibleTutorCourses;
    }
    
    
  // Added by Mohan 
  public static List<Eligible_Tutor_Courses__c> getEligibleTutorCoursesByUser(String selectedConsultant){
       List<Eligible_Tutor_Courses__c> eligibleTutorCourses = new List<Eligible_Tutor_Courses__c>();
       String selectedContact = [Select id,contactid from User where id=:selectedConsultant].contactid;
       if(selectedContact!=null){  
          eligibleTutorCourses = [SELECT Id,Course_Offering__c,Course_Offering__r.Name, Course_Offering__r.hed__Section_ID__c, Course_Offering__r.hed__Course__r.Subject_Code__c, Course_Offering__r.hed__Course__r.Course_Number__c FROM Eligible_Tutor_Courses__c WHERE Contact__c =:selectedContact order by Course_Offering__r.Name ASC];
        }
        return eligibleTutorCourses;
    } 
    
    /********************************************************************************
    Description: This method is used to return list of applicable centers for a particular user
    Return type: List<selectOption>
    Parameters: Id
    Created By: Vandana
    *********************************************************************************/
    public static List<selectOption> getApplicableCenters(String userId){
        List<selectOption> applicableCenters = new List<selectOption>();
        List<Consultant__c> consultantRecs = new List<Consultant__c>();
        User currentUser = [SELECT contactId, profile.Name, UserRole.Name FROM User WHERE ID=:userId LIMIT 1];
        if(currentUser.profile.Name.equalsIgnoreCase(App_Config__c.getInstance('Student Profile').Text_Value__c) && !String.isBlank(currentUser.contactId)){
            consultantRecs = [SELECT Center__r.Name, Center__r.Id FROM Consultant__c WHERE Contact__c=:currentUser.contactId AND Term__r.Active__c = true ORDER BY Center__r.Name ASC];
        }
        
        //This is for consultant users
        if(!consultantRecs.isEmpty()){
            for(Consultant__c con:consultantRecs){
                if(!(String.isBlank(con.Center__r.Id) && String.isBlank(con.Center__r.Name))){
                    applicableCenters.add(new selectOption(con.Center__r.Id, con.Center__r.Name));
                }
            }
        }
        //This is for other profiles
        else{
            String finalQuery = 'SELECT Id,Name FROM Account';
            
            if(currentUser.profile.Name.equalsIgnoreCase(App_Config__c.getInstance('LWC Staff Profile').Text_Value__c)){
                if(currentUser.UserRole.Name.equalsIgnoreCase(App_Config__c.getInstance('LWC - Learning Lead Role').Text_Value__c)){
                    finalQuery += ' WHERE Name LIKE %' + App_Config__c.getInstance('Learning Center').Text_Value__c + '% LIMIT 1';
                }else if(currentUser.UserRole.Name.equalsIgnoreCase(App_Config__c.getInstance('LWC - Writing Lead Role').Text_Value__c)){
                    finalQuery += ' WHERE Name LIKE %' + App_Config__c.getInstance('Writing Center').Text_Value__c + '% LIMIT 1';
                }else if(currentUser.UserRole.Name.equalsIgnoreCase(App_Config__c.getInstance('LWC - Speaking Lead Role').Text_Value__c)){
                    finalQuery += ' WHERE Name LIKE %' + App_Config__c.getInstance('Speaking Center').Text_Value__c + '% LIMIT 1';
                }
            }else{
               finalQuery += 'WHERE LWC_Account_Flag__c = true'; 
            }
            finalQuery += 'ORDER BY Name ASC';
            for(Account acc : Database.query(finalQuery)){
                applicableCenters.add(new selectOption(acc.Id, acc.Name));
            }
        
        }
    return applicableCenters;
    }
    
    /********************************************************************************
    Description: This method is used to return list of course offerings which have a course connection with the particular contact
    Return type: List<hed__Course_Offering__c>
    Parameters: ContactId
    Created By: Vandana
    *********************************************************************************/
    public static List<hed__Course_Offering__c> getCoursesByContact(String contactId) {
        List<hed__Course_Offering__c> coursesList = new List<hed__Course_Offering__c>();
        for(hed__Course_Offering__c course : [SELECT Id,Name,hed__Start_Date__c,hed__Faculty__r.Name,Schedule__c,
        hed__Course__r.Subject_Code__c,hed__Course__r.Course_Number__c,hed__Section_ID__c FROM hed__Course_Offering__c WHERE Id IN (SELECT hed__Course_Offering__c FROM hed__Course_Enrollment__c WHERE hed__Contact__c = :contactId AND Active__c = true) ORDER BY hed__Start_Date__c ASC]) {
            coursesList.add(course);
        }
        return coursesList;
    }
    
    public static List<Account> getCenters(){
        String parentName = App_Config__c.getInstance('Learning & Writing Center').Text_Value__c;
        List<Account> accountList = [SELECT Id,Name,BusinessHour__c,LeadTime__c FROM Account WHERE LWC_Account_Flag__c = true AND Parent.Name =: parentName];
        return accountList;
    }
    
    public static List<Account> getAccounts(String accountName) {
        List<Account> accountList = [SELECT Id,Name,BusinessHour__c,LeadTime__c FROM Account WHERE Name =: accountName];
        return accountList;
    }
    
    public static List<Account> getAccountsById(String accountId) {
        List<Account> accounts = new List<Account>();
         List<Account> accountList = new List<Account>();
         List<Id> accIds = new List<Id>();
        if(accountId == '--None--') {
            accounts = getCenters();
            for(Account a : accounts) {
                accIds.add(a.Id);
            }
            accountList = [SELECT Id,Name,BusinessHour__c,LeadTime__c FROM Account WHERE id in : accIds];
        }
        else {
            accountList = [SELECT Id,Name,BusinessHour__c,LeadTime__c FROM Account WHERE id =: accountId];
        }
        return accountList;
    }
    
    public static String getContactId(String userId) {
        String selectedContact = [Select id,contactid from User where id=:userId].contactid;
        return selectedContact;
    }
    
      // Check for first Appointment
  public static Boolean checkFirstAppointment(String studentContactID,String course) {
        Boolean firstAppointment= false;
        try{ 
        Date todayDate = Date.today();
        List<AppointmentContact__c> lstAppoint = new List<AppointmentContact__c>();
        if(studentContactID != null && course != null){
            lstAppoint = [Select Id,Contact__c,SelectedCourse__c from AppointmentContact__c 
            where SelectedCourse__c = :course AND Contact__c = :studentContactID LIMIT 1];
                if(lstAppoint.isEmpty()){
                    firstAppointment= true;
                }
                else{
                  firstAppointment= false;  
                }    
         }
        system.debug('studentContactID'+studentContactID);
        system.debug('course'+course);
        system.debug('lstAppoint'+lstAppoint);
        system.debug('firstAppointment'+firstAppointment);  
        return firstAppointment;
    }
    catch(Exception ex){
                // Display the error message
                System.debug('Exception:'+ex.getMessage()+ex.getStackTraceString());
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
    } 
    }
    
    /*********************************************************************************
    Description: This method is used to check student is already added on slot
    Return type: Boolean
    Parameters: ContactId,slotId
    Created By: Manjunath Singh
    *********************************************************************************/
    public static Boolean checkDuplicateAppointment(String contactId,String slotID) {
        List<AppointmentContact__c> existingAppointment= new List<AppointmentContact__c>();
        Boolean isDublicate=false;
        existingAppointment=[select id from AppointmentContact__c where AppointmentSlot__c=:slotID and Contact__c=:contactId LIMIT 1000];       
        System.debug('existingAppointment:::'+existingAppointment);
        if(existingAppointment.size()>0){
            isDublicate=true;
        }
        return isDublicate;
    }

    public static String getCurrentUserContactId() {
        String contactId = [Select Id, ContactId FROM User where Id =: UserInfo.getUserId() LIMIT 1].ContactId;
        return contactId;
    }
    
    public static String getUserContactId(Id userId) {
        String contactId = [Select Id, ContactId FROM User where Id =: userId LIMIT 1].ContactId;
        return contactId;
    }
    
    public static Decimal getLeadTime(Id accountId) {
        Decimal leadTime = [SELECT Id,Name,BusinessHour__c,LeadTime__c FROM Account WHERE id =: accountId].LeadTime__c;
        return leadTime;
    }
}