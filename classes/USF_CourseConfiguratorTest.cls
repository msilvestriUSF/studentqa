@isTest(seeAllData=false)
public class USF_CourseConfiguratorTest {
    public static String termId = '';
    public static String courseId = '';
    
    public static void insertTestData(){
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
        
        Account acc = new Account();
        acc.Name = 'Business Economics';
        acc.recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Academic Program').getRecordTypeId();
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
        insert courseOffering1;
        
        hed__Course_Offering__c courseOffering2 = new hed__Course_Offering__c();
        courseOffering2.Name = 'BE202Fall2016';
        courseOffering2.hed__Term__c = term1.Id;
        courseOffering2.Current_Term__c = true;
        courseOffering2.hed__Course__c = course1.Id;
        courseOffering2.Active__c = true;
        courseOffering2.LWC_Tutor__c = true;
        insert courseOffering2;
                        
    }
    static testMethod void validateGetTerms(){
        insertTestData();
        Test.startTest();
        USF_CourseConfigrator controller = new USF_CourseConfigrator();
        controller.getTerms();
        Test.stopTest();
    }
    static testMethod void validateGetCampus(){
        insertTestData();
        Test.startTest();
        USF_CourseConfigrator controller = new USF_CourseConfigrator();
        controller.getCampus();
        Test.stopTest();
    }
    static testMethod void validateGetMode(){
        insertTestData();
        Test.startTest();
        USF_CourseConfigrator controller = new USF_CourseConfigrator();
        controller.getMode();
        Test.stopTest();
    }
    static testMethod void validateGetLevel(){
        insertTestData();
        Test.startTest();
        USF_CourseConfigrator controller = new USF_CourseConfigrator();
        controller.getLevel();
        Test.stopTest();
    }
    
    public static void addAllCourses(USF_CourseConfigrator controller){
        if(!controller.courseMap.isEmpty()){
            for(String courseSubjectName : controller.courseMap.keySet()){
                for(USF_CourseConfigrator.courseWrapper wrapper : controller.courseMap.get(courseSubjectName)){
                    wrapper.selected = true;
                }
            }
        }
        controller.addCourses();
    }
    
    public static void removeAllCourses(USF_CourseConfigrator controller){
        if(!controller.courseMap.isEmpty()){
            for(String courseSubjectName : controller.addedCourseMap.keySet()){
                for(USF_CourseConfigrator.courseWrapper wrapper : controller.addedCourseMap.get(courseSubjectName)){
                    wrapper.selected = true;
                }
            }
        }
        controller.removeCourses();
    }
    
    static testMethod void validatePopulateCourses(){
        insertTestData();
        Test.startTest();
        USF_CourseConfigrator controller = new USF_CourseConfigrator();
        controller.populateCourses(termId,'--None--','--None--','--None--','--None--');
        System.debug('addedCourseMap: '+controller.addedCourseMap);
        System.debug('courseMap: '+controller.courseMap);
        addAllCourses(controller);
        removeAllCourses(controller);
        controller.saveCourses();
        controller.termId = termId;
        controller.levels = '--None--';
        controller.offeredtype = '--None--';
        controller.campusid = '--None--';
        controller.types = '--None--';
        
        hed__Course_Offering__c courseOffering1 = new hed__Course_Offering__c();
        courseOffering1.Name = 'BE202Fall2016';
        courseOffering1.hed__Term__c = termId;
        courseOffering1.Current_Term__c = true;
        courseOffering1.hed__Course__c = courseId;
        courseOffering1.Active__c = true;
        insert courseOffering1;
        
        hed__Course_Offering__c courseOffering2 = new hed__Course_Offering__c();
        courseOffering2.Name = 'BE202Fall2016';
        courseOffering2.hed__Term__c = termId;
        courseOffering2.Current_Term__c = true;
        courseOffering2.hed__Course__c = courseId;
        courseOffering2.Active__c = true;
        courseOffering2.LWC_Tutor__c = true;
        insert courseOffering2;
        
        controller.populateCoursesBasedUponTerm();
        removeAllCourses(controller);
        addAllCourses(controller);       
        
        Test.stopTest();
    }
    static testMethod void validateAddingRemovingCourses(){
        insertTestData();
        Test.startTest();
        USF_CourseConfigrator controller = new USF_CourseConfigrator();
        controller.populateCourses(termId,'--None--','--None--','--None--','--None--');
        System.debug('addedCourseMap: '+controller.addedCourseMap);
        System.debug('courseMap: '+controller.courseMap);
        //adding one course
        if(!controller.addedCourseMap.isEmpty()){
            for(String courseSubjectName : controller.addedCourseMap.keySet()){
                for(USF_CourseConfigrator.courseWrapper wrapper : controller.addedCourseMap.get(courseSubjectName)){
                    wrapper.selected = true;
                    break;
                }
            }
        }
        controller.addCourses();
        //removing one course
         if(!controller.courseMap.isEmpty()){
            for(String courseSubjectName : controller.addedCourseMap.keySet()){
                for(USF_CourseConfigrator.courseWrapper wrapper : controller.addedCourseMap.get(courseSubjectName)){
                    wrapper.selected = true;
                    break;
                }
            }
        }
        controller.removeCourses();
        controller.saveCourses();
        Test.stopTest();
    }
}