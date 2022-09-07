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
		<xsl:call-template name="ProcessInventoryRequirementToMultiApi">
			<xsl:with-param name="ProcessInventoryRequirement" select="$ProcessInventoryRequirement"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="ProcessInventoryRequirementToMultiApi">
		
		<xsl:param name="ProcessInventoryRequirement" />
		
		<xsl:variable name="storeId"><xsl:value-of select="$ProcessInventoryRequirement/*[local-name()='ApplicationArea']/_wcf:BusinessContext/_wcf:ContextData[@name='storeId']/text()" /></xsl:variable>
		<xsl:variable name="OrganizationCode"><xsl:value-of select="document('../../ValueMaps.xml')/mm:ValueMaps/mm:Map[@name='storeIdToOrganizationCode']/mm:Entry[@key=$storeId]/text()" /></xsl:variable>
		
		<xsl:variable name="order" select="$ProcessInventoryRequirement/_inv:DataArea/_inv:InventoryRequirement" />
		
		<MultiApi>
			<xsl:for-each select="$order/_ord:OrderItem">
				<xsl:choose>
					<xsl:when test="_ord:OrderItemComponent">
						<xsl:for-each select="_ord:OrderItemComponent">
							<API Name="cancelReservation">
								<Input>
									<CancelReservation>
										<xsl:attribute name="OrganizationCode"><xsl:value-of select="$OrganizationCode" /></xsl:attribute>
										<xsl:attribute name="ReservationID">
											<xsl:text>WC_</xsl:text><xsl:value-of select="$order/_ord:OrderIdentifier/_wcf:UniqueID" />
										</xsl:attribute>
										<xsl:attribute name="ItemID">
											<xsl:value-of select="_ord:CatalogEntryIdentifier/_wcf:ExternalIdentifier/_wcf:PartNumber" />
										</xsl:attribute>
										<xsl:attribute name="QtyToBeCancelled">
											<xsl:value-of select="number(_ord:Quantity)*number(../_ord:Quantity)" />
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
										<xsl:attribute name="ShipNode">
											<xsl:value-of
											select="../_ord:FulfillmentCenter/_ord:FulfillmentCenterIdentifier/_wcf:Name" />
										</xsl:attribute>
									</CancelReservation>
								</Input>
							</API>
						</xsl:for-each>
					</xsl:when>
					<xsl:otherwise>
						<API Name="cancelReservation">
							<Input>
								<CancelReservation>
									<xsl:attribute name="OrganizationCode"><xsl:value-of select="$OrganizationCode" /></xsl:attribute>
									<xsl:attribute name="ReservationID">
										<xsl:text>WC_</xsl:text><xsl:value-of select="$order/_ord:OrderIdentifier/_wcf:UniqueID" />
									</xsl:attribute>
									<xsl:attribute name="ItemID">
										<xsl:value-of select="_ord:CatalogEntryIdentifier/_wcf:ExternalIdentifier/_wcf:PartNumber" />
									</xsl:attribute>
									<xsl:attribute name="QtyToBeCancelled">
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
									<xsl:attribute name="ShipNode">
										<xsl:value-of select="_ord:FulfillmentCenter/_ord:FulfillmentCenterIdentifier/_wcf:Name" />
									</xsl:attribute>
								</CancelReservation>
							</Input>
						</API>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:for-each>
		</MultiApi>
		
	</xsl:template>
	
</xsl:stylesheet>
