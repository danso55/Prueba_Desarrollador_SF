global class DebuggingQuotes_bch implements Database.Batchable<SObject>, Database.Stateful {
    
    global debugging_of_quotes__mdt Metadata = [SELECT Id,Dias__c,Nombre_de_accion_de_log__c,DeveloperName FROM debugging_of_quotes__mdt WHERE DeveloperName = 'Depuracion_Quotes'];
    private Integer recordsProcessed = 0;
    private Integer recordsDeleted = 0;
    
    global  List<Audit_Log__c> Logs = New List<Audit_Log__c>();
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        DateTime retentionDate = System.now().addDays(-integer.valueof(Metadata.Dias__c));
        
        String strQuery = 
            'SELECT Id, Name, Status, CreatedDate ' +
            'FROM Quote ' +
            'WHERE Status = \'Rechazado\' ' +
            'AND CreatedDate <= :retentionDate';
        
        return Database.getQueryLocator(strQuery);
    }
    
    global void execute(Database.BatchableContext bc, List<Quote> records) {
        recordsProcessed += records.size();
        
        Database.DeleteResult[] results = Database.delete(records, false);
        
        for (Database.DeleteResult result : results) {
            
            if (result.isSuccess()) {
                recordsDeleted++;
            } else {
                
                for (Database.Error error : result.getErrors()) {   
                    AddlogError(String.valueof(error.getFields()),result.getId(), error.getStatusCode()+error.getMessage());
                }
            }
        }
        AddlogError('Procesadas: ' + recordsProcessed +'|| Eliminadas: ' + recordsDeleted, 'Eliminados',null );
    }
    
    global void finish(Database.BatchableContext bc) {
        if (!Logs.isEmpty()) {
            insert Logs;
        }
    }
    
    public void AddlogError(String Datos ,String Id,String Fallo){
        Logs.add(
            New Audit_Log__c(
                Acci_n_realizada__c = 'ERROR '+ Metadata.Nombre_de_accion_de_log__c,
                Datos_previos__c =  Datos,
                Datos_nuevos__c = Fallo, 
                Fecha_Modificacion__c = System.now(),
                Id_registro__c = Id
            ));
    }
}