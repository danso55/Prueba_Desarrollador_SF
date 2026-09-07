@IsTest
private class debuggingQuotes_sch_Test {

    @IsTest
    static void testSchedulerExecute() {
        String cronExpression = '0 0 0 1 1 ? 2099';
        String jobName = 'Test Debugging Quotes Scheduler';
        System.assertNotEquals(
            null,
            Label.debuggingQuotes_batch,
            'El Custom Label debuggingQuotes_batch debe estar configurado'
        );

        System.assert(
            String.isNotBlank(Label.debuggingQuotes_batch),
            'El Custom Label debuggingQuotes_batch no puede estar vacío'
        );

        Integer batchSize = Integer.valueOf(
            Label.debuggingQuotes_batch
        );

        System.assert(
            batchSize > 0,
            'El tamaño del Batch debe ser mayor a cero'
        );

        Test.startTest();

        String jobId = System.schedule(
            jobName,
            cronExpression,
            new debuggingQuotes_sch()
        );

        Test.stopTest();


        System.assertNotEquals(
            null,
            jobId,
            'El Scheduler debe retornar un Id de Job'
        );

        CronTrigger scheduledJob = [
            SELECT Id,
                   CronJobDetail.Name,
                   CronExpression,
                   State,
                   NextFireTime,
                   TimesTriggered
            FROM CronTrigger
            WHERE Id = :jobId
            LIMIT 1
        ];

        System.assertEquals(
            jobId,
            scheduledJob.Id,
            'El Id del Scheduler no coincide'
        );

        System.assertEquals(
            jobName,
            scheduledJob.CronJobDetail.Name,
            'El nombre del Scheduler no coincide'
        );

        System.assertEquals(
            cronExpression,
            scheduledJob.CronExpression,
            'La expresión CRON no coincide'
        );
    }
}