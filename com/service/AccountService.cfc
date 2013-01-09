/*

    Slatwall - An Open Source eCommerce Platform
    Copyright (C) 2011 ten24, LLC

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    Linking this library statically or dynamically with other modules is
    making a combined work based on this library.  Thus, the terms and
    conditions of the GNU General Public License cover the whole
    combination.
 
    As a special exception, the copyright holders of this library give you
    permission to link this library with independent modules to produce an
    executable, regardless of the license terms of these independent
    modules, and to copy and distribute the resulting executable under
    terms of your choice, provided that you also meet, for each linked
    independent module, the terms and conditions of the license of that
    module.  An independent module is a module which is not derived from
    or based on this library.  If you modify this library, you may extend
    this exception to your version of the library, but you are not
    obligated to do so.  If you do not wish to do so, delete this
    exception statement from your version.

Notes:

*/
component extends="BaseService" accessors="true" output="false" {
	
	property name="emailService" type="any";
	property name="sessionService" type="any";
	property name="paymentService" type="any";
	property name="permissionService" type="any";
	property name="priceGroupService" type="any";
	property name="validationService" type="any";
	
	// Mura Injection on Init
	property name="userManager" type="any";
	property name="userUtility" type="any";
	
	public any function init() {
		setUserManager( getCMSBean("userManager") );
		setUserUtility( getCMSBean("userUtility") );
		variables.permissions = '';
		
		return super.init();
	}
	
	public string function getHashedAndSaltedPassword(required string password, required string salt) {
		return hash(arguments.password & arguments.salt, 'SHA-512');
	}
	
	
	// ===================== START: Logical Methods ===========================
	
	// =====================  END: Logical Methods ============================
	
	// ===================== START: DAO Passthrough ===========================
	
	public any function getInternalAccountAuthenticationsByEmailAddress(required string emailAddress) {
		return getDAO().getInternalAccountAuthenticationsByEmailAddress(argumentcollection=arguments);
	}
	
	public boolean function getAccountAuthenticationExists() {
		return getDAO().getAccountAuthenticationExists();
	}
	
	// ===================== START: DAO Passthrough ===========================
	
	// ===================== START: Process Methods ===========================
	
	public any function processAccount_changePassword(required any account, struct data={}) {
		// TODO: Add Change Password Logic Here
	}
	
	public any function processAccount_setupInitialAdmin(any account=this.newAccount(), struct data={}) {
		
		var authExists = getAccountAuthenticationExists();
		
		if(!authExists) {
			if(len(arguments.data.password) && arguments.data.password == arguments.data.passwordConfirm) {
				arguments.account = this.saveAccount(arguments.account, arguments.data);
			} else {
				arguments.account.addError('password', rbKey('validate.account.passwordConfirmMismatch'));	
			}
			
			if(!arguments.account.hasErrors()) {
				var accountAuthentication = this.newAccountAuthentication();
				accountAuthentication.setAccount( arguments.account );
				
				// Put the accountAuthentication into the hibernate scope so that it has an id
				getDAO().save(accountAuthentication);
				
				// Set the password
				accountAuthentication.setPassword( getHashedAndSaltedPassword(arguments.data.password, accountAuthentication.getAccountAuthenticationID()) );
				
				// Add the super-user permission group to this new account
				arguments.account.addPermissionGroup( getPermissionService().getPermissionGroup('4028808a37037dbf01370ed2001f0074'));
				
				// Login this use (which will also ensure the data persists)
				getSessionService().loginAccount(arguments.account, arguments.account.getAccountAuthentications()[1]);
			}
		} else {
			rc.account.addError('invalid', rbKey('validate.account.accountAuthenticationExists'));
		}
		
		return arguments.account;
	}
	
	public any function processAccountPayment(required any accountPayment, struct data={}, string processContext="process") {
		
		param name="arguments.data.amount" default="0";
		
		// CONTEXT: offlineTransaction
		if (arguments.processContext == "offlineTransaction") {
		
			var newPaymentTransaction = getPaymentService().newPaymentTransaction();
			newPaymentTransaction.setTransactionType( "offline" );
			newPaymentTransaction.setAccountPayment( arguments.accountPayment );
			newPaymentTransaction = getPaymentService().savePaymentTransaction(newPaymentTransaction, arguments.data);
			
			if(newPaymentTransaction.hasErrors()) {
				arguments.accountPayment.addError('processing', rbKey('validate.accountPayment.offlineProcessingError'));	
			}
			
		} else {
			
			getPaymentService().processPayment(arguments.accountPayment, arguments.processContext, arguments.data.amount);
			
		}
		
		return arguments.accountPayment;
	}
	
	// =====================  END: Process Methods ============================
	
	// ====================== START: Save Overrides ===========================
	
	// ======================  END: Save Overrides ============================
	
	// ==================== START: Smart List Overrides =======================
	

	public any function getAccountSmartList(struct data={}, currentURL="") {
		arguments.entityName = "SlatwallAccount";
		
		var smartList = getDAO().getSmartList(argumentCollection=arguments);
		
		smartList.joinRelatedProperty("SlatwallAccount", "primaryEmailAddress", "left");
		smartList.joinRelatedProperty("SlatwallAccount", "primaryPhoneNumber", "left");
		smartList.joinRelatedProperty("SlatwallAccount", "primaryAddress", "left");
		
		smartList.addKeywordProperty(propertyIdentifier="firstName", weight=1);
		smartList.addKeywordProperty(propertyIdentifier="lastName", weight=1);
		smartList.addKeywordProperty(propertyIdentifier="company", weight=1);
		smartList.addKeywordProperty(propertyIdentifier="primaryEmailAddress.emailAddress", weight=1);
		smartList.addKeywordProperty(propertyIdentifier="primaryPhoneNumber.phoneNumber", weight=1);
		smartList.addKeywordProperty(propertyIdentifier="primaryAddress.streetAddress", weight=1);
		
		return smartList;
	}
	
	// ====================  END: Smart List Overrides ========================
	
	// ====================== START: Get Overrides ============================
	
	// ======================  END: Get Overrides =============================
	
	// ===================== START: Delete Overrides ==========================
	
	public boolean function deleteAccount(required any account) {
	
		// Set the primary fields temporarily in the local scope so we can reset if delete fails
		var primaryEmailAddress = arguments.account.getPrimaryEmailAddress();
		var primaryPhoneNumber = arguments.account.getPrimaryPhoneNumber();
		var primaryAddress = arguments.account.getPrimaryAddress();
		
		// Remove the primary fields so that we can delete this entity
		arguments.account.setPrimaryEmailAddress(javaCast("null", ""));
		arguments.account.setPrimaryPhoneNumber(javaCast("null", ""));
		arguments.account.setPrimaryAddress(javaCast("null", ""));
	
		// Use the base delete method to check validation
		var deleteOK = super.delete(arguments.account);
		
		// If the delete failed, then we just reset the primary fields in account and return false
		if(!deleteOK) {
			arguments.account.setPrimaryEmailAddress(primaryEmailAddress);
			arguments.account.setPrimaryPhoneNumber(primaryPhoneNumber);
			arguments.account.setPrimaryAddress(primaryAddress);
		
			return false;
		}
	
		return true;
	}
	
	// =====================  END: Delete Overrides ===========================
	
}
