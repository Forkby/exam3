@isTest
private with sharing class BuyProductControllerTest {

    @testSetup static void prepareData() {
        Integer periodTerm = 20;
        Org_Configuration__c orgConfiguration = new Org_Configuration__c (
            Period_Term__c = periodTerm
        );
        insert orgConfiguration;
        Product_Table__c product = new Product_Table__c (
            Name = 'Test',
            Units_Available__c = 50,
            Unit_Price__c = 300,
            Added_Date__c = date.today()
        );
        insert product;

        Contact contact = new Contact(
            FirstName = 'TestFirst',
            LastName = 'TestLast',
            Email = 'test@gmail.com'
        );
        insert contact;
    }

    @IsTest
    private static void buyProductForExistContactTest() {
        Product_Table__c product = [
            SELECT Id, Name, Units_Available__c, Unit_Price__c, Added_Date__c
            FROM Product_Table__c
        ];

        Contact contact = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
        ];

        test.startTest();
        PageReference pageRef = Page.BuyProductPage;
        pageRef.getParameters().put('id', String.valueOf(product.Id));
        test.setCurrentPage(pageRef);
        BuyProductController buyProductController = new BuyProductController();
        buyProductController.firstName = contact.FirstName;
        buyProductController.lastName = contact.LastName;
        buyProductController.email = contact.Email;
        buyProductController.count = Integer.valueOf(product.Units_Available__c);
        buyProductController.buyProduct();
        test.stopTest();

        Contact newContact = new Contact ();
        newContact = [
            SELECT Id, LastName
            FROM Contact
            WHERE Email = 'test@gmail.com'
        ];

        system.assertEquals(contact.LastName, newContact.LastName);
    }

    @isTest
    private static void buyProductForNewContactTest() {
        Contact newContact = new Contact(
            FirstName = 'FirstName',
            LastName = 'LastName',
            Email = 'test@gmail.com'
        );

        Product_Table__c product = [
            SELECT Id, Name, Units_Available__c, Unit_Price__c, Added_Date__c
            FROM Product_Table__c
        ];

        Org_Configuration__c orgConfiguration = [
            SELECT Period_Term__c
            FROM Org_Configuration__c
        ];

        test.startTest();
        PageReference pageRef = Page.BuyProductPage;
        pageRef.getParameters().put('id', String.valueOf(product.Id));

        test.setCurrentPage(pageRef);
        BuyProductController buyProductController = new BuyProductController();
        buyProductController.firstName = newContact.FirstName;
        buyProductController.lastName = newContact.LastName;
        buyProductController.email = newContact.Email;
        buyProductController.count = Integer.valueOf(product.Units_Available__c - orgConfiguration.Period_Term__c);
        buyProductController.buyProduct();
        test.stopTest();

        Product_Table__c newProduct = new Product_Table__c ();
        newProduct = [
            SELECT Id, Name, Unit_Price__c, Units_Available__c
            FROM Product_Table__c
            WHERE Id = :product.Id
        ];

        system.assertEquals((product.Units_Available__c - buyProductController.count), newProduct.Units_Available__c);
    }

    @isTest
    private static void missingLastNameTest() {
        Product_Table__c product = [
            SELECT Id, Name, Units_Available__c, Unit_Price__c, Added_Date__c
            FROM Product_Table__c
        ];

        Contact contact = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
        ];

        test.startTest();
        PageReference pageRef = Page.BuyProductPage;
        pageRef.getParameters().put('id', String.valueOf(product.Id));
        test.setCurrentPage(pageRef);
        BuyProductController buyProductController = new BuyProductController();
        buyProductController.firstName = contact.FirstName;
        buyProductController.email = contact.Email;
        buyProductController.count = Integer.valueOf(product.Units_Available__c);
        buyProductController.buyProduct();
        test.stopTest();

        system.assertEquals(label.errMsgMissingLastNamelabel, buyProductController.errorMessage);
    }

    @isTest
    private static void overCountUnitsAvailableTest() {
        Product_Table__c product = [
            SELECT Id, Name, Units_Available__c, Unit_Price__c, Added_Date__c
            FROM Product_Table__c
        ];

        Contact contact = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
        ];

        test.startTest();
        PageReference pageRef = Page.BuyProductPage;
        pageRef.getParameters().put('id', String.valueOf(product.Id));
        test.setCurrentPage(pageRef);
        BuyProductController buyProductController = new BuyProductController();
        buyProductController.firstName = contact.FirstName;
        buyProductController.lastName = contact.LastName;
        buyProductController.email = contact.Email;
        buyProductController.count = Integer.valueOf(product.Units_Available__c + 10);
        buyProductController.buyProduct();
        test.stopTest();

        system.assertEquals(label.errMsgProductCountOverlabel, buyProductController.errorMessage);
    }

    @isTest
    private static void missingFirstNameTest() {
        Product_Table__c product = [
            SELECT Id, Name, Units_Available__c, Unit_Price__c, Added_Date__c
            FROM Product_Table__c
        ];

        Contact contact = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
        ];

        test.startTest();
        PageReference pageRef = Page.BuyProductPage;
        pageRef.getParameters().put('id', String.valueOf(product.Id));
        test.setCurrentPage(pageRef);
        BuyProductController buyProductController = new BuyProductController();
        buyProductController.lastName = contact.LastName;
        buyProductController.email = contact.Email;
        buyProductController.count = Integer.valueOf(product.Units_Available__c);
        buyProductController.buyProduct();
        test.stopTest();

        system.assertEquals(label.errMsgMissingFirstNamelabel, buyProductController.errorMessage);
    }

    @isTest
    private static void incorrectCountTest() {
        Product_Table__c product = [
            SELECT Id, Name, Units_Available__c, Unit_Price__c, Added_Date__c
            FROM Product_Table__c
        ];

        Contact contact = [
            SELECT Id, FirstName, LastName, Email
            FROM Contact
        ];

        test.startTest();
        PageReference pageRef = Page.BuyProductPage;
        pageRef.getParameters().put('id', String.valueOf(product.Id));
        test.setCurrentPage(pageRef);
        BuyProductController buyProductController = new BuyProductController();
        buyProductController.firstName = contact.FirstName;
        buyProductController.lastName = contact.LastName;
        buyProductController.email = contact.Email;
        buyProductController.count = 0;
        buyProductController.buyProduct();
        test.stopTest();

        system.assertEquals(label.errMsgIncorrectProductCountLabel, buyProductController.errorMessage);
    }
}