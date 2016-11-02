/** Class Name   : USF_FacultyDashBoardControllerTest
 *  Description  : Test Class for USF_FacultyDashBoardController Class
 *  Created By   : Ankit Jain
 *  Created On   : 26-Sep-2016
 *  Modification Log:
   ------------------------------------------------------------------------------------
   Developer                       Date                Description
   ------------------------------------------------------------------------------------
   Ankit Jain                     26-Sep-2016          Original Version
 */
@isTest
public with sharing class USF_FacultyDashBoardControllerTest{
    @isTest
    static void testUSF_FacultyDashBoard(){
        User usr = Test_Utility.createTestUser('testusername','System Administrator');
        if(usr!=null)
            insert usr;
        System.runAs(usr){
            App_Config__c appConfig = Test_Utility.createAppConfig('EAP Report RecordType','EAP Report');
            if(appConfig!=null)
                insert appConfig;
            Account acc = Test_Utility.createAccount();
            if(acc!=null)
                insert acc;    
            List<Contact> conList = Test_Utility.createContact(1,usr.id,true,acc.id);
            if(conList!=null && conList.size()>0)
                insert conList;   
            hed__Course__c course = Test_Utility.createCourse(acc.id);
            if(course!=null)
               insert course;
            hed__Term__c term = Test_Utility.createTerm(acc.id);
            if(term!=null)
                insert term;        
            hed__Course_Offering__c courseOffering = Test_Utility.createCourseOffering(course.id,term.id);   
            if(courseOffering != null)
                insert courseOffering;
            List<Case> caseList = Test_Utility.createCase(1,conList[0].id,'EAP_Report',courseOffering.id);
            if(caseList!=null && caseList.size()>0)
                insert caseList;
            Test.startTest();
            USF_FacultyDashBoardController fd = new USF_FacultyDashBoardController();
            List<case> caseList2 = fd.getEAPReports();
            fd.first();
            fd.last();
            fd.previous();
            fd.next();
            Boolean hasPrevious = fd.hasPrevious;
            Boolean hasNext = fd.hasNext; 
            Integer pgNumber = fd.pageNumber;
            Test.stopTest(); 
        }           
    }
    
}