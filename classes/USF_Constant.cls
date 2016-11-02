public class USF_Constant {

    public static String VALID_DATE_TIME='valid_date_time';
    public static String INVALID_DATE_TIME='invalid_date_time';
    public static String USF_SETAVAILABILITY_AMPM = ' AM, PM';
    public static String USF_SETAVAILABILITY_MINUTES = ':00,:30';
    public static String USF_COURSECONFIGURATOR_NONE = '--None--';
    public static String USF_EMPTY = '';
    public static String USF_LWCSTAFFCONAVAILBLTYCONTROLLER_DATEFORMAT = 'EEE, d MMM yyyy HH:mm:ss uu';
    public static String USF_LWCSTAFFCONAVAILBLTYCONTROLLER_COACH = 'Coach';
    
    //Boolean variable to stop recursion in USF_SlotTrigger
    public static boolean slotTriggerRecursion = false;
    
    //Boolean variable to stop recursion in USF_AppointmentTrigger
    public static boolean appointmentTriggerRecursion = false;
}