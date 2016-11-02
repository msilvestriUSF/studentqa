/************************************************************************************
// Name             : USF_AppointmentDTO
// Description      : Wrapper class for Appointment 
// Created By       : Ankit Jain
// Created Date     : 09/09/2016
// ************************Version Updates********************************************
// Date             Developer           Description
// -----------------------------------------------------------------------------------
// 09/09/2016       Ankit Jain       Created
// ************************************************************************************/

public class USF_AppointmentDTO{
        public AppointmentContact__c appointment {get;set;}
        public String startdate {get;set;}
        public String starttime {get;set;}
        public String colorClass {get;set;}
        public String statusToDisplay {get;set;}
        public String statuSymbolClass {get;set;}
        public USF_AppointmentDTO(AppointmentContact__c appointment, String starttime){
            this.appointment = appointment;
            this.starttime = starttime;
            if(appointment.Status__c!=null){
                if(appointment.Status__c.contains(App_Config__c.getInstance('Confirm').Text_Value__c)){
                    colorClass = 'confirm';
                    statusToDisplay = appointment.Status__c.touppercase();
                    statuSymbolClass = 'glyphicon glyphicon-ok';
                }
                else if(appointment.Status__c.contains(App_Config__c.getInstance('Pending').Text_Value__c)){
                    colorClass = 'pending';
                    statusToDisplay = appointment.Status__c.touppercase()+' . . .';
                    statuSymbolClass = 'test';
                }
                else if(appointment.Status__c.contains(App_Config__c.getInstance('Cancel').Text_Value__c)){
                    colorClass = 'cancel';
                    statusToDisplay = appointment.Status__c.touppercase();
                    statuSymbolClass = 'glyphicon glyphicon-remove';
                }
                else if(appointment.Status__c.contains(App_Config__c.getInstance('Missed').Text_Value__c)){
                    colorClass = 'missed';
                    statusToDisplay = appointment.Status__c.touppercase()+' !';
                    statuSymbolClass = 'test';
                }
                else if(appointment.Status__c.contains(App_Config__c.getInstance('Check').Text_Value__c)){
                    colorClass = 'checkin';
                    statusToDisplay = appointment.Status__c.touppercase();
                    statuSymbolClass = 'glyphicon glyphicon-ok';
                }
                else{
                    colorClass = 'pending';
                    statusToDisplay = appointment.Status__c.touppercase();
                    statuSymbolClass = 'test';
                }  
            }     
        }
        
         public USF_AppointmentDTO(AppointmentContact__c appointment,String startdate,String starttime){
            this.appointment = appointment;
            this.startdate = startdate;
            this.starttime = starttime;
            if(appointment.Status__c!=null){
                if(appointment.Status__c.contains(App_Config__c.getInstance('Confirm').Text_Value__c)){
                    colorClass = 'confirm';
                    statusToDisplay = appointment.Status__c.touppercase();
                    statuSymbolClass = 'glyphicon glyphicon-ok';
                }
                else if(appointment.Status__c.contains(App_Config__c.getInstance('Pending').Text_Value__c)){
                    colorClass = 'pending';
                    statusToDisplay = appointment.Status__c.touppercase()+' . . .';
                    statuSymbolClass = 'test';
                }
                else if(appointment.Status__c.contains(App_Config__c.getInstance('Cancel').Text_Value__c)){
                    colorClass = 'cancel';
                    statusToDisplay = appointment.Status__c.touppercase();
                    statuSymbolClass = 'glyphicon glyphicon-remove';
                }
                else if(appointment.Status__c.contains(App_Config__c.getInstance('Missed').Text_Value__c)){
                    colorClass = 'missed';
                    statusToDisplay = appointment.Status__c.touppercase()+' !';
                    statuSymbolClass = 'test';
                }
                else if(appointment.Status__c.contains(App_Config__c.getInstance('Check').Text_Value__c)){
                    colorClass = 'checkin';
                    statusToDisplay = appointment.Status__c.touppercase();
                    statuSymbolClass = 'glyphicon glyphicon-ok';
                }
                else{
                    colorClass = 'pending';
                    statusToDisplay = appointment.Status__c.touppercase();
                    statuSymbolClass = 'test';
                }  
            }     
        }
    }