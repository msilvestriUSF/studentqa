@isTest(seeAllData = false)
public class USF_CourseAllocationControllerTest {
    
    public static String termId = '';
    public static String courseId = '';
    public static User currentUser = new User();
    public static String studentId = '';
    public static String studentCWID = '';
    public static Eligible_Tutor_Courses__c etc1 = new Eligible_Tutor_Courses__c();
    
	public static testmethod void insertTestData(){
        //insert account
        Account eduInstitution = new Account();
        eduInstitution.Name = 'University of San Fransisco';
        eduInstitution.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Educational Institution').getRecordTypeId();
        eduInstitution.Current_Term__c = 'Fall 2016';
        insert eduInstitution;
        
        Account parentAcc = new Account();
        parentAcc.Name = 'Economics Department';
        parentAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('University Department').getRecordTypeId();
        insert parentAcc;
        
        Account adminAcc = new Account();
        adminAcc.Name = 'Business Economics';
        adminAcc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
        insert adminAcc;
        
        //insert administrative account
        Account acc = new Account();
        acc.Name = 'Admin Account';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Administrative').getRecordTypeId();
        acc.Parent = parentAcc;
        acc.Academic_Program_Type__c = 'Major';
        insert acc;
        
        //insert a term
        hed__Term__c term1 = new hed__Term__c();
        term1.Name = 'Fall 2016';
        term1.hed__Start_Date__c = System.today() - 1;
        term1.hed__End_Date__c = System.today() + 3;
        term1.hed__Account__c = eduInstitution.Id;
        insert term1;
        termId = term1.Id;
        
        //insert course
        hed__Course__c course1 = new hed__Course__c();
        course1.Name = 'Business of the World';
        course1.hed__Course_ID__c = 'BUS202';
        course1.hed__Account__c = acc.Id;
        course1.Course_Number__c = '201';
        course1.Subject_Name__c = 'Business';
        insert course1;
        courseId = course1.Id;
        
        //insert course offering
        hed__Course_Offering__c courseOffering1 = new hed__Course_Offering__c();
        courseOffering1.Name = 'BE202Fall2016';
        courseOffering1.hed__Term__c = term1.Id;
        courseOffering1.Current_Term__c = true;
        courseOffering1.hed__Course__c = course1.Id;
        courseOffering1.Active__c = true;
        courseOffering1.LWC_Tutor__c = true;
        insert courseOffering1;
        
        hed__Course_Offering__c courseOffering2 = new hed__Course_Offering__c();
        courseOffering2.Name = 'BE202Fall2016';
        courseOffering2.hed__Term__c = term1.Id;
        courseOffering2.Current_Term__c = true;
        courseOffering2.hed__Course__c = course1.Id;
        courseOffering2.Active__c = true;
        courseOffering2.LWC_Tutor__c = true;
        insert courseOffering2;
        
        hed__Course_Offering__c courseOffering4 = new hed__Course_Offering__c();
        courseOffering4.Name = 'BE202Fall2016';
        courseOffering4.hed__Term__c = term1.Id;
        courseOffering4.Current_Term__c = true;
        courseOffering4.hed__Course__c = course1.Id;
        courseOffering4.Active__c = true;
        courseOffering4.LWC_Tutor__c = true;
        insert courseOffering4;
        
        hed__Course_Offering__c courseOffering3 = new hed__Course_Offering__c();
        courseOffering3.Name = 'CE202Fall2016';
        courseOffering3.hed__Term__c = term1.Id;
        courseOffering3.Current_Term__c = true;
        courseOffering3.hed__Course__c = course1.Id;
        courseOffering3.Active__c = true;
        courseOffering3.LWC_Tutor__c = true;
        insert courseOffering3;
        
        currentUser = [select id from User where id=: UserInfo.getUserId() limit 1];
        //create student contact
        List<Contact> contacts = Test_Utility.createContact(1, currentUser.Id, true, adminAcc.Id);
        Contact student = contacts[0];
        System.debug('**student: '+student);
        insert student;
        studentId = student.Id;
        studentCWID = student.CWID__c;
        System.debug('**studentId: '+student.Id);
        
        //create eligible tutor courses
        etc1 = new Eligible_Tutor_Courses__c();
        etc1.Course_Offering__c = courseOffering2.Id;
        etc1.Contact__c = student.Id;
        insert etc1;
        
        etc1 = new Eligible_Tutor_Courses__c();
        etc1.Course_Offering__c = courseOffering1.Id;
        etc1.Contact__c = student.Id;
        insert etc1;
                        
    }
    
    static testmethod void validateGetfacultyInfoByCWID(){
        Test.startTest();
        //Negative scenario
        ApexPages.StandardController stdcon = new ApexPages.StandardController(etc1);
        USF_CourseAllocationController controller = new USF_CourseAllocationController(stdcon);
        System.debug('Student');
        controller.CWID = studentCWID;
        controller.selectedStudentId = studentId;
        controller.getfacultyInfoByCWID();
        //Positive Scenario
        insertTestData();
        stdcon = new ApexPages.StandardController(etc1);
        controller = new USF_CourseAllocationController(stdcon);
        System.debug('Student');
        controller.CWID = studentCWID;
        controller.selectedStudentId = studentId;
        controller.getfacultyInfoByCWID();
        Integer i = 0;
        for(List<USF_CourseAllocationController.courseWrapper> cw : controller.courseMap.Values()){
            for(USF_CourseAllocationController.courseWrapper wrapObj : cw){
                if(Math.mod(i,2)==0){
                    wrapObj.selected = true;
                    i++;
                }
            }
        }
        controller.addCourses();
        i=0;
        for(List<USF_CourseAllocationController.courseWrapper> cw : controller.addedCourseMap.Values()){
            for(USF_CourseAllocationController.courseWrapper wrapObj : cw){
                if(Math.mod(i,2)==0){
                    wrapObj.selected = true;
                    i++;
                }
            }
        }
        controller.removeCourses();
        controller.saveCourses();
        Test.stopTest();
    }
    
    

}