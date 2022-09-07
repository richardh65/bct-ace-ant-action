<?xml version="1.0"?>

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
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:mediationUtil="http://ibm.com/commerce/mediationUtil"
                xmlns:func="http://exslt.org/functions"
                extension-element-prefixes="mediationUtil">


 <xsl:variable name="apos">'</xsl:variable>

  <!-- assuming if there are multi instance of a param in the selectionCriteria, 
  they will all be considered joined by keyword 'or' even if they are joined by 'and' 
  
  usage:
  -->
<func:function name="mediationUtil:xpathParameterValues">
   <xsl:param name="selectionCriteria" />
   <xsl:param name="parameterName" />
    <xsl:variable name="result">
         <xsl:call-template name="parseXPathExpression" >
            <xsl:with-param name="txt" select="$selectionCriteria" />
            <xsl:with-param name="paramName" select="$parameterName" />
        </xsl:call-template>
 
       </xsl:variable>
           
 
   <func:result select="$result" />   
</func:function>

       <xsl:template name="parseXPathExpression">
       <xsl:param name="txt" select="''" />
       <xsl:param name="paramName"/>
               <xsl:choose>
	            
	                <xsl:when test="contains($txt, concat(concat($paramName,'='),$apos))" >
	                 <xsl:element name="{$paramName}" >
	      
	                      <xsl:value-of select="substring-before(substring-after($txt,concat(concat($paramName,'='),$apos)),$apos)" />
	                   </xsl:element>
	                </xsl:when>
	               
	            </xsl:choose>
	      
	        <xsl:variable name="remaining" select="substring-after($txt,concat(concat($paramName,'='),$apos))" />
	        <xsl:if test="contains($remaining,$paramName)" >
	                <xsl:call-template name="parseXPathExpression" >
	                <xsl:with-param name="txt" select="$remaining" />
	                <xsl:with-param name="paramName" select="$paramName"/>
	            </xsl:call-template>
	        </xsl:if>
    </xsl:template>
    
    <xsl:template name="getJulianDayNumber">
     <xsl:param name="year"/>
     <xsl:param name="month"/>
     <xsl:param name="day"/>
   
    <xsl:variable name="a" select="floor((14 - $month) div 12)"/>
    <xsl:variable name="y" select="$year + 4800 - $a"/>
    <xsl:variable name="m" select="$month + 12 * $a - 3"/>
   
    <xsl:value-of select="$day + floor((153 * $m + 2) div 5) + $y * 365 + 
          floor($y div 4) - floor($y div 100) + floor($y div 400) - 
          32045"/>
   
  </xsl:template>


  <!-- MediationUtil date compare take date part (yyyy-MM-dd) and compare the days difference (in julian days) retuning 1, -1, 0, 2 -->
                      
<func:function name="mediationUtil:compare">
   <xsl:param name="start" />
   <xsl:param name="end" />

  
   <xsl:variable name="result">
     
         <xsl:variable name="start-year" select="substring($start, 1, 4)" />
         <xsl:variable name="end-year" select="substring($end, 1, 4)" />
         <xsl:variable name="start-month" select="substring($start, 6, 2)" />
         <xsl:variable name="end-month" select="substring($end, 6, 2)" />
         <xsl:variable name="start-day" select="substring($start, 9, 2)" />
         <xsl:variable name="end-day" select="substring($end, 9, 2)" />
                 
                 
       <xsl:variable name="start-julian-days">
        <xsl:call-template name="getJulianDayNumber">
         <xsl:with-param name="year" select="$start-year"/>
           <xsl:with-param name="month" select="$start-month"/>
           <xsl:with-param name="day" select="$start-day"/>
       </xsl:call-template>
     </xsl:variable>
   
     <xsl:variable name="end-julian-days">
       <xsl:call-template name="getJulianDayNumber">
         <xsl:with-param name="year" select="$end-year"/>
           <xsl:with-param name="month" select="$end-month"/>
           <xsl:with-param name="day" select="$end-day"/>
       </xsl:call-template>
     </xsl:variable>
                      <xsl:variable name="diff-days" select="$start-julian-days - $end-julian-days" />
                        <xsl:choose>
                        
                           
                                 <xsl:when test="$diff-days &lt; 0">-1</xsl:when>
                                  <xsl:when test="$diff-days &gt; 0">1</xsl:when>
                                 <xsl:otherwise><xsl:value-of select="$diff-days" /></xsl:otherwise>
                    
                        </xsl:choose>
            
      
   </xsl:variable>
   <func:result select="$result" />   
</func:function>

</xsl:stylesheet>