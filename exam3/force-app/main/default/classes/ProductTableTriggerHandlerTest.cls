@IsTest
public with sharing class ProductTableTriggerHandlerTest {
    @IsTest
    public static void testAssign () {

        Integer periodTerm = 15;
        Org_Configuration__c orgConfiguration = new Org_Configuration__c (
            Period_Term__c = periodTerm
        );
        insert orgConfiguration;

        List<Product_Table__c> testProductTablesList = new List<Product_Table__c>();
        Product_Table__c testProductTable1 = new Product_Table__c(
            Name = 'Test1'
        );
        testProductTablesList.add(testProductTable1);

        Product_Table__c testProductTable2 = new Product_Table__c(
            Name = 'Test2',
            Added_Date__c = Date.today() + 20
        );
        testProductTablesList.add(testProductTable2);

        List<Warehouse__c> testWarehousesList = new List<Warehouse__c>();

        Warehouse__c testWarehouse1 = new Warehouse__c(
            Name = 'TestWarehouse1',
            Period_Start__c = Date.today() - 40,
            Period_End__c = Date.today() - 25
        );
        testWarehousesList.add(testWarehouse1);

        Warehouse__c testWarehouse2 = new Warehouse__c(
            Name = 'Warehouse2',
            Period_Start__c = Date.today(),
            Period_End__c = Date.today() + periodTerm
        );
        testWarehousesList.add(testWarehouse2);

        Warehouse__c testWarehouse3 = new Warehouse__c(
            Name = 'Warehouse3',
            Period_Start__c = Date.today() + 20,
            Period_End__c = Date.today() + 35
        );
        testWarehousesList.add(testWarehouse3);

        insert testWarehousesList;

        Test.startTest();

        insert testProductTablesList;

        Test.stopTest();

        List<Product_Table__c> actualProductTablesList = [
            SELECT Id, Warehouse__c
            FROM Product_Table__c
            WHERE Warehouse__c != : testWarehouse1.Id
        ];

        List<Warehouse__c> actualWarehouseList = [
            SELECT Id, Name
            FROM Warehouse__c
        ];

        System.assertEquals(testWarehousesList.size(), actualWarehouseList.size());
        System.assertEquals(testProductTablesList.size(), actualProductTablesList.size());
    }
    @IsTest
    public static void testCreateAndAssign () {

        Integer periodTerm = 15;
        Org_Configuration__c orgConfiguration = new Org_Configuration__c (
            Period_Term__c = periodTerm
        );
        insert orgConfiguration;

        List<Product_Table__c> testProductTablesList = new List<Product_Table__c>();
        
        Product_Table__c testProductTable1 = new Product_Table__c(
            Name = 'Test1',
            Added_Date__c = Date.today() + 20
        );
        testProductTablesList.add(testProductTable1);

        Product_Table__c testProductTable2 = new Product_Table__c(
            Name = 'Test2',
            Added_Date__c = Date.today() + 20
        );
        testProductTablesList.add(testProductTable2);

        List<Warehouse__c> testWarehousesList = new List<Warehouse__c>();

        Warehouse__c testWarehouse1 = new Warehouse__c(
            Name = 'Warehouse1',
            Period_Start__c = Date.today() - 40,
            Period_End__c = Date.today() - 25
        );
        testWarehousesList.add(testWarehouse1);

        Warehouse__c testWarehouse2 = new Warehouse__c(
            Name = 'Warehouse2',
            Period_Start__c = Date.today(),
            Period_End__c = Date.today() + periodTerm
        );

        String wareHouseName = label.newWarehouse + ' ' + String.valueOf(testProductTable2.Added_Date__c) + ' ' + String.valueOf(testProductTable2.Added_Date__c + periodTerm);

        testWarehousesList.add(testWarehouse2);

        Test.startTest();

        insert testProductTablesList;

        Test.stopTest();

        List<Warehouse__c> actualProductTablesList = [
            SELECT Name
            FROM Warehouse__c
            WHERE Name = : wareHouseName
        ];

        System.assertEquals(1, actualProductTablesList.size());

    }
}