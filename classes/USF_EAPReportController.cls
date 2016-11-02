/************************************************************************************
// Name             : USF_EAPReportController
// Description      : Controller for USF_FacultyStaffEAPIntg Visualforce page
// Created By       : Manjunath Singh
// Created Date     : 08/30/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 08/30/2016       Manjunath Singh       Created
// ************************************************************************************/
public with sharing class USF_EAPReportController{

    private User loggedInUser;
    public Integer pageSize{get;set;}
    public Integer studentPageSize{get;set;}
    public Integer noOfRecords{get; set;}
    public String courseOfferingId {get;set;}
    public boolean showStudentSection{get;set;}
    public Integer noOfStudentRecords{get; set;}
    public String courseName {get;set;}
 
    //Variable to store course records
    public ApexPages.StandardSetController coursesRecords;
    
    //Variable to store Student records
    public ApexPages.StandardSetController studentRecords;

    //Constructor
    public USF_EAPReportController(){
    
        pageSize=5;
        studentPageSize=5;
        showStudentSection=false;
        //selectedStudent='';
        loggedInUser=[Select id,contactid from User where id=:UserInfo.getUserId()];
        /*coursesRecords= new ApexPages.StandardSetController(Database.getQueryLocator(
                [SELECT id,name,hed__Course__r.name,hed__Section_ID__c FROM hed__Course_Offering__c WHERE hed__Faculty__c=:loggedInUser.contactId LIMIT 10000])
                );
                */
        coursesRecords=USF_DBUtil.getCourseOfferings(loggedInUser.contactId);       
        coursesRecords.setpageSize(pageSize);
        noOfRecords = coursesRecords.getResultSize();
        
    }

    public List<hed__Course_Offering__c> getCourses() {
        return (List<hed__Course_Offering__c>) coursesRecords.getRecords();
    }
    
    //Pagination methods for Courses
    public Boolean hasNext {
        get {
            return coursesRecords.getHasNext();
        }
        set;
    }
    public Boolean hasPrevious {
        get {
            return coursesRecords.getHasPrevious();
        }
        set;
    }
  
    public Integer pageNumber {
        get {
            return coursesRecords.getPageNumber();
        }
        set;
    }
  
    public void first() {
        coursesRecords.first();
    }
  
    public void last() {
        coursesRecords.last();
    }
  
    public void previous() {
        coursesRecords.previous();
    }
  
    public void next() {
        coursesRecords.next();    
    }
    
    
    public void viewStudents(){
    
   /* studentRecords= new ApexPages.StandardSetController(Database.getQueryLocator(
                [SELECT id,name,lastname,firstname,AcademicSuccessCoach__r.name,CWID__c FROM contact WHERE Student__c=true
                AND ID in(SELECT hed__Contact__c FROM hed__Course_Enrollment__c WHERE hed__Course_Offering__c=:courseOfferingId) ORDER BY lastname LIMIT 10000])
                );
                */
   studentRecords= USF_DBUtil.getStudentsForCourseOffering(courseOfferingId);            
    //if(studentRecords.getResultSize()>0){showStudentSection=true;}
    showStudentSection=true;
    studentRecords.setPageSize(studentPageSize);
    noOfStudentRecords=studentRecords.getResultSize();
    }
    
    public List<contact> getStudents() {
        return (List<contact>) studentRecords.getRecords();
    }
    
    //Pagination methods for Students
    public Boolean studentHasNext {
        get {
            return studentRecords.getHasNext();
        }
        set;
    }
    public Boolean studentHasPrevious {
        get {
            return studentRecords.getHasPrevious();
        }
        set;
    }
  
    public Integer studentPageNumber {
        get {
            return studentRecords.getPageNumber();
        }
        set;
    }
  
    public void studentFirst() {
        studentRecords.first();
    }
  
    public void studentLast() {
        studentRecords.last();
    }
  
    public void studentPrevious() {
        studentRecords.previous();
    }
  
    public void studentNext() {
        studentRecords.next();    
    }

}