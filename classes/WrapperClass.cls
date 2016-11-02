/******************************************************************************************************************************************
Apex Class Name: CounselorAvailabilityUtils
Version        : 1.0
Created Date   : 26 MAY 2016
Function       : Utility class to handle passing of controller variables between page and controller for interview scheduler
Modification Log :
_____________________________________________________________________________________________________________________________________________
* Developer                         Date                            Description
*---------------------------------------------------------------------------------------------------------------------------------------------
* Scott C. Harbaugh                 05/05/2016                      Moved from being in controller to seperate file
TODO: Suggest we also move the functionallity to this class

**********************************************************************************************************************************************/

public class WrapperClass {
      public string startdate{get;set;}
      public string enddate{get;set;}
      public string custName{get;set;}
      public string custAvailid{get;set;}
      public string interviewerId{get;set;}
      public string typeofInterview{get;set;}
      public string typeofAppoitment{get;set;}
      public Decimal capacity {get;set;}
      public string location {get;set;}
      public boolean disabled {get;set;}   
    
  }