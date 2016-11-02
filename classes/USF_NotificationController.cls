public class USF_NotificationController {
    Public list<AppointmentContact__Feed> lstAppFeed {get;set;}
    Public Set<ID> SetAppID {get;set;}
    Public string strPostType {get;set;}
    public list<wrapChatterPost> lstFinalChatterPost {get;set;}
    public list<wrapChatterPost> lstDisplayPost {get;set;}
    public String pageNameValue {get;set;}
    //Added by Vandana - DFCT0011042
    public String selectedCoachValue{get;set;}
    
    public USF_NotificationController(){
        
       /* getAppointmentID();
        if(!SetAppID.isEmpty()){
            getChatterPost();
        }*/
        //Added by Vandana - DFCT0011042
        selectedCoachValue = '';
    }
    
    public void getAppointmentID(){
        SetAppID= new set<ID>();
        string filterCondition='';
        //list<AppointmentContact__c> lstAppFeedDisplay=[select ID From AppointmentContact__c /*where Start_Date__c >=TODAY AND Start_Date__c<=TOMORROW*/];
        String query='select ID From AppointmentContact__c where Start_Date__c >=TODAY AND Start_Date__c<=TOMORROW ';
        if(String.isNotBlank(pageNameValue) && pageNameValue.equalsignorecase('casaDashboard')){
        filterCondition=' AND recordType.developername=\''+App_Config__c.getInstance('CASA Appointment RecordType').Text_Value__c+'\'';
        }
        else if(String.isNotBlank(pageNameValue) && pageNameValue.equalsignorecase('lwcDashboard')){
         filterCondition=' AND recordType.developername=\''+App_Config__c.getInstance('LWC Appointment RecordType').Text_Value__c+'\'';
        }
        
        //Added by Vandana - DFCT0011042 - start
        if(selectedCoachValue!='' && selectedCoachValue!= null && selectedCoachValue!=App_Config__c.getInstance('Default CASA Coach filter').Text_Value__c){
	     filterCondition +=' AND AppointmentSlot__r.Availability__r.Coach__c=\''+selectedCoachValue+'\'';
	    }
        //Added by Vandana - DFCT0011042 - end
        list<AppointmentContact__c> lstAppFeedDisplay=Database.query(query+filterCondition);
        system.debug('teststring:'+query+filterCondition);
        if(!lstAppFeedDisplay.isEmpty()){
            for(AppointmentContact__c toset:lstAppFeedDisplay){
                SetAppID.add(toset.ID);
            }
        }
    }
    public list<wrapChatterPost> getChatterPost(){
        getAppointmentID();
        lstDisplayPost= new list<wrapChatterPost>();
        if(!SetAppID.isEmpty()){
        
        lstFinalChatterPost= new list<wrapChatterPost>();
        lstAppFeed= new list<AppointmentContact__Feed>();
        lstAppFeed=[SELECT Body,CreatedDate, ParentId, Title FROM AppointmentContact__Feed WHERE Type = 'TextPost' AND ParentId IN:SetAppID ORDER BY CreatedDate DESC LIMIT 5];
        if(!lstAppFeed.isEmpty()){
            for(AppointmentContact__Feed feedpost: lstAppFeed){
                if(feedpost.Title=='Checked-In' ||feedpost.Title=='Update' ||feedpost.Title=='Missed' || feedpost.Title=='Cancelled'){
                    Datetime startDate = system.now();// Start date
                    Datetime endDate = feedpost.CreatedDate;//End Date               
                    long decHours = (((startDate.getTime())/1000/60-(endDate.getTime())/1000/60) );
                    long hours =decHours/60;
                    long minute= math.mod(decHours, 60);
                    if(hours>=24){
                        lstFinalChatterPost.add(new wrapChatterPost(feedpost.Title, feedpost.Body, 'On '+endDate ));
                    }
                    else if(hours<>0 && minute<>0){
                        lstFinalChatterPost.add(new wrapChatterPost(feedpost.Title, feedpost.Body, hours+' Hr '+ minute+' Minutes Ago'));
                    }
                    else if(hours==0 && minute==0){
                        lstFinalChatterPost.add(new wrapChatterPost(feedpost.Title, feedpost.Body, 'Just Now'));
                    }
                    else if(hours<>0 && minute==0){
                        lstFinalChatterPost.add(new wrapChatterPost(feedpost.Title, feedpost.Body, hours+' Hr Ago'));
                    }
                    else{
                        lstFinalChatterPost.add(new wrapChatterPost(feedpost.Title, feedpost.Body, minute+' Minutes Ago'));
                    }
                    system.debug('lstFinalChatterPost'+lstFinalChatterPost);
                }
            }
            lstDisplayPost.addAll(lstFinalChatterPost);
        }
        return lstDisplayPost;
        }
      return lstDisplayPost;
    }
    
    public void getSpecified(){
        lstDisplayPost.clear();
        for(wrapChatterPost specified: lstFinalChatterPost){
            if(specified.strTittle==strPostType){
                lstDisplayPost.add(specified);
            }
        }
    }
    public void getAll(){
        getAppointmentID();
        if(!SetAppID.isEmpty()){
           // getChatterPost();
        }
    }
    
    public void getBack(){
        lstDisplayPost.clear();
        lstDisplayPost.addAll(lstFinalChatterPost);
    }
    
    public class wrapChatterPost{
        public string strTittle {get; set;}
        public string strBody {get; set;}
        public string strDuration {get; set;}
        
        public wrapChatterPost(string Tittle, string Body, string Duration){
            strTittle = Tittle;
            strBody = Body;
            strDuration = Duration;
        }
    }
}