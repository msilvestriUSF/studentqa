public with sharing class USF_TestPageController {

public List<PermissionSetAssignment> permissionAssign;
public Boolean isPermissionAssgined {get;set;}
public String linkValue {get;set;}
public List<Account> center {get;set;}

public USF_TestPageController(){

center=[Select id,name from account where id='0012C0000034yj1'];

permissionAssign=new List<PermissionSetAssignment>();
isPermissionAssgined =false;

if(getPermissionSetFlag()){

  linkValue='';

  String usrProfileName = [select id, Profile.Name from User where id = :Userinfo.getUserId()].Profile.Name;
	//Modified by Vandana to remove permission set related functionality
        User currentUser = [Select Id, ContactId, AccountId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        List<Consultant__c> activeConsultants = USF_DBUtil.getActiveConsultantsByContactId(currentUser.ContactId);
         
  if(!activeConsultants.isEmpty()){
            linkValue='Switch To Student View';
    }    
    else if(usrProfileName == App_Config__c.getInstance('Student Profile').Text_Value__c){
            linkValue='Switch To Consultant View';
    }



}
}


public Boolean getPermissionSetFlag(){

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


}