public without sharing class USF_SetAvailabilityController {

    public string center {get;set;} 
    public string location {get; set;}
    public string repeat {get;set;} 
    public string startdate {get;set;}
    public string datename {get;set;}
    public string endDate{get;set;}
    public string startTime {get;set;}
    public string endTime {get;set;}
    public Id learningCenterId {get;set;}
    public Id speakingCenterId {get;set;}
    public Id writingCenterId {get;set;}
    public Counselor_Availability_Definition__c avlRec {get;set;}
    public List<selectOption> centersList {get;set;}
    public List<selectOption> coursesList {get;set;}
    public List<selectOption> timeList {get;set;}
    public String selectedCourses {get;set;}
    public String[] selectedCourseIds {get;set;}
    public String message {get;set;}
    public List<String> selectedMeetingTypes {get;set;}
    public String selectedCenter {get;set;}
    public Boolean isExistingAvailability {get;set;}
    public Boolean isCoursesDisabled {get;set;}
    public Boolean isNotSpeaking {get;set;}
    public String messageBoxHeader {get;set;}
    public Boolean isError {get;set;}
    public USF_SetAvailabilityController(ApexPages.StandardController controller) {
        message='';
        messageBoxHeader = '';
        if(!Test.isRunningTest()) {     
        controller.addFields(new List<String> {'Name','Meeting_Location__c','Max_Number_of_Students__c','Monday__c','Tuesday__c',
                                                'Wednesday__c','Thursday__c','Friday__c','Success_Center__c','Location__c','Repeat__c','Start_Date_Time__c','End_Date_Time__c',
                                                'AppointmentType__c'});  
        }      
        isExistingAvailability = false;
        isError = false;
        isNotSpeaking = false;
        avlRec = (Counselor_Availability_Definition__c)controller.getRecord();
        selectedMeetingTypes = new List<String>();
        isCoursesDisabled = false;
        if(avlRec.Id != NULL){
            List<Appointment_Course__c> appointmentCourses = [Select id,Availability_Definition__c,Eligible_Tutor_Courses__c from Appointment_Course__c where Availability_Definition__c = :avlRec.Id];
            List<SelectOption> courseOptions = getCourseList(UserInfo.getUserId());
            selectedCourseIds = new String[]{};
            if(appointmentCourses != null && (courseOptions.size()-1 == appointmentCourses.size())) {
                selectedCourseIds.add('All');
            }
            else {
                for(Appointment_Course__c appointmentCourse: appointmentCourses) {
                    selectedCourseIds.add(appointmentCourse.Eligible_Tutor_Courses__c);
                }
            }
            String startDateTime = avlRec.Start_Date_Time__c.format('MM/dd/yyyy HH:mm');
            String endDateTime = avlRec.End_Date_Time__c.format('MM/dd/yyyy HH:mm');
            List <String> startDateTimeParts = startDateTime.split(' ');
            startdate = startDateTimeParts[0];
            startTime = convertToTimeOption(startDateTimeParts[1]);
            List <String> endDateTimeParts = endDateTime.split(' ');
            endDate = endDateTimeParts[0];
            endTime = convertToTimeOption(endDateTimeParts[1]);
            if(String.isNotBlank(avlRec.Meeting_Location__c)) {
                selectedMeetingTypes = avlRec.Meeting_Location__c.split(';');
            }
            selectedCenter = avlRec.Success_Center__c;
            isExistingAvailability = true;
        }
        /*if(avlRec.Id == NULL) {
            avlRec.AppointmentType__c = 'Scheduled';
        }*/
        // Assign recordtype as LWC Type
        Id LWCRecordTypeId = Schema.SObjectType.Counselor_Availability_Definition__c.getRecordTypeInfosByName().get('LWC Availabilty').getRecordTypeId();
        avlRec.RecordTypeId = LWCRecordTypeId;
        //Updated by Vandana to get only applicable centers of the consultant
        centersList = USF_DBUtil.getApplicableCenters(UserInfo.getUserId());
        for(selectOption option : centersList){
            if(option.getlabel().contains(Label.USF_LWCAppointmentLearningCenter)){
                learningCenterId=option.getvalue();
            }
            if(option.getlabel().contains(Label.USF_LWCAppointmentSpeakingCenter)){
                speakingCenterId=option.getvalue();
            }
            if(option.getlabel().contains(Label.USF_LWCAppointmentWritingCenter)){
                writingCenterId=option.getvalue();
            }
            if(selectedCenter == null) {
                selectedCenter = option.getvalue();
            }
        }
        if(selectedCenter != learningCenterId) {
            isCoursesDisabled = true;
        }
        System.debug('speakingCenterId...'+speakingCenterId+'***');
        if(selectedCenter != speakingCenterId) {
            System.debug('selectedCenter...'+selectedCenter+'***');
            System.debug('speakingCenterId...'+speakingCenterId+'***');
            isNotSpeaking = true;
        }
        String userId = Userinfo.getUserId();
        coursesList = getCourseList(userId);
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
    }
    public PageReference refreshOptions() {
        if(selectedCenter == speakingCenterId) {
            isCoursesDisabled = true;
            isNotSpeaking = false;
        }
        else if(selectedCenter == learningCenterId){
            isCoursesDisabled = false;
            isNotSpeaking = true;
        }
        else {
            isCoursesDisabled = true;
            isNotSpeaking = true;
        }
        return null;
    }
    public List<SelectOption> getMeetingTypes() {
        Schema.sObjectType sobject_type = Counselor_Availability_Definition__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<selectOption> options = new List<selectOption>();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Meeting_Location__c').getDescribe().getPickListValues();
        for (Schema.PicklistEntry a : pick_list_values) {
            if(selectedCenter == learningCenterId && a.getLabel() != App_Config__c.getInstance('AvailabilityMeetingType_Phone').Text_Value__c) {
                options.add(new selectOption(a.getLabel(), a.getValue()));
            }
            else if(selectedCenter == speakingCenterId && a.getLabel() == App_Config__c.getInstance('AvailabilityMeetingType_Phone').Text_Value__c) {
                options.add(new selectOption(a.getLabel(), a.getValue()));
            }
            else if(selectedCenter == writingCenterId) {
                options.add(new selectOption(a.getLabel(), a.getValue()));
            }
        }
        return options;
    }
    public List<SelectOption> getLocationValues(){
        Schema.sObjectType sobject_type = Counselor_Availability_Definition__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<selectOption> options = new List<selectOption>();
        if(selectedCenter == speakingCenterId) {
            options.add(new SelectOption(App_Config__c.getInstance('LWC Speaking Center Location').Text_Value__c,
                    App_Config__c.getInstance('LWC Speaking Center Location').Text_Value__c)); 
        }
        if(selectedCenter == writingCenterId) {
            options.add(new SelectOption(App_Config__c.getInstance('LWC Writing Center Location').Text_Value__c,
                    App_Config__c.getInstance('LWC Writing Center Location').Text_Value__c)); 
        }
        if(selectedCenter == learningCenterId) {
            List<Schema.PicklistEntry> pick_list_values = field_map.get('Location__c').getDescribe().getPickListValues();
            String casaLocations = App_Config__c.getInstance('CASA Locations').Text_Value__c;
            List<String> casaLocationsList ;
            if(String.isNotBlank(casaLocations)) {
                casaLocationsList = casaLocations.split(';');
            }
            Set<String> casaLocationsSet;
            if(casaLocationsList != null) {
                casaLocationsSet = new Set<String>(casaLocationsList);
            }
            for (Schema.PicklistEntry a : pick_list_values) {
                if((casaLocationsSet != null && casaLocationsSet.contains(a.getLabel()))) {
                    continue;
                }
                else {
                    options.add(new selectOption(a.getLabel(), a.getValue()));
                }
            }
        }
        return options;
    }
    public List<SelectOption> getRepeatValues(){
        Schema.sObjectType sobject_type = Counselor_Availability_Definition__c.getSObjectType();
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
        List<Schema.PicklistEntry> pick_list_values = field_map.get('Repeat__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for (Schema.PicklistEntry a : pick_list_values) {
            options.add(new selectOption(a.getLabel(), a.getValue()));
        }
        return options;
    } 
     public void submit(){
         String meetingLocation = '';
         if(selectedCenter == speakingCenterId) {
            selectedMeetingTypes = new List<String>();
            selectedMeetingTypes.add('In Person');
            isNotSpeaking = false;
         }
         if(avlRec.AppointmentType__c == null || String.isBlank(avlRec.AppointmentType__c)) {
            messageBoxHeader = 'Error';
            isError = true;
            message='Please select an Appointment Type';
            return;
         }
         if(selectedMeetingTypes != null && selectedMeetingTypes.size() > 0) {
            for(String selectedMeetingType : selectedMeetingTypes) {
                meetingLocation += selectedMeetingType+';';
            }
            meetingLocation = meetingLocation.removeEnd(';');
         }
         else if (selectedMeetingTypes == null || selectedMeetingTypes.size() == 0){
            messageBoxHeader = 'Error';
            isError = true;
            message='Please select a Meeting Type';
            return;
         }
         String input1=Apexpages.currentPage().getParameters().get('startDate');
         String input2=Apexpages.currentPage().getParameters().get('endDate');
         if(input1 == null || String.isBlank(input1)) {
             messageBoxHeader = 'Error';
             isError = true;
             message='Please select Start Date'+'\n';
             return;
         }
         if(input2 == null || String.isBlank(input2)) {
             messageBoxHeader = 'Error';
             isError = true;
             message='Please select End Date'+'\n';
             return;
         }
         if(startTime == null || String.isBlank(startTime)) {
             messageBoxHeader = 'Error';
             isError = true;
             message='Please select Start Time';
             return;
         }
         if(endTime == null || String.isBlank(endTime)) {
             messageBoxHeader = 'Error';
             isError = true;
             message='Please select End Time';
             return;
         }
         Datetime convertedStartDate;
         Datetime convertedEndDate;
         try {
            convertedStartDate = dateConvertor(input1, this.startTime);
            convertedEndDate = dateConvertor(input2, this.endTime);
         }
         catch(Exception ex) {
            messageBoxHeader = 'Error';
            isError = true;
            message='Please input all Start Date, Start Time, End Date and End Time'+'\n';
            return;
         }
         avlRec.Start_Date_Time__c = convertedStartDate;
         avlRec.End_Date_Time__c = convertedEndDate;
         avlRec.Success_Center__c = selectedCenter;
         avlRec.Coach__c = Userinfo.getUserId();
         avlRec.Meeting_Location__c = meetingLocation;
         upsertAvailability(avlRec);
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
     
    // Method to reroute user to Consultant Dashboard VF page
    public PageReference cancelAvailibiliy(){
            PageReference pageRef = Page.USF_ConsultantDashboard; 
            pageRef.setRedirect(true);
            return pageRef; 
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
    
    public List<selectOption> getAvailabilityTypes() {
        List<Schema.PicklistEntry> pickListValues = Counselor_Availability_Definition__c.getSObjectType().getDescribe().fields.getMap().get('AppointmentType__c').getDescribe().getPickListValues();
        List<selectOption> options = new List<selectOption>();
        for(Schema.PicklistEntry pickListEntry : pickListValues) {
            options.add(new selectOption(pickListEntry.getLabel(), pickListEntry.getValue()));
        }
        return options;
    }
    
    public List<Eligible_Tutor_Courses__c> getEligibleTutorCourses(Id contactId) {
        List<Eligible_Tutor_Courses__c> coursesList = new List<Eligible_Tutor_Courses__c>();
        for(Eligible_Tutor_Courses__c etc : USF_DBUtil.getEligibleTutorCoursesByContact(contactId)) {
            coursesList.add(etc);
        }
        return coursesList;
    }
    
    public List<SelectOption> getCourseList(Id userId) {
        List<SelectOption> courseList = new List<SelectOption>();
        if(isCoursesDisabled) {
            return courseList;
        }
        User loggedInUser = [SELECT ContactId FROM User WHERE Id =: userId];
        List<Eligible_Tutor_Courses__c> etcList = new List<Eligible_Tutor_Courses__c>();
        if(loggedInUser.ContactId != NULL){
            etcList = getEligibleTutorCourses(loggedInUser.ContactId);
        }
        if(etcList.size()>0){
            courseList.add(new selectOption('All','All'));
            for (Eligible_Tutor_Courses__c etcRec : etcList) {
                String optionlabel = etcRec.Course_Offering__r.hed__Course__r.Subject_Code__c + ' ' +etcRec.Course_Offering__r.hed__Course__r.Course_Number__c +' ('+etcRec.Course_Offering__r.hed__Section_ID__c+')';
                System.debug('optionlabel'+optionlabel);
                //courseList.add(new selectOption(etcRec.Id, etcRec.Course_Offering__r.Name));
                courseList.add(new selectOption(etcRec.Id, optionlabel));
            }              
        }
        return courseList;
    }
    
    public void upsertAvailability(Counselor_Availability_Definition__c avlRec) {
         String userId = Userinfo.getUserId();
         String contactId = [Select Id, ContactId FROM User where Id =: UserInfo.getUserId() LIMIT 1].ContactId;
         Boolean selectedAllCourses = false;
         try{
             // Check Courses if Center of Availability is Learning Center.
             if(avlRec.Success_Center__c == learningCenterId) {
                if(selectedCourseIds.size()>0){
                    for(String selectedCourseId:selectedCourseIds){
                        if(selectedCourseId.containsIgnoreCase('All')) {
                            selectedAllCourses = true;
                            break;
                        }
                    }
                }
                else if(selectedCourseIds == null || selectedCourseIds.size() == 0) {
                    messageBoxHeader = 'Error';
                    isError = true;
                    message='Please choose atleast one course\n';
                    return;
                }
             }
             // If Courses is selected as all insert app courses with all courses.
             if(selectedAllCourses) {
                selectedCourseIds = new List<String>();
                for (Eligible_Tutor_Courses__c eligibleTutorCourse : getEligibleTutorCourses(contactId)) {
                    selectedCourseIds.add(eligibleTutorCourse.Id);
                }
             }
             // Populate Consultant
             //Consultant__c consultant = getConsultant(avlRec,contactId);
             //if(consultant != null && consultant.id != null) {
                //avlRec.Consultant__c = consultant.Id;
             //}
             Boolean isUpdate = false;
             if(avlRec.Id != null) {
                isUpdate = true;
             }
             if(avlRec.Repeat__c != 'Weekly') {
                avlRec.Monday__c = false;
                avlRec.Tuesday__c = false;
                avlRec.Monday__c = false;
                avlRec.Wednesday__c = false;
                avlRec.Thursday__c = false;
                avlRec.Friday__c = false;
             }
             USF_DBUtil.upsertRecord(avlRec);
             List<Appointment_Course__c> toRemainAppCourses = new List<Appointment_Course__c>();
             if(avlRec.Id !=NULL && avlRec.Success_Center__c == learningCenterId) {
                List<Appointment_Course__c> appCourseList = new List<Appointment_Course__c>();
                Set<Id> newAppCourseSet = new Set<Id>();
                Map<Id,Id> existingAppCourseMap = new Map<Id,Id>();
                if(isUpdate) {
                    appCourseList = [SELECT Id,Eligible_Tutor_Courses__c FROM Appointment_Course__c WHERE Availability_Definition__c =: avlRec.Id];
                    delete appCourseList;
                }
                Appointment_Course__c appCourseRec;
                appCourseList = new List<Appointment_Course__c>();
                for(String appCourse:selectedCourseIds){
                    appCourseRec = new Appointment_Course__c();
                    appCourseRec.Availability_Definition__c = avlRec.Id;
                    appCourseRec.Eligible_Tutor_Courses__c = appCourse;
                    appCourseList.add(appCourseRec);
                }
                if(appCourseList.size()>0) {
                    System.debug('USF_CoachAvailabilityUtils.pageInfoMessage...'+USF_CoachAvailabilityUtils.pageInfoMessage);
                    upsert appCourseList;
                    System.debug('AfterUSF_CoachAvailabilityUtils.pageInfoMessage...'+USF_CoachAvailabilityUtils.pageInfoMessage);
                }
            }
            messageBoxHeader = 'Success ';
            isError = false;
            if(!isUpdate) {
                message = 'Your availability has been saved.\n';
            }
            else if(isUpdate){
                message = 'Your availability has been updated.\n';
            }
            if(String.isNotBlank(USF_CoachAvailabilityUtils.pageInfoMessage)) {
               message += USF_CoachAvailabilityUtils.pageInfoMessage;
            }
         }
         catch(QueryException ex) {
            messageBoxHeader = 'Error';
            isError = true;
            message = ex.getMessage();
         }
         catch(System.DMLException ex) {
            messageBoxHeader = 'Error';
            isError = true;
            for (Integer i = 0; i < ex.getNumDml(); i++) {
                message = ex.getDmlMessage(i);
            }
            return;
         }
         catch(Exception ex){
            messageBoxHeader = 'Error';
            isError = true;
            message = ex.getMessage();
        }
    }
    
    public Consultant__c getConsultant(Counselor_Availability_Definition__c avlRec, String contactId) {
         List<hed__Term__c> terms = USF_DBUtil.getTerm(avlRec.Start_Date_Time__c.date(),avlRec.End_Date_Time__c.date());
         String termId = '';
         if(terms.size() == 1) {
            termId = terms[0].id;
         }
         String centerId = avlRec.Success_Center__c;
         String consultantQuery = 'Select id from Consultant__c where Center__c =: centerId AND Contact__c =: contactId ';
         if(String.isNotBlank(termId)) {
            consultantQuery += 'AND Term__c =: termId';
         }
         consultantQuery += ' limit 1';
         List<Consultant__c> consultantList = Database.query(consultantQuery);
         if(!consultantList.isEmpty()) {
            return consultantList[0];
         }
         else {
            return new Consultant__c();
         }
    }
    
}