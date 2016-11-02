<?xml version="1.0" encoding="utf-8"?><Workflow xmlns="http://soap.sforce.com/2006/04/metadata"><alerts>
        <fullName>LWC_2nd_Strike_PA_Notification_LC_WC</fullName>
        <ccEmails>lwc@usfca.edu</ccEmails>
        <description>LWC 2nd Strike PA Notification - LC and WC</description>
        <protected>false</protected>
        <senderType>DefaultWorkflowUser</senderType>
        <template>LWC/LWC_2nd_Strike_PA_Notification_Email_Draft</template>
    </alerts><rules>
        <fullName>Send Email To center PA</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Contact.Birthdate</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules></Workflow>