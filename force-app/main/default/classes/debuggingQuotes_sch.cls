global class debuggingQuotes_sch implements Schedulable{
    
    global void execute(SchedulableContext sc) 
    {       
        
        Integer lote = Integer.valueOf(Label.debuggingQuotes_batch);
        Database.executeBatch(new debuggingQuotes_bch(), lote);
    }
}