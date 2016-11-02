/************************************************************************************
// Name             : CASASlot_EventManager
// Description      : This class is used to delete events when the apoointment status
                      is changed to cancelled.
// Created By       : Manjunath Singh
// Created Date     : 10/20/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 10/20/2016       Manjunath Singh       Created
// ************************************************************************************/
public without sharing class CASASlot_EventManager{

@invocableVariable(label='slot Id') //developerName
public List<id> slotId;

@invocableMethod
public static void deleteEvent(List<id> slotId){
    if(slotId!=null){
        try{
            List<event> events=[SELECT Id from event where WhatId IN:slotId];    
             delete events;        
         }
         catch(Exception e){    
         }
      }
  }

}