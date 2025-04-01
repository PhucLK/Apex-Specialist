/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts {

    private static final String WAREHOUSE_URL = 'https://th-superbadge-apex.herokuapp.com/equipment';

    public void execute(QueueableContext ctx){

        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(WAREHOUSE_URL);
        req.setMethod('GET');
            
            
        HttpResponse res = http.send(req);

        if(res != null && res.getStatusCode() == 200){
            List<Product2> equipmentToUpsert = parseWarehouseData(res.getBody());
                upsert equipmentToUpsert Warehouse_SKU__c;
        }
    }

    private static List<Product2> parseWarehouseData(String responseBody){
        List<Product2> equipments = new List<Product2>();
        List<Object> jsonData = (List<Object>) JSON.deserializeUntyped(responseBody);

        for(Object obj : jsonData){
            Map<String,Object> record = (Map<String,Object>) obj;

            Product2 equipment = new Product2();
            equipment.Replacement_Part__c = true; //(Boolean) record.get('replacement');
            equipment.Cost__c = (Integer) record.get('cost');
            equipment.Current_Inventory__c = (Integer) record.get('quantity');
            equipment.Lifespan_Months__c = (Integer) record.get('lifespan');
            equipment.Maintenance_Cycle__c = (Integer) record.get('maintenanceperiod');
            equipment.Warehouse_SKU__c = (String) record.get('sku');
            equipment.Name = (String) record.get('name');
            equipments.add(equipment);
        }

        return equipments;
    }
}