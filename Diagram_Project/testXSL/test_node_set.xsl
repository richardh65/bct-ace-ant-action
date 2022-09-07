<?xml version="1.0" encoding="UTF-8"?>

<!--
 =================================================================
  Licensed Materials - Property of IBM

  WebSphere Commerce

  (C) Copyright IBM Corp. 2010, 2011 All Rights Reserved.

  US Government Users Restricted Rights - Use, duplication or
  disclosure restricted by GSA ADP Schedule Contract with
  IBM Corp.
 =================================================================
-->
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:mm="http://WCToSSFSMediationModule"	
	xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:exslt="http://exslt.org/common"
	xmlns:mediationUtil="http://ibm.com/commerce/mediationUtil"
 	xmlns:oa="http://www.openapplications.org/oagis/9"
	xmlns:udt="http://www.openapplications.org/oagis/9/unqualifieddatatypes/1.1"
	xmlns:_wcf="http://www.ibm.com/xmlns/prod/commerce/9/foundation"
	xmlns:_inv="http://www.ibm.com/xmlns/prod/commerce/9/inventory"
	xmlns="http://www.sterlingcommerce.com/documentation/YFS/findInventory/output"
	extension-element-prefixes="datetime mediationUtil exslt"
	exclude-result-prefixes="mm"
	version="2.0">
		<xsl:import href="mediationUtil.function.xsl" /> 
	
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="no" />
	<xsl:strip-space elements="*" />
	
	<!-- This rule represents an element mapping: "io4:smo" to "io4:smo". -->
	<xsl:template match="/">
		<!-- a structural mapping: "body/in2:Promise"(PromiseXSDType) to "out5:ShowInventoryAvailability"(ShowInventoryAvailabilityType) -->
		<!-- variables for custom code -->
		<!--<xsl:variable name="Promise" select="body/_inv:Promise"/>-->
		<xsl:variable name="Promise" select="*"/>
		<xsl:variable name="Expression" select="$Promise/context/correlation/Expression"/>
		<xsl:call-template name="PromiseToShowInventoryAvailability">
			<xsl:with-param name="Promise" select="$Promise"/>
			<xsl:with-param name="Expression" select="$Expression"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="PromiseToShowInventoryAvailability">
		
		<xsl:param name="Promise" />
		<xsl:param name="Expression" />
		
		<xsl:variable name="OrganizationCode"><xsl:value-of select="$Promise/@OrganizationCode" /></xsl:variable>	  
		<xsl:variable name="storeId"><xsl:value-of select="document('../../ValueMaps.xml',/)/mm:ValueMaps/mm:Map[@name='storeIdToOrganizationCode']/mm:Entry[text()=$OrganizationCode]/@key" /></xsl:variable>	
		<xsl:variable name="storeNode"><xsl:value-of select="document('../../ValueMaps.xml',/)/mm:ValueMaps/mm:Map[@name='storeIdToNode']/mm:Entry[@key=$storeId]/text()" /></xsl:variable>
	
	
		<!-- xsl:variable name="selectionCriteria" select="mediationUtil:selectionCriteria($Expression)" /-->
		<xsl:variable name="today" select="datetime:date()" />
		<xsl:variable name="apos">'</xsl:variable>
		
		<_inv:ShowInventoryAvailability releaseID="">
			<_wcf:ApplicationArea>
				<oa:CreationDateTime xsi:type="udt:DateTimeType">
					<xsl:value-of select="datetime:dateTime()" />
				</oa:CreationDateTime>
			</_wcf:ApplicationArea>
			<_inv:DataArea>
				<xsl:for-each
					select="exslt:node-set(mediationUtil:xpathParameterValues($Expression, 'PartNumber'))/PartNumber">
				<xsl:variable name="sku" select="." />
					<xsl:for-each
						select="exslt:node-set(mediationUtil:xpathParameterValues($Expression, 'NameIdentifier'))/NameIdentifier">
						
						<xsl:variable name="promiseLine"
							select="$Promise/SuggestedOption/Option/PromiseLines/PromiseLine[@ItemID=$sku and @ShipNode=$storeNode]" />
						<xsl:variable name="availableQuantity"
							select="sum($promiseLine/Assignments/Assignment[@ProductAvailDate and mediationUtil:compare($today, @ProductAvailDate) &gt;= 0]/@Quantity)" />
						<_inv:InventoryAvailability>
							<_inv:InventoryAvailabilityIdentifier>
								<_wcf:ExternalIdentifier>
									<_wcf:CatalogEntryIdentifier>
										<_wcf:ExternalIdentifier>
											<_wcf:PartNumber>
												<xsl:value-of select="$sku" />											
											</_wcf:PartNumber>
										</_wcf:ExternalIdentifier>
									</_wcf:CatalogEntryIdentifier>
									<_wcf:OnlineStoreIdentifier>
										<_wcf:ExternalIdentifier>
											<_wcf:NameIdentifier>
												<xsl:value-of select="." />
											</_wcf:NameIdentifier>
										</_wcf:ExternalIdentifier>
									</_wcf:OnlineStoreIdentifier>
								</_wcf:ExternalIdentifier>
							</_inv:InventoryAvailabilityIdentifier>
							<xsl:choose>
								<xsl:when test="$availableQuantity &gt; 0">
									<_inv:InventoryStatus>Available</_inv:InventoryStatus>
									<_inv:AvailableQuantity uom="C62">
										<xsl:value-of select="$availableQuantity" />
									</_inv:AvailableQuantity>
								</xsl:when>
								<xsl:when
									test="$promiseLine/Assignments/Assignment[@Quantity &gt; 0] and $promiseLine/Assignments/Assignment[@Quantity &gt; 0]/@ProductAvailDate != ''">
									<_inv:InventoryStatus>Backorderable</_inv:InventoryStatus>
									<_inv:AvailabilityDateTime>
										<xsl:value-of
											select="datetime:formatDate($promiseLine/Assignments/Assignment[@Quantity &gt; 0]/@ProductAvailDate,'yyyy-MM-dd')" />T00:00:00.000
									</_inv:AvailabilityDateTime>
								</xsl:when>
								<xsl:otherwise>
									<_inv:InventoryStatus>Unavailable</_inv:InventoryStatus>
								</xsl:otherwise>
							</xsl:choose>
						</_inv:InventoryAvailability>
					</xsl:for-each>
					<xsl:for-each
						select="exslt:node-set(mediationUtil:xpathParameterValues($Expression, 'ExternalIdentifier'))/ExternalIdentifier">
						<xsl:variable name="promiseLine"
							select="$Promise/SuggestedOption/Option/PromiseLines/PromiseLine[@ItemID=$sku and @ShipNode=current()]" />
						<xsl:variable name="availableQuantity"
							select="sum($promiseLine/Assignments/Assignment[@ProductAvailDate and mediationUtil:compare($today, @ProductAvailDate) &gt;= 0]/@Quantity)" />
						<_inv:InventoryAvailability>
							<_inv:InventoryAvailabilityIdentifier>
								<_wcf:ExternalIdentifier>
									<_wcf:CatalogEntryIdentifier>
										<_wcf:ExternalIdentifier>
											<_wcf:PartNumber>
												<xsl:value-of select="$sku" />
											</_wcf:PartNumber>
										</_wcf:ExternalIdentifier>
									</_wcf:CatalogEntryIdentifier>
									<_wcf:PhysicalStoreIdentifier>
										<_wcf:ExternalIdentifier>
											<xsl:value-of select="." />
										</_wcf:ExternalIdentifier>
									</_wcf:PhysicalStoreIdentifier>
								</_wcf:ExternalIdentifier>
							</_inv:InventoryAvailabilityIdentifier>
							<xsl:choose>
								<xsl:when test="$availableQuantity &gt; 0">
									<_inv:InventoryStatus>Available</_inv:InventoryStatus>
									<_inv:AvailableQuantity uom="C62">
										<xsl:value-of select="$availableQuantity" />
									</_inv:AvailableQuantity>
								</xsl:when>
								<xsl:when
									test="$promiseLine/Assignments/Assignment[@Quantity &gt; 0] and $promiseLine/Assignments/Assignment[@Quantity &gt; 0]/@ProductAvailDate != ''">
									<_inv:InventoryStatus>Backorderable</_inv:InventoryStatus>
									<_inv:AvailabilityDateTime>
										<xsl:value-of
											select="datetime:formatDate($promiseLine/Assignments/Assignment[@Quantity &gt; 0]/@ProductAvailDate,'yyyy-MM-dd')" />T00:00:00.000
									</_inv:AvailabilityDateTime>
								</xsl:when>
								<xsl:otherwise>
									<_inv:InventoryStatus>Unavailable</_inv:InventoryStatus>
								</xsl:otherwise>
							</xsl:choose>
						</_inv:InventoryAvailability>
						
					
					</xsl:for-each>
				</xsl:for-each>
			</_inv:DataArea>
		</_inv:ShowInventoryAvailability>
		
	</xsl:template>
	
</xsl:stylesheet>
