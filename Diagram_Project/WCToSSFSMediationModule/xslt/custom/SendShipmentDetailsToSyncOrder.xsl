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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:mm="http://WCToSSFSMediationModule"
	xmlns:oa="http://www.openapplications.org/oagis/9"
	xmlns:udt="http://www.openapplications.org/oagis/9/unqualifieddatatypes/1.1"
	xmlns:_wcf="http://www.ibm.com/xmlns/prod/commerce/9/foundation"
	xmlns:_ord="http://www.ibm.com/xmlns/prod/commerce/9/order"
	extension-element-prefixes="datetime"
	version="1.0">
	
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />
	<xsl:strip-space elements="*" />
	
	<xsl:template match="/">
	<xsl:variable name="Shipment" select="*"/>
      <xsl:call-template name="ShipmentToSyncOrder">
        <xsl:with-param name="Shipment" select="$Shipment"/>
      </xsl:call-template>
        </xsl:template>
	
	<xsl:key name="ShipmentLineOrderNo" match="ShipmentLines/ShipmentLine" use="@OrderNo" />
	
	<xsl:template name="ShipmentToSyncOrder">
		
		<xsl:param name="Shipment" />
		
		<xsl:variable name="OrganizationCode"><xsl:value-of select="$Shipment/@SellerOrganizationCode" /></xsl:variable>
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
				
				<!-- Use the Muenchian Method to iterate over the unique orders -->
				<xsl:for-each select="$Shipment/ShipmentLines/ShipmentLine[count(. | key('ShipmentLineOrderNo', @OrderNo)[1]) = 1]">
					<_ord:Order>
						<_ord:OrderIdentifier>
							<_wcf:UniqueID>
								<xsl:choose>
									<xsl:when test="starts-with(@OrderNo, 'WC_')">
										<xsl:value-of select="substring-after(@OrderNo, 'WC_')" />
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="@OrderNo" />
									</xsl:otherwise>
								</xsl:choose>
				    		</_wcf:UniqueID>
						</_ord:OrderIdentifier>
						<_ord:OrderStatus>
							<_ord:Status>
								<xsl:text>S</xsl:text>
							</_ord:Status>
						</_ord:OrderStatus>
						<xsl:for-each select="key('ShipmentLineOrderNo', @OrderNo)">
							<xsl:if test="not(BundleParentLine)">
								<_ord:OrderItem>
									<_ord:OrderItemIdentifier>
										<_wcf:UniqueID><xsl:value-of select="@PrimeLineNo" /></_wcf:UniqueID>
									</_ord:OrderItemIdentifier>
									<_ord:OrderItemStatus>
										<_ord:Status>
											<xsl:text>D</xsl:text>
										</_ord:Status>
									</_ord:OrderItemStatus>
								</_ord:OrderItem>
							</xsl:if>
						</xsl:for-each>
					</_ord:Order>
				</xsl:for-each>
				
			</_ord:DataArea>
			
		</_ord:SyncOrder>
		
	</xsl:template>

</xsl:stylesheet>
