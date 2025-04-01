/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/


trigger MaintenanceRequest on Case (after update) {
    Map<Id, Case> closedRequestsMap = new Map<Id, Case>();

    for (Case req : Trigger.new) {
        Case oldReq = Trigger.oldMap.get(req.Id);
        if (req.Status == 'Closed' && oldReq.Status != 'Closed' &&
            (req.Type == 'Repair' || req.Type == 'Routine Maintenance')) {
            closedRequestsMap.put(req.Id, req);
        }
    }

    if (!closedRequestsMap.values().isEmpty()) {
        MaintenanceRequestHelper.createFutureMaintenanceRequests(closedRequestsMap);
    }
}
