/************************************************************************************
 Name             : USF_FacultyStaffEAPFormController 
 Description      : Controller for USF_FacultyStaffEAPForm Visualforce page
 Created By       : Manjunath Singh
 Created Date     : 09/09/2016
 ************************Version Updates********************************************
 Date             Developer           Description
 -----------------------------------------------------------------------------------
 09/09/2016       Manjunath Singh       Created
 ************************************************************************************/

public with sharing class USF_FacultyStaffEAPFormController {

    public Case newEAPReport{get;set;}
    public String sId;
    public String sName{get;set;}
    public String cId;
    public String ascId;
    public String caseId;
    public Boolean viewFormToggle {get;set;}
    public String facultyName{get;set;}
    public List<hed__Course_Offering__c> courseOffering;
    public String courseSectionName{get;set;}
    public String message {get;set;}
    public Case eapReportRecord {get;set;}
    private User loggedInUser;



  /***************************************************************************
    Description: This method is used for Areas for Improvement multiselect 
                 picklist to checkbox conversion
    Return type: String[]
    Parameters: None
    Created By: Manjunath Singh
    ***************************************************************************/
    
    public String[] areasOfImp=new String [] {};
    
    public String[] getareasOfImp() {
        return areasOfImp;
    }

    public void setareasOfImp(String[] areasOfImp) {
        this.areasOfImp= areasOfImp;
    }
    
    


  /***************************************************************************
    Description: This method is used for work multiselect 
                 picklist to checkbox conversion
    Return type: String[]
    Parameters: None
    Created By: Manjunath Singh
    ***************************************************************************/
    Public String[] selectedWork = new String[]{};
    
    public String[] getselectedWork() {
        return selectedWork;
    }

    public void setselectedWork(String[] selectedWork) {
        this.selectedWork = selectedWork;
    }
    

    
  /***************************************************************************
    Description: This method is used for recomendations multiselect 
                 picklist to checkbox conversion
    Return type: String[]
    Parameters: None
    Created By: Manjunath Singh
    ***************************************************************************/
    Public String[] selectedRecomendations = new String[]{};
    
    public String[] getselectedRecomendations () {
        return selectedRecomendations ;
    }

    public void setselectedRecomendations (String[] selectedRecomendations) {
        this.selectedRecomendations = selectedRecomendations;
    }

    /***************************************************************************
    Description: This is the consturtor.
    Return type: None
    Parameters: None
    Created By: Manjunath Singh
    ***************************************************************************/
    public USF_FacultyStaffEAPFormController(ApexPages.StandardController controller) {
    
    viewFormToggle=false;
    
    courseOffering=new List<hed__Course_Offering__c>();
    sId=Apexpages.currentPage().getParameters().get('sId');
    sName=Apexpages.currentPage().getParameters().get('sName');
    cId=Apexpages.currentPage().getParameters().get('cId');
    ascId=Apexpages.currentPage().getParameters().get('ascId');
    
    //This is for View form functionality-Start
    caseId=Apexpages.currentPage().getParameters().get('eapId');
    viewFormToggle=(Apexpages.currentPage().getParameters().get('view')!=null && Apexpages.currentPage().getParameters().get('view')!='')?true:false;
    loggedInUser=[Select id,contactid from User where id=:UserInfo.getUserId()];

    if(caseId!=null && caseId!='' && viewFormToggle){
          
          populateViewForm();
    }
    
    //This is for View form functionality-End
    
    facultyName=UserInfo.getName();
    
    
    //courseOffering=[SELECT id,hed__Course__r.name,hed__Section_ID__c,hed__Course__r.Course_Number__c from hed__Course_Offering__c where id=:cId LIMIT 1];
    courseOffering=USF_DBUtil.getCourseOfferingInfo(cId);
    if(courseOffering.size()!=0 && courseOffering!=null){
        if(courseOffering[0].hed__Section_ID__c != null)
            courseSectionName=courseOffering[0].hed__Course__r.name+ ' ('+courseOffering[0].hed__Section_ID__c +')';
        else
            courseSectionName=courseOffering[0].hed__Course__r.name;
    }
    
    Id devRecordTypeId = Schema.SObjectType.case.getRecordTypeInfosByName().get(App_Config__c.getInstance('EAP Report RecordType').Text_Value__c).getRecordTypeId();
    newEAPReport=(Case)controller.getRecord();
    if(ascId!=null && ascId!=''){
    newEAPReport.ownerId=ascId;
    }
    if(cId!=null && cId!=''){
    newEAPReport.Course_Offering__c=cId;
    }
    if(loggedInUser.contactid !=null){
    newEAPReport.Faculty__c=loggedInUser.contactId;
    }
    if(courseOffering!=null && courseOffering.size()>0)
    newEAPReport.subject=sName+' '+courseOffering[0].hed__Course__r.name+' '+courseOffering[0].hed__Course__r.Course_Number__c;
    newEAPReport.contactId=sId;
    newEAPReport.recordTypeId=devRecordTypeId;
    newEAPReport.Origin=App_Config__c.getInstance('EAP Form Referral value').Text_Value__c;
    newEAPReport.Reason=App_Config__c.getInstance('EAP Form Reason value').Text_Value__c;

    }
   /***************************************************************************
   Description: This method is used to save the submitted report. (Case)
   Return type: PageReference 
   Parameters: None
   Created By: Manjunath Singh
   ***************************************************************************/   
   public PageReference submitReferral(){

   try{
    if(areasOfImp !=null){
        for(String areaOfImprovement : areasOfImp ){
                                if(newEAPReport.Areas_for_improvement__c == null || newEAPReport.Areas_for_improvement__c == '')
                                    newEAPReport.Areas_for_improvement__c = areaOfImprovement + ';';
        
                                 else
                                    newEAPReport.Areas_for_improvement__c = newEAPReport.Areas_for_improvement__c + areaOfImprovement + ';';
                            } 
         }
     
    if(selectedWork !=null ){
        for(String work: selectedWork ){
                                if(newEAPReport.Work__c == null || newEAPReport.Work__c == '')
                                    newEAPReport.work__c = work+ ';';
        
                                 else
                                    newEAPReport.work__c = newEAPReport.work__c + work+ ';';
                            } 
    }
    
    if(selectedRecomendations !=null ){
        for(String recommendation: selectedRecomendations ){
                                if(newEAPReport.Recommendations__c == null || newEAPReport.Recommendations__c == '')
                                    newEAPReport.Recommendations__c = recommendation+ ';';
        
                                 else
                                    newEAPReport.Recommendations__c = newEAPReport.Recommendations__c + recommendation+ ';';
                            } 
    }
        if(newEAPReport != null){
            //insert newEAPReport;
            USF_DBUtil.insertEAPReport(newEAPReport);
        }
        message=App_Config__c.getInstance('EAP Form Submit Success Message').Text_Value__c;
    }
    catch(Exception e){
    message=e.getMessage();
    //Apexpages.addmessage(new ApexPages.message(ApexPages.severity.Error,e.getMessage()));
    }

return null;
}

 /*********************************************************************************
    Description: This method is is used to populate areas of improvment checkboxes.
    Return type: List<SelectOption>
    Parameters: None
    Created By: Manjunath Singh
    ******************************************************************************/

 public List<SelectOption> getAreasOfImprovement()
    {
       List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =case.Areas_for_improvement__c.getDescribe();
       
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    
    
 /*********************************************************************************
    Description: This method is is used to populate work checkboxes.
    Return type: List<SelectOption>
    Parameters: None
    Created By: Manjunath Singh
    ******************************************************************************/
    
    public List<SelectOption> getWorkValues()
    {
       List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =case.Work__c.getDescribe();
       
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    
    
 /*********************************************************************************
    Description: This method is is used to populate recommendations checkboxes.
    Return type: List<SelectOption>
    Parameters: None
    Created By: Manjunath Singh
    ******************************************************************************/
    
    public List<SelectOption> getRecommendationValues()
    {
      List<SelectOption> options = new List<SelectOption>();
            
       Schema.DescribeFieldResult fieldResult =case.Recommendations__c.getDescribe();
       
       List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            
       for( Schema.PicklistEntry f : ple)
       {
          options.add(new SelectOption(f.getLabel(), f.getValue()));
       }       
       return options;
    }
    
    
   /*******************************************************************************
    Description: This method is is used to populate form details in Read only mode.
    Return type: Void
    Parameters: None
    Created By: Manjunath Singh
    ******************************************************************************/
    
    public void populateViewForm(){
    
    try{
        eapReportRecord=[Select id,contact.name,CaseNumber,ContactLastName__c,ContactFirstName__c,Notes__c,CWID__c,CourseName__c,Course_Section__c, Areas_for_improvement__c,work__c,Recommendations__c,Description,Estimated_Grade__c from case where id=:caseId limit 1];
        areasOfImp=(eapReportRecord.Areas_for_improvement__c!=null && eapReportRecord.Areas_for_improvement__c!='')?eapReportRecord.Areas_for_improvement__c.split(';'):new string[]{};
        selectedWork=(eapReportRecord.work__c!=null && eapReportRecord.work__c!='')?eapReportRecord.work__c.split(';'):new string[]{};
        selectedRecomendations=(eapReportRecord.Recommendations__c!=null && eapReportRecord.Recommendations__c!='')?eapReportRecord.Recommendations__c.split(';'):new string[]{};
    }
    Catch(Exception e){
    
    }
    
    
    
    }

}