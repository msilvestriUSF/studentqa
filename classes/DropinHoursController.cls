public with sharing class DropinHoursController {
    public Boolean renderReport{get;set;}
    public String selectedCenter{get;set;}
    public String selectedCourse{get;set;}
    public List<SelectOption> centers{get{
    	return new List<SelectOption>();
    }set;}
    public List<SelectOption> courses{get;set;}
    
    public DropinHoursController() {
    	renderReport = false;
    }
    
    public void viewReport() {
    	renderReport = true;
    }
}