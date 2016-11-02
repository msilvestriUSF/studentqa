public without sharing class CaseTutorRequestExtension {
    
    Static Id userContactId;
    
    public List<selectOption> courseConnection {
        
        get {
            // Get ContactId from User
            List<user> lstUser = [Select ContactId From User Where Id =: UserInfo.getUserId()];
            userContactId = lstUser[0].ContactId;
            
            // Get Course
            List<selectOption> courses = new List<selectOption>();
            courses.add(new selectOption('', '- None -'));
            for (hed__Course_Enrollment__c cc : [select id, Course_Name__c, hed__Contact__c from hed__Course_Enrollment__c where hed__Contact__c =: userContactId limit 100]) {
                courses.add(new selectOption(cc.id, cc.Course_Name__c));
            }
            return courses;
    
        }
        private set;
        
    }
   
    public String CourseSelected {get; set;}
        
    public Case cs;
    
    public CaseTutorRequestExtension(ApexPages.StandardController stdController){
        
        // Get ContactId from User
        //List<user> lstUser = [Select ContactId From User Where Id =: UserInfo.getUserId()];
        //userContactId = lstUser[0].ContactId;
            
        this.cs = (Case)stdController.getRecord();
        
    }
    
    public PageReference save(){
            
        Pagereference p = apexpages.Currentpage();
        PageReference pageRef = new PageReference('/USF_TutorRequestConfirmation');
        pageRef.setRedirect(true);
        
        // Set auto fields here
        cs.RecordtypeId = Label.Tutor_Request_Record_Type_Id;
        cs.Reason = 'Tutor Request';
        cs.Subject = 'Tutor Request';
        cs.Origin = 'Portal';  // Required
        cs.course_connection__c = CourseSelected;
        
        
        // Set Validation for Save with ContactId
            try {
                //system.debug('userContactId 2: ' + userContactId);
                
                //integer maxCount = database.countQuery('Select count() from Case where (contactId =: userContactId ) and ((status = \'New\') or (status = \'Open\')) ');
                //integer subjectCount = database.countQuery('Select count() from Case where (contactId =: userContactId) and ((status = \'New\') or (status = \'Open\')) and (course_connection__c =: CourseSelected )');
                
                integer maxCount = database.countQuery('Select count() from Case where (contactId =: userContactId ) and (isClosed = false) ');
                integer subjectCount = database.countQuery('Select count() from Case where (contactId =: userContactId) and (isClosed = false) and (course_connection__c =: CourseSelected )');
               
                if (maxCount >= 3) {
                    ApexPages.Message msg = new Apexpages.Message(ApexPages.severity.Info,'You have reached maximum number of request!');
                    ApexPages.addmessage(msg);
                    return p; 
                } else if (subjectCount >= 1) {
                    ApexPages.Message msg2 = new Apexpages.Message(ApexPages.severity.Info,'You have already requested tutor for this subject!');
                    ApexPages.addmessage(msg2);
                    return p; 
                } else {
                    try {
                        upsert cs;
                        return pageRef;
                    } catch(Exception ex) {
                        ApexPages.addMessages(ex);
                    }    
                }
            } catch(Exception ex) {
                ApexPages.addMessages(ex);
            }
        
        return null;
    }
    
    public PageReference cancel() {
       
        //system.debug('Cancel method');
        
        //PageReference pageRef = new PageReference(ApexPages.currentPage().getUrl());
        PageReference pageRef = new PageReference('/USF_StudentDashboard');
        pageRef.setRedirect(true);
        return pageRef;
    } 
       
}