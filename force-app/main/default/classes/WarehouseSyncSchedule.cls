/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class WarehouseSyncSchedule implements Schedulable {
    
    public void execute(SchedulableContext sc) {
        System.enqueueJob(new WarehouseCalloutService());
    }

    public static void scheduleDailySync() {
        String cronExp = '0 0 1 * * ?';  // Runs at 1:00 AM daily
        System.schedule('WarehouseSyncScheduleJob', cronExp, new WarehouseSyncSchedule());
    }
}
