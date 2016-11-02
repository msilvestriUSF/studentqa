Public class USF_DateTimeService{
    
    public Set<DateTime> removeNonWorkingTime(set<DateTime> setAllDateTime, account recAccount){
        Set<DateTime> validDateTime = setAllDateTime;
        if(setAllDateTime!=null && !setAllDateTime.isEmpty() &&setAllDateTime.size() > 0 && recAccount!=null){
            
            if(recAccount.BusinessHour__c!=null){
                for(DateTime providedDate: setAllDateTime){
                    if(!BusinessHours.isWithin(recAccount.BusinessHour__c,providedDate))
                        validDateTime.remove(providedDate);
                }
            }
            else{
                BusinessHours defaultBusinessHours = getdefaultBusinessHours();
                if(defaultBusinessHours!=null){
                    for(DateTime providedDate: setAllDateTime){
                        if(!BusinessHours.isWithin(defaultBusinessHours.Id,providedDate))
                            validDateTime.remove(providedDate);
                    }                   
                }
                
            }
        }
        return validDateTime;
    }
    
    public BusinessHours getdefaultBusinessHours(){
        BusinessHours bh = [SELECT Id FROM BusinessHours WHERE IsDefault=true];
        return bh;
    }
    
    
    public Map<Account,List<Set<DateTime>>> getValidInvalidDateTimeMap(Map<Account, set<Datetime>> inputMap){
        
        /*  map populated*/
        Map<Account,List<Set<DateTime>>> validDateTimeMap =new Map<Account,List<Set<DateTime>>>()   ;
        Set<DateTime> setAllDateTime;
        List<Set<DateTime>> validDateTimeList;
        Set<DateTime> validDateTime;
        Set<DateTime> invalidDateTime;
        for(Account recAccount:inputMap.keySet()){
            System.debug('{recAccounts Business Hour}'+recAccount.BusinessHour__c);
            /* Id populated*/
            Id acc_id=recAccount.Id;
            setAllDateTime=inputMap.get(recAccount);
                 
            
            /*  List populated  */ 
            validDateTimeList=new List<Set<DateTime>>();
           
            
            /*  populate two sets with valid tim slot and invalid time slot  */ 
            validDateTime = inputMap.get(recAccount);
            System.Debug('##before processing[validDateTime]    :'+validDateTime);
            invalidDateTime=new Set<DateTime>();
            System.Debug('before processing[invalidDateTime]    :'+invalidDateTime);
            
            /*logic for generating valid and invalid date Time */
            if(setAllDateTime!=null && !setAllDateTime.isEmpty() &&setAllDateTime.size() > 0 && recAccount!=null){
                
                if(recAccount.BusinessHour__c!=null){
                    for(DateTime providedDate: setAllDateTime){
                        
                        if(!BusinessHours.isWithin(recAccount.BusinessHour__c,providedDate.date())){
                           
                            validDateTime.remove(providedDate);
                        invalidDateTime.add(providedDate);
                        }
                    }
                }
                else{
                    BusinessHours defaultBusinessHours = getdefaultBusinessHours();
                    if(defaultBusinessHours!=null){
 

                        for(DateTime providedDate: setAllDateTime){
                        System.debug('{recAccount.BusinessHour__c}:'+recAccount.BusinessHour__c +'&{providedDate}'+providedDate);

                            if(!BusinessHours.isWithin(defaultBusinessHours.Id,providedDate.date())){
                                validDateTime.remove(providedDate);
                            invalidDateTime.add(providedDate);
                            }
                        }                   
                    }
                    
                }
            }
            
            /* gaenerate List */
            validDateTimeList.add(validDateTime);
            validDateTimeList.add(invalidDateTime);
            validDateTimeMap.put(recAccount, validDateTimeList);
        }
        
    
    return validDateTimeMap;
}
   
    
        public Map<Account,Set<DateTime>> getValidDateTimeMap(Map<Account, set<Datetime>> inputMap){
        
        /*  map populated*/
        Map<Account,Set<DateTime>> validDateTimeMap =new Map<Account,Set<DateTime>>()   ;
        Set<DateTime> setAllDateTime;
        Set<DateTime> validDateTime;
        
        for(Account recAccount:inputMap.keySet()){
            /* Id populated*/
            Id acc_id=recAccount.Id;
            setAllDateTime=inputMap.get(recAccount);
                 
            
            /*  List populated  
            List<Set<DateTime>> validDateTimeList=new List<Set<DateTime>>();*/ 
           
            
            /*  populate two sets with valid tim slot and invalid time slot  */ 
            validDateTime = inputMap.get(recAccount);
    
            
            /*logic for generating valid and invalid date Time */
            if(setAllDateTime!=null && !setAllDateTime.isEmpty() &&setAllDateTime.size() > 0 && recAccount!=null){
                
                if(recAccount.BusinessHour__c!=null){
                    for(DateTime providedDate: setAllDateTime){
                        if(!BusinessHours.isWithin(recAccount.BusinessHour__c,providedDate)){
                            validDateTime.remove(providedDate);
                        }
                        
                    }
                }
                else{
                    BusinessHours defaultBusinessHours = getdefaultBusinessHours();
                    if(defaultBusinessHours!=null){
                        for(DateTime providedDate: setAllDateTime){
                            if(!BusinessHours.isWithin(defaultBusinessHours.Id,providedDate)){
                                validDateTime.remove(providedDate);
                            }
                         
                        }                   
                    }
                    
                }
            }
            
           

          
            validDateTimeMap.put(recAccount, validDateTime);
        }
        
    
    return validDateTimeMap;
}
    
/*
 *  Name        :   getValidInvalidDateTimeMap_map
 *  Author      :   Ritam Mukherjee
 *  Date        :   10/28/2016
 *  Parameter   :   Map<Account, set<Datetime>> inputMap    
 *  Return      :   Map<Account,Map<String,Set<DateTime>>>
 *  
 * 
 * */    
    
        public Map<Account,Map<String,Set<DateTime>>> getValidInvalidDateTimeMap_map(Map<Account, set<Datetime>> inputMap){
        
        /*  map populated*/
        Map<Account,Map<String,Set<DateTime>>> validDateTimeMap =new Map<Account,Map<String,Set<DateTime>>>()   ;
        Id acc_id;
        Set<DateTime> setAllDateTime;
        Set<DateTime> validDateTime;
        Set<DateTime> invalidDateTime;
        Map<String,Set<DateTime>> valid_invalid_map;
        for(Account recAccount:inputMap.keySet()){
            System.debug('{recAccounts Business Hour}'+recAccount.BusinessHour__c);
            /* Id populated*/
            acc_id=recAccount.Id;
            setAllDateTime=inputMap.get(recAccount);
                 
            
            /*  List populated  */ 
            valid_invalid_map=new Map<String,Set<DateTime>>();
           
            
            /*  populate two sets with valid tim slot and invalid time slot  */ 
            validDateTime = inputMap.get(recAccount);
            System.Debug('##before processing[validDateTime]    :'+validDateTime);
            invalidDateTime=new Set<DateTime>();
            System.Debug('before processing[invalidDateTime]    :'+invalidDateTime);
            
            /*logic for generating valid and invalid date Time */
            if(setAllDateTime!=null && !setAllDateTime.isEmpty() &&setAllDateTime.size() > 0 && recAccount!=null){
                
                if(recAccount.BusinessHour__c!=null){
                    for(DateTime providedDate: setAllDateTime){
                        system.debug('providedDate: '+providedDate.date());
                        system.debug('recAccount.BusinessHour__c: '+recAccount.BusinessHour__c);
                        if(!BusinessHours.isWithin(recAccount.BusinessHour__c,providedDate)){ // Nishit 
                            system.debug('providedDateIN: '+providedDate);
                            validDateTime.remove(providedDate);
                        invalidDateTime.add(providedDate);
                        system.debug('invalidDateTimeIN: '+invalidDateTime);
                        }
                    }
                }
                else{
                    BusinessHours defaultBusinessHours = getdefaultBusinessHours();
                    if(defaultBusinessHours!=null){
 

                        for(DateTime providedDate: setAllDateTime){
                        System.debug('{recAccount.BusinessHour__c}:'+recAccount.BusinessHour__c +'&{providedDate}'+providedDate);

                            if(!BusinessHours.isWithin(defaultBusinessHours.Id,providedDate)){
                                validDateTime.remove(providedDate);
                            invalidDateTime.add(providedDate);
                            }
                        }                   
                    }
                    
                }
            }
            
            /* gaenerate List */
            valid_invalid_map.put(USF_Constant.VALID_DATE_TIME,validDateTime);
            valid_invalid_map.put(USF_Constant.INVALID_DATE_TIME,invalidDateTime);
            validDateTimeMap.put(recAccount, valid_invalid_map);
        }
        
    
    return validDateTimeMap;
}
}