<aura:application access="GLOBAL" extends="ltng:outAppUnstyled">
    <aura:handler name="init" value="{!this}" action="{!c.init}"/>

    <aura:dependency resource="hed:STG_CMP_Header" />
    <aura:dependency resource="hed:STG_CMP_Tabs" />
</aura:application>