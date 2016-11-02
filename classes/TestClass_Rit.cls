public class TestClass_Rit {
   
 /*
 *  @author     :   R. Mukherjee
 *  @date       :   4th August, 2016
 *  @param      :   Department,Date
 *  @purpose    :   Fetch CASA spesific details
 */ 
    public static List<Counsellor_Availability__c> getCA_CASA(String department, Date d){
        System.Debug('#Search Criteria  #   Date:'+d +',Deaprtment:'+department);
        List<Counsellor_Availability__c> slots=[
            Select  Id,
                    Selected_Course__c,
                    Coach_First_Name__c, 
                    Coach_Last_Name__c,
                    Start_Time__c, 
                    End_Time__c,
                    
                    Availability__r.Success_Center__r.Name
            from Counsellor_Availability__c
            where   Availability__r.Success_Center__r.Name = :department and 
                    DAY_Only(Start_Time__c) > :d and   
                    DAY_Only(Start_Time__c) <=:(d.addDays(15))                                          
                                                         ];
                
        return slots;
    }
    
    /*
 *  @author     :   R. Mukherjee
 *  @date       :   3rd August, 2016
 *  @param      :   Department,Centre,Course,Date
 *  @purpose    :   Fetch LWC spesific details
 * 
 */ 
     public static List<Counsellor_Availability__c> getCA_LWC(String department,String center,String course, Date d){
         
         
        System.Debug('#Search Criteria  #   Date:'+d +',Deaprtment:'+department+',Centre:'+center+',Course:'+course);
         
         if(course!=null){
             
             List<Counsellor_Availability__c>  slots=[
            
                    Select  Id,
                            Selected_Course__c,
                            Coach_First_Name__c, 
                            Coach_Last_Name__c,
                            Start_Time__c, 
                            End_Time__c,
                            
                            Availability__r.Success_Center__r.Name
                            
                    from Counsellor_Availability__c
                    where   
                            Availability__r.Success_Center__r.Name = :center and
                            //Availability__r.Course__c = :course and
                            DAY_Only(Start_Time__c) > :d and   
                            DAY_Only(Start_Time__c) <=:(d.addDays(15))                                          
                
                                                                 ];
             return slots;
         }
         else{
            
             List<Counsellor_Availability__c>  slots=[
            
                    Select  Id,
                            Selected_Course__c,
                            Coach_First_Name__c, 
                            Coach_Last_Name__c,
                            Start_Time__c, 
                            End_Time__c,
                            
                            Availability__r.Success_Center__r.Name
                    from Counsellor_Availability__c
                    where   
                            Availability__r.Success_Center__r.Name = :center and
                            DAY_Only(Start_Time__c) > :d and   
                            DAY_Only(Start_Time__c) <=:(d.addDays(15))                                          
                
                                                                 ];
             return slots;
             
         }
   
        
        
    }
    
    
/*
 *  @author     :   R. Mukherjee
 *  @date       :   4th August, 2016
 *  @purpose    :   Fetch  CASA/LWC spesific details according to paremeter 
 */  
      public static List<Counsellor_Availability__c> getCA(String department,String center, Date d){
        
        List<Counsellor_Availability__c> coaches=[
            
    Select  Id,
            Selected_Course__c,
            Coach_First_Name__c, 
            Coach_Last_Name__c,
            Start_Time__c, 
            End_Time__c,
            
            Availability__r.Success_Center__r.Name
    from Counsellor_Availability__c
    where   
           Availability__r.Success_Center__r.Name = :center and
            DAY_Only(Start_Time__c) > :d and   
            DAY_Only(Start_Time__c) <=:(d.addDays(15))                                          

                                                 ];  
        return coaches;
    }
    
}