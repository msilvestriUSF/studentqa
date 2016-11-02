public with sharing class USF_CourseConfigrator{
    
    public Map<String, List<courseWrapper>> courseMap {get;set;} 
    public Map<String, List<courseWrapper>> addedCourseMap {get;set;}
    public Id termId{get;set;}
    public String Levels{get;set;}
    public String types {get;set;}
    public String offeredtype{get;set;}
    public String campusid {get;set;}
    
    public String  condition=USF_Constant.USF_EMPTY;
   
    
    public USF_CourseConfigrator(){
        courseMap = new Map<String, List<courseWrapper>>();
        addedCourseMap = new Map<String, List<courseWrapper>>();
        
        List<hed__Term__c> termList = [SELECT Id, Name FROM hed__Term__c WHERE hed__Start_Date__c <:Date.Today() AND hed__End_Date__c >=:Date.Today() LIMIT 1]; 
        if(!termList.iSEmpty()){
            termId = termList[0].Id;
            types = 'Tutoring';
            Levels = USF_Constant.USF_COURSECONFIGURATOR_NONE;
            offeredtype = USF_Constant.USF_COURSECONFIGURATOR_NONE;
            campusid= USF_Constant.USF_COURSECONFIGURATOR_NONE;
            populateCourses(termId,types,Levels,offeredtype,campusid);
        
        }
    }
    
    public List<SelectOption> getTerms() {     
        List<SelectOption> options = new List<SelectOption>();
        List<hed__Term__c> termsList =  [Select id, Name From hed__Term__c WHERE hed__End_Date__c >=:Date.Today()  order by hed__Start_Date__c ];
        for(hed__Term__c objTerm : termsList ){
            options.add(new  SelectOption(objTerm.id, objTerm.Name));
        }
        return options;
    }
    
    
    
    
    
   public List<SelectOption> getCampus() {     
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        List<AggregateResult> groupedResults = [select Campus__c, count(id) from hed__course_offering__c where Campus__c!=null group by Campus__c];
        Schema.DescribeFieldResult fieldResult = hed__course_offering__c.Campus__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
//for (AggregateResult ar : groupedResults)  {
        for(Schema.PicklistEntry f : ple) {
 //system.debug()
    //options.add(new SelectOption('--None--','--None--'));
     //--String start1=(String)ar.get('Campus__c');
     // hed__course_offering__c start1=(hed__course_offering__c)ar.get('Campus__c');

//if(start1 !=NULL ) 
//{
            // options.add(new SelectOption(ar.get('Campus__c'),ar.get('Campus__c')));     
             options.add(new SelectOption(f.getLabel(),f.getValue()));    
             //} 
     }
        options.sort();
        return options; 
      
    }
    
    
    public List<SelectOption> getMode() {     
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('--None--','--None--'));
        List<AggregateResult> groupedResults = [select Offering_Type__c, count(id) from hed__course_offering__c where Offering_Type__c!=null group by Offering_Type__c];
        Schema.DescribeFieldResult fieldResult = hed__course_offering__c.Offering_Type__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        //for (AggregateResult ar : groupedResults)  {
         for(Schema.PicklistEntry f : ple) {
         //system.debug()
        //options.add(new SelectOption('None',''));
             //----String start1=(String)ar.get('Offering_Type__c');
             // hed__course_offering__c start1=(hed__course_offering__c)ar.get('Campus__c');

        //if(!String.isempty(start1) ) 
        //{
            // options.add(new SelectOption(ar.get('Campus__c'),ar.get('Campus__c')));     
             options.add(new SelectOption(f.getLabel(),f.getValue()));    
             //} 
        }
        options.sort();
        return options;  
      
    }
    
    
    
    
   public List<SelectOption> getLevel() {     
        List<SelectOption> options = new List<SelectOption>();
     
        options.add(new SelectOption('--None--','--None--'));

        Schema.DescribeFieldResult fieldResult = hed__Course_Offering__c.Level__c.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry p : ple)

        options.add(new SelectOption(p.getValue(), p.getValue()));     
     
      /*  List<hed__Term__c> termsList =  [Select id, Name From hed__Term__c WHERE hed__End_Date__c >=:Date.Today()  order by hed__Start_Date__c ];
        for(hed__Term__c objTerm : termsList ){
            options.add(new  SelectOption(objTerm.id, objTerm.Name));
        }*/
        
        options.sort();
        return options;
    }   
    
    public List<SelectOption> getType() {     
        List<SelectOption> options = new List<SelectOption>();
     
        //options.add(new SelectOption('--None--','--None--'));

        Schema.DescribeFieldResult fieldResult = hed__Course_Offering__c.Type__c.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry p : ple)

        options.add(new SelectOption(p.getValue(), p.getValue()));     
     
      /*  List<hed__Term__c> termsList =  [Select id, Name From hed__Term__c WHERE hed__End_Date__c >=:Date.Today()  order by hed__Start_Date__c ];
        for(hed__Term__c objTerm : termsList ){
            options.add(new  SelectOption(objTerm.id, objTerm.Name));
        }*/
        
        //options.sort();
        return options;
    }
    
    public void addCourses(){
        Map<String, List<courseWrapper>> courseMapTemp = new Map<String, List<courseWrapper>>();
        for(List<courseWrapper> objCourseMap : courseMap.Values()){
            for(courseWrapper wrapObj : objCourseMap ){
                System.debug('wrapObj**'+wrapObj);
                if(wrapObj.selected == true){
                    hed__Course_Offering__c csObj = wrapObj.courseOffering;
                    if(addedCourseMap.containsKey(csObj.hed__Course__r.subject_name__c)){
                        List<courseWrapper> cs = addedCourseMap.get(csObj.hed__Course__r.subject_name__c);
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering = csObj;
                        if(types == 'SI Session') {
                            courseWrapperObj.courseOffering.SI_Session__c = True;
                        }
                        else if(types == 'PLTL') {
                            courseWrapperObj.courseOffering.PLTL__c = True;
                        }
                        else if(types == 'Tutoring') {
                            courseWrapperObj.courseOffering.LWC_Tutor__c = True;
                        }
                        cs.add(courseWrapperObj);
                        addedCourseMap.put(csObj.hed__Course__r.subject_name__c,cs);
                    }
                    else{
                        List<courseWrapper> cs = new List<courseWrapper>();
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering= csObj;
                        cs.add(courseWrapperObj);
                        addedCourseMap.put(csObj.hed__Course__r.subject_name__c,cs);
                    }
                }
                else{
                    
                    hed__Course_Offering__c csObj = wrapObj.courseOffering;
                    if(courseMapTemp.containsKey(csObj.hed__Course__r.subject_name__c)){
                        List<courseWrapper> cs = courseMapTemp.get(csObj.hed__Course__r.subject_name__c);
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering= csObj;
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(csObj.hed__Course__r.subject_name__c,cs);
                    }
                    else{
                        List<courseWrapper> cs = new List<courseWrapper>();
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering= csObj;
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(csObj.hed__Course__r.subject_name__c,cs);
                    }
                    
                }
            }    
        }
        courseMap = courseMapTemp.clone();
    }
    public void removeCourses(){
        Map<String, List<courseWrapper>> courseMapTemp = new Map<String, List<courseWrapper>>();
        for(List<courseWrapper> objCourseMap : addedCourseMap.Values()){
            for(courseWrapper wrapObj : objCourseMap ){
                if(wrapObj.selected == true){
                    hed__Course_Offering__c csObj = wrapObj.courseOffering;
                    if(courseMap.containsKey(csObj.hed__Course__r.subject_name__c)){
                        List<courseWrapper> cs = courseMap.get(csObj.hed__Course__r.subject_name__c);
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering = csObj;
                        if(types == 'SI Session') {
                            courseWrapperObj.courseOffering.SI_Session__c = True;
                        }
                        else if(types == 'PLTL') {
                            courseWrapperObj.courseOffering.PLTL__c = True;
                        }
                        else if(types == 'Tutoring') {
                            courseWrapperObj.courseOffering.LWC_Tutor__c = True;
                        }
                        cs.add(courseWrapperObj);
                        courseMap.put(csObj.hed__Course__r.subject_name__c,cs);
                    }
                    else{
                        List<courseWrapper> cs = new List<courseWrapper>();
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering= csObj;
                        cs.add(courseWrapperObj);
                        courseMap.put(csObj.hed__Course__r.subject_name__c,cs);
                    }
                }
                else{
                    
                    hed__Course_Offering__c csObj = wrapObj.courseOffering;
                    if(courseMapTemp.containsKey(csObj.hed__Course__r.subject_name__c)){
                        List<courseWrapper> cs = courseMapTemp.get(csObj.hed__Course__r.subject_name__c);
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering= csObj;
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(csObj.hed__Course__r.subject_name__c,cs);
                    }
                    else{
                        List<courseWrapper> cs = new List<courseWrapper>();
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering= csObj;
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(csObj.hed__Course__r.subject_name__c,cs);
                    }
                    
                }
            }    
        }
        System.Debug('courseMapTemp-->'+courseMapTemp);
        addedCourseMap = courseMapTemp.clone();
        System.Debug('addedCourseMap -->'+addedCourseMap);
    }
    
    
    public void populateCourses(Id objTermId,String types, String Levels,string offeredtype,String campusid){
        List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>();
        courseMap = new Map<String, List<courseWrapper>>();
        addedCourseMap = new Map<String, List<courseWrapper>>();
        condition = '';
        
        if(types == 'SI Session' || types == 'PLTL') {
            condition = ' AND RecordType.Name =\'Banner Course Offering\'';
        }
        
        if(Levels != '--None--')  
        {
        //if(Levels!='')
        //CT Id,hed__Section_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c FROM hed__Course_Offering__c WHERE Active__c =: True AND hed__Term__c =: objTermId AND Level__c=:levels AND campus__c=:campusid AND Offering_Type__c=:offeredtype order by hed__Course__r.Name ];
     condition=' AND hed__Course_Offering__c.Level__c=\''+Levels+'\'';
            
         }


         if(offeredtype != '--None--' )  
        {
        
        //if(offeredtype!='')
        
     condition+=' AND hed__Course_Offering__c.offering_type__c=\''+offeredtype+'\'';
            
         }
         
        if(campusid != '--None--')  
        {
            system.debug('helllllooooooooooofferedtypecampusid'+campusid);
            //if(campusid!='')
         
            // courseOfferingList = [SELECT Id,hed__Section_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c FROM hed__Course_Offering__c WHERE Active__c =: True AND hed__Term__c =: objTermId AND Level__c=:levels AND campus__c=:campusid AND Offering_Type__c=:offeredtype order by hed__Course__r.Name ];
            condition+=' AND hed__Course_Offering__c.Campus__c=\''+campusid+'\'';
        } 
         
         String myTestString = objTermId;
         String cam=campusid;
         string mode=offeredtype;
         string lev=Levels;
         String ar='SELECT Id,hed__Section_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c,SI_Session__c,PLTL__c FROM hed__Course_Offering__c WHERE Active__c =: True AND hed__Term__c =:myTestString  order by hed__Course__r.Name';
     
        System.debug(' SOOOOOOQLLLL'+ar);
     
        //courseOfferingList=Database.query('SELECT Id,hed__Section_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c FROM hed__Course_Offering__c WHERE Active__c = True AND hed__Term__c =:myTestString AND Level__c=:lev AND  campus__c=:cam AND Offering_Type__c=:mode order by hed__Course__r.Name');
        String test = 'SELECT Id,hed__Section_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c,SI_Session__c,PLTL__c FROM hed__Course_Offering__c WHERE Active__c = True AND hed__Term__c =:myTestString '+condition+' order by hed__Course__r.Name';
        System.debug('testQuery: '+test);
        courseOfferingList=Database.query('SELECT Id,hed__Section_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c,SI_Session__c,PLTL__c FROM hed__Course_Offering__c WHERE Active__c = True AND hed__Term__c =:myTestString '+condition+' order by hed__Course__r.Name');
        system.debug('courseOfferingList: '+courseOfferingList);
        
        
        if(!courseOfferingList.isEmpty()){
          System.debug('courseOfferingList.size()'+courseOfferingList.size());
            for(hed__Course_Offering__c courseObj : courseOfferingList){
                if(types == 'SI Session') {
                    if(courseObj.SI_Session__c){
                        if(addedCourseMap.containsKey(courseObj.hed__Course__r.subject_name__c)){
                            List<courseWrapper> cs = addedCourseMap.get(courseObj.hed__Course__r.subject_name__c);
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            addedCourseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        else{
                            List<courseWrapper> cs = new List<courseWrapper>();
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            addedCourseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        
                    }
                    else{
                        if(courseMap.containsKey(courseObj.hed__Course__r.subject_name__c)){
                            List<courseWrapper> cs = courseMap.get(courseObj.hed__Course__r.subject_name__c);
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        else{
                            List<courseWrapper> cs = new List<courseWrapper>();
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                    }
                }
                else if(types == 'PLTL') {
                    if(courseObj.PLTL__c){
                        if(addedCourseMap.containsKey(courseObj.hed__Course__r.subject_name__c)){
                            List<courseWrapper> cs = addedCourseMap.get(courseObj.hed__Course__r.subject_name__c);
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            addedCourseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        else{
                            List<courseWrapper> cs = new List<courseWrapper>();
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            addedCourseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        
                    }
                    else{
                        if(courseMap.containsKey(courseObj.hed__Course__r.subject_name__c)){
                            List<courseWrapper> cs = courseMap.get(courseObj.hed__Course__r.subject_name__c);
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        else{
                            List<courseWrapper> cs = new List<courseWrapper>();
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                    }
                }
                else if(types == 'Tutoring') {
                    if(courseObj.LWC_Tutor__c){
                        if(addedCourseMap.containsKey(courseObj.hed__Course__r.subject_name__c)){
                            List<courseWrapper> cs = addedCourseMap.get(courseObj.hed__Course__r.subject_name__c);
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            addedCourseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        else{
                            List<courseWrapper> cs = new List<courseWrapper>();
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            addedCourseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        
                    }
                    else{
                        if(courseMap.containsKey(courseObj.hed__Course__r.subject_name__c)){
                            List<courseWrapper> cs = courseMap.get(courseObj.hed__Course__r.subject_name__c);
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        else{
                            List<courseWrapper> cs = new List<courseWrapper>();
                            courseWrapper csObj = new courseWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseObj;
                            cs.add(csObj);
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                    }
                }
                //
            }
        }
        else{
            courseMap = new Map<String, List<courseWrapper>>();
            addedCourseMap = new Map<String, List<courseWrapper>>();
        }
        
    }
        public void populateCoursesBasedUponTerm(){
            System.Debug('##RA'+ termId);
            System.Debug('##levels'+ levels);
            System.Debug('##offeredtype'+ offeredtype);
            System.Debug('##campusid'+ campusid);
            populateCourses(termId,types,levels,offeredtype,campusid);
            
        }
        public void saveCourses(){
          try{
            System.Debug('addedCourseMap -->'+addedCourseMap);
              System.Debug('courseMap -->'+courseMap);
              List<hed__Course_Offering__c> updateCourseList = new List<hed__Course_Offering__c>();
              for(List<courseWrapper> objCourseMap : courseMap.Values()){
                  for(courseWrapper wrapObj : objCourseMap ){ 
                      System.Debug('##RA______--->'+ wrapObj.courseOffering.hed__Course__r.Name + '------>'+wrapObj.courseOffering.LWC_Tutor__c);
                      if(types == 'SI Session') {
                        wrapObj.courseOffering.SI_Session__c =False;
                      }
                      else if(types == 'PLTL') {
                        wrapObj.courseOffering.PLTL__c =False;
                      }
                      else if(types == 'Tutoring') {
                        wrapObj.courseOffering.LWC_Tutor__c =False;
                      }
                      updateCourseList.add(wrapObj.courseOffering);
                  }
              }       
              for(List<courseWrapper> objCourseMap : addedCourseMap.Values()){
                  for(courseWrapper wrapObj : objCourseMap ){ 
                      System.Debug('##RA______--->'+ wrapObj.courseOffering.hed__Course__r.Name + '------>'+wrapObj.courseOffering.LWC_Tutor__c);
                      if(types == 'SI Session') {
                        wrapObj.courseOffering.SI_Session__c = TRUE;
                      }
                      else if(types == 'PLTL') {
                        wrapObj.courseOffering.PLTL__c =TRUE;
                      }
                      else if(types == 'Tutoring') {
                        wrapObj.courseOffering.LWC_Tutor__c =TRUE;
                      }
                      updateCourseList.add(wrapObj.courseOffering);
                  }
              }  
              if(!updateCourseList.isEmpty()){                  
                  Database.Update(updateCourseList);
              }
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Records are successfully updated'));
          }catch (DMLException e){
                String message = '';
                 System.debug('esc--->'+e);
                 for (Integer i = 0; i < e.getNumDml(); i++) {
                 message += e.getDmlMessage(i);
               }
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
            } catch(Exception ex){
                System.debug('esc--->'+ex);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            }               
        }
        
    public class courseWrapper{
    
        public hed__Course_Offering__c courseOffering {get;set;}
        public boolean selected{get;set;}
        
        public courseWrapper(){
        
        }
        
    }

}