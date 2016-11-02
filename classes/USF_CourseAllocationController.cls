public with sharing class USF_CourseAllocationController {
    public  List<hed__Course_Offering__c> counselor_courses{get;set;}
    public Contact faculty{get;set;}
    public Map<String, List<courseWrapper>> courseMap {get;set;} 
    public Map<String, List<courseWrapper>> addedCourseMap {get;set;}
    public Map<String, List<courseWrapper>> coachAssignedCourseMap {get;set;}
    public Id termId{get;set;}
    public Id coachID{get;set;}
    public string CWID{get;set;}
    public Map<Id,Eligible_Tutor_Courses__c> couseEligibleMap;
    public Map<Id,hed__Course_Offering__c> courseOfferingMap;
    List<Eligible_Tutor_Courses__c> deleteEligibleList;
    Map<Id,String> idCourseMap;
    Map<Id,String> idSubjectMap;
    Map<Id,String> courseIdMap;
    Map<Id,String> sectionIdMap;
    public Set<Id> courseIdSet{get;set;}
    private final Eligible_Tutor_Courses__c etcRec{get; set;}
    public String selectedStudentId{get;set;}
    
    public USF_CourseAllocationController(ApexPages.StandardController controller){
        
        etcRec = (Eligible_Tutor_Courses__c)controller.getRecord();
        System.debug('Hello');
        idCourseMap = new Map<Id,String>();
        idSubjectMap = new Map<Id,String>();
        courseIdMap = new Map<Id,String>();
        sectionIdMap = new Map<Id,String>();
        couseEligibleMap = new Map<Id,Eligible_Tutor_Courses__c>();
        courseOfferingMap= new Map<Id,hed__Course_Offering__c>();
        deleteEligibleList = new List<Eligible_Tutor_Courses__c>();
        faculty= new contact();           
        courseMap = new Map<String, List<courseWrapper>>();
        addedCourseMap = new Map<String, List<courseWrapper>>();
        coachAssignedCourseMap=new Map<String, List<courseWrapper>>();
        List<hed__Course_Offering__c> courseOfferingList;
        List<hed__Course_Offering__c> coachCourseOfferingList;
        courseIdSet =  new Set<Id>();
        String url = ApexPages.currentPage().getURL();
        //system.debug('asas'+url.indexOf('nishit'));
        //System.debug('p_lkid: '+url.substring(url.indexOf('nishit') + 7));
        system.debug('url: '+url);
        if(url.indexOf('_lkid=') != -1) {
            selectedStudentId = url.substring(url.indexOf('_lkid=') + 6).substring(0,15);
            system.debug('stdId: '+selectedStudentId);
            if(selectedStudentId != '') {
                List<Contact> contacts = [Select CWID__c FROM Contact where Id =: selectedStudentId];
                CWID = contacts[0].CWID__c;
            }
        }
        else {
            CWID = '';
        }
        //getfacultyInfoByCWID();
      
    }      
    public void getfacultyInfoByCWID(){
        System.debug('**selectedStudentId: '+selectedStudentId);
      List<Contact> conList = new List<Contact>();
      System.debug('**CWID: '+CWID);
      //CWID = 'q';
      if(String.isBlank(CWID)){
        selectedStudentId = '';
      }

      if(String.isBlank(selectedStudentId) || selectedStudentId==''){
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No Records Found'));
        faculty= new contact();
      }else{
        /*Changed by Vandana to support Auto-complete functionality of the search box*/
          //conList = [select ID, Name,Academic_Standing__c,CWID__c,ASC_Email__c,MobilePhone from Contact where CWID__c=:CWID limit 1];    
          conList = [select ID, Name,Academic_Standing__c,CWID__c,ASC_Email__c,Phone from Contact where Id=:selectedStudentId limit 1];     
          if(!conList.IsEmpty()){
              faculty = conList[0];
              List<hed__Term__c> termList = [SELECT Id, Name FROM hed__Term__c WHERE hed__Start_Date__c <: Date.Today() AND hed__End_Date__c >=: Date.Today() LIMIT 1];
              //selectedStudentId = '';
                populateCourses(termList[0].Id);                
                //System.debug('**selectedStudentId: '+selectedStudentId);
          }
      }
    }    
    public void addCourses(){
        System.debug('In add courses');
        Map<String, List<courseWrapper>> courseMapTemp = new Map<String, List<courseWrapper>>();
        for(List<courseWrapper> objCourseMap : courseMap.Values()){
            for(courseWrapper wrapObj : objCourseMap ){
                if(wrapObj.selected == true){
                    System.Debug('wrapObj-->'+wrapObj);
                    hed__Course_Offering__c csObj = wrapObj.courseOffering;
                    if(addedCourseMap.containsKey(wrapObj.eligibleSubjectName)){
                        List<courseWrapper> cs = addedCourseMap.get(wrapObj.eligibleSubjectName);
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        Eligible_Tutor_Courses__c newEligibleCourse = new Eligible_Tutor_Courses__c();
                        newEligibleCourse.Contact__c = faculty.Id;
                        if(wrapObj.courseOffering != null)
                            newEligibleCourse.Course_Offering__c = wrapObj.courseOffering.Id;
                        else
                            newEligibleCourse.Course_Offering__c = wrapObj.courseEligible.Course_Offering__c;
                        courseWrapperObj.courseEligible = newEligibleCourse;
                        courseWrapperObj.eligibleCourseName = wrapObj.eligibleCourseName;
                        courseWrapperObj.eligibleSubjectName = wrapObj.eligibleSubjectName;
                        /*Added by R. Mukherjee on Aug 31,2016 */
                        courseWrapperObj.courseID = wrapObj.courseID;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        cs.add(courseWrapperObj);
                        addedCourseMap.put(wrapObj.eligibleSubjectName,cs);
                    }
                    else{
                        List<courseWrapper> cs = new List<courseWrapper>();
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        Eligible_Tutor_Courses__c newEligibleCourse = new Eligible_Tutor_Courses__c();
                        newEligibleCourse.Contact__c = faculty.Id;
                        if(wrapObj.courseOffering != null)
                            newEligibleCourse.Course_Offering__c = wrapObj.courseOffering.Id;
                        else
                            newEligibleCourse.Course_Offering__c = wrapObj.courseEligible.Course_Offering__c;
                        courseWrapperObj.courseEligible = newEligibleCourse;
                        courseWrapperObj.eligibleCourseName = wrapObj.eligibleCourseName;
                        courseWrapperObj.eligibleSubjectName = wrapObj.eligibleSubjectName;
                        /*Added by R. Mukherjee on Aug 31,2016 */
                        courseWrapperObj.courseID = wrapObj.courseID;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        cs.add(courseWrapperObj);
                        addedCourseMap.put(wrapObj.eligibleSubjectName,cs);
                    }
                }
                else{
                    
                    hed__Course_Offering__c csObj = wrapObj.courseOffering;
                    if(courseMapTemp.containsKey(wrapObj.eligibleSubjectName)){
                        List<courseWrapper> cs = courseMapTemp.get(wrapObj.eligibleSubjectName);
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering= csObj;
                        courseWrapperObj.eligibleCourseName = wrapObj.eligibleCourseName;
                        courseWrapperObj.eligibleSubjectName = wrapObj.eligibleSubjectName;
                        /*Added by R. Mukherjee on Aug 31,2016 */
                        courseWrapperObj.courseID = wrapObj.courseID;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        System.Debug('courseWrapperObj-->'+courseWrapperObj);
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(wrapObj.eligibleSubjectName,cs);
                    }
                    else{
                        List<courseWrapper> cs = new List<courseWrapper>();
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering= csObj;
                        courseWrapperObj.eligibleCourseName =  wrapObj.eligibleCourseName;
                        courseWrapperObj.eligibleSubjectName = wrapObj.eligibleSubjectName;
                        /*Added by R. Mukherjee on Aug 31,2016 */
                        courseWrapperObj.courseID = wrapObj.courseID;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        System.Debug('courseWrapperObj-->'+courseWrapperObj);
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(wrapObj.eligibleSubjectName,cs);
                    }
                    
                }
            }    
        }
        courseMap = courseMapTemp.clone();
        System.Debug('$$$$$RA CourseMap '+courseMap);
        
    }
    public void removeCourses(){
        System.debug('In remove courses');
        Map<String, List<courseWrapper>> courseMapTemp = new Map<String, List<courseWrapper>>();
        for(List<courseWrapper> objCourseMap : addedCourseMap.Values()){
            System.debug('objCourseMap:'+objCourseMap);
            for(courseWrapper wrapObj : objCourseMap ){
                System.debug('In for. wrapObj: '+wrapObj);
                if(wrapObj.selected == true){
                    System.debug('Selected=true');
                    Eligible_Tutor_Courses__c csObj = wrapObj.courseEligible;
                    deleteEligibleList.add(csObj);
                    System.Debug(wrapObj.eligibleSubjectName);
                    System.Debug(wrapObj.eligibleCourseName);
                    if(courseMap.containsKey(wrapObj.eligibleSubjectName)){ 
                        System.debug('Course map contains the final header key');
                        List<courseWrapper> cs = courseMap.get(wrapObj.eligibleSubjectName);
                        System.debug('csObj.Course_Offering__c::::'+csObj.Course_Offering__c);
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseOffering = courseOfferingMap.get(csObj.Course_Offering__c);
                        courseWrapperObj.eligibleCourseName = idCourseMap.get(csObj.Course_Offering__c);
                        courseWrapperObj.eligibleSubjectName = idSubjectMap.get(csObj.Course_Offering__c);
                        /*Added by R. Mukherjee on Aug 31,2016 */
                        courseWrapperObj.courseID=courseIdMap.get(csObj.Course_Offering__c);
                         courseWrapperObj.sectionId=sectionIdMap.get(csObj.Course_Offering__c);
                        cs.add(courseWrapperObj);
                        courseMap.put(wrapObj.eligibleSubjectName,cs);
                    }
                    else{
                        System.debug('Course map does not contain the final header key');
                        List<courseWrapper> cs = new List<courseWrapper>();
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        System.debug('csObj.Course_Offering__c::::'+csObj.Course_Offering__c);
                        courseWrapperObj.courseOffering= courseOfferingMap.get(csObj.Course_Offering__c);
                        courseWrapperObj.eligibleCourseName = idCourseMap.get(csObj.Course_Offering__c);
                        courseWrapperObj.eligibleSubjectName = idSubjectMap.get(csObj.Course_Offering__c);
                          /*Added by R. Mukherjee on Aug 31,2016 */
                        courseWrapperObj.courseID=courseIdMap.get(csObj.Course_Offering__c);
                         courseWrapperObj.sectionId=sectionIdMap.get(csObj.Course_Offering__c);
                        System.debug('courseWrapperObj**** '+courseWrapperObj);
                        cs.add(courseWrapperObj);
                        courseMap.put(wrapObj.eligibleSubjectName,cs);
                    }
                }
                else{
                    System.debug('Selected=false');
                    Eligible_Tutor_Courses__c csObj = wrapObj.courseEligible;
                    System.Debug('csObj--->'+csObj );
                    if(courseMapTemp.containsKey(wrapObj.eligibleSubjectName)){
                        System.debug('coursemaptemp contains key');
                        System.Debug('138---->'+wrapObj.eligibleSubjectName);
                        List<courseWrapper> cs = courseMapTemp.get(wrapObj.eligibleSubjectName);
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseEligible= csObj;
                        courseWrapperObj.courseOffering= courseOfferingMap.get(csObj.Course_Offering__c);
                        courseWrapperObj.eligibleCourseName = idCourseMap.get(csObj.Course_Offering__c);
                        courseWrapperObj.eligibleSubjectName = idSubjectMap.get(csObj.Course_Offering__c);
                          /*Added by R. Mukherjee on Aug 31,2016 */
                        courseWrapperObj.courseID=courseIdMap.get(csObj.Course_Offering__c);
                         courseWrapperObj.sectionId=sectionIdMap.get(csObj.Course_Offering__c);
                    
                        //courseWrapperObj.courseOffering.hed__Course__r.subject_name__c =idSubjectMap.get(csObj.Course_Offering__c);
                        //courseWrapperObj.courseOffering.hed__Course__r.Name =idCourseMap.get(csObj.Course_Offering__c);
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(wrapObj.eligibleSubjectName,cs);
                    }
                    else{
                        System.debug('coursemaptemp does not contain key');
                        List<courseWrapper> cs = new List<courseWrapper>();
                        courseWrapper courseWrapperObj = new courseWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.courseEligible= csObj;
                        courseWrapperObj.courseOffering= courseOfferingMap.get(csObj.Course_Offering__c);
                        //courseWrapperObj.courseOffering.hed__Course__r.subject_name__c =idSubjectMap.get(csObj.Course_Offering__c);
                        //courseWrapperObj.courseOffering.hed__Course__r.Name =idCourseMap.get(csObj.Course_Offering__c);
                        System.DEbug('csObj.Course_Offering__c'+csObj.Course_Offering__c);
                        System.DEbug('idCourseMap'+idCourseMap);
                        courseWrapperObj.eligibleCourseName = idCourseMap.get(csObj.Course_Offering__c);
                        courseWrapperObj.eligibleSubjectName = idSubjectMap.get(csObj.Course_Offering__c);
                          /*Added by R. Mukherjee on Aug 31,2016 */
                          System.debug('**courseIdMap.get(csObj.Course_Offering__c):'+courseIdMap.get(csObj.Course_Offering__c));
                          System.debug('**sectionIdMap.get(csObj.Course_Offering__c):'+sectionIdMap.get(csObj.Course_Offering__c));
                          System.debug('sectionIdMap on removal: '+sectionIdMap);
                          System.debug('courseIdMap on removal: '+courseIdMap);
                        courseWrapperObj.courseID=courseIdMap.get(csObj.Course_Offering__c);
                         courseWrapperObj.sectionId=sectionIdMap.get(csObj.Course_Offering__c);
                        
                        System.Debug('162---->'+courseWrapperObj.eligibleSubjectName);
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(wrapObj.eligibleSubjectName,cs);
                    }
                    
                }
            }    
        }
        addedCourseMap = courseMapTemp.clone();
    }
    
    public void populateCourses(Id objTermId){
        List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>();
        List<Eligible_Tutor_Courses__c> courseEligibleList = new List<Eligible_Tutor_Courses__c>();
        courseIdSet =  new Set<Id>();
        courseMap = new Map<String, List<courseWrapper>>();
        addedCourseMap = new Map<String, List<courseWrapper>>();
        courseOfferingList = [SELECT Id,hed__Section_ID__c,hed__Faculty__c,hed__Course__r.hed__Course_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c,hed__Term__c,LWC_Tutor__c FROM hed__Course_Offering__c WHERE Active__c =: True AND hed__Term__c =: objTermId AND LWC_Tutor__c =:TRUE ORDER BY hed__Course__r.subject_name__c ASC,hed__Course__r.hed__Course_ID__c ASC,hed__Course__r.Name ASC,hed__Section_ID__c ASC];
 /*       courseEligibleList = [SELECT Id,Contact__c,Course_Offering__r.hed__Course__r.subject_name__c,Course_Offering__r.hed__Course__r.Course_Number__c,Course_Offering__r.hed__Course__r.Name FROM Eligible_Tutor_Courses__c WHERE Contact__c=: faculty.Id];*/
           courseEligibleList = [SELECT Id,Course_Offering__c,Course_Offering__r.hed__Section_ID__c,Course_Offering__r.hed__Course__r.hed__Course_ID__c ,Contact__c,Course_Offering__r.hed__Course__r.subject_name__c,Course_Offering__r.hed__Course__r.Course_Number__c,Course_Offering__r.hed__Course__r.Name FROM Eligible_Tutor_Courses__c WHERE Contact__c=: faculty.Id ORDER BY Course_Offering__r.hed__Course__r.subject_name__c ASC,Course_Offering__r.hed__Course__r.hed__Course_ID__c ASC,Course_Offering__r.hed__Course__r.Name ASC,Course_Offering__r.hed__Section_ID__c ASC];
        
        if(!courseEligibleList.isEmpty()){
            for(Eligible_Tutor_Courses__c courseObj : courseEligibleList ){
                courseIdSet.add(courseObj.Course_Offering__c);
                idCourseMap.put(courseObj.Course_Offering__c,courseObj.Course_Offering__r.hed__Course__r.Name);
                idSubjectMap.put(courseObj.Course_Offering__c,courseObj.Course_Offering__r.hed__Course__r.subject_name__c);
                /*Added by R. Mukherjee */
                courseIdMap.put(courseObj.Course_Offering__c,courseObj.Course_Offering__r.hed__Course__r.hed__Course_ID__c);
                sectionIdMap.put(courseObj.Course_Offering__c, courseObj.Course_Offering__r.hed__Section_ID__c);
                System.debug('sectionIdMap selected courses: '+sectionIdMap);

                if(addedCourseMap.containsKey(courseObj.Course_Offering__r.hed__Course__r.subject_name__c)){
                    List<courseWrapper> cs = addedCourseMap.get(courseObj.Course_Offering__r.hed__Course__r.subject_name__c);
                    courseWrapper csObj = new courseWrapper();
                    csObj.selected= FALSE;
                    csObj.courseEligible= courseObj;
                    csObj.eligibleCourseName = csObj.courseEligible.Course_Offering__r.hed__Course__r.Name;
                    csObj.eligibleSubjectName = csObj.courseEligible.Course_Offering__r.hed__Course__r.subject_name__c;
                    /*Added by Ritam on Aug 30*/
                    
                    csObj.courseId= csObj.courseEligible.Course_Offering__r.hed__Course__r.hed__Course_ID__c;
                    csObj.sectionId =csObj.courseEligible.Course_Offering__r.hed__Section_ID__c;
                    System.debug('#####courseid :'+csObj.courseId +',Section Id :'+csObj.sectionId);
                    cs.add(csObj);
                    addedCourseMap.put(courseObj.Course_Offering__r.hed__Course__r.subject_name__c,cs);
                }
                else{
                    List<courseWrapper> cs = new List<courseWrapper>();
                    courseWrapper csObj = new courseWrapper();
                    csObj.selected= FALSE;
                    csObj.courseEligible= courseObj;
                   
                    csObj.eligibleCourseName = csObj.courseEligible.Course_Offering__r.hed__Course__r.Name;
                    csObj.eligibleSubjectName = csObj.courseEligible.Course_Offering__r.hed__Course__r.subject_name__c;
                     /*Added by Ritam on Aug 30*/
                    csObj.courseId= csObj.courseEligible.Course_Offering__r.hed__Course__r.hed__Course_ID__c;
                    csObj.sectionId =csObj.courseEligible.Course_Offering__r.hed__Section_ID__c;
                       System.debug('#####courseid  :'+csObj.courseId +',Section Id :'+csObj.sectionId);
                    cs.add(csObj);
                    addedCourseMap.put(courseObj.Course_Offering__r.hed__Course__r.subject_name__c,cs);
                }    
            }
        }
    
    if(!courseIdSet.isEmpty()){
            courseOfferingMap = new Map<Id,hed__Course_Offering__c>([SELECT Id,hed__Section_ID__c,hed__Faculty__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c FROM hed__Course_Offering__c WHERE Id IN :courseIdSet]);
        }
        
        if(!courseOfferingList.isEmpty()){
            for(hed__Course_Offering__c courseObj : courseOfferingList){
                //System.debug('###courseObj.Id: '+courseObj.Id);
                if(!courseIdSet.contains(courseObj.id)){
                    idCourseMap.put(courseObj.Id,courseObj.hed__Course__r.Name);
                    idSubjectMap.put(courseObj.Id,courseObj.hed__Course__r.subject_name__c);
                    
                    /*Added by R. Mukherjee */
                    courseOfferingMap.put(courseObj.Id,courseObj);
                   /*Added by R. Mukherjee */
                    courseIdMap.put(courseObj.Id,courseObj.hed__Course__r.hed__Course_ID__c);
                    sectionIdMap.put(courseObj.Id, courseObj.hed__Section_ID__c);
                    System.debug('sectionIdMap available courses: '+sectionIdMap);
                    if(courseMap.containsKey(courseObj.hed__Course__r.subject_name__c)){
                        List<courseWrapper> cs = courseMap.get(courseObj.hed__Course__r.subject_name__c);
                        courseWrapper csObj = new courseWrapper();
                        csObj.selected= FALSE;
                        csObj.courseOffering = courseObj;
                        csObj.eligibleCourseName = csObj.courseOffering.hed__Course__r.Name;
                        csObj.eligibleSubjectName = csObj.courseOffering.hed__Course__r.subject_name__c;
                          /*Added by Ritam on Aug 30*/
                        csObj.courseId= csObj.courseOffering.hed__Course__r.hed__Course_ID__c;
                        csObj.sectionId =csObj.courseOffering.hed__Section_ID__c;
                           System.debug('#####courseid  :'+csObj.courseId +',Section Id :'+csObj.sectionId+',eligibleCourseName:'+csObj.eligibleCourseName);
                        if(csObj.courseId == null) {
                            csObj.courseId = 'NA';
                        }
                        if(csObj.sectionId == null) {
                            csObj.sectionId = 'NA';
                        }
                        cs.add(csObj);
                        if(courseObj.hed__Course__r.subject_name__c != null) {
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                    }
                    else{
                        List<courseWrapper> cs = new List<courseWrapper>();
                        courseWrapper csObj = new courseWrapper();
                        csObj.selected= FALSE;
                        csObj.courseOffering = courseObj;
                        csObj.eligibleCourseName = csObj.courseOffering.hed__Course__r.Name;
                        csObj.eligibleSubjectName = csObj.courseOffering.hed__Course__r.subject_name__c;
                        
                          /*Added by Ritam on Aug 30*/
                    csObj.courseId= csObj.courseEligible.Course_Offering__r.hed__Course__r.hed__Course_ID__c;
                    csObj.sectionId =csObj.courseEligible.Course_Offering__r.hed__Section_ID__c;
                       System.debug('#####courseid1  :'+courseObj.hed__Course__r.subject_name__c +',Section Id :'+csObj.sectionId);
                       if(csObj.courseId == null) {
                            csObj.courseId = 'NA';
                        }
                        if(csObj.sectionId == null) {
                            csObj.sectionId = 'NA';
                        }
                        System.debug('#####courseid12  :'+csObj.courseId +',Section Id :'+csObj.sectionId);    
                        cs.add(csObj);
                        if(courseObj.hed__Course__r.subject_name__c != null) {
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        
                   }
                }
            }
        }
        
        /*for(courseWrapper test : courseMap.get('Biology')){
            System.debug('title: '+test.eligibleSubjectName);
            System.debug('content: '+test.courseID+' - '+test.eligibleCourseName+'('+test.sectionId+')');
        }*/
        System.Debug('idSubjectMap'+idSubjectMap);
    }
        public void saveCourses(){
            List<Eligible_Tutor_Courses__c> updateCourseList = new List<Eligible_Tutor_Courses__c>();
            try{  
                for(List<courseWrapper> objCourseMap : addedCourseMap.Values()){
                    for(courseWrapper wrapObj : objCourseMap ){
                       if(!courseIdSet.contains(wrapObj.courseEligible.Course_Offering__c)){
                          updateCourseList.add(wrapObj.courseEligible);
                          courseIdSet.add(wrapObj.courseEligible.Course_Offering__c);
                       }
                    }
                }  
                if(!updateCourseList.isEmpty()){
                    for(Eligible_Tutor_Courses__c ETCc:updateCourseList){
                        System.debug('ETCc  >>'+ETCc);
                    }
                
                  insert updateCourseList;                  
                }
                if(!deleteEligibleList.isEmpty()){
                    Database.Delete(deleteEligibleList);
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
            public Eligible_Tutor_Courses__c courseEligible{get;set;}
            public String eligibleSubjectName {get;set;}
            public String eligibleCourseName {get;set;}
            public boolean selected {get;set;}
            public String courseID {get;set;}
            public String sectionId {get;set;}
            public courseWrapper(){
                
            }
            
        }
        
    }