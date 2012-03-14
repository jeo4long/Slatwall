﻿<!---

    Slatwall - An e-commerce plugin for Mura CMS
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

--->
<cfparam name="rc.subscriptionBenefit" type="any">
<cfparam name="rc.edit" type="boolean">

<ul id="navTask">
	<cf_SlatwallActionCaller action="admin:subscription.listsubscriptionbenefits" type="list">
	<cfif !rc.edit>
		<cf_SlatwallActionCaller action="admin:subscription.editsubscriptionbenefit" queryString="subscriptionBenefitID=#rc.subscriptionBenefit.getSubscriptionBenefitID()#" type="list">
	</cfif>
</ul>

<cfoutput>
	<div class="svoadminsubscriptionbenefitdetail">
		<cfif rc.edit>
			<form name="BenefitEdit" action="#buildURL('admin:subscription.savesubscriptionbenefit')#" method="post">
				<input type="hidden" name="subscriptionBenefitID" value="#rc.subscriptionBenefit.getSubscriptionBenefitID()#" />
		</cfif>
		
		<dl class="twoColumn">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="subscriptionBenefitName" edit="#rc.edit#" first="true">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="accessCodeType" edit="#rc.edit#">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="priceGroupQuantity" edit="#rc.edit#">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="priceGroups" edit="#rc.edit#">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="promotionQuantity" edit="#rc.edit#">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="promotions" edit="#rc.edit#">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="categoryQuantity" edit="#rc.edit#">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="categories" edit="#rc.edit#">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="contentQuantity" edit="#rc.edit#">
			<cf_SlatwallPropertyDisplay object="#rc.subscriptionBenefit#" property="content" edit="#rc.edit#">
		</dl>
		
		<cfif rc.edit>
				<cf_SlatwallActionCaller action="admin:subscription.listsubscriptionbenefits" type="link" class="button" text="#rc.$.Slatwall.rbKey('sitemanager.cancel')#">
				<cf_SlatwallActionCaller action="admin:subscription.savesubscriptionbenefit" type="submit" class="button">
			</form>
		</cfif>
		
	</div>	
		
</cfoutput>