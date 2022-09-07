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
<!-- Convert xml message to a CSV type and store it in the CSVFormat Element which is used later in the Java Compute to output 
to file. Structure of this CSV is in the message set project. InventoryAvailabilityCSVType.xsd -->
<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	exclude-result-prefixes="xsi "
	version="1.0">

	<xsl:output method="xml" encoding="UTF-8"  />
	<xsl:strip-space elements="*" />


	<xsl:template match="/">
	<xsl:variable name="Content" select="*"/>
      <xsl:call-template name="ContentToCSV">
        <xsl:with-param name="Content" select="$Content"/>
      </xsl:call-template>
        </xsl:template>
        
	<xsl:template name="ContentToCSV">

		<xsl:param name="Content" />
		<CSVFormat>
		
		<xsl:value-of select="$Content/PartNumber" />,<xsl:value-of select="$Content/OnlineStoreUniqueID" />,<xsl:value-of select="$Content/physicalStoreIdentifier" />,<xsl:value-of select="$Content/InventoryStatus" />,<xsl:value-of select="$Content/AvailableQuantity" />,<xsl:value-of select="$Content/AvailableQuantityUOM" />,<xsl:value-of select="$Content/AvailabilityTime" />,<xsl:value-of select="$Content/AvailabilityOffset" />,<xsl:value-of select="$Content/LastUpdate" />,<xsl:value-of select="$Content/ContextStoreId" />,<xsl:value-of select="$Content/Field1" />,<xsl:value-of select="$Content/Field2" />,<xsl:value-of select="$Content/Field3" />,</CSVFormat> <!-- extra comma is for Delete field -->

	</xsl:template>

</xsl:stylesheet>