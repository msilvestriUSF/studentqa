/************************************************************************************
// Name             : USF_PermissionSetAssignmentUtli
// Description      : Controller for reusing permission set assignment
// Created By       : Manjunath Singh
// Created Date     : 09/27/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 09/27/2016       Manjunath Singh       Created
// ************************************************************************************/

public class USF_PermissionSetAssignmentUtli{

public Static Boolean isToggled=false;

public Static List<PermissionSetAssignment> permissionAssign;

  //This method is used for toggle dashboard functionality
  public static Boolean getPermissionSetFlag(){
    Boolean isPermissionAssgined=false;
    try{
        permissionAssign=[SELECT Id, PermissionSetId FROM PermissionSetAssignment WHERE AssigneeId = :UserInfo.getUserId() and PermissionSet.Name='USF_StudentConsultantSwitch'];
        
        if(permissionAssign.size()>0){
            isPermissionAssgined =true;
        }
    }
    Catch(Exception e){
    
    }
    
    return isPermissionAssgined ;
    
    }  
    
    
      //This method is used for toggle dashboard functionality
  public static List<User> getPermissionSetAssignees(String permissionSetName){
  
   List<User> assignedUsers=new List<User>();
    try{     
        assignedUsers=[SELECT id,name from User where id in (SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSet.Name=:permissionSetName)];
        if(assignedUsers.size()>0){
            return assignedUsers;
        }
    }
    Catch(Exception e){
    
    }
    
    return assignedUsers;
    
    } 


}