/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
public class MaintenanceRequestHelperTest {
    
    @testSetup
    static void setupTestData() {

        // Create test Vehicles
        List<Vehicle__c> vehicles = new List<Vehicle__c>();
        for (Integer i = 0; i < 5; i++) {
            vehicles.add(new Vehicle__c(Name = 'Test Vehicle ' + i));
        }
        insert vehicles;

        // Create Equipment that meets lookup filter criteria
        List<Product2> equipmentList = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            equipmentList.add(new Product2(
                Name = 'Equipment ' + i, 
                Maintenance_Cycle__c = 30,
                Replacement_Part__c = true
            ));
        }
        insert equipmentList;
        
        // Create Maintenance Requests (Cases)
        List<Case> maintenanceRequests = new List<Case>();
        for (Integer i = 0; i < 5; i++) {
            String st = 'Working';
            String t = 'Repair';
            if(i==2){
                st = 'New';
                t = 'Routine Maintenance';
            }
            maintenanceRequests.add(new Case(
                Type = t,
                Subject = 'Test Maintenance ' + i,
                Date_Reported__c = Date.today(),
                Vehicle__c = vehicles[i].Id,
                Status = st
            ));
        }
        insert maintenanceRequests;

        // Create Equipment Maintenance Items
        List<Equipment_Maintenance_Item__c> maintenanceItems = new List<Equipment_Maintenance_Item__c>();
        for (Integer i = 0; i < maintenanceRequests.size(); i++) {
            maintenanceItems.add(new Equipment_Maintenance_Item__c(
                Maintenance_Request__c = maintenanceRequests[i].Id,
                Equipment__c = equipmentList[i].Id,
                Quantity__c = 2
            ));
        }
        insert maintenanceItems;
    }

    @isTest
    static void testCreateFutureMaintenanceRequests() {

        Test.startTest();

        List<Case> updateCase = new List<Case>();
        For(Case c : [SELECT Id, Vehicle__c FROM Case WHERE Status != 'Closed']){

            c.Status = 'Closed';
            updateCase.add(c);
        
        }
        update updateCase;

        Test.stopTest();
        // Verify the new maintenance requests are created
        List<Case> newRequests = [SELECT Id, Type FROM Case WHERE Type = 'Routine Maintenance'];

        for (Case newCase : newRequests) {
            System.assertEquals('Routine Maintenance', newCase.Type, 'The new case type should be Routine Maintenance');
        }
    }

    @isTest
    static void testCreateFutureMaintenanceRequests_Bulk() {
        Test.startTest();

        // Create 300 maintenance requests
        List<Case> bulkCases = new List<Case>();
        for (Integer i = 0; i < 300; i++) {
            bulkCases.add(new Case(
                Type = 'Repair',
                Subject = 'Bulk Test ' + i,
                Date_Reported__c = Date.today(),
                Status = 'Open'
            ));
        }
        insert bulkCases;

        Map<Id, Case> closedRequestsMap = new Map<Id, Case>([SELECT Id, Vehicle__c  FROM Case WHERE Subject LIKE 'Bulk Test%']);

        // Call the helper method
        MaintenanceRequestHelper.createFutureMaintenanceRequests(closedRequestsMap);

        Test.stopTest();

        // Verify that 300 new routine maintenance requests were created
        Integer newCasesCount = [SELECT COUNT() FROM Case WHERE Type = 'Routine Maintenance'];
        System.assertEquals(301, newCasesCount, 'The system should handle 300 records in bulk');

    }
}
