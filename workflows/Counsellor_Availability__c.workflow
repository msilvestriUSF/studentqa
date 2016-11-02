<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts>
        <fullName>LWC_Peer_Center_Missed_Appointment_Notes</fullName>
        <description>LWC Peer Center - Missed Appointment Notes</description>
        <protected>false</protected>
        <recipients>
            <field>Interviewer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/LWC_Peer_Center_Missed_Appointment_Notes</template>
    </alerts><alerts>
        <fullName>LWC_Peer_Center_Update_Appointment_Notes_Notice</fullName>
        <description>LWC Peer Center - Update Appointment Notes Notice</description>
        <protected>false</protected>
        <recipients>
            <field>Interviewer__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/LWC_Peer_Center_Update_Appointment_Notes_Notice</template>
    </alerts><alerts>
        <fullName>LWC_consultant_location_change_email_alert</fullName>
        <description>LWC consultant location change email alert</description>
        <protected>false</protected>
        <recipients>
            <field>Coach_Email__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/Email_LWC_Location_change</template>
    </alerts><fieldUpdates>
        <fullName>Assign_CASA_RecordType</fullName>
        <field>RecordTypeId</field>
        <lookupValue>CASA_Slot</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Assign CASA RecordType</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Assign_LWC_Record_Type</fullName>
        <field>RecordTypeId</field>
        <lookupValue>LWC_Slot</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Assign LWC Record Type</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Populate_Max_Students_from_Availability</fullName>
        <description>Populate Max Students from Availability</description>
        <field>Capacity__c</field>
        <formula>Availability__r.Max_Number_of_Students__c</formula>
        <name>Populate Max Students from Availability</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Set_Status_to_Missed_By_Consultant</fullName>
        <field>Status__c</field>
        <literalValue>Missed by Consultant</literalValue>
        <name>Set Status to Missed By Consultant</name>
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
        <fullName>USF_Update_Coach_email_on_Slot</fullName>
        <description>Updates Coach email on Slot</description>
        <field>Coach_Email__c</field>
        <formula>Availability__r.Coach__r.Email</formula>
        <name>USF Update Coach email on Slot</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Status_to_Booked</fullName>
        <field>Status__c</field>
        <literalValue>Booked</literalValue>
        <name>Update Status to Booked</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Missed Appointment By Consultant</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Counsellor_Availability__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Counsellor_Availability__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>LWC Slot</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Status_to_Missed_By_Consultant</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Counsellor_Availability__c.Time_Trigger_15__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules><rules>
        <fullName>No Show By Coach</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Counsellor_Availability__c.Status__c</field>
            <operation>equals</operation>
            <value>Confirmed</value>
        </criteriaItems>
        <criteriaItems>
            <field>Counsellor_Availability__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>CASA Slot</value>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Set_Status_to_NO_SHOW</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Counsellor_Availability__c.Time_Trigger_15__c</offsetFromField>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules><rules>
        <fullName>Populate Max Students from Availability</fullName>
        <actions>
            <name>Populate_Max_Students_from_Availability</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Counsellor_Availability__c.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Populate Max Students from Availability</description>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>USF Capture Coach email on Slot</fullName>
        <actions>
            <name>USF_Update_Coach_email_on_Slot</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Captures Coach email on Slot</description>
        <formula>OR(ISNEW(),ISCHANGED( Availability__c ))</formula>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Update Status to Booked</fullName>
        <actions>
            <name>Update_Status_to_Booked</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Update Status to Booked on Capacity Reached</description>
        <formula>Noofstudentsregistered__c == Capacity__c</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules></Workflow>