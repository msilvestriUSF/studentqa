/******************************************************************************************************************************************
Apex Class Name     : TestAvailabilityDefinitionCreation
Version             : 1.0
Created Date        : 11 AUG 2016
Function            : Test class containing for Unit Testing
Modification Date   : 
Modified By         : Ritam Mukherjee
Modification Log    : 

**********************************************************************************************************************************************/




@isTest
public class TestAvailabilityDefinitionCreation {
    
    
     /* Method name : createAvailabilityDefinitionOnlyOnce
     * Purpose      : Test when trigger fire for creates coach availability slot records for Repeat = "Only Once"
     * Return Type  : Void
     * Mapping      : USF_CoachAvailabilityUtils.createOnlyOnceAvailabilitySlots(List<Counselor_Availability_Definition__c> nonRecurList)
     * Created on   : 11 AUG 2016 by Ritam Mukherjee
     */
    
    @isTest
    static void createAvailabilityDefinitionOnlyOnce(){
        Counselor_Availability_Definition__c cad_success=new Counselor_Availability_Definition__c(
        Start_Date_Time__c= Datetime.newInstance(2016,8,15,8,10,10),
        End_Date_Time__c= Datetime.newInstance(2016,8,15,10,10,10),
        Location__c='New York',
        
        Max_No_Of_Slots__c=2,
        Repeat__c='Only Once'
        
        );
        
        Counselor_Availability_Definition__c cad_failure=new Counselor_Availability_Definition__c(
        Start_Date_Time__c= Datetime.newInstance(2016,8,16,8,10,10),
        End_Date_Time__c= Datetime.newInstance(2016,8,15,10,10,10),
        Location__c='New York',
        
        Max_No_Of_Slots__c=2,
        Repeat__c='Only Once'
        
        );
        
        Test.startTest();
        Database.SaveResult result_success; 
        Database.SaveResult result_failure;
        Exception except;
        try
            {
                 result_success=Database.insert(cad_success);
                    result_failure=Database.insert(cad_failure);
            }
            catch(Exception ee)
            {
                except=ee.getCause();
                System.debug(ee);
            }
        
        Test.stopTest();
        
         System.assertEquals(result_success.isSuccess(),true);
         System.assertEquals(result_failure,null);
            
    }
    
  /* Method name    : createAvailabilityDefinitionDaily
     * Purpose      : Test when trigger fire for creates coach availability slot records for Repeat = "Daily"
     * Return Type  : Void
     * Mapping      : USF_CoachAvailabilityUtils.createWeeklyAvailabilitySlots(List<Counselor_Availability_Definition__c> weeklyRecList)
     * Created on   : 11 AUG 2016 by Ritam Mukherjee
     */
    
      @isTest
    static void createAvailabilityDefinitionDaily(){
        Counselor_Availability_Definition__c cad=new Counselor_Availability_Definition__c(
        Start_Date_Time__c= Datetime.newInstance(2016,8,15,8,10,10),
        End_Date_Time__c= Datetime.newInstance(2016,10,16,10,10,10),
        Location__c='New York',
        
        Max_No_Of_Slots__c=2,
        Repeat__c='Daily'
        
        );
        
        Test.startTest();
        Database.SaveResult result;  
        try
            {
                 result=Database.insert(cad);
            }
            catch(Exception ee)
            {
                System.debug(ee);
            }
        
        Test.stopTest();
        
         System.assertEquals(result.isSuccess(),true);
            
    }
    
     /* Method name : createAvailabilityDefinitionWeekly
     * Purpose      : Test when trigger fire for creates coach availability slot records for Repeat = "Only Once"
     * Return Type  : Void
     * Mapping      : USF_CoachAvailabilityUtils.createWeeklyAvailabilitySlots(List<Counselor_Availability_Definition__c> nonRecurList)
     * Created on   : 12 AUG 2016 by Ritam Mukherjee
     */
      @isTest
    static void createAvailabilityDefinitionWeekly(){
        Counselor_Availability_Definition__c cad=new Counselor_Availability_Definition__c(
        Start_Date_Time__c= Datetime.newInstance(2016,8,15,8,10,10),
        End_Date_Time__c= Datetime.newInstance(2016,8,16,10,10,10),
        Location__c='New York',
        
        Max_No_Of_Slots__c=2,
        Repeat__c='Weekly',
        Monday__c = true,
        Wednesday__c = true
        
        );
        
        Test.startTest();
        Database.SaveResult result;  
        try
            {
                 result=Database.insert(cad);
            }
            catch(Exception ee)
            {
                System.debug(ee);
            }
        
        Test.stopTest();
        
         System.assertEquals(result.isSuccess(),true);
            
    }
 
 @isTest
    static void createAvailabilityDefinitionOnlyOnce_exceptional() {
     
        
        Counselor_Availability_Definition__c cad_failure=new Counselor_Availability_Definition__c(
        Start_Date_Time__c= Datetime.newInstance(2016,8,16,8,10,10),
        End_Date_Time__c= Datetime.newInstance(2016,8,15,10,10,10),
        Location__c='New York',
        
        Max_No_Of_Slots__c=0,
        Repeat__c='Only Once'
        
        );
        
        Test.startTest();
        Database.SaveResult result; 
        try
        {
            result=Database.insert(cad_failure);
            
        }catch(Exception e){
            System.debug('Exception :   '+e);
        }
        Test.stopTest();
        
        

         
            
    }
}