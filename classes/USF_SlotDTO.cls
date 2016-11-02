/************************************************************************************
// Name             : USF_SlotDTO
// Description      : Wrapper class for Slot 
// Created By       : Mohan Kalagatla
// Created Date     : 09/09/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 09/09/2016       Mohan Kalagatla       Created
// ************************************************************************************/

public class USF_SlotDTO{
        public Counsellor_Availability__c slot {get;set;}
        public String startdate {get;set;}
        public String starttime {get;set;}
        public List<AppointmentContact__c> appointmentList{get;set;}
        
        public USF_SlotDTO(Counsellor_Availability__c slot, String starttime){
            this.slot = slot;
            this.starttime = starttime;
        }
        public USF_SlotDTO(Counsellor_Availability__c slot,String startdate,String starttime){
            this.slot = slot;
            this.startdate = startdate;
            this.starttime = starttime;
        }
    }