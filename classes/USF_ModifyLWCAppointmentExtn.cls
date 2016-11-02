//************************************************************************************
// Name             : USF_ModifyLWCAppointmentExtn
// Description      : Contoller to USF_ModifyLWCAppointment Visualforce page
// Created By       : Mohan Kalagatla
// Created Date     : 08/25/2016 
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 08/25/2016        Mohan Kalagatla       Created
// ************************************************************************************
public with sharing class USF_ModifyLWCAppointmentExtn {
    ApexPages.StandardController stdController {get; set;}
    public Id appointmentId {get; set;}
    public String fileName {get;set;}
    public Blob fileBody{get;set;}
    public String newType{get;set;}
    public String newPhone{get;set;}
    public String newNotes{get;set;}
    public Boolean disableNotes{get;set;}
    public Boolean isLearning{get;set;}
    public Boolean isWriting{get;set;}
    public Boolean isSpeaking{get;set;}
    public List<Attachment> allCurrentAttachments{get;set;}
    public String attachmentIdsToBeRemoved{get;set;}
    public Attachment attachment { 
        get {
          if (attachment == null)
            attachment = new Attachment();
          return attachment;
        }
        set;}
    
    // Counstuctor for initializations
    public USF_ModifyLWCAppointmentExtn(ApexPages.StandardController controller){
        isLearning = false;
        isWriting = false;
        isSpeaking = false;
        disableNotes = false;
        attachmentIdsToBeRemoved = '';
        stdController = controller;
        appointmentId = ((AppointmentContact__c)stdController.getRecord()).Id; 
        allCurrentAttachments = new List<Attachment>();
        AppointmentContact__c  appointment = [SELECT Id,(SELECT Id,Name FROM Attachments) FROM AppointmentContact__c WHERE Id=:appointmentId];
        allCurrentAttachments = appointment.Attachments;
    }
    
    // Get Appointment
    public USF_AppointmentDTO getAppDTO(){
         AppointmentContact__c  appointment = [SELECT Id,Status__c,Reason_for_Meeting__c,Notes__c,Phone__c,Referred_By__c,Referrer_Name__c,Date_Time__c,
                        Type__c,SelectedCourse__r.Name,Contact__r.id,AppointmentSlot__r.Name,AppointmentSlot__r.Location__c,Center__c,
                        AppointmentSlot__r.Type__c,AppointmentSlot__r.Coach_Full_Name__c,AppointmentSlot__r.Start_Time__c,
                        AppointmentSlot__r.End_Time__c,Coach_Specialty__r.Name,LWC_LearningStyles__c,Preferred_Phone__c,(SELECT Id,Name FROM Attachments)
                        FROM AppointmentContact__c WHERE Id=:appointmentId]; 
         newType = appointment.Type__c;
         newPhone = appointment.Preferred_Phone__c;
         newNotes = appointment.Notes__c;
         
         DateTime currentTime = DateTime.now();
        if(currentTime > appointment.AppointmentSlot__r.Start_Time__c){
           disableNotes = true;
        }
         allCurrentAttachments = new List<Attachment>();
         allCurrentAttachments = appointment.Attachments;
         System.debug('allCurrentAttachments: '+allCurrentAttachments);
         if(appointment.Center__c.contains(App_Config__c.getInstance('Learning Center').Text_Value__c)){
            isLearning = true;
         }else if(appointment.Center__c.contains(App_Config__c.getInstance('Speaking Center').Text_Value__c)){
            isSpeaking = true;
         }else if(appointment.Center__c.contains(App_Config__c.getInstance('Writing Center').Text_Value__c)){
            isWriting = true;
         }
         System.debug('isLearning'+isLearning);
         System.debug('isWriting'+isWriting);
         System.debug('isSpeaking'+isSpeaking);
         
         USF_AppointmentDTO appDTO = new USF_AppointmentDTO(appointment,appointment.AppointmentSlot__r.Start_Time__c.format('d MMMM yyyy'),appointment.AppointmentSlot__r.Start_Time__c.format('hh:mm a')+' - '+appointment.AppointmentSlot__r.End_Time__c.format('hh:mm a'));
         return appDTO;     
    }
    
    // Get Type picklist values   
     public List<SelectOption> getType(){     
        List<SelectOption> options = new List<SelectOption>();     
        options.add(new SelectOption('','-None-'));
        Schema.DescribeFieldResult fieldResult = AppointmentContact__c.Type__c.getDescribe();
        if(fieldResult!=null){
        for(Schema.PicklistEntry p : fieldResult.getPicklistValues()){
        options.add(new SelectOption(p.getValue(), p.getValue()));   
        }
        }
        return options;
    }    
    
    //  Method to save Appointment record and return to USF_ModifyLWCAppointmentConfirmation VF page
    public PageReference modifyAppointment(){ 
        try{  
            AppointmentContact__c appointment = new AppointmentContact__c();  
            if(appointmentId!=null){
                appointment.id=appointmentId;
               /*  if(fileBody != null && fileName != null){
                      Attachment myAttachment  = new Attachment();
                      myAttachment.Body = fileBody;
                      myAttachment.Name = fileName;
                      myAttachment.ParentId = appointmentId;
                      insert myAttachment;
                 } */
                 
                 if(appointment.Type__c!=newType) 
                    appointment.Type__c = newType;
                 if(appointment.Preferred_Phone__c != newPhone)   
                    appointment.Preferred_Phone__c = newPhone;    
                 if(appointment.Notes__c != newNotes)     
                    appointment.Notes__c = newNotes;            
                    if(appointment!=null){  
                        update appointment;   
                    }  
             }
                deleteAttachments();
                PageReference pageRef = Page.USF_ModifyLWCAppointmentConfirmation;
                pageRef.getParameters().put('Id',appointmentId);
                pageRef.setRedirect(true);
                return pageRef; 
                
        }        
        catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
                return null;
        }
     }
     
     public void deleteAttachments(){
        try{
            System.debug('attachmentIdsToBeRemoved**'+attachmentIdsToBeRemoved);
            List<String> allAttachmentIds = new List<String>();
            allAttachmentIds = attachmentIdsToBeRemoved.split(';');
            List<Attachment> finalAttachmentsDelete = new List<Attachment>();
            finalAttachmentsDelete = [Select Id FROM Attachment WHERE Id IN :allAttachmentIds];
            if(!finalAttachmentsDelete.isEmpty()){
                delete finalAttachmentsDelete;
            }
        }catch(Exception ex){
                // Display the error message
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
        }
        
     }   
}