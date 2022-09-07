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
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:datetime="http://exslt.org/dates-and-times"
	xmlns:mediationUtil="xalan://com.ibm.commerce.sample.mediation.util.MediationUtil"
	xmlns:mm="http://WCToSSFSMediationModule"
	extension-element-prefixes="datetime mediationUtil"
	exclude-result-prefixes="xalan "
	version="1.0">

	<xsl:output method="xml" encoding="UTF-8" indent="yes" xalan:indent-amount="2" />
	<xsl:strip-space elements="*" />


	<xsl:template match="/">
	<xsl:variable name="AvailabilityChange" select="*"/>
      <xsl:call-template name="AvailabilityChangeToContent">
        <xsl:with-param name="AvailabilityChange" select="$AvailabilityChange"/>
      </xsl:call-template>
        </xsl:template>
        
	<xsl:template name="AvailabilityChangeToContent">

		<xsl:param name="AvailabilityChange" />

		<xsl:variable name="OrganizationCode"><xsl:value-of select="$AvailabilityChange/Item/@OrganizationCode" /></xsl:variable>
		<xsl:variable name="storeId"><xsl:value-of select="document('../../ValueMaps.xml')/mm:ValueMaps/mm:Map[@name='storeIdToOrganizationCode']/mm:Entry[text()=$OrganizationCode]/@key" /></xsl:variable>
		<xsl:variable name="storeNode"><xsl:value-of select="document('../../ValueMaps.xml')/mm:ValueMaps/mm:Map[@name='storeIdToNode']/mm:Entry[@key=$storeId]/text()" /></xsl:variable>

		<Content>
			<PartNumber><xsl:value-of select="$AvailabilityChange/Item/@ItemID" /></PartNumber>
			<xsl:choose>
				<xsl:when test="$AvailabilityChange/@IsDefaultDistributionGroup='Y' or $AvailabilityChange/@Node=$storeNode">
					<OnlineStoreUniqueID><xsl:value-of select="$storeId" /></OnlineStoreUniqueID>
				</xsl:when>
				<xsl:otherwise>
					<physicalStoreIdentifier><xsl:value-of select="$AvailabilityChange/@Node" /></physicalStoreIdentifier>
				</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="$AvailabilityChange/@OnhandAvailableQuantity &gt; 0">
					<InventoryStatus>AVL</InventoryStatus>
					<AvailableQuantity><xsl:value-of select="$AvailabilityChange/@OnhandAvailableQuantity" /></AvailableQuantity>
					<AvailableQuantityUOM>C62</AvailableQuantityUOM>
				</xsl:when>
				<xsl:when test="$AvailabilityChange/@FirstFutureAvailableDate != '' and $AvailabilityChange/@FirstFutureAvailableDate != '2500-01-01'">
					<InventoryStatus>BA</InventoryStatus>
					<AvailabilityTime><xsl:value-of select="datetime:formatDate($AvailabilityChange/@FirstFutureAvailableDate, 'yyyy-MM-dd HH:mm:ss.SSS')" /></AvailabilityTime>
				</xsl:when>
				<xsl:otherwise>
					<InventoryStatus>UAVL</InventoryStatus>
				</xsl:otherwise>
			</xsl:choose>
			<LastUpdate><xsl:value-of select="datetime:formatDate(datetime:dateTime(), 'yyyy-MM-dd HH:mm:ss.SSS')" /></LastUpdate>
			<ContextStoreId><xsl:value-of select="$storeId" /></ContextStoreId>
		</Content>

	</xsl:template>

</xsl:stylesheet>
