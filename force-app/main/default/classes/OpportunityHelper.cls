/**
* ------------------------------------------------------------------------------------------------
* @Name     OpportunityHelper
* @Author   Daniel Jaimes
* @Date     06 Septiembre 2026
* -----------------------------------------------------------------------------------------------
* @Description Class "Class helper Responsible for rejecting quotes that were not accepted"
* -----------------------------------------------------------------------------------------------
* @Changes
* 
* -----------------------------------------------------------------------------------------------
*/
public class OpportunityHelper {
    
    public static void rechazarCotizaciones(Set<Id> opportunityIds) {
        
        List<Quote> quotesToUpdate = new List<Quote>();
        List<Audit_Log__c> auditLogs = new List<Audit_Log__c>();
        Set<Id> syncedQuoteIds = new Set<Id>();
        
        for (Opportunity opp : [SELECT Id, SyncedQuoteId FROM Opportunity
                                WHERE Id IN :opportunityIds AND SyncedQuoteId != null]) {
                                    syncedQuoteIds.add(opp.SyncedQuoteId);
                                }
        
        for (Quote quote : [SELECT Id,OpportunityId,Status FROM Quote
                            WHERE OpportunityId IN :opportunityIds AND Id NOT IN :syncedQuoteIds
                           ]) {
                               
                               if (quote.Status != 'Rechazado') {
                                   
                                   String estadoAnterior = quote.Status;
                                   quote.Status = 'Rechazado';
                                   quotesToUpdate.add(quote);
                                   
                                   
                                   Audit_Log__c audit = new Audit_Log__c();
                                   audit.Acci_n_realizada__c = label.Audit_Log_update_status_quote;
                                   audit.Datos_previos__c =    'Estado: ' + estadoAnterior;
                                   audit.Datos_nuevos__c =     'Estado: ' + quote.Status;
                                   audit.Fecha_Modificacion__c = System.now();
                                   audit.Id_registro__c = quote.Id;
                                   auditLogs.add(audit);
                               }
                           }
        if (!quotesToUpdate.isEmpty()) {
            update quotesToUpdate;
            if (!auditLogs.isEmpty()) {
                insert auditLogs;
            }
        }
    }
}