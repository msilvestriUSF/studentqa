<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts>
        <fullName>CASA_Appointment_Cancelation</fullName>
        <description>CASA Appointment Cancelation</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>casa@usfca.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CASA/CASA_Appointment_Cancellation</template>
    </alerts><alerts>
        <fullName>CASA_Appointment_Confirmation</fullName>
        <description>CASA Appointment Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>casa@usfca.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CASA/USF_CASA_Appointment_Confirmation</template>
    </alerts><alerts>
        <fullName>CASA_Appointment_Denied</fullName>
        <description>CASA Appointment Denied</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>casa@usfca.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CASA/CASA_Appointment_Denied</template>
    </alerts><alerts>
        <fullName>CASA_Appointment_Reminder</fullName>
        <description>CASA Appointment Reminder</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>casa@usfca.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CASA/CASA_Appointment_Reminder</template>
    </alerts><alerts>
        <fullName>CASA_Student_Appointment_No_Show_Email</fullName>
        <description>CASA Student Appointment No-Show Email</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderAddress>casa@usfca.edu</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>CASA/CASA_Appointment_No_Show</template>
    </alerts><alerts>
        <fullName>Email_Notification_for_Location_change</fullName>
        <description>Email Notification for Location change</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/Mass_Student_Email_Alert</template>
    </alerts><alerts>
        <fullName>LC_30_Minute_Notification_Consultant</fullName>
        <description>LC 30 Minute Notification - Consultant</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/LC_30_Minute_Notification_Consultant</template>
    </alerts><alerts>
        <fullName>LWC_30_Minute_Notification_Writing_and_Learning</fullName>
        <description>LWC 30 Minute Notification - Student</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/LWC_30_Minute_Notification_Writing_and_Learning</template>
    </alerts><alerts>
        <fullName>LWC_3rd_Strike_Notification_LC_and_WC</fullName>
        <description>LWC 3rd Strike Notification - LC and WC</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>LWC/LWC_3rd_Strike_Notification_LC_and_WC</template>
    </alerts><alerts>
        <fullName>LWC_Appointment_Cancelation_Student</fullName>
        <description>LWC Appointment Cancelation - Student</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Consultant_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/LWC_Appointment_Cancelled</template>
    </alerts><alerts>
        <fullName>LWC_Appointment_Modification_Student</fullName>
        <description>LWC Appointment Modification - Student</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/LWC_Appointment_Changed_Student</template>
    </alerts><alerts>
        <fullName>LWC_Consultant_Appointment_Request_Summary</fullName>
        <description>LWC Consultant Appointment Request Summary</description>
        <protected>false</protected>
        <recipients>
            <type>owner</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/LWC_Consultant_Appointment_Request_Summary</template>
    </alerts><alerts>
        <fullName>LWC_LC_Tutoring_Appointment_Instruction_Confirmation</fullName>
        <description>LWC LC Tutoring Appointment Instruction/Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Consultant_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>LWC/LC_Tutoring_Appointment_Instruction_Confirmation</template>
    </alerts><alerts>
        <fullName>LWC_SC_Speaking_Appointment_Instruction_Confirmation</fullName>
        <description>LWC SC Speaking Appointment Instruction/Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Consultant_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>LWC/SC_Speaking_Appointment_Instruction_Confirmation</template>
    </alerts><alerts>
        <fullName>LWC_Strike_Notification_LC</fullName>
        <description>LWC Strike Notification - LC</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>LWC/LWC_Strike_Notification_LC</template>
    </alerts><alerts>
        <fullName>LWC_Strike_Notification_WC</fullName>
        <description>LWC Strike Notification - WC</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>LWC/LWC_Strike_Notification_WC</template>
    </alerts><alerts>
        <fullName>LWC_WC_Writing_Appointment_Instruction_Confirmation</fullName>
        <description>LWC WC Writing Appointment Instruction/Confirmation</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Consultant_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>DefaultWorkflowUser</senderType>
        <template>LWC/WC_Writing_Appointment_Instruction_Confirmation</template>
    </alerts><fieldUpdates>
        <fullName>Populate_Center</fullName>
        <field>Center__c</field>
        <formula>AppointmentSlot__r.Availability__r.Success_Center__r.Name</formula>
        <name>Populate Center</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Status_to_Missed_By_Student</fullName>
        <field>Status__c</field>
        <literalValue>Missed by Student</literalValue>
        <name>Set Status to Missed By Student</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Status_to_NO_SHOW</fullName>
        <field>Status__c</field>
        <literalValue>No Show</literalValue>
        <name>Set Status to NO SHOW</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>USF_Update_Cancelled_timestamp</fullName>
        <description>Updates Appointment's Cancelled timestamp with current date/time</description>
        <field>Canceled_Date_Time__c</field>
        <formula>NOW()</formula>
        <name>USF Update Cancelled timestamp</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Active_Term_on_Appointment</fullName>
        <description>Update Active Term on Appointment</description>
        <field>Active_Term__c</field>
        <literalValue>1</literalValue>
        <name>Update Active Term on Appointment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Record_Type_CASA_Appt</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CASA_Appointment</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type CASA Appt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Record_Type_LWC_Appt</fullName>
        <field>RecordTypeId</field>
        <lookupValue>LWC_Appointment</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type LWC Appt</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Status_CASA_Appointment</fullName>
        <field>Status__c</field>
        <literalValue>Pending</literalValue>
        <name>Update Status CASA Appointment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Status_LWC_Appointment</fullName>
        <field>Status__c</field>
        <literalValue>Confirmed</literalValue>
        <name>Update Status LWC Appointment</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Active Term Appointment</fullName>
        <actions>
            <name>Update_Active_Term_on_Appointment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <description>Active Term Appointment</description>
        <formula>((Term__c != '' || Term__c != null) &amp;&amp; (Term__c == AppointmentSlot__r.Availability__r.Success_Center__r.Current_Term_Parent_Center__c || Term__c == AppointmentSlot__r.Availability__r.Success_Center__r.Current_Term_Child_Center__c ))</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>CASA Appointment Cancellation Email</fullName>
        <actions>
            <name>CASA_Appointment_Cancelation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>contains</operation>
            <value>Cancelled,Cancelled by Student,Cancelled by Consultant</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CASA Appointment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>CASA Appointment Confirmation</fullName>
        <actions>
            <name>CASA_Appointment_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>True,CASA Appointment</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <description>Send an email to the student when an appointment is confirmed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>CASA Appointment Denied Email</fullName>
        <actions>
            <name>CASA_Appointment_Denied</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>equals</operation>
            <value>Denied</value>
        </criteriaItems>
        <description>Send an email notification to the student when a pending CASA appointment is denied</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>CASA Appointment Reminder</fullName>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CASA Appointment</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>LC Tutoring Appointment Instruction%2FConfirmation</fullName>
        <actions>
            <name>LWC_LC_Tutoring_Appointment_Instruction_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LWC Appointment</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.Center__c</field>
            <operation>contains</operation>
            <value>Learning Center</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <description>Send an email to the student when an appointment with a tutoring appointment with the LC is confirmed.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>LWC Appointment Modification - Student</fullName>
        <actions>
            <name>LWC_Appointment_Cancelation_Student</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>LWC_Appointment_Modification_Student</name>
            <type>Alert</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>equals</operation>
            <value>Cancelled,Cancelled by Student,Cancelled by Consultant</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>LWC SC Spaking Appointment Instruction%2FConfirmation</fullName>
        <actions>
            <name>LWC_SC_Speaking_Appointment_Instruction_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AppointmentContact__c.Center__c</field>
            <operation>contains</operation>
            <value>Speaking Center</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LWC Appointment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>LWC WC Writing Appointment Instruction%2FConfirmation</fullName>
        <actions>
            <name>LWC_WC_Writing_Appointment_Instruction_Confirmation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>AppointmentContact__c.Center__c</field>
            <operation>contains</operation>
            <value>Writing Center</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LWC Appointment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Missed Appointment By Student</fullName>
        <active>false</active>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LWC Appointment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Status_to_Missed_By_Student</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AppointmentContact__c.Time_Trigger_15__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules><rules>
        <fullName>No Show By Student</fullName>
        <active>true</active>
        <criteriaItems>
            <field>AppointmentContact__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CASA Appointment</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>CASA_Student_Appointment_No_Show_Email</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Set_Status_to_NO_SHOW</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>AppointmentContact__c.Time_Trigger_15__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules><rules>
        <fullName>Populate Center</fullName>
        <actions>
            <name>Populate_Center</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AppointmentContact__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Creating this so we can use this field in the roll up summary for no of strikes at contact level</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>USF Capture Cancelled time stamp on Appointment</fullName>
        <actions>
            <name>USF_Update_Cancelled_timestamp</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update time stamp when appointment has been cancelled</description>
        <formula>AND( OR(ISNEW(),ISCHANGED(Status__c)), CONTAINS(TEXT(Status__c),'Cancelled') )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Update Record Type CASA Appt</fullName>
        <actions>
            <name>Update_Record_Type_CASA_Appt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AppointmentSlot__r.RecordType.Name == 'CASA Slot'</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Update Record Type LWC Appt</fullName>
        <actions>
            <name>Update_Record_Type_LWC_Appt</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AppointmentSlot__r.RecordType.Name == 'LWC Slot'</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules><rules>
        <fullName>Update Status CASA Appointment</fullName>
        <actions>
            <name>Update_Status_CASA_Appointment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CASA Appointment</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Update Status LWC Appointment</fullName>
        <actions>
            <name>Update_Status_LWC_Appointment</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <criteriaItems>
            <field>AppointmentContact__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LWC Appointment</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules></Workflow>