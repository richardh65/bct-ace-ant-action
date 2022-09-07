<?xml version="1.0" encoding="UTF-8"?>

<!--
 =================================================================
  Licensed Materials - Property of IBM

  WebSphere Commerce

  (C) Copyright IBM Corp. 2010 All Rights Reserved.

  US Government Users Restricted Rights - Use, duplication or
  disclosure restricted by GSA ADP Schedule Contract with
  IBM Corp.
 =================================================================
-->

<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:mm="http://WCToSSFSMediationModule"
	xmlns:_wcf="http://www.ibm.com/xmlns/prod/commerce/9/foundation"
	xmlns:_inv="http://www.ibm.com/xmlns/prod/commerce/9/inventory"
	xmlns:_ord="http://www.ibm.com/xmlns/prod/commerce/9/order"
	exclude-result-prefixes="mm _wcf _inv _ord"
	version="1.0">
	
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />
	<xsl:strip-space elements="*" />
		<xsl:template match="/">
		<xsl:variable name="ProcessInventoryRequirement" select="*"/>
		<xsl:call-template name="ProcessInventoryRequirementToPromise">
			<xsl:with-param name="ProcessInventoryRequirement" select="$ProcessInventoryRequirement"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="ProcessInventoryRequirementToPromise">
		
		<xsl:param name="ProcessInventoryRequirement" />
		
		<xsl:variable name="storeId"><xsl:value-of select="$ProcessInventoryRequirement/*[local-name()='ApplicationArea']/_wcf:BusinessContext/_wcf:ContextData[@name='storeId']/text()" /></xsl:variable>
		<xsl:variable name="OrganizationCode"><xsl:value-of select="document('../../ValueMaps.xml')/mm:ValueMaps/mm:Map[@name='storeIdToOrganizationCode']/mm:Entry[@key=$storeId]/text()" /></xsl:variable>
		
		<xsl:variable name="order" select="$ProcessInventoryRequirement/_inv:DataArea/_inv:InventoryRequirement" />
		
		<Promise>
			<xsl:attribute name="OrganizationCode"><xsl:value-of select="$OrganizationCode" /></xsl:attribute>
			<ReservationParameters>
				<xsl:attribute name="ReservationID">
					<xsl:text>WC_</xsl:text><xsl:value-of
					select="$order/_ord:OrderIdentifier/_wcf:UniqueID" />
				</xsl:attribute>
				<xsl:attribute name="AllowPartialReservation">
					<xsl:text>N</xsl:text>
				</xsl:attribute>
			</ReservationParameters>
			<PromiseLines>
				<xsl:for-each select="$order/_ord:OrderItem">
					<PromiseLine>
						<xsl:attribute name="LineId">
							<xsl:text>WC_</xsl:text><xsl:value-of
							select="_ord:OrderItemIdentifier/_wcf:UniqueID" />
						</xsl:attribute>
						<xsl:attribute name="ItemID">
							<xsl:value-of
							select="_ord:CatalogEntryIdentifier/_wcf:ExternalIdentifier/_wcf:PartNumber" />
						</xsl:attribute>
						<xsl:attribute name="RequiredQty">
							<xsl:value-of select="_ord:Quantity" />
						</xsl:attribute>
						<xsl:attribute name="FillQuantity">
							<xsl:value-of select="_ord:Quantity" />
						</xsl:attribute>
						<xsl:attribute name="UnitOfMeasure">
							<xsl:choose>
								<xsl:when test="_ord:Quantity/@uom='C62'">EACH</xsl:when>
								<xsl:when test="_ord:Quantity/@uom">
									<xsl:value-of select="_ord:Quantity/@uom" />
								</xsl:when>
								<xsl:otherwise>EACH</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="CarrierServiceCode">
							<xsl:choose>
								<xsl:when
							test="_ord:OrderItemShippingInfo/_ord:ShippingMode/_ord:ShippingModeIdentifier/_ord:ExternalIdentifier/_ord:ShipModeCode">
									<xsl:value-of
							select="_ord:OrderItemShippingInfo/_ord:ShippingMode/_ord:ShippingModeIdentifier/_ord:ExternalIdentifier/_ord:ShipModeCode" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>Priority</xsl:text>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:attribute>
						<xsl:attribute name="ShipNode">
							<xsl:value-of
							select="_ord:FulfillmentCenter/_ord:FulfillmentCenterIdentifier/_wcf:Name" />
						</xsl:attribute>
						<ShipToAddress>
							<xsl:attribute name="AddressLine1">
								<xsl:value-of
								select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:AddressLine[1]" />
							</xsl:attribute>
							<xsl:attribute name="AddressLine2">
								<xsl:value-of
								select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:AddressLine[2]" />
							</xsl:attribute>
							<xsl:attribute name="AddressLine3">
								<xsl:value-of
								select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:AddressLine[3]" />
							</xsl:attribute>
							<xsl:attribute name="City">
								<xsl:value-of
								select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:City" />
							</xsl:attribute>
							<xsl:attribute name="State">
								<xsl:value-of
								select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:StateOrProvinceName" />
							</xsl:attribute>
							<xsl:attribute name="Country">
								<xsl:value-of
								select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:Country" />
							</xsl:attribute>
							<xsl:attribute name="ZipCode">
								<xsl:value-of
								select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:PostalCode" />
							</xsl:attribute>
						</ShipToAddress>
					</PromiseLine>
					<xsl:if test="_ord:ConfigurationID">
						<xsl:for-each select="_ord:OrderItemComponent">
							<PromiseLine>
								<xsl:attribute name="LineId">
									<xsl:text>WCC_</xsl:text><xsl:value-of
									select="_ord:OrderItemComponentIdentifier/_ord:UniqueID" />
								</xsl:attribute>
								<xsl:attribute name="BundleParentLineId">
									<xsl:text>WC_</xsl:text><xsl:value-of
									select="../_ord:OrderItemIdentifier/_wcf:UniqueID" />
								</xsl:attribute>
								<xsl:attribute name="ItemID">
									<xsl:value-of
									select="_ord:CatalogEntryIdentifier/_wcf:ExternalIdentifier/_wcf:PartNumber" />
								</xsl:attribute>
								<xsl:attribute name="KitQty">
									<xsl:value-of select="_ord:Quantity" />
								</xsl:attribute>
								<xsl:attribute name="UnitOfMeasure">
									<xsl:choose>
										<xsl:when test="_ord:Quantity/@uom='C62'">EACH</xsl:when>
										<xsl:when test="_ord:Quantity/@uom">
											<xsl:value-of select="_ord:Quantity/@uom" />
										</xsl:when>
										<xsl:otherwise>EACH</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:attribute name="CarrierServiceCode">
									<xsl:choose>
										<xsl:when
									test="../_ord:OrderItemShippingInfo/_ord:ShippingMode/_ord:ShippingModeIdentifier/_ord:ExternalIdentifier/_ord:ShipModeCode">
											<xsl:value-of
									select="../_ord:OrderItemShippingInfo/_ord:ShippingMode/_ord:ShippingModeIdentifier/_ord:ExternalIdentifier/_ord:ShipModeCode" />
										</xsl:when>
										<xsl:otherwise>
											<xsl:text>Priority</xsl:text>
										</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
								<xsl:attribute name="ShipNode">
									<xsl:value-of
									select="../_ord:FulfillmentCenter/_ord:FulfillmentCenterIdentifier/_wcf:Name" />
								</xsl:attribute>
								<ShipToAddress>
									<xsl:attribute name="AddressLine1">
										<xsl:value-of
										select="../_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:AddressLine[1]" />
									</xsl:attribute>
									<xsl:attribute name="AddressLine2">
										<xsl:value-of
										select="../_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:AddressLine[2]" />
									</xsl:attribute>
									<xsl:attribute name="AddressLine3">
										<xsl:value-of
										select="../_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:AddressLine[3]" />
									</xsl:attribute>
									<xsl:attribute name="City">
										<xsl:value-of
										select="../_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:City" />
									</xsl:attribute>
									<xsl:attribute name="State">
										<xsl:value-of
										select="../_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:StateOrProvinceName" />
									</xsl:attribute>
									<xsl:attribute name="Country">
										<xsl:value-of
										select="../_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:Country" />
									</xsl:attribute>
									<xsl:attribute name="ZipCode">
										<xsl:value-of
										select="../_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:PostalCode" />
									</xsl:attribute>
								</ShipToAddress>
							</PromiseLine>
						</xsl:for-each>
					</xsl:if>
				</xsl:for-each>
			</PromiseLines>
		</Promise>
		
	</xsl:template>
	
</xsl:stylesheet>
