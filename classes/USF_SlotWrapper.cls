global class USF_SlotWrapper implements Comparable {
	public Counsellor_Availability__c sl;
	public DateTime startTime;
	public Decimal appointmentLength;
	public DateTime endTime;
	// Constructor
	public USF_SlotWrapper(Counsellor_Availability__c slot) {
		sl = slot;
		startTime = slot.Start_Time__c;
		appointmentLength = slot.Availability__r.Success_Center__r.AppointmentLength__c;
		endTime = slot.End_Time__c;
	}

     
    // Compare opportunities based on the opportunity amount.
    global Integer compareTo(Object compareTo) {

        // Cast argument to OpportunityWrapper

        USF_SlotWrapper compareToSl = (USF_SlotWrapper)compareTo;

         

        // The return value of 0 indicates that both elements are equal.

        Integer returnValue = 0;

        if (sl.Start_Time__c > compareToSl.sl.Start_Time__c) {

            // Set return value to a positive value.

            returnValue = 1;

       } else if (sl.Start_Time__c < compareToSl.sl.Start_Time__c) {

            // Set return value to a negative value.

            returnValue = -1;

        }

         

        return returnValue;      

    }

}