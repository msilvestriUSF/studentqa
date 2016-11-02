<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts>
        <fullName>CASA_Referral_Notification_Email</fullName>
        <description>CASA Referral Notification Email</description>
        <protected>false</protected>
        <recipients>
            <field>Referred_To__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Student__c</field>
            <type>contactLookup</type>
        </recipients>
        <recipients>
            <field>Other_Resource_Email__c</field>
            <type>email</type>
        </recipients>
        <recipients>
            <field>Resource_Email_Workflow__c</field>
            <type>email</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>CASA/CASA_Referral_Notification</template>
    </alerts><fieldUpdates>
        <fullName>CASA_Update_Referral_Resource_Email</fullName>
        <field>Resource_Email_Workflow__c</field>
        <formula>Campus_Resource__r.Email__c</formula>
        <name>CASA Update Referral Resource Email</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><fieldUpdates>
        <fullName>Referral_Name</fullName>
        <field>Name</field>
        <formula>Formula_Name__c</formula>
        <name>Referral Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
        <reevaluateOnChange>true</reevaluateOnChange>
    </fieldUpdates><rules>
        <fullName>Referral Name Update</fullName>
        <actions>
            <name>Referral_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Referral__c.Referral_Date__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules></Workflow>