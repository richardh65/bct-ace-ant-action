<?xml version="1.0" encoding="UTF-8"?>

<!--
 =================================================================
  Licensed Materials - Property of IBM

  WebSphere Commerce

  (C) Copyright IBM Corp. 2011 All Rights Reserved.

  US Government Users Restricted Rights - Use, duplication or
  disclosure restricted by GSA ADP Schedule Contract with
  IBM Corp.
 =================================================================
-->

<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:mm="http://WCToSSFSMediationModule"
	xmlns:oa="http://www.openapplications.org/oagis/9"
	xmlns:udt="http://www.openapplications.org/oagis/9/unqualifieddatatypes/1.1"
	xmlns:_wcf="http://www.ibm.com/xmlns/prod/commerce/9/foundation"
	xmlns:_inv="http://www.ibm.com/xmlns/prod/commerce/9/inventory"
	xmlns:yfc="http://www.sterlingcommerce.com/documentation/YFS/REALTIME_ATP_MONITOR/REALTIME_AVAILABILITY_CHANGE"
	extension-element-prefixes="mm datetime" version="1.0">
	
	<xsl:output method="xml" encoding="UTF-8"
		omit-xml-declaration="yes" indent="no" />
	<xsl:strip-space elements="*" />
	
		<xsl:template match="/">
	<xsl:variable name="AvailabilityChange" select="*"/>
      <xsl:call-template name="AvailabilityChangeToSyncInventoryAvailability">
        <xsl:with-param name="AvailabilityChange" select="$AvailabilityChange"/>
      </xsl:call-template>
        </xsl:template>
	
	<xsl:template name="AvailabilityChangeToSyncInventoryAvailability">
		
		<xsl:param name="AvailabilityChange" />
		
		<xsl:variable name="OrganizationCode"><xsl:value-of select="$AvailabilityChange/Item/@OrganizationCode" /></xsl:variable>
		<xsl:variable name="storeId"><xsl:value-of select="document('../../ValueMaps.xml')/mm:ValueMaps/mm:Map[@name='storeIdToOrganizationCode']/mm:Entry[text()=$OrganizationCode]/@key" /></xsl:variable>
		<xsl:variable name="storeNode"><xsl:value-of select="document('../../ValueMaps.xml')/mm:ValueMaps/mm:Map[@name='storeIdToNode']/mm:Entry[@key=$storeId]/text()" /></xsl:variable>
		
		<_inv:SyncInventoryAvailability releaseID="">
			<_wcf:ApplicationArea>
				<oa:CreationDateTime xsi:type="udt:DateTimeType">
					<xsl:value-of select="datetime:dateTime()" />
				</oa:CreationDateTime>
				<_wcf:BusinessContext>
					<_wcf:ContextData name="storeId"><xsl:value-of select="$storeId" /></_wcf:ContextData>
				</_wcf:BusinessContext>
			</_wcf:ApplicationArea>
			<_inv:DataArea>
				<oa:Sync>
					<oa:ActionCriteria>
						<oa:ActionExpression actionCode="Change" expressionLanguage="_wcf:XPath">/InventoryAvailability[1]</oa:ActionExpression>
					</oa:ActionCriteria>
				</oa:Sync>
				<_inv:InventoryAvailability>
					<_inv:InventoryAvailabilityIdentifier>
						<_wcf:ExternalIdentifier>
							<_wcf:CatalogEntryIdentifier>
								<_wcf:ExternalIdentifier>
									<_wcf:PartNumber><xsl:value-of select="$AvailabilityChange/Item/@ItemID" /></_wcf:PartNumber>
								</_wcf:ExternalIdentifier>
							</_wcf:CatalogEntryIdentifier>
							<xsl:choose>
								<xsl:when test="$AvailabilityChange/@IsDefaultDistributionGroup='Y' or $AvailabilityChange/@Node=$storeNode">
									<_wcf:OnlineStoreIdentifier>
										<_wcf:UniqueID><xsl:value-of select="$storeId" /></_wcf:UniqueID>
									</_wcf:OnlineStoreIdentifier>
								</xsl:when>
								<xsl:otherwise>
									<_wcf:PhysicalStoreIdentifier>
										<_wcf:ExternalIdentifier><xsl:value-of select="$AvailabilityChange/@Node" /></_wcf:ExternalIdentifier>
									</_wcf:PhysicalStoreIdentifier>
								</xsl:otherwise>
							</xsl:choose>
						</_wcf:ExternalIdentifier>
					</_inv:InventoryAvailabilityIdentifier>
					<xsl:choose>
						<xsl:when test="$AvailabilityChange/@OnhandAvailableQuantity &gt; 0">
							<_inv:InventoryStatus>Available</_inv:InventoryStatus>
							<_inv:AvailableQuantity uom="C62"><xsl:value-of select="$AvailabilityChange/@OnhandAvailableQuantity" /></_inv:AvailableQuantity>
						</xsl:when>
						<xsl:when test="$AvailabilityChange/@FirstFutureAvailableDate != '' and $AvailabilityChange/@FirstFutureAvailableDate != '2500-01-01'">
							<_inv:InventoryStatus>Backorderable</_inv:InventoryStatus>
							<_inv:AvailabilityDateTime>
						<!-- xsl:value-of select="mediationUtil:dateToDateTime($AvailabilityChange/@FirstFutureAvailableDate)" /-->
							<xsl:value-of select="datetime:formatDate($AvailabilityChange/@FirstFutureAvailableDate, 'yyyy-MM-dd')" />T00:00:00.000
						</_inv:AvailabilityDateTime>
						
						</xsl:when>
						<xsl:otherwise>
							<_inv:InventoryStatus>Unavailable</_inv:InventoryStatus>
						</xsl:otherwise>
					</xsl:choose>
				</_inv:InventoryAvailability>
			</_inv:DataArea>
		</_inv:SyncInventoryAvailability>
		
	</xsl:template>
	
</xsl:stylesheet>
