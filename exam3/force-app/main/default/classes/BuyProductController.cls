public class BuyProductController {
    public String firstName { get; set; }
    public String lastName { get; set; }
    public String email { get; set; }
    public String message { get; set; }
    public String errorMessage { get; set; }
    public Product_Table__c product { get; set; }
    public Contact contact { get; set; }
    public String productId { get; set; }
    public Decimal totalAmount { get; set; }
    public Decimal count { get; set; }

    public BuyProductController() {
        formingProducts();
    }

    public void formingProducts() {
        productId = ApexPages.currentPage().getParameters().get('Id');
        product = [
            SELECT Id, Name, Image_Url__c, Product_Description__c, Units_Available__c, Unit_Price__c
            FROM Product_Table__c
            WHERE Id = :productId
        ];
        count = 0;
        getTotalAmount();
    }

    public void getTotalAmount() {
        totalAmount = count * product.Unit_Price__c;
    }

    public Product_Table__c getProduct() {
        return product;
    }

    public void buyProduct() {
        List <Contact> contactList = new List<Contact>();
        contact = new Contact();
        Boolean isNotBlankFields = (String.isNotBlank(firstName) &&
                                    String.isNotBlank(lastName)
                                   );
        Boolean isCorrectCountUnits = (count > 0 &&
                                       count <= product.Units_Available__c
                                      );
        if (isNotBlankFields && isCorrectCountUnits) {
            contactList.addAll([
                SELECT FirstName, LastName, Email
                FROM Contact
                WHERE Email = :email
            ]);
            if (!contactList.isEmpty()) {
                contact = contactList.get(0);
            }

            if (contact.Email == email) {
                contact.FirstName = firstName;
                contact.LastName = lastName;
                update contact;
            } else {
                contact.FirstName = firstName;
                contact.LastName = lastName;
                contact.Email = email;
                insert contact;
            }
            Order_Table__c order = new Order_Table__c ();
            order.Product__c = product.Id;
            order.Units__c = count;
            order.Order_Amount__c = totalAmount;
            order.Contact__c = contact.Id;
            if (order.Units__c <= product.Units_Available__c) {
                product.Units_Available__c -= order.Units__c;
                update product;
                insert order;
                errorMessage = null;
                message = label.successMsgProductBuyLabel;
            }
        } else {
            if (count < 1) {
                message = null;
                errorMessage = label.errMsgIncorrectProductCountLabel;
            } else if (count > product.Units_Available__c) {
                message = null;
                errorMessage = label.errMsgProductCountOverLabel;
            } else if (String.isBlank(firstName)) {
                message = null;
                errorMessage = label.errMsgMissingFirstNameLabel;
            } else if (String.isBlank(lastName)) {
                message = null;
                errorMessage = label.errMsgMissingLastNameLabel;
            }
        }
    }
}