@IsTest
private class OpportunityHelperTest {
    
    @TestSetup
    static void setupData() {
        
        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity',
            StageName = 'Prospecting',
            CloseDate = Date.today()
        );
        
        insert opp;
        
        
        
        Quote quote1 = new Quote(
            Name = 'Quote Test 1',
            OpportunityId = opp.Id,
            VersionKey__c = opp.Id + '1',
            Status = 'Borrador'
        );
        insert quote1;
        quote1 = new Quote(
            Name = 'Quote Test 2',
            OpportunityId = opp.Id,
            VersionKey__c = opp.Id + '2',
            Status = 'Borrador'
        );
        opp.Numero_de_versiones_de_presupuesto__c = 1;
        Update opp;
        insert quote1;
        quote1 = new Quote(
            Name = 'Quote Test 3',
            OpportunityId = opp.Id,
            VersionKey__c = opp.Id + '2',
            Status = 'Borrador'
        );
        opp.Numero_de_versiones_de_presupuesto__c = 2;
        Update opp;
        insert quote1;
    }
    
    
    @IsTest
    static void testRechazarCotizaciones() {
        Opportunity opp = [
            SELECT Id, SyncedQuoteId
            FROM Opportunity
            LIMIT 1
        ];
        List<Quote> quotes = [
            SELECT Id, OpportunityId, Status
            FROM Quote
            WHERE OpportunityId = :opp.Id
            ORDER BY CreatedDate ASC
        ];
        Quote quoteGanadora = quotes[0];
        
        Test.startTest();
        
        opp.SyncedQuoteId = quoteGanadora.Id;
        update opp;
        
        Test.stopTest();
        
        quotes = [
            SELECT Id, OpportunityId, Status
            FROM Quote
            WHERE OpportunityId = :opp.Id
            ORDER BY CreatedDate ASC
        ];
        
        List<Audit_Log__c> auditLogs = [
            SELECT Id,
            Acci_n_realizada__c,
            Datos_previos__c,
            Datos_nuevos__c,
            Fecha_Modificacion__c,
            Id_registro__c
            FROM Audit_Log__c
            WHERE Id_registro__c IN :new Set<Id>{
                quotes[1].Id,
                    quotes[2].Id
                    }
        ];
    }
    
    
    @IsTest
    static void testNoRechazarCotizacionesSinSincronizar() {
        
        Opportunity opp = [
            SELECT Id, SyncedQuoteId
            FROM Opportunity
            LIMIT 1
        ];
        
        Test.startTest();
        opp.Name = 'Opportunity Updated';
        update opp;
        
        Test.stopTest();
        
        List<Quote> quotes = [
            SELECT Id, Status
            FROM Quote
            WHERE OpportunityId = :opp.Id
        ];
        
        List<Audit_Log__c> auditLogs = [
            SELECT Id
            FROM Audit_Log__c
            WHERE Id_registro__c IN :new Set<Id>{
                quotes[0].Id,
                    quotes[1].Id,
                    quotes[2].Id
                    }
        ];
        
    }
}