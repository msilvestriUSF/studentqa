public with sharing class USF_StudentHelpFAQExtn{
    
    public String FolderName{get;set;}
    public String FolderId{get;set;}
    public List<Document> allDocuments{get;set;}
    public USF_StudentHelpFAQExtn(){
        try{
            FolderName = App_Config__c.getValues('Document Folder Name for Student Help').Text_Value__c;
            FolderId = USF_DBUtil.getFolderIdByFolderName(FolderName);
            
            allDocuments = new List<Document>();
            allDocuments = USF_DBUtil.getDocumentsByFolderId(FolderId);
            System.debug('allDocuments***'+allDocuments);
            
        }catch(Exception e){
            System.debug('Exception: '+e.getMessage());
        }
    }
   
}