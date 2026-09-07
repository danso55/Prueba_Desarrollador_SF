/**
* ------------------------------------------------------------------------------------------------
* @Name     OpportunityCls
* @Author   Daniel Jaimes
* @Date     06 Septiembre 2026
* -----------------------------------------------------------------------------------------------
* @Description Class "Class controller the trigger Opp"
* -----------------------------------------------------------------------------------------------
* @Changes
* 
* -----------------------------------------------------------------------------------------------
*/
public class OpportunityCls extends TriggerHandler{
    protected override void beforeUpdate(){}
    protected override void beforeInsert(){}
    protected override void afterInsert(){}
    protected override void afterUpdate(){
        Set<Id> opportunityIds = new Set<Id>();
        for (Opportunity opp : (List<Opportunity>) Trigger.new) {
            Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.Id);
            if (opp.SyncedQuoteId != null && opp.SyncedQuoteId != oldOpp.SyncedQuoteId) {
                opportunityIds.add(opp.Id);
            }
        }
        
        if (!opportunityIds.isEmpty()) {
            OpportunityHelper.rechazarCotizaciones(opportunityIds);
        }
    }
}