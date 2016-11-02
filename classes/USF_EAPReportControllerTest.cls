/** Class Name   : USF_EAPReportControllerTest
 *  Description  : Test Class for USF_EAPReportControllerClass
 *  Created By   : Ankit Jain
 *  Created On   : 27-Sep-2016
 *  Modification Log:
   ------------------------------------------------------------------------------------
   Developer                       Date                Description
   ------------------------------------------------------------------------------------
   Ankit Jain                     27-Sep-2016          Original Version
 */
@isTest
public with sharing class USF_EAPReportControllerTest{
    @isTest
    static void testUSF_EAPReportController(){
        /*UserRole ur = Test_Utility.createRole();
        insert ur;*/
        User usr = Test_Utility.createTestUser('testAdmin','System Administrator');
        if(usr!=null)
            insert usr;
        hed__Course_Offering__c courseOffering; 
        hed__Course__c course;   
        System.runAs(usr){           
            Account acc = Test_Utility.createAccount();
            if(acc!=null)
                insert acc;    
            List<Contact> conList = Test_Utility.createContact(1,usr.id,true,acc.id);
            if(conList!=null && conList.size()>0)
                insert conList;   
            course = Test_Utility.createCourse(acc.id);
            if(course!=null)
               insert course;
            hed__Term__c term = Test_Utility.createTerm(acc.id);
            if(term!=null)
                insert term; 
       
        
            courseOffering = Test_Utility.createCourseOffering(course.id,term.id);   
        
            if(courseOffering != null)
                insert courseOffering;
        
            Test.startTest();
            USF_EAPReportController rc = new USF_EAPReportController();
            List<hed__Course_Offering__c> coList= rc.getCourses();
            System.assertEquals(coList.size(),1);
            rc.first();
            rc.last();
            rc.previous();
            rc.next();
            Boolean hasPrevious = rc.hasPrevious;
            Boolean hasNext = rc.hasNext; 
            Integer pgNumber = rc.pageNumber;
            rc.viewStudents();
            List<contact> stuList = rc.getStudents();
            rc.studentfirst();
            rc.studentlast();
            rc.studentprevious();
            rc.studentnext();
            Boolean studenthasPrevious = rc.studenthasPrevious;
            Boolean studenthasNext = rc.studenthasNext; 
            Integer studentpgNumber = rc.studentpageNumber;
            rc.courseName = course.Name+'-'+courseOffering.Name;
            Test.stopTest();        
        } 
          
    }
    
}