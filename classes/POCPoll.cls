public without sharing class POCPoll {
	
	private final Contact ct;
	public Id contactId{get;set;}
	
	public POCPoll(ApexPages.StandardController ctr){
		this.ct=(Contact)ctr.getRecord();
	}
    
    public void createPoll(){
    	
    }
}