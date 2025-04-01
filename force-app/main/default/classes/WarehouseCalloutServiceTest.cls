/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 04-01-2025
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
@isTest
private class WarehouseCalloutServiceTest {
    @isTest
    static void testWarehouseCallout() {
        
        // Test data using the same values as JSON
        List<Product2> testProducts = new List<Product2>{
            new Product2(
                Warehouse_SKU__c = '100003',
                Name = 'Generator 1000 kW',
                Cost__c = 5000,
                Current_Inventory__c = 5,
                Lifespan_Months__c = 120,
                Maintenance_Cycle__c = 365,
                Replacement_Part__c = false
            ),
            new Product2(
                Warehouse_SKU__c = '100004',
                Name = 'Cooling Fan',
                Cost__c = 300,
                Current_Inventory__c = 183,
                Lifespan_Months__c = 0,
                Maintenance_Cycle__c = 0,
                Replacement_Part__c = true
            )
        };

        // Insert test data
        insert testProducts;

        // Setup mock callout
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());

        // Start test execution
        Test.startTest();
        System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();

        // Check the records created in Product2
        Integer productCount = [SELECT COUNT() FROM Product2];
        System.assertEquals(2, productCount, 'The product amount should be 2.');
    }
}
