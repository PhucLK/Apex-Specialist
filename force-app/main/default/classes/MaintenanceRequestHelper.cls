/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public class MaintenanceRequestHelper {
    
    public static void createFutureMaintenanceRequests( Map<Id, Case> closedRequestsMap) {
        Set<Id> validCaseIds = new Set<Id>();
        List<Case> newMaintenanceCases = new List<Case>();
        Map<Id, Decimal> maintenanceCycles = new Map<Id, Decimal>();
        Map<Id, List<Equipment_Maintenance_Item__c>> equipmentItemsMap = new Map<Id, List<Equipment_Maintenance_Item__c>>();
        
        if(!closedRequestsMap.values().isEmpty()){
            List<AggregateResult> results = [
                SELECT Maintenance_Request__c, MIN(Equipment__r.Maintenance_Cycle__c) maintenanceCycle
                FROM Equipment_Maintenance_Item__c
                WHERE Maintenance_Request__c IN :closedRequestsMap.keyset()
                GROUP BY Maintenance_Request__c
            ];

            for(AggregateResult result : results){
                maintenanceCycles.put((Id) result.get('Maintenance_Request__c'), (Decimal) result.get('maintenanceCycle'));

            }

            for(Equipment_Maintenance_Item__c item :  [SELECT Id, Equipment__c, Quantity__c, Maintenance_Request__c
                                                        FROM Equipment_Maintenance_Item__c
                                                        WHERE Maintenance_Request__c IN :closedRequestsMap.keyset()]){
                if(!equipmentItemsMap.containsKey(item.Maintenance_Request__c)){
                    equipmentItemsMap.put(item.Maintenance_Request__c, new List<Equipment_Maintenance_Item__c>());
                }
                equipmentItemsMap.get(item.Maintenance_Request__c).add(item);
            }

            for(Case updatedCase : closedRequestsMap.values()){

                if(closedRequestsMap.keyset().contains(updatedCase.Id)){
                    Case newCase = new Case(
                        Type = 'Routine Maintenance',
                        Subject = 'Routine checkup in the future',
                        Date_Reported__c = Date.today(),
                        Vehicle__c = updatedCase.Vehicle__c,
                        ParentId = updatedCase.Id
                    );
    
                    if(maintenanceCycles != null && maintenanceCycles.containsKey(updatedCase.Id)){
                        newCase.Date_Due__c = Date.today().addDays((Integer) maintenanceCycles.get(updatedCase.Id));
                    }
    
                    newMaintenanceCases.add(newCase);
                }
            }

            if(!newMaintenanceCases.isEmpty()){
                insert newMaintenanceCases;

                List<Equipment_Maintenance_Item__c> clonedItems = new List<Equipment_Maintenance_Item__c>();
                
                for(Case newCase : newMaintenanceCases){
                
                    if(equipmentItemsMap != null && equipmentItemsMap.containsKey(newCase.ParentId)){
                        
                        for(Equipment_Maintenance_Item__c oldItem : equipmentItemsMap.get(newCase.ParentId)){
                            Equipment_Maintenance_Item__c newItem = oldItem.clone();
                            newItem.Maintenance_Request__c = newCase.Id;
                            clonedItems.add(newItem);
                        }
                    }
                }

                if(!clonedItems.isEmpty()){
                    insert clonedItems;
                }
            }
        }
    }
}
