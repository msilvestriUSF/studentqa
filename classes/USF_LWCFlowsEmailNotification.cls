Public class USF_LWCFlowsEmailNotification
{
/** Class Name  : USF_LWC_Email_Notification    
*  Description  : An Invocable Communication Preference Handler to execute functions from Process Builder or Flows. 
*  Created By   : Gere Prasath 
*  Created On   : 1st SEP 2016.
*
*  Modification Log:  
*  --------------------------------------------------------------------------------------------------------------------------------------
*   Developer                Date                   Modification ID      Description 
*  ---------------------------------------------------------------------------------------------------------------------------------------
*/

Public List<AppointmentContact__c> Listofstud {get;set;}
public List<AppointmentContact__c> IdList {get;set;}
public emailtemplate em {get;set;}
public USF_LWCFlowsEmailNotification()
{
}
@invocableMethod
public static void EmailList(List<LWCEmailWrapper>  cs){
    List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
     
    List<String> sendTo = new List<String>();
    EmailTemplate em;
    //Added by Vandana - STRY0012151 - Start
    if(cs[0].eventName == 'Notify Staff'){
        //contactsToNotify: List of set of strings, each string has contact ids separated by a semicolon
        List<String> allcontactIds = new List<String>();  
        
        //Put all individual ids in a list called allcontactIds
        if(cs[0].contactsToNotify!=null && cs[0].contactsToNotify!=''){
            allcontactIds = cs[0].contactsToNotify.split(';');
        }
        System.debug('**allcontactIds:'+allcontactIds);
        //Query the email of each contact     
        em = [SELECT Id,DeveloperName FROM EmailTemplate WHERE DeveloperName = :cs[0].EmailTemplateName LIMIT 1];
         
        for(Contact con : [Select Id,Email from Contact where Id IN :allcontactIds]){
            
            sendTo = new List<String>();
            Messaging.SingleEmailMessage emails=new Messaging.SingleEmailMessage();
            System.debug('**con.Email**'+con.Email);
            sendTo.add(con.Email);
            emails.setTargetObjectId(con.Id);
            if(em!=null){           
                emails.setTemplateId(em.id);
                emails.setWhatId(cs[0].AppointmentId);
                
            }else{
                String body = 'Appointment ['+cs[0].AppointmentId+'] has been completed.';
                emails.setPlainTextBody(body);
            }
            
             //compose the email and send
            emails.setToAddresses(sendTo);
            emails.setSenderDisplayName('University Of San Fransisco');
            mails.add(emails);
        }
       
        Messaging.sendEmail(mails);
    }
    //Added by Vandana - STRY0012151 - End
    else{
        Messaging.SingleEmailMessage emails=new Messaging.SingleEmailMessage();
        Counsellor_Availability__c  counavail=new Counsellor_Availability__c();
        List<user> IdList=[select ID from user where email=:cs[0].AccountId LIMIT 1];
        //em = [SELECT id from emailtemplate where name='Email LWC Location change' LIMIT 1]; 
        List<Id> vLstUserId = new List<Id>();
        for(User vUser: IdList){
            vLstUserId.add(vUser.Id);
        }
        
        if(!vLstUserId.isempty()){
              sendTo.add(cs[0].AccountId);
              emails.setToAddresses(sendTo);
              emails.setSenderDisplayName('University Of Sanfransisco');
              emails.setSubject('Regarding Location Change Request');
              String body = 'Dear ' +cs[0].eventName +',\n\n';
              body += 'Your Location Change for Appointment at '+cs[0].ObjId+' has been changed to '+cs[0].Location+'. \n\n';
              body +=  'Have a wonderful day, \n\n';
              body +=  'The Learning & Writing Center';
        
              emails.setPlainTextBody(body);
              mails.add(emails);
              Messaging.sendEmail(mails);           
        }
    }
} 

//Wrapper classe for invocable Variables
public class LWCEmailWrapper{
        @invocableVariable(label='event Name') //developerName
        public string eventName;
        @invocableVariable(label='Object Id')
        public DateTime ObjId;
        @invocableVariable(label='Account Id')
        public string AccountId;
        @invocableVariable(label='Location')
        Public String Location;
        @invocableVariable(label='Email Template Name')
        Public String EmailTemplateName;
        @invocableVariable(label='Contacts To Notify')
        public string contactsToNotify;
        @invocableVariable(label='Appointment Id')
        public string AppointmentId;

    }
}