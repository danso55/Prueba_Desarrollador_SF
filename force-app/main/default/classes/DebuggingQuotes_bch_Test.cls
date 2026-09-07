@IsTest
private class DebuggingQuotes_bch_Test {

    private static debugging_of_quotes__mdt getMetadata() {

        return [
            SELECT Id,
                   Dias__c,
                   Nombre_de_accion_de_log__c,
                   DeveloperName
            FROM debugging_of_quotes__mdt
            WHERE DeveloperName = 'Depuracion_Quotes'
            LIMIT 1
        ];
    }


    private static Opportunity createOpportunity() {

        Account acc = new Account(
            Name = 'Test Account Debugging Quotes'
        );

        insert acc;

        Opportunity opp = new Opportunity(
            Name = 'Test Opportunity Debugging Quotes',
            AccountId = acc.Id,
            StageName = 'Prospecting',
            CloseDate = Date.today().addDays(30)
        );

        insert opp;

        return opp;
    }

    private static Quote createQuote(
        Id opportunityId,
        Integer index
    ) {

        return new Quote(
            Name = 'Quote Test ' + index,
            OpportunityId = opportunityId,
            Status = 'Rechazado',
            VersionKey__c = 'TEST_VERSION_KEY_' + String.valueOf(index)
        );
    }

    @IsTest
    static void testBatchBulk200Quotes() {

        debugging_of_quotes__mdt metadata = getMetadata();

        System.assertNotEquals(
            null,
            metadata,
            'Debe existir el Custom Metadata Depuracion_Quotes'
        );

        System.assertNotEquals(
            null,
            metadata.Dias__c,
            'Dias__c debe estar configurado'
        );

        Integer retentionDays = Integer.valueOf(metadata.Dias__c);

        System.assert(
            retentionDays >= 0,
            'Los días de retención no pueden ser negativos'
        );

        Opportunity opp = createOpportunity();

        List<Quote> quotes = new List<Quote>();

        Set<String> versionKeys = new Set<String>();

        for (Integer i = 0; i < 200; i++) {

            Quote quote = createQuote(
                opp.Id,
                i
            );

            quotes.add(quote);

            versionKeys.add(quote.VersionKey__c);
        }

        System.assertEquals(
            200,
            versionKeys.size(),
            'Cada Quote debe tener un VersionKey__c diferente'
        );


        insert quotes;


        System.assertEquals(
            200,
            quotes.size(),
            'Deben crearse exactamente 200 Quotes'
        );

        List<Quote> insertedQuotes = [
            SELECT Id,
                   Name,
                   Status,
                   VersionKey__c,
                   CreatedDate
            FROM Quote
            WHERE Id IN :quotes
        ];

        System.assertEquals(
            200,
            insertedQuotes.size(),
            'Deben existir las 200 Quotes después del insert'
        );


        Set<String> insertedVersionKeys = new Set<String>();

        for (Quote quote : insertedQuotes) {
            insertedVersionKeys.add(quote.VersionKey__c);
        }

        System.assertEquals(
            200,
            insertedVersionKeys.size(),
            'Los VersionKey__c almacenados deben ser únicos'
        );


        DateTime oldDate = System.now().addDays(
            -(retentionDays + 1)
        );

        for (Quote quote : quotes) {

            Test.setCreatedDate(
                quote.Id,
                oldDate
            );
        }

        Test.startTest();

        Id batchJobId = Database.executeBatch(
            new DebuggingQuotes_bch(),
            200
        );

        Test.stopTest();

        System.assertNotEquals(
            null,
            batchJobId,
            'Debe generarse un Id para el Job del Batch'
        );

        Integer deletedQuotes = [
            SELECT COUNT()
            FROM Quote
            WHERE Id IN :quotes
            ALL ROWS
        ];

        System.assertEquals(
            200,
            deletedQuotes,
            'Las 200 Quotes deben haber sido eliminadas'
        );

        List<Quote> remainingQuotes = [
            SELECT Id
            FROM Quote
            WHERE Id IN :quotes
        ];

        System.assertEquals(
            0,
            remainingQuotes.size(),
            'No debe quedar ninguna Quote activa'
        );
      
    }

    @IsTest
    static void testBatchStartQuery() {

        debugging_of_quotes__mdt metadata = getMetadata();

        System.assertNotEquals(
            null,
            metadata,
            'Debe existir el Custom Metadata'
        );

        Integer retentionDays = Integer.valueOf(
            metadata.Dias__c
        );

        Opportunity opp = createOpportunity();

        Quote quote = createQuote(
            opp.Id,
            1
        );

        insert quote;

        Test.setCreatedDate(
            quote.Id,
            System.now().addDays(
                -(retentionDays + 1)
            )
        );


        Test.startTest();

        DebuggingQuotes_bch batch = new DebuggingQuotes_bch();

        Database.QueryLocator locator = batch.start(null);

        Test.stopTest();


        System.assertNotEquals(
            null,
            locator,
            'start() debe retornar un QueryLocator'
        );
    }

    @IsTest
    static void testAddLogError() {

        DebuggingQuotes_bch batch = new DebuggingQuotes_bch();

        System.assertEquals(
            0,
            batch.Logs.size(),
            'El Batch debe iniciar sin Logs'
        );


        String testRecordId = UserInfo.getUserId();

        batch.AddlogError(
            'Datos anteriores',
            testRecordId,
            'Error de prueba'
        );


        System.assertEquals(
            1,
            batch.Logs.size(),
            'Debe agregarse un Audit Log'
        );


        Audit_Log__c log = batch.Logs[0];

        debugging_of_quotes__mdt metadata = getMetadata();

        System.assertEquals(
            'ERROR ' + metadata.Nombre_de_accion_de_log__c,
            log.Acci_n_realizada__c,
            'La acción del log no coincide'
        );

        System.assertEquals(
            'Datos anteriores',
            log.Datos_previos__c,
            'Datos_previos__c no coincide'
        );

        System.assertEquals(
            'Error de prueba',
            log.Datos_nuevos__c,
            'Datos_nuevos__c no coincide'
        );

        System.assertEquals(
            testRecordId,
            log.Id_registro__c,
            'El Id del registro no coincide'
        );

        System.assertNotEquals(
            null,
            log.Fecha_Modificacion__c,
            'La fecha del log debe estar diligenciada'
        );
    }

    @IsTest
    static void testScheduler() {

        Test.startTest();

        String cronExpression = '0 0 0 1 1 ? 2099';

        String jobId = System.schedule(
            'Test Debugging Quotes Scheduler',
            cronExpression,
            new debuggingQuotes_sch()
        );

        Test.stopTest();


        System.assertNotEquals(
            null,
            jobId,
            'El Scheduler debe generar un Id'
        );


        CronTrigger scheduledJob = [
            SELECT Id,
                   CronExpression,
                   TimesTriggered,
                   State
            FROM CronTrigger
            WHERE Id = :jobId
            LIMIT 1
        ];


        System.assertEquals(
            cronExpression,
            scheduledJob.CronExpression,
            'La expresión CRON no coincide'
        );

        System.assertEquals(
            'WAITING',
            scheduledJob.State,
            'El Scheduler debe quedar en estado WAITING'
        );
    }
}