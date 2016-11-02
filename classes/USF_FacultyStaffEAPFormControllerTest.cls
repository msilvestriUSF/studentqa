/** Class Name   : USF_FacultyStaffEAPFormControllerTest
 *  Description  : Test Class for USF_FacultyStaffEAPFormController
 *  Created By   : Ankit Jain
 *  Created On   : 3-Oct-2016
 *  Modification Log:
   ------------------------------------------------------------------------------------
   Developer                       Date                Description
   ------------------------------------------------------------------------------------
   Ankit Jain                     3-Oct-2016          Original Version
 */
@isTest
public with sharing class USF_FacultyStaffEAPFormControllerTest{
    @isTest
    static void TestUSF_FacultyStaffEAPFormController(){
        User usr = Test_Utility.createTestUser('testusername','System Administrator');
        if(usr!=null)
            insert usr;
        List<Contact> conList; 
        hed__Course_Offering__c courseOffering;
        List<Case> caseList;   
        System.runAs(usr){
        
           
            Account acc = Test_Utility.createAccount();
            if(acc!=null)
                insert acc; 
            List<App_Config__c> appConfigList = new List<App_Config__c>();  
            App_Config__c appConfig = Test_Utility.createAppConfig('EAP Report RecordType','EAP Report');
            if(appConfig!=null)
                appConfigList.add(appConfig);   
            App_Config__c appConfig2 = Test_Utility.createAppConfig('EAP Form Referral value','Referral');
            if(appConfig2!=null)
                appConfigList.add(appConfig2); 
            App_Config__c appConfig3 = Test_Utility.createAppConfig('EAP Form Submit Success Message','Referral has been submitted successfully.');
            if(appConfig3!=null)
                appConfigList.add(appConfig3);   
            if(appConfigList!= null && appConfigList.size()>0)
                insert appConfigList ;
            
            conList = Test_Utility.createContact(1,usr.id,true,acc.id);
            if(conList!=null && conList.size()>0)
                insert conList;     
            hed__Course__c course = Test_Utility.createCourse(acc.id);
            if(course!=null)
                insert course;
            hed__Term__c term = Test_Utility.createTerm(acc.id);
            if(term!=null)
                insert term; 
           
            courseOffering = Test_Utility.createCourseOffering(course.id,term.id);          
            if(courseOffering != null)
                insert courseOffering;
            caseList = Test_Utility.createCase(2,conList[0].id,'EAP_Report',courseOffering.id);
            if(caseList!=null && caseList.size()>0)
                insert caseList[1];
                caseList[1].Areas_for_improvement__c = 'Attendance';
            caseList[1].work__c = 'Quality of work';
            update CaseList[1];
        }         
        List<User> usrList = [select id from user where profile.Name='Faculty' ];         
        System.runAs(usrList[0]){        
            Test.startTest();
            Pagereference pg = Page.USF_FacultyStaffEAPForm;
            Test.setCurrentPage(pg);
            ApexPages.currentPage().getParameters().put('cId',courseOffering.id);
            ApexPages.currentPage().getParameters().put('view','true');
            ApexPages.currentPage().getParameters().put('eapId',caseList[0].id);
            ApexPages.currentPage().getParameters().put('sId',conList[0].id);
            ApexPages.currentPage().getParameters().put('ascId',usr.id);
            USF_FacultyStaffEAPFormController fc = new USF_FacultyStaffEAPFormController(new ApexPages.Standardcontroller(caseList[0]));
            List<String> selectedWork = fc.getselectedWork();
            fc.setselectedWork(selectedWork);
            List<String> selRecom = fc.getselectedRecomendations();
            fc.setselectedRecomendations(selRecom); 
            fc.areasOfImp.add('Attendance');
            fc.areasOfImp.add('Participation');
            fc.selectedWork.add('Quality of work');
            fc.selectedWork.add('Late work');
            fc.selectedRecomendations.add('See Instructor');
            fc.selectedRecomendations.add('Tutoring');
            Pagereference pg2 = fc.submitReferral();
            List<String> area = fc.getareasOfImp();
            fc.setareasOfImp(area);
            List<selectOption> aoi = fc.getAreasOfImprovement();
            List<selectOption> wv = fc.getWorkValues();
            List<selectOption> rv = fc.getRecommendationValues();
            System.assertEquals(9,rv.size());
            fc.populateViewForm();
            
            ApexPages.currentPage().getParameters().put('eapId',caseList[1].id);
            USF_FacultyStaffEAPFormController fc2 = new USF_FacultyStaffEAPFormController(new ApexPages.Standardcontroller(caseList[1]));
            fc2.populateViewForm();
            Test.stopTest();
        }              
    }
    
}