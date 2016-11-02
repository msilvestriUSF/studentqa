@isTest(seeAllData = false)
public class USF_ModifyLWCAppointmentExtnTest {
    public static String sysAdminId = '';
    public static String AdminAccId = '';
    public static String LCWAccId = '';
    public static Contact student = new Contact();
    public static String appointmentId = '';
    public static User StudentTestUser = new User();
    public static AppointmentContact__c appointment = new AppointmentContact__c();
    
    public static void createTestData(){
        
        Id profileId;
        Id sysAdminProfileId;
        Id studentProfileId;
        try{
            profileId = [SELECT Id FROM Profile WHERE  name ='LWC Consultant' LIMIT 1 ].Id;
            sysAdminProfileId = [SELECT Id FROM Profile WHERE  name ='System Administrator' LIMIT 1].Id;
            studentProfileId = [SELECT Id FROM Profile WHERE  name ='Student' LIMIT 1].Id;
        }catch (Exception ex) {
            System.assert( false, 'Profile does not exist in the system');
        }
        
        //Getting standard business hours
        BusinessHours stdBusinessHours = [select id,TimeZoneSidKey from BusinessHours where isDefault = true limit 1];
        System.debug('stdBusinessHours::'+stdBusinessHours);
        
        //Create a user
        UserRole usrrole=[select Id,Name from UserRole where Name='LWC Admin' limit 1];
        User sysAdmin = new User();
        sysAdmin.LastName = 'test Nick';
        sysAdmin.Alias = 'testNick';
        sysAdmin.Email = 'testNick@test.com';
        sysAdmin.Username = 'testNick@test.com';
        sysAdmin.ProfileId = sysAdminProfileId;
        sysAdmin.UserRoleId = usrrole.Id;
        sysAdmin.CommunityNickname = 'testNick';
        sysAdmin.TimeZoneSidKey = stdBusinessHours.TimeZoneSidKey;
        sysAdmin.LocaleSidKey = 'en_US';
        sysAdmin.EmailEncodingKey = 'ISO-8859-1';
        sysAdmin.LanguageLocaleKey = 'en_US';
        sysAdmin.IsActive = true;
        insert sysAdmin;
        
        sysAdminId = sysAdmin.Id;
        
        System.runAs(sysAdmin){ 
            //Insert custom setting values
            List<App_Config__c> settingsList = new List<App_Config__c>();
            settingsList.add(Test_Utility.createAppConfig('Learning Center','Learning Center'));
            settingsList.add(Test_Utility.createAppConfig('Writing Center','Writing Center'));
            settingsList.add(Test_Utility.createAppConfig('Speaking Center','Speaking Center'));
            settingsList.add(Test_Utility.createAppConfig('CASA','Center for Academic Student Achievement'));
            settingsList.add(Test_Utility.createAppConfig('CASA Slot Type','CASA Slot'));
            settingsList.add(Test_Utility.createAppConfig('LWC Slot Type','LWC Slot'));
            settingsList.add(Test_Utility.createAppConfig('Scheduled Appointment','Scheduled'));
            settingsList.add(Test_Utility.createAppConfig('Dropin Appointment','Drop In'));
            settingsList.add(Test_Utility.createAppConfig('CASA Appointment RecordType','CASA_Appointment'));
            settingsList.add(Test_Utility.createAppConfig('LWC Appointment RecordType','LWC_Appointment'));
            settingsList.add(Test_Utility.createAppConfig('Cancel','Cancel'));
            settingsList.add(Test_Utility.createAppConfig('Complete','Complete'));
            settingsList.add(Test_Utility.createAppConfig('CASA Appointment Cancelled Status','Cancelled'));
            settingsList.add(Test_Utility.createAppConfig('Student Profile','Student'));
            settingsList.add(Test_Utility.createAppConfig('LWC Appointment CancelledbyStudent','Cancelled by Student'));
            settingsList.add(Test_Utility.createAppConfig('LWC Appointment Confirmed Status','Confirmed'));
            settingsList.add(Test_Utility.createAppConfig('Confirm','Confirm'));
            settingsList.add(Test_Utility.createAppConfig('Pending','Pending'));
            settingsList.add(Test_Utility.createAppConfig('Missed','Missed'));
            settingsList.add(Test_Utility.createAppConfig('Check','Check'));
            insert settingsList;
            System.debug('inserted**');
            //Parent Account
            Account eduInstitution = new Account();
            eduInstitution.Name = 'University of San Fransisco';
            eduInstitution.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
            eduInstitution.Current_Term__c = 'Fall 2016';
            insert eduInstitution;
            
            //Economics dept Acc
            Account parentAcc = new Account();
            parentAcc.Name = 'Economics Department';
            parentAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            insert parentAcc;
            
                        
            //LWC Account
            Account lwcAcc = new Account();
            lwcAcc.Name = 'Learning and Writing Center(LWC)';
            lwcAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            lwcAcc.LWC_Account_Flag__c = true;
            lwcAcc.CASA_Referral__c = true;
            lwcAcc.BusinessHour__c = stdBusinessHours.Id;
            lwcAcc.LeadTime__c = 24;
            lwcAcc.Student_Missed_Per_Center__c = 1;
            insert lwcAcc;
            LCWAccId = lwcAcc.Id;
            System.debug('**LCWAccId: '+LCWAccId+':'+lwcAcc.Student_Missed_Per_Center__c);
            //Administrative Account
            Account acc = new Account();
            acc.Name = 'Administrative acc';
            acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Administrative').getRecordTypeId();
            acc.Parent = parentAcc;
            acc.Academic_Program_Type__c = 'Major';
            insert acc;
            AdminAccId = acc.Id;
            
            //Learning Center Account
            Account learningAcc = new Account();
            learningAcc.Name = 'Learning Center';
            learningAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
            learningAcc.LWC_Account_Flag__c = true;
            learningAcc.Center__c = true;
            learningAcc.BusinessHour__c = stdBusinessHours.Id;
            insert learningAcc;
            
            //User currentUser = [select id from User where id=: UserInfo.getUserId() limit 1];
            
            //create student
            student = Test_Utility.createContact(1,sysAdminId,true,AdminAccId)[0];
            student.Email = 'Test@test.com';
            student.No_of_strikes_in_Writing_Center__c = 2;
            insert student;
            Contact faculty = Test_Utility.createContact(1,sysAdminId,false,AdminAccId)[0];
            faculty.Faculty__c = true;
            insert faculty;
            
            //create a LWC consultant contact
            contact con = new contact();
            con.lastname='Test';
            con.CWID__c = 'TestCWID';
            con.AcademicSuccessCoach__c = sysAdmin.Id;
            con.Staff__c = true;
            con.LWC_Staff__c = true;
            con.AccountId = lwcAcc.Id;
            insert con;
            
            //create portal user
            
            StudentTestUser.LastName = 'test Rick';
            StudentTestUser.Alias = 'testRick';
            StudentTestUser.Email = 'testRick@test.com';
            StudentTestUser.Username = 'testRick@test.com';
            StudentTestUser.ProfileId = studentProfileId;
            StudentTestUser.CommunityNickname = 'testRick';
            StudentTestUser.TimeZoneSidKey = stdBusinessHours.TimeZoneSidKey;
            StudentTestUser.LocaleSidKey = 'en_US';
            StudentTestUser.EmailEncodingKey = 'ISO-8859-1';
            StudentTestUser.LanguageLocaleKey = 'en_US';
            StudentTestUser.IsActive = true;    
            StudentTestUser.contactId = student.id;
            insert StudentTestUser;
            
            User testUser = new User();
            testUser.LastName = 'test Mick';
            testUser.Alias = 'testMick';
            testUser.Email = 'testMick@test.com';
            testUser.Username = 'testMick@test.com';
            testUser.ProfileId = profileId;
            testUser.CommunityNickname = 'testMick';
            testUser.TimeZoneSidKey = stdBusinessHours.TimeZoneSidKey;
            testUser.LocaleSidKey = 'en_US';
            testUser.EmailEncodingKey = 'ISO-8859-1';
            testUser.LanguageLocaleKey = 'en_US';
            testUser.IsActive = true;    
            testUser.contactId = con.id;
            insert testUser;
            
            //create a consultant
            Consultant__c consultant = new Consultant__c();
            consultant.Appointments_completed_in_Learning_Ctr__c = 2;
            consultant.Center__c = learningAcc.Id;
            consultant.Name = 'Test Consultant';
            consultant.Contact__c = con.Id;
            insert consultant;
            
            
            Datetime st = Datetime.newInstance(2017, 2, 17, 13, 0, 0);
            Boolean isWithin= BusinessHours.isWithin(stdBusinessHours.Id, st);
            System.debug('isWithin: '+isWithin);
            //create availability
            Counselor_Availability_Definition__c availability = new Counselor_Availability_Definition__c();
            availability.Coach__c = testUser.Id;
            availability.Meeting_Location__c = 'In Person';
            availability.AppointmentType__c = 'Drop In';
            availability.Success_Center__c = lwcAcc.Id;
            availability.Location__c = 'San Francisco';
            availability.Start_Date_Time__c = st;
            availability.End_Date_Time__c = st.addMinutes(30);
            availability.Max_Number_of_Students__c = 1;
            availability.Consultant__c = consultant.Id;
            availability.Repeat__c = 'Only Once';
            insert availability;
            
            System.debug('availability Id:'+availability.Id);
            //insert a term
            hed__Term__c term1 = new hed__Term__c();
            term1.Name = 'Fall 2016';
            term1.hed__Start_Date__c = System.today() - 1;
            term1.hed__End_Date__c = System.today() + 3;
            term1.hed__Account__c = eduInstitution.Id;
            insert term1;
            
            //insert course
            hed__Course__c course1 = new hed__Course__c();
            course1.Name = 'Business of the World';
            course1.hed__Course_ID__c = 'BUS202';
            course1.hed__Account__c = AdminAccId;
            course1.Course_Number__c = '201';
            course1.Subject_Name__c = 'Business';
            insert course1;
            
            hed__Course_Offering__c courseOffering1 = new hed__Course_Offering__c();
            courseOffering1.Name = 'BE202Fall2016';
            courseOffering1.hed__Term__c = term1.Id;
            courseOffering1.Current_Term__c = true;
            courseOffering1.hed__Course__c = course1.Id;
            courseOffering1.Active__c = true;
            courseOffering1.LWC_Tutor__c = true;
            insert courseOffering1;
            
            //insert Appointment            
            appointment.Center__c = 'Learning Center';
            appointment.Contact__c = student.Id;
            appointment.AppointmentSlot__c = [Select Id From Counsellor_Availability__c LIMIT 1].Id;
            appointment.SelectedCourse__c = courseOffering1.Id;
            appointment.Group_Assignment__c = 'No';
            appointment.Consultant__c = consultant.Id;
            appointment.Status__c = 'Confirmed';
            insert appointment;
            appointmentId = appointment.Id;
        }
    }
    
    public static testmethod void validateMethods(){
        createTestData();
        Test.startTest();
        ApexPages.StandardController stdcon = new ApexPages.StandardController(appointment);
        USF_ModifyLWCAppointmentExtn controller = new USF_ModifyLWCAppointmentExtn(stdcon);
        controller.getType();
        controller.getAppDTO(); 
        controller.newPhone = '9876543211';
        controller.modifyAppointment();
        System.runAs(StudentTestUser){
            Attachment att = controller.attachment;
            controller.attachment = new Attachment();
            att = controller.attachment;
            controller.fileName = '';
            controller.fileBody = Blob.valueOf('test');
            controller.newPhone = '9876543211';
            controller.modifyAppointment();
        }
        Test.stopTest();
    }
}