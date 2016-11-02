/*******************************************************************************************
Apex Class: Test_Utility
Description: Utility class for test data
**********************************************************************************************/


@isTest
public with sharing class Test_Utility {

     /*public static UserRole createRole(){
         UserRole r = new UserRole(name = 'TEST ROLE');
         return r;
     }*/
     
     public static User createTestUser(String userName, String profileName ){

        Id profileId;
        try{
            profileId = [SELECT Id FROM Profile WHERE  name =: profileName LIMIT 1 ].Id;
        }catch (Exception ex) {
            System.assert( false, profileName + ' profile does not exist in the system');
        }
        
        User testUser = new User();
        testUser.LastName = 'test ' + UserName;
        testUser.Alias = (userName.length() > 8 ) ?  userName.substring(0 , 8) : userName;
        testUser.Email = UserName+'@test.com';
        testUser.Username = UserName+UserName+'@test.com';
        testUser.ProfileId = profileId;
        testUser.CommunityNickname = 'a'+UserName;
        testUser.TimeZoneSidKey = 'America/New_York';
        testUser.LocaleSidKey = 'en_US';
        testUser.EmailEncodingKey = 'ISO-8859-1';
        testUser.LanguageLocaleKey = 'en_US';
        testUser.IsActive = true;
        
        if(profileName == 'Faculty' || profileName== 'LWC Consultant'){   //Community User     
            testUser.user_type__c = 'ASC';
            Account acc = createAccount(); 
            insert acc;
            List<contact> conList = createContact(1,UserInfo.getUserId(),false,acc.id);
            conList[0].accountId = acc.id;
            insert conList;     
            testUser.contactId = conList[0].id;
        } 
        else //Not a community user
        {
            UserRole r = new UserRole(name = 'TEST ROLE'); //Role is specified because Portal Account owner should have a role
            insert r;
            testUser.UserRoleId = r.Id; //Community Users dont have role
        }   
        return testUser;
    }
    
    public static Account createAccount(){
        Account acc = new Account();
        acc.name='Center for Academic Student Achievement'; // in USF_CoachAvailabilityUtils class getRecordType method acc recordtype is found depending on its name
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        acc.BusinessHour__c = bhs[0].id;
        return acc;
    }
    
    public static App_Config__c createAppConfig(String Name, String TextValue){
        App_Config__c appConfig = new App_Config__c();
        appConfig.name = Name;
        appConfig.Text_Value__c = TextValue;
        return appConfig;
    }
    
    public static List<App_Config__c> createAppConfigList(){
        List<App_Config__c> appConfigList = new List<App_Config__c>();
        appConfigList.add(new App_Config__c(Name='Learning Center',Text_Value__c='Learning Center'));
        
        appConfigList.add(new App_Config__c(Name='Writing Center',Text_Value__c='Writing Center'));
        
        appConfigList.add(new App_Config__c(Name='Speaking Center',Text_Value__c='Speaking Center'));
        
        appConfigList.add(new App_Config__c(Name='CASA',Text_Value__c='Center for Academic Student Achievement'));
        appConfigList.add(new App_Config__c(Name='CASA Slot Type',Text_Value__c='CASA Slot'));
        appConfigList.add(new App_Config__c(Name='LWC Slot Type',Text_Value__c='LWC Slot'));
        appConfigList.add(new App_Config__c(Name='Scheduled Appointment',Text_Value__c='Scheduled'));
        appConfigList.add(new App_Config__c(Name='Dropin Appointment',Text_Value__c='Drop In'));
        appConfigList.add(new App_Config__c(Name='Confirm',Text_Value__c='Confirm'));
        appConfigList.add(new App_Config__c(Name='Pending',Text_Value__c='Pending'));
        appConfigList.add(new App_Config__c(Name='Cancel',Text_Value__c='Cancel'));
        appConfigList.add(new App_Config__c(Name='Missed',Text_Value__c='Missed'));
        appConfigList.add(new App_Config__c(Name='Check',Text_Value__c='Check'));
        appConfigList.add(new App_Config__c(Name='Complete',Text_Value__c='Complete'));
        appConfigList.add(new App_Config__c(Name='LWC Slot Complete Status',Text_Value__c='Complete'));
        appConfigList.add(new App_Config__c(Name='USF_CASAAppointmentMissedStatus',Text_Value__c='No Show'));
        appConfigList.add(new App_Config__c(Name='LWC Appointment Confirmed Status',Text_Value__c='Confirmed'));
        appConfigList.add(new App_Config__c(Name='Checkin',Text_Value__c='Checkin'));
        appConfigList.add(new App_Config__c(Name='CASA Appointment Complete Status',Text_Value__c='Complete'));
        appConfigList.add(new App_Config__c(Name='CASA Appointment Pending Status',Text_Value__c='Pending'));
        appConfigList.add(new App_Config__c(Name='CASA Appointment Confirmed Status',Text_Value__c='Confirmed'));
        appConfigList.add(new App_Config__c(Name='ASC User type',Text_Value__c='ASC'));
        appConfigList.add(new App_Config__c(Name='Student Checkin by Consultant',Text_Value__c='Checked-In'));
        appConfigList.add(new App_Config__c(Name='CASA Appointment Cancelled Status',Text_Value__c='Cancelled'));
        appConfigList.add(new App_Config__c(Name='Student Profile',Text_Value__c='Student'));
        appConfigList.add(new App_Config__c(Name='AvailabilityMeetingType_Phone',Text_Value__c='Phone'));
        
        return appConfigList;
    }
    
    public static hed__Term__c createTerm(Id accId){
        hed__Term__c term = new hed__Term__c();
        term.hed__Account__c = accId;      
        return term;
    }
    
    public static List<Contact> createContact(integer size, Id userId, Boolean isStudent, Id accId){
        List<Contact> conList = new List<Contact>();
        for(integer i=0;i<size;i++)
        {
            contact con = new contact();
            con.lastname='Test'+i;
            con.CWID__c = 'TestCWID'+i;
            con.AcademicSuccessCoach__c = userId;
            con.Student__c=isStudent;
            con.AccountId = accId;
            conList.add(con);
        }
        return conList;
    } 
    public static hed__Course_Offering__c createCourseOffering(id courseId, id termId){
        User usr = Test_Utility.createTestUser('testFaculty','Faculty');
        if(usr!=null)
            insert usr;
        hed__Course_Offering__c courseOffering = new hed__Course_Offering__c();
        courseOffering.hed__Course__c = courseId;
        courseOffering.hed__Section_ID__c = 'TestSection01';
        courseOffering.hed__Term__c = termId;
        //user loggedInUser=[Select id,contactid from User where id=:UserInfo.getUserId()];
        courseOffering.hed__Faculty__c = usr.contactid;
        return courseOffering;
        
    }
    public static hed__Course__c createCourse(Id accId){
        hed__Course__c course = new hed__Course__c();
        course.Name = 'TestCourse';
        course.hed__Account__c = accId;
        return course;
    }
    public static List<case> createCase(Integer size, Id contactId, String RecTypeName,Id courseOffId){
        List<case> caseList = new List<case>();
        Id idCaseRecordType= [Select Id From RecordType where RecordType.developername =: RecTypeName and SobjectType='Case' limit 1].id;      
        for(integer i=0;i<size;i++){
            Case cse = new case();
            cse.contactId = contactId;
            cse.Course_Offering__c = courseOffId;
            if(idCaseRecordType!=null)
                cse.RecordTypeId=idCaseRecordType;
            caseList.add(cse);
        }
        return caseList;
    }
    public static List<AppointmentContact__c> createAppointmentContact(Integer size, String RecTypeName, Id conId, Id slotId){
        List<AppointmentContact__c> appConList = new List<AppointmentContact__c>();
        Id appRecordTypeId= [Select Id From RecordType where RecordType.developername =:RecTypeName and SobjectType='AppointmentContact__c' limit 1].id;
        AppointmentContact__c appCon;
        for(integer i=0;i<size;i++)
        {
            appCon = new AppointmentContact__c();
            appCon.RecordTypeId = appRecordTypeId;
            appCon.Contact__c= conId;
            appCon.Canceled_Date_Time__c = System.now();
            appCon.Reason_for_Meeting__c = 'Academic Coaching';
            appCon.Status__c='Denied';  
            appCon.AppointmentSlot__c = slotId;
            appCon.Strike__c = false;
            appConList.add(appCon);
        } 
        return appConList;
    }
    
    public static Counselor_Availability_Definition__c createAvailability(Id accId, DateTime startTime){
        Counselor_Availability_Definition__c avail = new Counselor_Availability_Definition__c();
        User usr = createTestUser('testFaculty','LWC Consultant');
        insert usr;
        avail.Coach__c = usr.id;
        avail.Success_Center__c = accId;
        avail.Repeat__c = 'Only Once';
        avail.AppointmentType__c = 'Scheduled';
        
        avail.Start_Date_Time__c = StartTime;
        //DateTime testDateTime = 
        avail.End_Date_Time__c= avail.Start_Date_Time__c.addHours(3);
        return avail;
    }
    
    public static Counsellor_Availability__c createSlot(Id availabilityId){
        Counsellor_Availability__c slot = new Counsellor_Availability__c();
        slot.Start_Time__c = System.now().addHours(1);
        DateTime testDateTime = System.now();
        slot.End_Time__c = testDateTime.addHours(3);
        slot.Availability__c = availabilityId;
        return slot;
    }
    public static Event createEvent(Id relatedSlotId){ 
        Event evnt = new Event();
        evnt.WhatId = relatedSlotId;
        evnt.StartDateTime = System.now();
        DateTime testDateTime = System.now();
        evnt.EndDateTime = testDateTime.addHours(3);
        return evnt; 
    }
    
}