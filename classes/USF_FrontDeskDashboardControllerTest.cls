/** Class Name   : USF_FrontDeskDashboardControllerTest
 *  Description  : Test Class for USF_FacultyStaffEAPFormController
 *  Created By   : Ankit Jain
 *  Created On   : 5-Oct-2016
 *  Modification Log:
   ------------------------------------------------------------------------------------
   Developer                       Date                Description
   ------------------------------------------------------------------------------------
   Ankit Jain                     5-Oct-2016          Original Version
 */
@isTest
public with sharing class USF_FrontDeskDashboardControllerTest{
    @isTest
    static void TestUSF_FrontDeskDashboardController(){
        
        User usr = Test_Utility.createTestUser('testusername','System Administrator');
        if(usr!=null)
            insert usr;
        System.runAs(usr){ 
            List<App_Config__c> appConfigList = new List<App_Config__c>();  
            App_Config__c appConfig = Test_Utility.createAppConfig('CASA Dashboard Today Value','TODAY');
            if(appConfig!=null)
                appConfigList.add(appConfig);   
            App_Config__c appConfig2 = Test_Utility.createAppConfig('Default CASA status filter','All Appointments');
            if(appConfig2!=null)
                appConfigList.add(appConfig2); 
            App_Config__c appConfig3 = Test_Utility.createAppConfig('Default CASA Coach filter','CASA Staff');
            if(appConfig3!=null)
                appConfigList.add(appConfig3);  
            App_Config__c appConfig4 = Test_Utility.createAppConfig('Dropin Appointment','Drop In');
            if(appConfig4!=null)
                appConfigList.add(appConfig4); 
            if(appConfigList!= null && appConfigList.size()>0)
                insert appConfigList ;  
            List<App_Config__c> configList = Test_Utility.createAppConfigList();
                insert configList;
            Account acc = Test_Utility.createAccount();
            if(acc!=null)
                insert acc;
            List<Contact> conList = Test_Utility.createContact(1,usr.id,true,acc.id);
            if(conList!=null && conList.size()>0)
                insert conList; 
            BusinessHours bhs = [select id from BusinessHours where IsDefault=true];    
            DateTime startTime = BusinessHours.nextStartDate(bhs.id, System.now());
            List<Counselor_Availability_Definition__c> availList = new List<Counselor_Availability_Definition__c>();
            availList.add(Test_Utility.createAvailability(acc.Id,startTime));
            //availList.add(Test_Utility.createAvailability(acc.Id,System.now().time()));    
            insert availList;
                
            Counsellor_Availability__c slot = Test_Utility.createSlot(availList[0].id);    
                insert slot;
            // Event is required for Process builder - USF Create/Update Event for Pending/Confirmed CASA Appointment    
            Event evnt = Test_Utility.createEvent(slot.id);
                insert evnt;  
            List<AppointmentContact__c> appList = Test_Utility.createAppointmentContact(2,'CASA_Appointment',conList[0].id,slot.id);
            if(!appList.isEmpty()){
                //appList[1].status__c = 'Missed';
                //appList[2].status__c = 'Confirm';
                appList[1].status__c = 'Checked-In';
                insert appList;
                System.debug('rectype'+appList[0].recordtypeid);
                System.debug('stats'+appList[1].status__c);
                System.debug('Date_Timec'+appList[1].Date_Time__c);
            }
            Test.startTest();
            USF_FrontDeskDashboardController fddc = new USF_FrontDeskDashboardController();
            /*List<USF_AppointmentDTO> appDtoList = fddc.getAppoinitmentRecords();
            System.assert(appDtoList.size()>0);
            List<SelectOption> options = fddc.getTodayFilterValues();
            System.assertEquals(4,options.size());
            List<SelectOption> option2 = fddc.getCoachFilterValues();
            System.assert(option2.size()>0);
            fddc.selectedAction = App_Config__c.getInstance('Checkin').Text_Value__c;
            fddc.updateStatusField();
            fddc.selectedAction = App_Config__c.getInstance('Confirm').Text_Value__c;
            fddc.updateStatusField();
            fddc.selectedAction = App_Config__c.getInstance('Missed').Text_Value__c;
            fddc.updateStatusField();
            fddc.selectedAction = App_Config__c.getInstance('Complete').Text_Value__c;
            fddc.updateStatusField();
            fddc.getLatestCheckedInStudent();*/
            Test.stopTest();    
        }   
                         
    }
    
}