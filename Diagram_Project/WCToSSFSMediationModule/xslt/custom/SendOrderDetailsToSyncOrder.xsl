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
	xmlns:mm="http://WCToSSFSMediationModule"
	xmlns:oa="http://www.openapplications.org/oagis/9"
	xmlns:udt="http://www.openapplications.org/oagis/9/unqualifieddatatypes/1.1"
	xmlns:_wcf="http://www.ibm.com/xmlns/prod/commerce/9/foundation"
	xmlns:_ord="http://www.ibm.com/xmlns/prod/commerce/9/order"
	xmlns="http://www.sterlingcommerce.com/documentation/YFS/getOrderDetails/output"
	extension-element-prefixes="mm datetime"
	version="1.0">
	
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />
	<xsl:strip-space elements="*" />
	
		<xsl:template match="/">
	<xsl:variable name="Order" select="*"/>
      <xsl:call-template name="OrderToSyncOrder">
        <xsl:with-param name="Order" select="$Order"/>
      </xsl:call-template>
        </xsl:template>
	
	<xsl:template name="OrderToSyncOrder">
		
		<xsl:param name="Order" />
		
		<xsl:variable name="OrganizationCode"><xsl:value-of select="$Order/@SellerOrganizationCode" /></xsl:variable>
		<xsl:variable name="storeId"><xsl:value-of select="document('../../ValueMaps.xml')/mm:ValueMaps/mm:Map[@name='storeIdToOrganizationCode']/mm:Entry[text()=$OrganizationCode]/@key" /></xsl:variable>
		
		<_ord:SyncOrder releaseID="">
			<_wcf:ApplicationArea>
				<oa:CreationDateTime xsi:type="udt:DateTimeType">
					<xsl:value-of select="datetime:dateTime()" />
				</oa:CreationDateTime>
				<_wcf:BusinessContext>
					<_wcf:ContextData name="storeId"><xsl:value-of select="$storeId" /></_wcf:ContextData>
				</_wcf:BusinessContext>
			</_wcf:ApplicationArea>
			<_ord:DataArea>
				<oa:Sync>
					<oa:ActionCriteria>
						<oa:ActionExpression actionCode="Change" expressionLanguage="_wcf:XPath">/Order[1]</oa:ActionExpression>
					</oa:ActionCriteria>
				</oa:Sync>
				<_ord:Order>
					<_ord:OrderIdentifier>
						<_wcf:UniqueID>
							<xsl:choose>
								<xsl:when test="starts-with($Order/@OrderNo, 'WC_')">
									<xsl:value-of select="substring-after($Order/@OrderNo, 'WC_')" />
								</xsl:when>
								<xsl:otherwise>
									<xsl:value-of select="$Order/@OrderNo" />
								</xsl:otherwise>
							</xsl:choose>
						</_wcf:UniqueID>
					</_ord:OrderIdentifier>
					<_ord:OrderStatus>
						<_ord:Status>
							<xsl:choose>
								<xsl:when test="$Order/@MaxOrderStatus &gt;= 3200 and $Order/@MaxOrderStatus &lt; 3700">
									<xsl:text>R</xsl:text>
								</xsl:when>
								<xsl:when test="$Order/@MaxOrderStatus = '1300' or $Order/@MaxOrderStatus = '1400'">
									<xsl:text>B</xsl:text>
								</xsl:when>
							</xsl:choose>
						</_ord:Status>
					</_ord:OrderStatus>
				</_ord:Order>
			</_ord:DataArea>
		</_ord:SyncOrder>
		
	</xsl:template>
	
</xsl:stylesheet>
