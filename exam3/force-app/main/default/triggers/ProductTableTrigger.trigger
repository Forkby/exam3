trigger ProductTableTrigger on Product_Table__c (before insert) {
	ProductTableTriggerHandler.productTableTriggerHandler(Trigger.new);
}