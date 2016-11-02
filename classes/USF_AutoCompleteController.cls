global without sharing class USF_AutoCompleteController {




    /*********************************************************
    Method Name: searchObject
    Description: Remote action method called from VF component
             which do search on User based on parameters
    Input Parameters: strings
    Return type: List of sObject
    **********************************************************/
    @
    RemoteAction
    global static list < sObject > searchObject(string objectName, string query, String numberOfResults, String wildCardOption, String additionalFilter) {

        // check if the object is a valid object to search
        System.debug('Enetered');
        //System.debug('Faculty'+faculty);
        // create the where-clause
        String WhereClause = ' like \'';
        //add wild casd option to where clause
        if (wildCardOption == 'true') {
            Whereclause += '%';
        }

        //create final where clause
        Whereclause += String.escapeSingleQuotes(query) + '%\'';

        //build the dynamic soql query
        String soqlQuery;
        
        soqlQuery = 'select id,Full_Name__c,Full_Name_Email__c from ' + objectName + ' where';
        
        if(additionalFilter.equalsIgnoreCase('faculty')){
            soqlQuery += ' (Name' + Whereclause + 'OR Email'+ Whereclause +')';
            soqlQuery += ' AND (Faculty__c = true OR Staff__c = true)';
        }else{
            
            soqlQuery+=' (Name' + Whereclause + 'OR CWID__c '+Whereclause+')';
            
            if(additionalFilter.equalsIgnoreCase('student')){
                soqlQuery += ' AND Student__c = true';
            }
            if(additionalFilter.equalsIgnoreCase('consultant')){
                soqlQuery += ' AND LWC_Staff__c = true';
            }
        }
        soqlQuery += ' order by Name limit ' + numberOfResults;
        System.debug('**soqlQuery** '+soqlQuery);

        List < sObject > Results = new List < sObject > ();

        try {
            //Query for results
            Results = Database.query(soqlQuery);
        } catch (QueryException e) {
            return null;
        }

        //return the query results
        return Results;
    }



}