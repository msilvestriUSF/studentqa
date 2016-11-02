public without sharing class USF_LWCStaffViewAppointmentController {
    public Counsellor_Availability__c slotRec {get;set;}
    public string availabilityId {get;set;}  
    public String slotDate {get;set;}
    public String slotTime {get;set;}    
    public final Id slotId {get;set;} 
    public Id currentAppointmentId {get; set;}    
    public List<USF_AppointmentDTO> appDTOList {get;set;}
    public string CWID{get;set;}
    public integer capacity{get; set;}
    public string newLocation {get; set;}
    public String selectedSpecialty {get;set;}
    public String selectedSpecialtyName {get;set;}
    public String selectedCourse{get;set;}
    public boolean isStrike {get;set;}
    public datetime timenow {get;set;}
    public date todayDate {get;set;}
    public string errMsg {get;set;}
    public string newSpecialty {get;set;}
    public boolean isWritingCenter {get;set;}
    public boolean isLearningCenter {get;set;}
    public Boolean isDropInAppointmentType {get;set;}
    public String appointmentType {get;set;}
    public List<selectOption> timeList {get;set;}
    public Boolean isCourseDisabled {get;set;}
    public string checkInStartTime {get;set;}
    public string checkOutEndTime {get;set;}
    public string selectedSpeciality {get;set;}
    public string selectedStudentName {get;set;}
    public string message{get;set;}
    
    //Boolean flags to toggle functionality
    public boolean isLWCStaff{get;set;}
    public boolean isLWCConsultant{get;set;}
    
    //Added by Manjunath-Start
    public String selectedStudentId{get;set;}
    //Added by Manjunath-End
    
    public USF_LWCStaffViewAppointmentController(ApexPages.StandardController controller){
        isLWCConsultant=false;
        isLWCStaff=false;
        isWritingCenter = false;
        isLearningCenter = false;    
        isCourseDisabled = false;
        message='';
        String usrProfileName = [select id, Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
        //Modified by Vandana to remove permission set related functionality
        User currentUser = [Select Id, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<Consultant__c> activeConsultants = USF_DBUtil.getActiveConsultantsByContactId(currentUser.ContactId);
         
        if(usrProfileName.equalsIgnoreCase('lwc staff') ||usrProfileName.equalsIgnoreCase('System Administrator')){
            isLWCStaff =true; 
        }
        else if(!activeConsultants.isEmpty()){
            isLWCConsultant =true;
        }
                    
        selectedStudentId=USF_Constant.USF_EMPTY;
        selectedSpecialty = ApexPages.currentPage().getParameters().get('selectedSpecialty');
        if(selectedSpecialty != null) {
            system.debug('Specialty in VF 2-->' + selectedSpecialty);
            Specialty__c specRec = [SELECT Id, Name FROM Specialty__c WHERE Id=:selectedSpecialty];
            selectedSpecialtyName = specRec.Name;
        }
        slotId = ((Counsellor_Availability__c)controller.getRecord()).Id;
        timenow = system.now();
        todayDate = date.today();
        isStrike = false;
        //slotRec = (Counsellor_Availability__c)controller.getRecord();
        if(slotId != null)
            slotRec = [SELECT Id, Start_Time__c, Status__c, Availability__c,Availability__r.Success_Center__r.LeadTime__c,Availability__r.Success_Center__r.Name, Availability__r.Success_Center__c, Noofstudentsregistered__c, Selected_Course__c,AppointmentType__c,Selected_Course__r.Name,(Select id from Appointment_Contacts__r) FROM Counsellor_Availability__c WHERE Id =: slotId];
            
        if(slotRec.Start_Time__c != null && UserInfo.getTimeZone().getID()!=null){
            slotDate = slotRec.Start_Time__c.format('M/d/yyyy', UserInfo.getTimeZone().getID());
            slotTime = slotRec.Start_Time__c.format('hh:mm a', UserInfo.getTimeZone().getID());
        }
        if(slotRec != null) {
            availabilityId = slotRec.Availability__c;
        }
        System.debug('slotRec.Appointment_Contacts__r'+slotRec.Appointment_Contacts__r);
        if(String.isNotBlank(slotRec.Selected_Course__c)) {
            selectedCourse = slotRec.Selected_Course__c;
            isCourseDisabled = true;
        }
        if(slotRec.Availability__r.Success_Center__r.Name == App_Config__c.getInstance('Writing Center').Text_Value__c)
            isWritingCenter = true;
        if(slotRec.Availability__r.Success_Center__r.Name == App_Config__c.getInstance('Learning Center').Text_Value__c)
            isLearningCenter = true;
        timeList = new List<selectOption>();
        List<String> ampm = USF_Constant.USF_SETAVAILABILITY_AMPM.split(',');
        List<String> minutes = USF_Constant.USF_SETAVAILABILITY_MINUTES.split(',');
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
        if(slotRec != null && slotRec.AppointmentType__c!=null) {
            appointmentType = slotRec.AppointmentType__c;
        }
        String dropInAppointmentLabel = App_Config__c.getInstance('Dropin Appointment').Text_Value__c;
        System.debug('dropInAppointmentLabel...'+dropInAppointmentLabel+'...'+appointmentType+'...');
        if(dropInAppointmentLabel == appointmentType) {
            isDropInAppointmentType = true;
        }
        else {
            isDropInAppointmentType = false;
        }      
          
    }
    
    public List<SelectOption> getLocationList(){     
        List<SelectOption> options = new List<SelectOption>();     
        //options.add(new SelectOption('0001','-Select-'));
        Schema.DescribeFieldResult fieldResult = Counselor_Availability_Definition__c.Location__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry p : ple)
        options.add(new SelectOption(p.getValue(), p.getValue()));   
        return options;
    } 
    
    public List<SelectOption> getSpecialtyList(){      
        List<SelectOption> options = new List<SelectOption>();      
        options.add(new selectOption('--None--', '--None--'));
        for (Specialty__c spRec : [SELECT Id, Name FROM Specialty__c limit 10000]) {
            options.add(new selectOption(spRec.Id, spRec.Name));
        }              

        return options; 
    }
    
    public List<SelectOption> getSpecialityList(){      
        List<SelectOption> options = new List<SelectOption>();      
        options.add(new selectOption('--None--', '--None--'));
        for (Specialty__c spRec : [SELECT Id, Name FROM Specialty__c limit 10000]) {
            options.add(new selectOption(spRec.Id, spRec.Name));
        }              

        return options; 
    }
    
    public List<SelectOption> getCourseList() {
        List<SelectOption> options = new List<SelectOption>(); 
        Map<id,hed__Course_Enrollment__c> courseConnectionMap=new Map<id,hed__Course_Enrollment__c>();     
        options.add(new selectOption('--None--', '--None--'));
        //Added by Manjunath-DFCT0011009-Start
         if(selectedStudentId != null){
          Map<id,Appointment_Course__c> appointmentCourseMap=new Map<id,Appointment_Course__c>([SELECT Id, Name, Eligible_Tutor_Courses__r.Course_Offering__r.Id,Eligible_Tutor_Courses__r.Course_Offering__r.Name FROM Appointment_Course__c where Availability_Definition__r.Id =: availabilityId]);
          List<hed__Course_Enrollment__c> courseConnectionList=[SELECT id,hed__Course_Offering__c from hed__Course_Enrollment__c where hed__Contact__c=:selectedStudentId];
          if(courseConnectionList.size()>0){
              for(hed__Course_Enrollment__c courseConnection:courseConnectionList){
                  
                  courseConnectionMap.put(courseConnection.hed__Course_Offering__c,courseConnection);
              
              }
          }
          //List<Appointment_Course__c> appointmentCourses=[SELECT Id, Name, Eligible_Tutor_Courses__r.Course_Offering__r.Id,Eligible_Tutor_Courses__r.Course_Offering__r.Name FROM Appointment_Course__c where Availability_Definition__r.Id =: availabilityId and Eligible_Tutor_Courses__r.Course_Offering__c IN (SELECT hed__Course_Offering__c from hed__Course_Enrollment__c where hed__Contact__c=:selectedStudentId)];
         //List<Appointment_Course__c> appointmentCourses=[SELECT Id, Name, (Select id,Course_Offering__r.Id,Course_Offering__r.Name from Course_Association__r where Course_Offering__c IN (SELECT hed__Course_Offering__c from hed__Course_Enrollment__c where hed__Contact__c=:selectedStudentId)) FROM Appointment_Course__c where Availability_Definition__r.Id =: availabilityId ];
         if(!courseConnectionMap.isEmpty()){
         for (Appointment_Course__c spRec :appointmentCourseMap.values()) {
          if(courseConnectionMap.containsKey(spRec.Eligible_Tutor_Courses__r.Course_Offering__r.Id)){
             options.add(new selectOption(spRec.Eligible_Tutor_Courses__r.Course_Offering__r.Id, spRec.Eligible_Tutor_Courses__r.Course_Offering__r.Name));
          
         }  
         //Added by Manjunath-DFCT0011009-End
        }            

        return options; 
    } 
   } 
    return options; 
  }         
    
    public list<USF_AppointmentDTO> getAppointMentRecords(){
    
    List<AppointmentContact__c> appointments = [Select Id,Contact__r.name,CWID__c,Date_Time__c,Status__c,SelectedCourse__r.Name,Coach_Specialty__r.Name from AppointmentContact__c WHERE AppointmentSlot__c =: slotId];
        appDTOList = new List<USF_AppointmentDTO>();
        if(appointments != NULL) {
            for(AppointmentContact__c app:appointments ){
                USF_AppointmentDTO appDTO = new USF_AppointmentDTO(app,app.Date_Time__c.format('EEEE,MMM d yyyy,hh:mm a'));
                appDTOList.add(appDTO);
            } 
          }  
        return appDTOList;
    
    }
    
    public void validateCenterRules(){
        isStrike = false;
        Date slotDate = date.newinstance(slotRec.Start_Time__c.year(), slotRec.Start_Time__c.month(), slotRec.Start_Time__c.day());
        Contact contactRec = USF_DBUtil.getSelectedContact(selectedStudentId);
        selectedStudentName = contactRec.Name+' ('+contactRec.CWID__c+  ')';
        if(String.isNotBlank(slotRec.Selected_Course__c)) {
            isCourseDisabled = true;
        }
        if(selectedStudentId != null) {
            errMsg = USF_DBUtil.validateCenterRules(slotId, slotRec.Availability__r.Success_Center__c, slotDate,slotRec.Selected_Course__c, selectedStudentId);
            if(String.isNotEmpty(errMsg))
                isStrike = true; 
        }
        system.debug('Lead Time-->' + slotRec.Availability__r.Success_Center__r.LeadTime__c);
        system.debug('Error Message-->' + errMsg);
            
        if(slotRec.Availability__r.Success_Center__r.LeadTime__c != null && (slotRec.Status__c == 'Confirmed' || slotRec.Status__c == 'Pending' || slotRec.Status__c == 'Open') && (errMsg != null || errMsg != '')){        
            if(timenow > slotRec.Start_Time__c.addHours(-Integer.valueOf(slotRec.Availability__r.Success_Center__r.LeadTime__c))) {
                isStrike = true;
                system.debug('Test123-->');
                errMsg = 'You are about to violate the lead time rule of this Center';
            }
            else {
                //isStrike = false;
            }                  
        }
        
        system.debug('strike flag-->'+ isStrike);    
    
    }   

    // Method to add the student
    public void addStudent(){            
        message = '';                           
        Contact conRec = new Contact();
        if(selectedStudentId != null){
            System.debug('selectedStudentId ...'+selectedStudentId);
            conRec = USF_DBUtil.getSelectedContact(selectedStudentId);
        }
        AppointmentContact__c newStudent = new AppointmentContact__c();
        Counsellor_Availability__c selectedSlot;
        newStudent.AppointmentSlot__c = slotId;
        newStudent.Status__c = App_Config__c.getInstance('Confirmed').name__c;
        if(conRec != null)
            newStudent.Contact__c = conRec.Id;
            
   //     if(selectedSpeciality != null) {
   //         newStudent.Coach_Specialty__c = selectedSpeciality;
   //     }
        
        if(isDropInAppointmentType) {
            DateTime checkInDateTime = dateConvertor(slotDate, checkInStartTime);
            DateTime checkOutDateTime = dateConvertor(slotDate, checkOutEndTime);
            newStudent.CheckInTime__c = checkInDateTime;
            newStudent.CheckOutTime__c = checkOutDateTime;
        }
        if(String.isNotBlank(selectedCourse) && selectedCourse != '--None--') {
            selectedSlot = new Counsellor_Availability__c();
            selectedSlot.Id = slotId;
            selectedSlot.Selected_Course__c = selectedCourse;
            newStudent.SelectedCourse__c = selectedCourse;
        }
        try{
        if((isLWCConsultant && !isStrike) || !isLWCConsultant)      
            if(newStudent!= null) {
                 // Added by Manjunath for defect DFCT0011054-Start
                if(USF_DBUtil.checkDuplicateAppointment(conRec.Id,slotId)){
                    message='Student is already added.';
                 }
                 else if(USF_DBUtil.checkFirstAppointment(conRec.Id,selectedCourse)){
                    message='This is the first appointment for this student in this course. The student must book the appointment through the portal and complete required forms.';
                 }
                 else{
                 insert newStudent;  
                 }              
                //Added by Manjunath for defect DFCT0011054-End
            }
            if(selectedSlot != null && selectedSlot.Id != null) {
                update selectedSlot;
                isCourseDisabled = true;
            }
        }
        catch(Exception e) {
            System.debug('Exception..'+e);
        }    
        
        if(slotId != null)
            slotRec = [SELECT Id, Start_Time__c, Status__c, Availability__r.Success_Center__r.LeadTime__c, Availability__r.Success_Center__c, Noofstudentsregistered__c, Selected_Course__c FROM Counsellor_Availability__c WHERE Id =: slotId];            
            
        
        isStrike = false;   
    }
     
    // Method to remove the student
    public void removeStudent(){
        //Update logic after discussion with Naya/Ken
        /*    if(currentAppointmentId != NULL) {
                AppointmentContact__c studentToBeRemoved = [SELECT Id FROM AppointmentContact__c WHERE Id = :currentAppointmentId LIMIT 1];
                delete studentToBeRemoved;
            }*/
    } 
    
    // Method to cancel the slot
    public PageReference cancelSlot(){
        PageReference pageRef = ApexPages.currentPage();  
        //Move Status to Custom Label
        slotRec.Status__c = 'Cancelled';
        if(slotRec != null) {
            update slotRec;
        }
        pageRef = Page.USF_AvailabilityCalendar;
        return pageRef;
        
    }   
    
    // Method to update the slot
    public PageReference updateSlot(){
        system.debug('Capacity --> '+ capacity);
        slotRec.Location__c = newLocation;
        slotRec.Capacity__c = capacity;
        if(slotRec != null) {
            update slotRec;
        }
        PageReference pageRef = new PageReference('/apex/USF_LWCStaffViewAppointment?id='+slotRec.Id);  
        return pageRef;                
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
}