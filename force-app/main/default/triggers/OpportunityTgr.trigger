/**
* ------------------------------------------------------------------------------------------------
* @Name     OpportunityTgr
* @Author   Daniel Jaimes
* @Date     06 Septiembre 2026
* -----------------------------------------------------------------------------------------------
* @Description Trigger "Trigger the Opportunity"
* -----------------------------------------------------------------------------------------------
* @Changes
* 
* -----------------------------------------------------------------------------------------------
*/
trigger OpportunityTgr on Opportunity (before insert, before update, after insert, after update) {
    new OpportunityCls().run();
}