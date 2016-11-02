public without sharing class USF_LearningProgramCtrl{
    
    public Map<String, List<studentsWrapper>> courseMap {get;set;} 
    public Map<String, List<studentsWrapper>> addedCourseMap {get;set;}
    public Learning_Program__c siSession {get;set;}
    public String siSessionId {get;set;}
    public String programName {get;set;}
    public Id termId{get;set;}
    public String Levels{get;set;}
    public String types {get;set;}
    public String offeredtype{get;set;}
    public String campusid {get;set;}
    public String startDate {get;set;}
    public String endDate {get;set;}
    public String startTime {get;set;}
    public String endTime {get;set;}
    public List<SelectOption> timeList {get;set;}
    
    public String  condition=USF_Constant.USF_EMPTY;
   
    
    public USF_LearningProgramCtrl(ApexPages.StandardController stdController){
        courseMap = new Map<String, List<studentsWrapper>>();
        addedCourseMap = new Map<String, List<studentsWrapper>>();
        timeList = new List<selectOption>();
        String[] ampm = new List<String>{' AM',' PM'};
        String[] minutes = new List<String>{':00',':30'};
        String timeOption = '';
        for(String timeType:ampm) {
            for(Integer i=0;i<=11;i++) {
                for(String minuteInstance:minutes) {
                    if(i==0) {
                        timeOption = '12'+minuteInstance+timeType;
                    }
                    else {
                        timeOption = i+minuteInstance+timeType;
                    }
                    timeList.add(new SelectOption(timeOption,timeOption));
                }
            }
        }
        if(!Test.isRunningTest()) {     
            stdController.addFields(new List<String> {'Name','Staff__c','Staff__r.Name','StartTime__c','EndTime__c'});  
        }
        siSession = (Learning_Program__c)stdController.getRecord();
        siSessionId = siSession.Id;
        if(siSessionId != null) {
            if(siSession.StartTime__c != null) {
                String startDateTime = siSession.StartTime__c.format('MM/dd/yyyy HH:mm');
                String endDateTime = siSession.EndTime__c.format('MM/dd/yyyy HH:mm');
                List <String> startDateTimeParts = startDateTime.split(' ');
                startdate = startDateTimeParts[0];
                startTime = convertToTimeOption(startDateTimeParts[1]);
                List <String> endDateTimeParts = endDateTime.split(' ');
                endDate = endDateTimeParts[0];
                endTime = convertToTimeOption(endDateTimeParts[1]);
            }
        }
        List<hed__Term__c> termList = [SELECT Id, Name FROM hed__Term__c WHERE hed__Start_Date__c <:Date.Today() AND hed__End_Date__c >=:Date.Today() LIMIT 1]; 
        if(!termList.iSEmpty()){
            termId = termList[0].Id;
            types = 'SI';
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
    
    
    public String convertToTimeOption(String timeIn24HourFormat) {
        Integer hours = Integer.valueOf(timeIn24HourFormat.split(':')[0]);
        Integer minutes = Integer.valueOf(timeIn24HourFormat.split(':')[1]);
        String hoursAsString='';
        String minutesAsString='';
        String ampm = '';
        if(hours > 12) {
            hours -= 12;
            ampm =' PM';
        }
        else {
            ampm =' AM';
        }
        if(minutes == 0) {
            minutesAsString = '00';
        }
        else {
            minutesAsString = String.valueOf(minutes);
        }
        hoursAsString = String.valueOf(hours);
        return hoursAsString+':'+minutesAsString+ampm;
    }
    
    public datetime dateConvertor(String inputdate,String inputtime) {
         List<String> splitDate = inputdate.split('/');
         Integer year = Integer.valueOf(splitDate[2]);
         Integer month = Integer.valueOf(splitDate[0]);
         Integer day = Integer.valueOf(splitDate[1]);
         Date selectedDate = Date.newInstance(year,month,day);
         Time selectedTime= getTime(inputtime);
         
         DateTime convertedDate = DateTime.newInstance(selectedDate,selectedTime);
         return convertedDate;
     }
     
     public Time getTime(String selectedTime) {
        Integer hours=0;
        Integer minutes=0;
        Integer seconds=0;
        Integer milliseconds=0;
        List<String> timeSplit=selectedTime.split(':');
        hours = Integer.valueOf(timeSplit[0]);
        if(timeSplit[1].contains('PM')) {
            if(hours!=12) {
                hours+=12;
            }
        }
        minutes=Integer.valueOf(timeSplit[1].split(' ')[0]);
        Time returnTime= Time.newInstance(hours,minutes,seconds,milliseconds);
        return returnTime;
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
        List<Profile> profiles = [Select Id,Name FROM Profile where Id =: UserInfo.getProfileId()];
        String profileName = '';
        if(profiles.size() > 0 && profiles[0].Name != null) {
            profileName = profiles[0].Name;
        }
        //options.add(new SelectOption('--None--','--None--'));

        Schema.DescribeFieldResult fieldResult = Learning_Program__c.Type__c.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry p : ple)
        if(profileName == 'PLTL Lead' && p.getValue() == 'PLTL') {
            options.add(new SelectOption(p.getValue(), p.getValue()));  
        }
        else {
            options.add(new SelectOption(p.getValue(), p.getValue()));  
        }
           
     
      /*  List<hed__Term__c> termsList =  [Select id, Name From hed__Term__c WHERE hed__End_Date__c >=:Date.Today()  order by hed__Start_Date__c ];
        for(hed__Term__c objTerm : termsList ){
            options.add(new  SelectOption(objTerm.id, objTerm.Name));
        }*/
        
        //options.sort();
        return options;
    }
    
    public void addCourses(){
        Map<String, List<studentsWrapper>> courseMapTemp = new Map<String, List<studentsWrapper>>();
        for(List<studentsWrapper> objCourseMap : courseMap.Values()){
            for(studentsWrapper wrapObj : objCourseMap ){
                System.debug('wrapObj**'+wrapObj);
                if(wrapObj.selected == true){
                    LP_Attendee__c csObj = wrapObj.attendee;
                    if(addedCourseMap.containsKey(wrapObj.courseSubject)){
                        List<studentsWrapper> cs = addedCourseMap.get(wrapObj.courseSubject);
                        studentsWrapper courseWrapperObj = new studentsWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.attendee = csObj;
                        courseWrapperObj.subjectName  = wrapObj.subjectName;
                        courseWrapperObj.coId = wrapObj.coId;
                        courseWrapperObj.studentName = wrapObj.studentName;
                        courseWrapperObj.subjectCode = wrapObj.subjectCode;
                        courseWrapperObj.courseNumber = wrapObj.courseNumber;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        courseWrapperObj.courseSubject = wrapObj.courseSubject;
                        /*if(types == 'SI') {
                            courseWrapperObj.attendee.Type__c = 'SI';
                        }
                        else if(types == 'PLTL') {
                            courseWrapperObj.attendee.Type__c = 'PLTL';
                        }*/
                        cs.add(courseWrapperObj);
                        addedCourseMap.put(courseWrapperObj.courseSubject,cs);
                    }
                    else{
                        List<studentsWrapper> cs = new List<studentsWrapper>();
                        studentsWrapper courseWrapperObj = new studentsWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.attendee = csObj;
                        courseWrapperObj.subjectName  = wrapObj.subjectName;
                        courseWrapperObj.coId = wrapObj.coId;
                        courseWrapperObj.studentName = wrapObj.studentName;
                        courseWrapperObj.subjectCode = wrapObj.subjectCode;
                        courseWrapperObj.courseNumber = wrapObj.courseNumber;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        courseWrapperObj.courseSubject = wrapObj.courseSubject;
                        cs.add(courseWrapperObj);
                        addedCourseMap.put(courseWrapperObj.courseSubject,cs);
                    }
                }
                else{
                    
                    LP_Attendee__c csObj = wrapObj.attendee;
                    String sbj = wrapObj.courseSubject;
                    if(courseMapTemp.containsKey(sbj)){
                        List<studentsWrapper> cs = courseMapTemp.get(sbj);
                        studentsWrapper courseWrapperObj = new studentsWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.attendee= csObj;
                        courseWrapperObj.subjectName  = wrapObj.subjectName;
                        courseWrapperObj.coId = wrapObj.coId;
                        courseWrapperObj.studentName = wrapObj.studentName;
                        courseWrapperObj.subjectCode = wrapObj.subjectCode;
                        courseWrapperObj.courseNumber = wrapObj.courseNumber;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        courseWrapperObj.courseSubject = wrapObj.courseSubject;
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(courseWrapperObj.courseSubject,cs);
                    }
                    else{
                        List<studentsWrapper> cs = new List<studentsWrapper>();
                        studentsWrapper courseWrapperObj = new studentsWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.attendee= csObj;
                        courseWrapperObj.subjectName  = wrapObj.subjectName;
                        courseWrapperObj.coId = wrapObj.coId;
                        courseWrapperObj.studentName = wrapObj.studentName;
                        courseWrapperObj.subjectCode = wrapObj.subjectCode;
                        courseWrapperObj.courseNumber = wrapObj.courseNumber;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        courseWrapperObj.courseSubject = wrapObj.courseSubject;
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(courseWrapperObj.courseSubject,cs);
                    }
                    
                }
            }    
        }
        courseMap = courseMapTemp.clone();

        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Records are successfully updated'));
    }
    public void removeCourses(){
        Map<String, List<studentsWrapper>> courseMapTemp = new Map<String, List<studentsWrapper>>();
        for(List<studentsWrapper> objCourseMap : addedCourseMap.Values()){
            for(studentsWrapper wrapObj : objCourseMap ){
                if(wrapObj.selected == true){
                    LP_Attendee__c csObj = wrapObj.attendee;
                    if(courseMap.containsKey(wrapObj.courseSubject)){
                        List<studentsWrapper> cs = courseMap.get(wrapObj.courseSubject);
                        studentsWrapper courseWrapperObj = new studentsWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.attendee = csObj;
                        courseWrapperObj.studentName = wrapObj.studentName;
                        courseWrapperObj.subjectName = wrapObj.subjectName;
                        courseWrapperObj.coId = wrapObj.coId;
                        courseWrapperObj.subjectCode = wrapObj.subjectCode;
                        courseWrapperObj.courseNumber = wrapObj.courseNumber;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        courseWrapperObj.courseSubject = wrapObj.courseSubject;
                        /*if(types == 'SI Session') {
                            courseWrapperObj.courseOffering.SI_Session__c = True;
                        }
                        else if(types == 'Tutoring') {
                            courseWrapperObj.courseOffering.LWC_Tutor__c = True;
                        }*/
                        cs.add(courseWrapperObj);
                        courseMap.put(courseWrapperObj.courseSubject,cs);
                    }
                    else{
                        List<studentsWrapper> cs = new List<studentsWrapper>();
                        studentsWrapper courseWrapperObj = new studentsWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.attendee = csObj;
                        courseWrapperObj.studentName = wrapObj.studentName;
                        courseWrapperObj.subjectName = wrapObj.subjectName;
                        courseWrapperObj.coId = wrapObj.coId;
                        courseWrapperObj.subjectCode = wrapObj.subjectCode;
                        courseWrapperObj.courseNumber = wrapObj.courseNumber;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        courseWrapperObj.courseSubject = wrapObj.courseSubject;
                        cs.add(courseWrapperObj);
                        courseMap.put(courseWrapperObj.courseSubject,cs);
                    }
                }
                else{
                    
                    LP_Attendee__c csObj = wrapObj.attendee;
                    if(courseMapTemp.containsKey(wrapObj.courseSubject)){
                        List<studentsWrapper> cs = courseMapTemp.get(wrapObj.courseSubject);
                        studentsWrapper courseWrapperObj = new studentsWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.attendee= csObj;
                        courseWrapperObj.studentName = wrapObj.studentName;
                        courseWrapperObj.subjectName = wrapObj.subjectName;
                        courseWrapperObj.coId = wrapObj.coId;
                        courseWrapperObj.subjectCode = wrapObj.subjectCode;
                        courseWrapperObj.courseNumber = wrapObj.courseNumber;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        courseWrapperObj.courseSubject = wrapObj.courseSubject;
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(courseWrapperObj.courseSubject,cs);
                    }
                    else{
                        List<studentsWrapper> cs = new List<studentsWrapper>();
                        studentsWrapper courseWrapperObj = new studentsWrapper();
                        courseWrapperObj.selected = False;
                        courseWrapperObj.attendee = csObj;
                        courseWrapperObj.studentName = wrapObj.studentName;
                        courseWrapperObj.subjectName = wrapObj.subjectName;
                        courseWrapperObj.coId = wrapObj.coId;
                        courseWrapperObj.subjectCode = wrapObj.subjectCode;
                        courseWrapperObj.courseNumber = wrapObj.courseNumber;
                        courseWrapperObj.sectionId = wrapObj.sectionId;
                        courseWrapperObj.courseSubject = wrapObj.courseSubject;
                        cs.add(courseWrapperObj);
                        courseMapTemp.put(courseWrapperObj.courseSubject,cs);
                    }
                    
                }
            }    
        }
        System.Debug('courseMapTemp-->'+courseMapTemp);
        addedCourseMap = courseMapTemp.clone();
        System.Debug('addedCourseMap -->'+addedCourseMap);
    }
    
    
    public void populateCourses(Id objTermId, String types, String Levels,string offeredtype,String campusid){
        List<hed__Course_Offering__c> courseOfferingList = new List<hed__Course_Offering__c>();
        courseMap = new Map<String, List<studentsWrapper>>();
        addedCourseMap = new Map<String, List<studentsWrapper>>();
        condition = '';
        if(types != '--None--') {
            if(types == 'SI') {
                condition=' AND hed__Course_Offering__c.SI_Session__c = true AND RecordType.Name =\'Banner Course Offering\'';
            }
            else if(types == 'PLTL') {
                condition=' AND hed__Course_Offering__c.PLTL__c = true AND RecordType.Name =\'Banner Course Offering\'';
            }
            
        }
        if(Levels != '--None--')  
        {
        //if(Levels!='')
        //CT Id,hed__Section_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c FROM hed__Course_Offering__c WHERE Active__c =: True AND hed__Term__c =: objTermId AND Level__c=:levels AND campus__c=:campusid AND Offering_Type__c=:offeredtype order by hed__Course__r.Name ];
     //--condition=' AND hed__Course_Offering__c.Level__c=\''+Levels+'\'';
            
         }


         if(offeredtype != '--None--' )  
        {
        
        //if(offeredtype!='')
        
     //--condition+=' AND hed__Course_Offering__c.offering_type__c=\''+offeredtype+'\'';
            
         }
         
        if(campusid != '--None--')  
        {
            system.debug('helllllooooooooooofferedtypecampusid'+campusid);
            //if(campusid!='')
         
            // courseOfferingList = [SELECT Id,hed__Section_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c FROM hed__Course_Offering__c WHERE Active__c =: True AND hed__Term__c =: objTermId AND Level__c=:levels AND campus__c=:campusid AND Offering_Type__c=:offeredtype order by hed__Course__r.Name ];
            //--condition+=' AND hed__Course_Offering__c.Campus__c=\''+campusid+'\'';
        } 
         
         String myTestString = objTermId;
         String cam=campusid;
         string mode=offeredtype;
         string lev=Levels;
         
        courseOfferingList=Database.query('SELECT Id,hed__Section_ID__c,hed__Course__r.subject_name__c ,hed__Course__r.Subject_Code__c,hed__Course__r.Course_Number__c,hed__Course__r.Name,hed__Course__c, hed__Course__r.hed__Course_ID__c,hed__Term__c,LWC_Tutor__c,SI_Session__c FROM hed__Course_Offering__c WHERE Active__c = True AND hed__Term__c =:myTestString '+condition+' order by hed__Course__r.Name');
        system.debug('courseOfferingList: '+courseOfferingList);//this is good.
        Set<Id> courseOfferingIds = new Set<Id>();
        for(hed__Course_Offering__c cO : courseOfferingList) {
            courseOfferingIds.add(cO.Id);
        }
        List<hed__Course_Enrollment__c> crseEnrollments = [Select Id,hed__Course_Offering__c,hed__Course_Offering__r.hed__Section_ID__c,hed__Course_Offering__r.hed__Course__r.Subject_Code__c,hed__Course_Offering__r.hed__Course__r.Course_Number__c,hed__Course_Offering__r.hed__Course__r.subject_name__c, hed__Contact__c,hed__Contact__r.Full_Name__c FROM hed__Course_Enrollment__c where hed__Course_Offering__c in : courseOfferingIds AND Active__c = true order by hed__Contact__r.Full_Name__c];
        Map<Id,List<hed__Course_Enrollment__c>> offeringToStudent = new Map<Id,List<hed__Course_Enrollment__c>>();
        for(hed__Course_Enrollment__c cE : crseEnrollments) {
            if(cE.Id != null) {
                if(offeringToStudent.keySet().contains(cE.hed__Course_Offering__c)) {
                    offeringToStudent.get(cE.hed__Course_Offering__c).add(cE);
                }
                else {
                    List<hed__Course_Enrollment__c> enrollments = new List<hed__Course_Enrollment__c>();
                    enrollments.add(cE);
                    offeringToStudent.put(cE.hed__Course_Offering__c,enrollments);
                }
                
            }
            
        }
        system.debug('size: '+offeringToStudent.get('a043C0000012WZn').size());
        system.debug('size: '+offeringToStudent.get('a043C0000012WZm').size());
        Map<Id,List<LP_Attendee__c>> courseToAttendee = new Map<Id,List<LP_Attendee__c>>();

        List<LP_Attendee__c> siAttendees = new List<LP_Attendee__c>();
        List<LP_Course_Offering__c> siCos = new List<LP_Course_Offering__c>();
        if(siSessionId != null) {
            siAttendees = [Select Id,Student__c,Course_Enrollment__c,Course_Enrollment__r.hed__Course_Offering__c,Course_Enrollment__r.hed__Course_Offering__r.hed__Course__r.subject_name__c FROM LP_Attendee__c where Learning_Program__c =: siSessionId order by Student__c asc];//si/pltl condition
            for(LP_Attendee__c siA : siAttendees) {
                if(courseToAttendee.keySet().contains(siA.Course_Enrollment__r.hed__Course_Offering__c)) {
                    courseToAttendee.get(siA.Course_Enrollment__r.hed__Course_Offering__c).add(siA);
                }
                else {
                    List<LP_Attendee__c> atts = new List<LP_Attendee__c>();
                    atts.add(siA);
                    courseToAttendee.put(siA.Course_Enrollment__r.hed__Course_Offering__c,atts);
                }
                
            }
            siCos = [Select Id,Course_Offering__c,Course_Offering__r.hed__Course__r.subject_name__c FROM LP_Course_Offering__c where Learning_Program__c =: siSessionId];
        }
        
        //List<SI_Course_Offering__c> siCourses = [Select Id, Course_Offering__c, hed__Course__r.subject_name__c FROM SI_Course_Offering__c where SI_Session__c =: siSessionId];
        
        if(siSessionId != null){
          System.debug('courseOfferingList.size()'+courseOfferingList.size());
            for(hed__Course_Offering__c courseObj : courseOfferingList){
                String courseSubjectKey = courseObj.hed__Course__r.Subject_Code__c+' '+courseObj.hed__Course__r.Course_Number__c+' '+courseObj.hed__Section_ID__c+' '+courseObj.hed__Course__r.subject_name__c;
                //if(types == 'SI Session') {//???
                    if(courseToAttendee.containsKey(courseObj.Id) && courseToAttendee.get(courseObj.Id) != null){
                        if(addedCourseMap.containsKey(courseSubjectKey)){
                            List<studentsWrapper> cs = addedCourseMap.get(courseObj.hed__Course__r.subject_name__c);
                            for(LP_Attendee__c lpAtt : courseToAttendee.get(courseObj.Id)) {
                                studentsWrapper csObj = new studentsWrapper();
                                csObj.selected= FALSE;
                                csObj.attendee = lpAtt;
                                csObj.subjectName = courseObj.hed__Course__r.subject_name__c;
                                csObj.studentName = lpAtt.Student__c;
                                cs.add(csObj);
                            }
                            
                            addedCourseMap.put(courseSubjectKey,cs);
                        }
                        else{
                            List<studentsWrapper> cs = new List<studentsWrapper>();
                            for(LP_Attendee__c lpAtt : courseToAttendee.get(courseObj.Id)) {
                                studentsWrapper csObj = new studentsWrapper();
                                csObj.selected= FALSE;
                                csObj.attendee = lpAtt;
                                csObj.subjectName = courseObj.hed__Course__r.subject_name__c;
                                csObj.studentName = lpAtt.Student__c;
                                cs.add(csObj);
                            }
                            
                            addedCourseMap.put(courseSubjectKey,cs);
                        }
                        
                    }
                    else{
                        if(courseMap.containsKey(courseSubjectKey)){
                            List<studentsWrapper> cs = courseMap.get(courseSubjectKey);
                            
                            if(offeringToStudent.get(courseObj.Id) != null) {
                                for(hed__Course_Enrollment__c ce : offeringToStudent.get(courseObj.Id)) {
                                    studentsWrapper csObj = new studentsWrapper();
                                    csObj.selected= FALSE;
                                    csObj.attendee = new LP_Attendee__c(Course_Enrollment__c = ce.Id);
                                    csObj.studentName = ce.hed__Contact__r.Full_Name__c;
                                    csObj.subjectName = ce.hed__Course_Offering__r.hed__Course__r.subject_name__c;
                                    csObj.coId = ce.hed__Course_Offering__c;
                                    csObj.sectionId = ce.hed__Course_Offering__r.hed__Section_ID__c;
                                    csObj.courseNumber = ce.hed__Course_Offering__r.hed__Course__r.Course_Number__c;
                                    csObj.subjectCode = ce.hed__Course_Offering__r.hed__Course__r.Subject_Code__c;
                                    csObj.courseSubject = csObj.subjectCode + ' '+ csObj.courseNumber + ' '+ csObj.sectionId + ' '+csObj.subjectName;
                                /*csObj.attendee = courseToAttendee.get(courseObj.Id);
                                csObj.subjectName = courseObj.hed__Course__r.subject_name__c;
                                system.debug('courseObj.Id: '+courseToAttendee.get(courseObj.Id));
                                csObj.studentName = courseToAttendee.get(courseObj.Id).Student__c;*/
                                cs.add(csObj);
                                //--courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                                }
                                
                                courseMap.put(courseSubjectKey,cs);
                            }
                        }
                        else{
                            List<studentsWrapper> cs = new List<studentsWrapper>();
                            
                            if(offeringToStudent.get(courseObj.Id) != null) {
                                for(hed__Course_Enrollment__c ce : offeringToStudent.get(courseObj.Id)) {
                                    studentsWrapper csObj = new studentsWrapper();
                                    csObj.selected= FALSE;
                                    csObj.attendee = new LP_Attendee__c(Course_Enrollment__c = ce.Id);
                                    csObj.studentName = ce.hed__Contact__r.Full_Name__c;
                                    csObj.subjectName = ce.hed__Course_Offering__r.hed__Course__r.subject_name__c;
                                    csObj.coId = ce.hed__Course_Offering__c;
                                    csObj.sectionId = ce.hed__Course_Offering__r.hed__Section_ID__c;
                                    csObj.courseNumber = ce.hed__Course_Offering__r.hed__Course__r.Course_Number__c;
                                    csObj.subjectCode = ce.hed__Course_Offering__r.hed__Course__r.Subject_Code__c;
                                    csObj.courseSubject = csObj.subjectCode + ' '+ csObj.courseNumber + ' '+ csObj.sectionId + ' '+csObj.subjectName;
                                    /*csObj.attendee = courseToAttendee.get(courseObj.Id);
                                    csObj.subjectName = courseObj.hed__Course__r.subject_name__c;
                                    system.debug('courseObj.Id: '+courseToAttendee.get(courseObj.Id));
                                    csObj.studentName = courseToAttendee.get(courseObj.Id).Student__c;*/
                                    cs.add(csObj);
                                    //--courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                                }
                                
                                courseMap.put(courseSubjectKey,cs);
                            }
                        }
                    }
                //}
                /*else if(types == 'Tutoring') {// ???? 
                    if(courseToAttendee.containsKey(courseObj.Id) && courseToAttendee.get(courseObj.Id) != null){ // ????
                        if(addedCourseMap.containsKey(courseObj.hed__Course__r.subject_name__c)){
                            List<studentsWrapper> cs = addedCourseMap.get(courseObj.hed__Course__r.subject_name__c);
                            studentsWrapper csObj = new studentsWrapper();
                            csObj.selected= FALSE;
                            csObj.attendee = courseToAttendee.get(courseObj.Id);
                            cs.add(csObj);
                            addedCourseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        else{
                            List<studentsWrapper> cs = new List<studentsWrapper>();
                            studentsWrapper csObj = new studentsWrapper();
                            csObj.selected= FALSE;
                            csObj.attendee = courseToAttendee.get(courseObj.Id);
                            cs.add(csObj);
                            addedCourseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        
                    }
                    else{
                        if(courseMap.containsKey(courseObj.hed__Course__r.subject_name__c)){
                            List<studentsWrapper> cs = courseMap.get(courseObj.hed__Course__r.subject_name__c);
                            studentsWrapper csObj = new studentsWrapper();
                            csObj.selected= FALSE;
                            csObj.attendee = courseToAttendee.get(courseObj.Id);
                            cs.add(csObj);
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                        else{
                            List<studentsWrapper> cs = new List<studentsWrapper>();
                            studentsWrapper csObj = new studentsWrapper();
                            csObj.selected= FALSE;
                            csObj.courseOffering = courseToAttendee.get(courseObj.Id);
                            cs.add(csObj);
                            courseMap.put(courseObj.hed__Course__r.subject_name__c,cs);
                        }
                    }
                }*/
                //
            }
        }
        else{//new Session 
            system.debug('size1: '+offeringToStudent.get('a043C0000012WZn').size());
        system.debug('size: '+offeringToStudent.get('a043C0000012WZm').size());
            for(hed__Course_Offering__c courseObj : courseOfferingList){
                String courseSubjectKey = courseObj.hed__Course__r.Subject_Code__c+' '+courseObj.hed__Course__r.Course_Number__c+' '+courseObj.hed__Section_ID__c+' '+courseObj.hed__Course__r.subject_name__c;
                if(courseMap.containsKey(courseSubjectKey)){
                            List<studentsWrapper> cs = courseMap.get(courseSubjectKey);

                            
                            
                            if(offeringToStudent.get(courseObj.Id) != null) {
                                for(hed__Course_Enrollment__c ce : offeringToStudent.get(courseObj.Id)) {
                                    studentsWrapper csObj = new studentsWrapper();
                                    csObj.selected= FALSE;
                                    csObj.attendee = new LP_Attendee__c(Course_Enrollment__c = ce.Id);
                                    csObj.studentName = ce.hed__Contact__r.Full_Name__c;
                                    csObj.subjectName = ce.hed__Course_Offering__r.hed__Course__r.subject_name__c;
                                    csObj.coId = ce.hed__Course_Offering__c;
                                    csObj.sectionId = ce.hed__Course_Offering__r.hed__Section_ID__c;
                                    csObj.courseNumber = ce.hed__Course_Offering__r.hed__Course__r.Course_Number__c;
                                    csObj.subjectCode = ce.hed__Course_Offering__r.hed__Course__r.Subject_Code__c;
                                    csObj.courseSubject = csObj.subjectCode + ' '+ csObj.courseNumber + ' '+ csObj.sectionId + ' '+csObj.subjectName;
                                    //for(studentsWrapper c : cs) {
                                        //if(c.studentName != offeringToStudent.get(courseObj.Id).hed__Contact__r.Full_Name__c) {
                                            cs.add(csObj);
                                        //}
                                    //}
                                }
                                
                                courseMap.put(courseSubjectKey,cs); 
                            }
                }
                else{
                            List<studentsWrapper> cs = new List<studentsWrapper>();
                            
                            if(offeringToStudent.get(courseObj.Id) != null) {
                                for(hed__Course_Enrollment__c ce : offeringToStudent.get(courseObj.Id)) {
                                    studentsWrapper csObj = new studentsWrapper();
                                    csObj.selected= FALSE;
                                    csObj.attendee = new LP_Attendee__c(Course_Enrollment__c = ce.Id);
                                    csObj.studentName = ce.hed__Contact__r.Full_Name__c;
                                    csObj.subjectName = ce.hed__Course_Offering__r.hed__Course__r.subject_name__c;
                                    csObj.coId = ce.hed__Course_Offering__c;
                                    csObj.sectionId = ce.hed__Course_Offering__r.hed__Section_ID__c;
                                    csObj.courseNumber = ce.hed__Course_Offering__r.hed__Course__r.Course_Number__c;
                                    csObj.subjectCode = ce.hed__Course_Offering__r.hed__Course__r.Subject_Code__c;
                                    csObj.courseSubject = csObj.subjectCode + ' '+ csObj.courseNumber + ' '+ csObj.sectionId + ' '+csObj.subjectName;
                                    // for(studentsWrapper c : cs) {
                                       // if(c.studentName != offeringToStudent.get(courseObj.Id).hed__Contact__r.Full_Name__c) {
                                            cs.add(csObj);
                                       // }
                                   // }
                                }
                                
                                courseMap.put(courseSubjectKey,cs); 
                            }
                            
                            
                }
                   
            }
            //courseMap = new Map<String, List<studentsWrapper>>();
            addedCourseMap = new Map<String, List<studentsWrapper>>();
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
              //siSession.Staff__c = si; // temp
              String input1=Apexpages.currentPage().getParameters().get('startDate');
                //String input2=Apexpages.currentPage().getParameters().get('endDate');
                System.debug('startDate..'+startDate);
                //System.debug('endDate..'+endDate);
                Datetime convertedStartDate;
                Datetime convertedEndDate;
                try {
                    convertedStartDate = dateConvertor(input1, this.startTime);
                    convertedEndDate = dateConvertor(input1, this.endTime);
                }
                catch(Exception ex) {
                    //message+='Please input all Start Date, Start Time, End Date and End Time'+'\n';
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please input all Start Date, Start Time, End Date and End Time'+'\n'));
                    //return null;
                }
              //siSession.Name = programName;
              siSession.Type__c = types;
              siSession.StartTime__c = convertedStartDate;
              siSession.EndTime__c = convertedEndDate;
              system.debug('siSession999: '+siSession);
              upsert siSession;
              delete [Select Id FROM LP_Attendee__c where Learning_Program__c =: siSession.Id];
              delete [Select Id FROM LP_Course_Offering__c where Learning_Program__c =: siSession.Id];
              List<LP_Attendee__c> updateCourseList = new List<LP_Attendee__c>();
              Set<Id> siCourseOfferings = new Set<Id>();
              List<LP_Course_Offering__c> updateSICourseOfferings = new List<LP_Course_Offering__c>();
              //for(List<studentsWrapper> objCourseMap : courseMap.Values()){
                  //for(studentsWrapper wrapObj : objCourseMap ){ 
                      //System.Debug('##RA______--->'+ wrapObj.courseOffering.hed__Course__r.Name + '------>'+wrapObj.courseOffering.LWC_Tutor__c);
                      /*if(types == 'SI Session') {
                        wrapObj.courseOffering.SI_Session__c =False;
                      }
                      else if(types == 'Tutoring') {
                        wrapObj.courseOffering.LWC_Tutor__c =False;
                      }*/
                      //updateCourseList.add(wrapObj.courseOffering);
                  //}
             // }       
              for(List<studentsWrapper> objCourseMap : addedCourseMap.Values()){
                  for(studentsWrapper wrapObj : objCourseMap){ 
                      LP_Attendee__c student = new LP_Attendee__c();
                      student.Learning_Program__c = siSession.Id;
                      student.Course_Enrollment__c = wrapObj.attendee.Course_Enrollment__c;
                      siCourseOfferings.add(wrapObj.coId);
                      updateCourseList.add(student);
                  }
              }
              if(siCourseOfferings.size() > 0) {
                for(Id crseId : siCourseOfferings) {
                    LP_Course_Offering__c siCo = new LP_Course_Offering__c();
                    siCo.Learning_Program__c = siSession.Id;
                    siCo.Course_Offering__c = crseId;
                    updateSICourseOfferings.add(siCo);
                }
              }  
              if(!updateCourseList.isEmpty()){ 
                system.debug('updateCourseList: '+updateCourseList);                 
                  Database.upsert(updateCourseList);
              }
              if(!updateSICourseOfferings.isEmpty()){    
                system.debug('updateSICourseOfferings: '+updateSICourseOfferings);              
                 Database.upsert(updateSICourseOfferings);
              }
              siSessionId = siSession.Id;
              //PageReference pg = new PageReference('/'+siSession.Id);
             // pg.setRedirect(true);
              //system.debug('pg: '+pg);
              //return pg;
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
            //return null;           
        }
        
    public class courseWrapper{
    
        public hed__Course_Offering__c courseOffering {get;set;}
        public boolean selected{get;set;}
        
        public courseWrapper(){
        
        }
        
    }

    public class studentsWrapper{
    
        public LP_Attendee__c attendee {get;set;}
        public String studentName {get;set;}
        public String subjectName {get;set;}
        public String sectionId {get;set;}
        public String courseNumber {get;set;}
        public String subjectCode {get;set;}
        public String courseSubject {get;set;}
        public String coId {get;set;}
        public boolean selected{get;set;}
        
        public studentsWrapper(){
        
        }
        
    }

}