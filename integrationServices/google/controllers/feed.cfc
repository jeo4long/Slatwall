component extends="Slatwall.admin.controllers.BaseController" persistent="false" accessors="true" output="false" {

	property name="productService" type="any";
	
	this.publicMethods="product";
	this.anyAdminMethods="";
	this.secureMethods="";
		
	public void function product(required struct rc) {
		// Hide the layout
		request.layout = false;
		
		// Create the product feed
		rc.skuSmartList = getSkuService().getSkuSmartList();
		rc.skuSmartList.addFilter('activeFlag', 1);
		rc.skuSmartList.addFilter('product.activeFlag', 1);
		rc.skuSmartList.addFilter('product.publishedFlag', 1);
		rc.skuSmartList.addRange('product.calculatedQATS', '1^');
	}
}