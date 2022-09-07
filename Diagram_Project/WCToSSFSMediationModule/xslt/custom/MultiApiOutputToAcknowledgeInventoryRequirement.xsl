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
	xmlns:oa="http://www.openapplications.org/oagis/9"
	xmlns:udt="http://www.openapplications.org/oagis/9/unqualifieddatatypes/1.1"
	xmlns:_wcf="http://www.ibm.com/xmlns/prod/commerce/9/foundation"
	xmlns:_inv="http://www.ibm.com/xmlns/prod/commerce/9/inventory"
	xmlns:_ord="http://www.ibm.com/xmlns/prod/commerce/9/order"
	xmlns="http://www.sterlingcommerce.com/documentation/YCP/multiApi/output"
	extension-element-prefixes="datetime"
	version="1.0">
	
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />
	<xsl:strip-space elements="*" />
	
	<xsl:template match="/">
		<xsl:variable name="MultiApi" select="*"/>
		<xsl:call-template name="MultiApiToAcknowledgeInventoryRequirement">
			<xsl:with-param name="MultiApi" select="$MultiApi"/>
		</xsl:call-template>
	</xsl:template>
	
	<xsl:template name="MultiApiToAcknowledgeInventoryRequirement">
		<xsl:param name="MultiApi" />
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
							<xsl:value-of select="substring-after($MultiApi/API[1]/Output/CancelReservation/@ReservationID, 'WC_')" />
						</_wcf:UniqueID>
					</_ord:OrderIdentifier>
				</_inv:InventoryRequirement>
			</_inv:DataArea>
		</_inv:AcknowledgeInventoryRequirement>
	</xsl:template>
</xsl:stylesheet>
