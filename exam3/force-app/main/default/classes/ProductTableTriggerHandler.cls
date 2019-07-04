public with sharing class ProductTableTriggerHandler {

    private static final Org_Configuration__c ORG_CONFIGURATION = Org_Configuration__c.getInstance();

    public static void productTableTriggerHandler (List<Product_Table__c> productTablesList) {

        List<Product_Table__c> cloneProductTablesList = productTablesList.clone();

        Integer periodTerm;

        if (ORG_CONFIGURATION != null && ORG_CONFIGURATION.Period_Term__c != null) {
            periodTerm = ORG_CONFIGURATION.Period_Term__c.intValue();
        }

        List<Date> addedDates = new List<Date>();
        for(Product_Table__c itemProd : cloneProductTablesList) {
            if(itemProd.Added_Date__c == null){
                itemProd.Added_Date__c = date.today();
            }
            addedDates.add(itemProd.Added_Date__c);
        }

        Date addDateMin;
        Date addDateMax;
        addedDates.sort();

        addDateMin = addedDates[0];
        addDateMax = addedDates[addedDates.size()-1];

        Map<Product_Table__c, Warehouse__c> warehouseObjByProductTables = new Map <Product_Table__c, Warehouse__c>();

        List<Warehouse__c> warehousesList = [
            SELECT Id, Period_Start__c, Period_End__c
            FROM Warehouse__c
            WHERE NOT( Period_Start__c > : addDateMax
                OR Period_End__c < : addDateMin)
        ];

        List<Warehouse__c> newWarehousesList = new List<Warehouse__c>();

        if(warehousesList.isEmpty()) {
            warehousesList.add(new Warehouse__c());
        }
        
       /* for(Integer i = 0; i < cloneProductTablesList.size() - 1; i++) {
            q++;
            for(Integer  j = i + 1; j < cloneProductTablesList.size(); j++ ) {  
                if(cloneProductTablesList[j].Added_Date__c < cloneProductTablesList[i].Added_Date__c) {
                    z++;
                    Product_Table__c temp = cloneProductTablesList[i];
                    cloneProductTablesList[i] = cloneProductTablesList[j];
                    cloneProductTablesList[j] = temp;
                }
            }
        }*/
        for (Integer i = 0; i < cloneProductTablesList.size() - 1; i++) {
            for (Integer j = 0; j < cloneProductTablesList.size() - 1 - i; j++) {
                if (cloneProductTablesList[j].Added_Date__c > cloneProductTablesList[j+1].Added_Date__c) {
                    Product_Table__c tempProduct = cloneProductTablesList[j];
                    cloneProductTablesList[j] = cloneProductTablesList[j+1];
                    cloneProductTablesList[j+1] = tempProduct;
                }
            }
        }

        for(Product_Table__c itemProd : cloneProductTablesList) {
            for(Integer i = 0; i < warehousesList.size(); i++) {
                if(warehousesList[i].Period_Start__c <= itemProd.Added_Date__c && warehousesList[i].Period_End__c >= itemProd.Added_Date__c) {
                    itemProd.Warehouse__c = warehousesList[i].Id;
                    if (String.isBlank(warehousesList[i].Id)) {
                        warehouseObjByProductTables.put(itemProd, warehousesList[i]);
                    } else {
                        itemProd.Warehouse__c = warehousesList[i].Id;
                    }
                    break;
                }
            }
            if (String.isBlank(itemProd.Warehouse__c) && !warehouseObjByProductTables.containsKey(itemProd)) {
                Warehouse__c newWarehouse = new Warehouse__c ();
                    newWarehouse.Name = label.newWarehouse + ' ' + String.valueOf(itemProd.Added_Date__c) + ' ' + String.valueOf(itemProd.Added_Date__c + periodTerm);
                    newWarehouse.Period_Start__c = itemProd.Added_Date__c;
                    newWarehouse.Period_End__c = itemProd.Added_Date__c + periodTerm;
                    newWarehousesList.add(newWarehouse);
                    warehousesList.add(newWarehouse);
                    warehouseObjByProductTables.put(itemProd, newWarehouse);
            }
        }
        insert newWarehousesList;
        for(Product_Table__c itemProd : cloneProductTablesList) {
            if(String.isBlank(itemProd.Warehouse__c)) {
                itemProd.Warehouse__c = warehouseObjByProductTables.get(itemProd).Id;
            }
        }
    }

}