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
	xmlns:mm="http://WCToSSFSMediationModule"
	xmlns:oa="http://www.openapplications.org/oagis/9"
	xmlns:_wcf="http://www.ibm.com/xmlns/prod/commerce/9/foundation"
	xmlns:_inv="http://www.ibm.com/xmlns/prod/commerce/9/inventory"
	xmlns="http://www.sterlingcommerce.com/documentation/YFS/findInventory/input"
	xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/"
	xmlns:exslt="http://exslt.org/common"
	xmlns:mediationUtil="http://ibm.com/commerce/mediationUtil"
	extension-element-prefixes="mediationUtil exslt"
	exclude-result-prefixes="mm oa _inv"
	version="1.0">
	<xsl:import href="mediationUtil.function.xsl" />
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="no" indent="no" />
	<xsl:strip-space elements="*" />
	 <xsl:template match="/">

        <!-- a structural mapping: "body/in5:GetInventoryAvailability"(GetInventoryAvailabilityType) to "out2:Promise"(PromiseXSDType) -->
        <!-- variables for custom code -->
        <xsl:variable name="GetInventoryAvailability" select="*"/>
        <xsl:call-template name="GetInventoryAvailabilityToPromise">
          <xsl:with-param name="GetInventoryAvailability" select="$GetInventoryAvailability"/>
        </xsl:call-template>

  </xsl:template>
		<xsl:template name="GetInventoryAvailabilityToPromise">

		<xsl:param name="GetInventoryAvailability" />

		<xsl:variable name="storeId"><xsl:value-of select="$GetInventoryAvailability/*[local-name()='ApplicationArea']/_wcf:BusinessContext/_wcf:ContextData[@name='storeId']/text()" /></xsl:variable>
		<xsl:variable name="OrganizationCode"><xsl:value-of select="document('../../ValueMaps.xml',/)/mm:ValueMaps/mm:Map[@name='storeIdToOrganizationCode']/mm:Entry[@key=$storeId]/text()" /></xsl:variable>
		<xsl:variable name="shipNode"><xsl:value-of select="document('../../ValueMaps.xml',/)/mm:ValueMaps/mm:Map[@name='storeIdToNode']/mm:Entry[@key=$storeId]/text()" /></xsl:variable>
		
		<xsl:variable name="expression" select="$GetInventoryAvailability/_inv:DataArea/oa:Get/oa:Expression" />
		
		<Promise>
			<xsl:attribute name="OrganizationCode"><xsl:value-of select="$OrganizationCode" /></xsl:attribute>
			<PromiseLines>
				<xsl:for-each
					select="exslt:node-set(mediationUtil:xpathParameterValues($expression, 'PartNumber'))/PartNumber">
					<xsl:variable name="sku" select="." />				
					<xsl:for-each
						select="exslt:node-set(mediationUtil:xpathParameterValues($expression, 'NameIdentifier'))/NameIdentifier">
						<xsl:variable name="lineId" select="position()"/>
						<PromiseLine RequiredQty="999999999" UnitOfMeasure="EACH">
							<xsl:attribute name="ItemID"><xsl:value-of select="$sku" /></xsl:attribute>
							<xsl:attribute name="LineId"><xsl:value-of select="concat('online_', format-number($lineId, '#'))" /></xsl:attribute>
							<xsl:attribute name="ShipNode"><xsl:value-of select="$shipNode" /></xsl:attribute>																			
						</PromiseLine>
					</xsl:for-each>
					<xsl:for-each
						select="exslt:node-set(mediationUtil:xpathParameterValues($expression, 'ExternalIdentifier'))/ExternalIdentifier">	<xsl:variable name="lineId" select="position()"/>
						<PromiseLine RequiredQty="999999999" UnitOfMeasure="EACH">
							<xsl:attribute name="ItemID"><xsl:value-of select="$sku" /></xsl:attribute>
							<xsl:attribute name="ShipNode"><xsl:value-of select="." /></xsl:attribute>	
							<xsl:attribute name="LineId"><xsl:value-of select="concat('physical_', format-number($lineId, '#'))" /></xsl:attribute>						
						</PromiseLine>
					</xsl:for-each>
				</xsl:for-each>
			</PromiseLines>
		</Promise>
		
	</xsl:template>
	

	
</xsl:stylesheet>
