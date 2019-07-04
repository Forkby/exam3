public with sharing class ProductTablePageControllerExtension {

	public Id currentProductTableId {
		get {
			return currentProductTableId;
		}
		set {
			currentProductTableId = ApexPages.currentPage().getParameters().get('currentProductTableId');
		}
	}

	public ProductTablePageControllerExtension(ApexPages.StandardSetController productController) {
	}

	public ProductTablePageControllerExtension(ApexPages.StandardController stdController) {
	}
}