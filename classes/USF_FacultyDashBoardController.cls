/************************************************************************************
// Name             : USF_FacultyDashBoardController 
// Description      : Controller for USF_FacultyDashBoard Visualforce page
// Created By       : Manjunath Singh
// Created Date     : 09/14/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 09/14/2016       Manjunath Singh       Created
// ************************************************************************************/
public with sharing class USF_FacultyDashBoardController {

    //Variable to store eapReport records
    public ApexPages.StandardSetController eapReportRecords;  
    public Map<Id,String> eapDateMap {get; set;}
    public Integer eapPageSize{get;set;}
    public Integer noOfRecords{get; set;}

    //Constructor
    public USF_FacultyDashBoardController (){
    
    eapDateMap=new Map<Id,String>();
    Id eapRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get(App_Config__c.getInstance('EAP Report RecordType').Text_Value__c).getRecordTypeId();
    
    eapPageSize=5;
    eapReportRecords= new ApexPages.StandardSetController(Database.getQueryLocator(
                [SELECT id,contact.name,CWID__c,ContactFirstName__c,ContactLastName__c,contact.CWID__c,CourseName__c, Course_Section__c ,createddate 
                FROM case 
                WHERE createdById=:UserInfo.getUserId() 
                AND recordTypeID=:eapRecordTypeId
                ORDER BY createddate desc,ContactLastName__c asc
                LIMIT 10000])
                );
    //eapReportRecords=USF_DBUtil.getFacultyDashboardReports(eapRecordTypeId);
    
    eapReportRecords.setPageSize(eapPageSize);
    noOfRecords=eapReportRecords.getResultSize();
    }
    
    //This method is used to format createddatetime
    
   /* public void formatCreatedDateTime(){
    
     for(AppointmentContact__c app: appointments){   
            if(app.Date_Time__c != null && UserInfo.getTimeZone().getID()!=null){
            appointmentDateMap.put(app.Id,app.Date_Time__c.format('d MMM yy, HH:mm a', UserInfo.getTimeZone().getID()));
            }
    
    }*/
    
    
    /**************************************************************
    Description: This method is used to populate eap report table
    Return type: List<case>
    Parameters: None
    Created By: Manjunath Singh
    ***************************************************************/
    public List<case> getEAPReports() {
    
    for(Case caseRecord: (List<case>)eapReportRecords.getRecords()){ 
    system.debug('Record:'+caseRecord.contact.name);  
          //  if(app.Date_Time__c != null && UserInfo.getTimeZone().getID()!=null){
            eapDateMap.put(caseRecord.Id,caseRecord.createddate.format('EEEE,MMM d yyyy,hh:mm a'));
            //caseRecord.createddate.format('EEEE,MMM d yyyy,hh:mm a');
           // }
    }
        return (List<case>) eapReportRecords.getRecords();
    }
    
    //Pagination methods for EapReport Records
    public Boolean hasNext {
        get {
            return eapReportRecords.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return eapReportRecords.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber {
        get {
            return eapReportRecords.getPageNumber();
        }
        set;
    }
  
    public void first() {
        eapReportRecords.first();
    }
  
    public void last() {
        eapReportRecords.last();
    }
  
    public void previous() {
        eapReportRecords.previous();
    }
  
    public void next() {
        eapReportRecords.next();    
    }
    
    
}