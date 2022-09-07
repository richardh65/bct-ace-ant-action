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
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:mediationUtil="http://ibm.com/commerce/mediationUtil"
 	xmlns:oa="http://www.openapplications.org/oagis/9"
	xmlns:udt="http://www.openapplications.org/oagis/9/unqualifieddatatypes/1.1"
	xmlns:_wcf="http://www.ibm.com/xmlns/prod/commerce/9/foundation"
	xmlns:_inv="http://www.ibm.com/xmlns/prod/commerce/9/inventory"
	xmlns:_ord="http://www.ibm.com/xmlns/prod/commerce/9/order"
	xmlns:ou="http://www.sterlingcommerce.com/documentation/YFS/reserveAvailableInventory/output"
	extension-element-prefixes="datetime mediationUtil"
	version="1.0">
	<xsl:import href="mediationUtil.function.xsl" /> 
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />
	<xsl:strip-space elements="*" />
	
	<xsl:template match="/">
		<xsl:variable name="PromiseHeader" select="*"/>
		<xsl:call-template name="PromiseHeaderToAcknowledgeInventoryRequirement">
			<xsl:with-param name="PromiseHeader" select="$PromiseHeader"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="PromiseHeaderToAcknowledgeInventoryRequirement">
		
		<xsl:param name="PromiseHeader" />
		
		<xsl:variable name="today" select="datetime:date()" />
		
		<_inv:AcknowledgeInventoryRequirement releaseID="">
			<_wcf:ApplicationArea>
				<oa:CreationDateTime xsi:type="udt:DateTimeType">
					<xsl:value-of select="datetime:dateTime()" />
				</oa:CreationDateTime>
			</_wcf:ApplicationArea>
			<_inv:DataArea>
				<oa:Acknowledge />
				<_inv:InventoryRequirement>
					<_ord:OrderIdentifier>
						<_wcf:UniqueID>
							<xsl:value-of select="substring-after($PromiseHeader/PromiseLines/PromiseLine/Reservations/Reservation/@ReservationID[1], 'WC_')" />
						</_wcf:UniqueID>
					</_ord:OrderIdentifier>
					<xsl:for-each
						select="$PromiseHeader/PromiseLines/PromiseLine[starts-with(@LineId, 'WC_') and not(@BundleParentLineId)]">
						<_ord:OrderItem>
							<_ord:OrderItemIdentifier>
								<_wcf:UniqueID>
									<xsl:value-of select="substring-after(@LineId, 'WC_')" />
								</_wcf:UniqueID>
							</_ord:OrderItemIdentifier>
							<_ord:OrderItemStatus>
								<xsl:choose>
									<xsl:when test="Reservations/Reservation/@ProductAvailabilityDate and mediationUtil:compare($today, Reservations/Reservation/@ProductAvailabilityDate[1]) &gt;= 0">
										<_ord:InventoryStatus xsi:type="_ord:InventoryStatusEnumerationType">Allocated</_ord:InventoryStatus>
									</xsl:when>
									<xsl:when test="Reservations/Reservation/@ReservationID">
										<_ord:InventoryStatus xsi:type="_ord:InventoryStatusEnumerationType">Backordered</_ord:InventoryStatus>
									</xsl:when>
									<xsl:otherwise>
										<_ord:InventoryStatus xsi:type="_ord:InventoryStatusEnumerationType">Unallocated</_ord:InventoryStatus>
									</xsl:otherwise>
								</xsl:choose>
							</_ord:OrderItemStatus>
							<_ord:OrderItemFulfillmentInfo>
								<xsl:if test="Reservations/Reservation/@ProductAvailabilityDate">
									<_ord:AvailableDate>
										<xsl:value-of select="datetime:formatDate(Reservations/Reservation/@ProductAvailabilityDate[1],'yyyy-MM-dd')" />T00:00:00.000
									</_ord:AvailableDate>
								</xsl:if>
								<xsl:if test="Reservations/Reservation/@ShipDate">
									<_ord:ExpectedShipDate>
										<xsl:value-of select="datetime:formatDate(Reservations/Reservation/@ShipDate[1],'yyyy-MM-dd')" />T00:00:00.000
									</_ord:ExpectedShipDate>
								</xsl:if>
							</_ord:OrderItemFulfillmentInfo>
							<xsl:if test="@ShipNode">
								<_ord:FulfillmentCenter>
									<_ord:FulfillmentCenterIdentifier>
										<_wcf:Name>
											<xsl:value-of select="@ShipNode" />
										</_wcf:Name>
									</_ord:FulfillmentCenterIdentifier>
								</_ord:FulfillmentCenter>
							</xsl:if>
						</_ord:OrderItem>
					</xsl:for-each>
				</_inv:InventoryRequirement>
			</_inv:DataArea>
		</_inv:AcknowledgeInventoryRequirement>
		
	</xsl:template>
	
</xsl:stylesheet>
