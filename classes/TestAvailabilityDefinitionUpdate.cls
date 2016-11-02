/******************************************************************************************************************************************
Apex Class Name     : TestAvailabilityDefinitionUpdate
Version             : 1.0
Created Date        : 18 AUG 2016
Function            : Test class containing for Unit Testing
Modification Date   :   
Modified By         : Ritam Mukherjee
Modification Log: 

**********************************************************************************************************************************************/





@isTest
public class TestAvailabilityDefinitionUpdate {
    
    /* Method name : updateAvailabilityDefinitionOnlyOnce
* Purpose       : Test when trigger fire for update coach availability slot records for Repeat = "Only Once"
* Return Type   : Void
* Mapping       : USFCreateCoachAvailabilityRecordsHandler.doAfterUpdate
* Created on    : 18 AUG 2016 by Ritam Mukherjee
*/
    
    
    @isTest
    static void updateAvailabilityDefinitionOnlyOnce(){
        Counselor_Availability_Definition__c cad_before=new Counselor_Availability_Definition__c(
            Start_Date_Time__c= Datetime.newInstance(2016,8,15,8,10,10),
            End_Date_Time__c= Datetime.newInstance(2016,8,15,10,10,10),
            Location__c='New York',
           
            Max_No_Of_Slots__c=2,
            Repeat__c='Only Once'
            
        );
        
        Test.startTest();
        Database.SaveResult result_before; 
        Database.SaveResult result_after;
        Exception except;
        try
        {
            result_before=Database.insert(cad_before);
    
            
            cad_before.Start_Date_Time__c=Datetime.newInstance(2016,8,15,8,10,10);
            cad_before.End_Date_Time__c=Datetime.newInstance(2016,8,15,10,10,10);
            
            result_after=Database.update(cad_before);               

            
        }
        catch(Exception ee)
        {
            except=ee.getCause();
            System.debug(ee);
        }
        
        Test.stopTest();
        
        System.assertEquals(result_after.isSuccess(),true);
        System.assertEquals(result_after.getId(),result_before.getId());//
        
    }
    
    /* Method name : updateAvailabilityDefinitionDaily
* Purpose       : Test when trigger fire for update coach availability slot records for Repeat = "Daily"
* Return Type   : Void
* Mapping       : USFCreateCoachAvailabilityRecordsHandler.doAfterUpdate
* Created on    : 18 AUG 2016 by Ritam Mukherjee
*/
    @isTest
    static void updateAvailabilityDefinitionDaily(){
        Counselor_Availability_Definition__c cad_before=new Counselor_Availability_Definition__c(
            Start_Date_Time__c= Datetime.newInstance(2016,8,15,8,10,10),
            End_Date_Time__c= Datetime.newInstance(2016,10,16,10,10,10),
            Location__c='New York',
           
            Max_No_Of_Slots__c=2,
            Repeat__c='Daily'
            
        );
        
        Test.startTest();
        Database.SaveResult result_before; 
        Database.SaveResult result_after;
        Exception except;
        try
        {
            result_before=Database.insert(cad_before);

            
            cad_before.Start_Date_Time__c=Datetime.newInstance(2016,8,15,8,10,10);
            cad_before.End_Date_Time__c=Datetime.newInstance(2016,8,15,10,10,10);
            
            result_after=Database.update(cad_before);               

            
        }
        catch(Exception ee)
        {
            except=ee.getCause();
            System.debug(ee);
        }
        
        Test.stopTest();
        
        System.assertEquals(result_after.isSuccess(),true);
        System.assertEquals(result_after.getId(),result_before.getId());
        
    }
    
    /* Method name : updateAvailabilityDefinitionWeekly
* Purpose       : Test when trigger fire for update coach availability slot records for Repeat = "Weekly"
* Return Type   : Void
* Mapping       : USFCreateCoachAvailabilityRecordsHandler.doAfterUpdate
* Created on    : 18 AUG 2016 by Ritam Mukherjee
*/
    @isTest
    static void updateAvailabilityDefinitionWeekly(){
        Counselor_Availability_Definition__c cad_before=new Counselor_Availability_Definition__c(
            Start_Date_Time__c= Datetime.newInstance(2016,8,5,8,10,10),
            End_Date_Time__c= Datetime.newInstance(2016,8,15,10,10,10),
            Location__c='New York',
           
            Max_No_Of_Slots__c=2,
            Repeat__c='Weekly',
            Monday__c = true,
            Wednesday__c = true
            
        );
        
        Test.startTest();
        Database.SaveResult result_before; 
        Database.SaveResult result_after;
        Exception except;
        try
        {
            result_before=Database.insert(cad_before);
            
            
            cad_before.Start_Date_Time__c=Datetime.newInstance(2016,8,15,8,10,10);
            cad_before.End_Date_Time__c=Datetime.newInstance(2016,8,25,10,10,10);
            cad_before.Thursday__c=true;
            cad_before.Wednesday__c=false;
            
            result_after=Database.update(cad_before);               
        
            
        }
        catch(Exception ee)
        {
            except=ee.getCause();
            System.debug(ee);
        }
        
        Test.stopTest();
        
        System.assertEquals(result_after.isSuccess(),true);
        System.assertEquals(result_after.getId(),result_before.getId());
        
    }
    
    /* Method name : updateAvailabilityDefinitionDaily_noUpdate
* Purpose       : Test when trigger fire for update coach availability slot records for Repeat = "daily" but actually no update happen
* Return Type   : Void
* Mapping       : USFCreateCoachAvailabilityRecordsHandler.doAfterUpdate
* Created on    : 18 AUG 2016 by Ritam Mukherjee
*/
    @isTest
    static void updateAvailabilityDefinitionDaily_NoUpdate(){
        Counselor_Availability_Definition__c cad_before=new Counselor_Availability_Definition__c(
            Start_Date_Time__c= Datetime.newInstance(2016,8,15,8,10,10),
            End_Date_Time__c= Datetime.newInstance(2016,10,16,10,10,10),
            Location__c='New York',
            
            Max_No_Of_Slots__c=2,
            Repeat__c='Daily'
            
        );
        
        Test.startTest();
        Database.SaveResult result_before; 
        Database.SaveResult result_after;
        Exception except;
        try
        {
            result_before=Database.insert(cad_before);
            
            
            cad_before.Start_Date_Time__c=Datetime.newInstance(2016,8,15,8,10,10);
            cad_before.End_Date_Time__c=Datetime.newInstance(2016,8,16,10,10,10);
            
            result_after=Database.update(cad_before);               
            
            
        }
        catch(Exception ee)
        {
            except=ee.getCause();
            System.debug(ee);
        }
        
        Test.stopTest();
        
        System.assertEquals(result_after.isSuccess(),true);
        System.assertEquals(result_after.getId(),result_before.getId());
        
        
    }
    
}