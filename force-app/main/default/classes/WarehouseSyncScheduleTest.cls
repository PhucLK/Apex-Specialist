/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class WarehouseSyncScheduleTest {
    
    @isTest
    static void testExecute() {
        Test.startTest();
        
        // Execute the Schedulable class
        WarehouseSyncSchedule scheduler = new WarehouseSyncSchedule();
        scheduler.execute(null);
        
        // Verify an async job was enqueued
        Integer jobCount = [SELECT COUNT() FROM AsyncApexJob WHERE JobType = 'Queueable'];
        System.assert(jobCount > 0, 'Expected a queueable job to be enqueued');

        Test.stopTest();
    }
    
    @isTest
    static void testScheduleDailySync() {
        Test.startTest();
        
        // Call the scheduling method
        WarehouseSyncSchedule.scheduleDailySync();
        
        // Query the scheduled job
        CronTrigger ct = [SELECT Id, CronExpression, State, CronJobDetail.Name 
                          FROM CronTrigger 
                          WHERE CronJobDetail.Name = 'WarehouseSyncScheduleJob' 
                          LIMIT 1];

        // Assert the job is scheduled correctly
        System.assertEquals('0 0 1 * * ?', ct.CronExpression, 'Cron expression mismatch');
        System.assertEquals('WAITING', ct.State, 'Job should be scheduled and in WAITING state');
        
        Test.stopTest();
    }
}
