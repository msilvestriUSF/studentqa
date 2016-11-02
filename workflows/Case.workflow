<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts>
        <fullName>Email_Notification_to_Faculty_and_Student</fullName>
        <description>Email Notification to Faculty and Student</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <type>creator</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/ContactFollowUpSAMPLE</template>
    </alerts><alerts>
        <fullName>LWC_Tutor_Request_Confirmation_Lead</fullName>
        <description>LWC - Tutor Request Confirmation - Lead</description>
        <protected>false</protected>
        <recipients>
            <recipient>kdrutledge@usfca.edu.stu</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/LWC_Tutor_Request_Confirmation_Lead</template>
    </alerts><alerts>
        <fullName>LWC_Tutor_Request_Confirmation_Student</fullName>
        <description>LWC - Tutor Request Confirmation - Student</description>
        <protected>false</protected>
        <recipients>
            <field>ContactId</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>LWC/LWC_Tutor_Request_Confirmation_Student</template>
    </alerts><fieldUpdates>
        <fullName>Case_Subject_Update</fullName>
        <field>Subject</field>
        <formula>TEXT (Reason)</formula>
        <name>Case Subject Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Case_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>LWC_Tutor_Request</lookupValue>
        <lookupValueType>Queue</lookupValueType>
        <name>Update Case Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><fieldUpdates>
        <fullName>Update_Record_Type_for_Tutor_Request</fullName>
        <field>RecordTypeId</field>
        <lookupValue>Tutor_Request</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Update Record Type for Tutor Request</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates><rules>
        <fullName>Email Notification for EAP Report Submission</fullName>
        <actions>
            <name>Email_Notification_to_Faculty_and_Student</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.RecordTypeId</field>
            <operation>equals</operation>
            <value>EAP Report</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules><rules>
        <fullName>Update Subject</fullName>
        <actions>
            <name>Case_Subject_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Case.Reason</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules><rules>
        <fullName>Update Tutor Request Case Owner</fullName>
        <actions>
            <name>Update_Case_Owner</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>RecordType.Name = 'Tutor Request'</formula>
        <triggerType>onCreateOnly</triggerType>
    </rules></Workflow>