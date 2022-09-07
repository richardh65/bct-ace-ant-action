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
	xmlns:xalan="http://xml.apache.org/xalan"
	xmlns:mm="http://WCToSSFSMediationModule"
	xmlns:_wcf="http://www.ibm.com/xmlns/prod/commerce/9/foundation"
	xmlns:_ord="http://www.ibm.com/xmlns/prod/commerce/9/order"
	xmlns="http://www.sterlingcommerce.com/documentation/YFS/createOrder/input"
	exclude-result-prefixes="xalan mm _wcf _ord"
	version="1.0">
	
	
	<xsl:output method="xml" encoding="UTF-8" omit-xml-declaration="yes" indent="no" />
	<xsl:strip-space elements="*" />
	<xsl:template match="/">
	<xsl:variable name="ProcessOrder" select="*"/>
      <xsl:call-template name="ProcessOrderToOrder">
        <xsl:with-param name="ProcessOrder" select="$ProcessOrder"/>
      </xsl:call-template>
        </xsl:template>
      
           
	
	<xsl:template name="ProcessOrderToOrder">
		
		<xsl:param name="ProcessOrder" />
		
		<xsl:variable name="order" select="$ProcessOrder/_ord:DataArea/_ord:Order" />
		
		<xsl:variable name="storeId"><xsl:value-of select="$order/_ord:StoreIdentifier/_wcf:UniqueID/text()" /></xsl:variable>
		<xsl:variable name="OrganizationCode"><xsl:value-of select="document('../../ValueMaps.xml')/mm:ValueMaps/mm:Map[@name='storeIdToOrganizationCode']/mm:Entry[@key=$storeId]/text()" /></xsl:variable>
		
		<Order>
			<xsl:attribute name="OrderNo">
					<xsl:text>WC_</xsl:text><xsl:value-of
				select="$order/_ord:OrderIdentifier/_wcf:UniqueID" />
				</xsl:attribute>
			<xsl:attribute name="EnterpriseCode"><xsl:value-of select="$OrganizationCode" /></xsl:attribute>
			<xsl:attribute name="SellerOrganizationCode"><xsl:value-of select="$OrganizationCode" /></xsl:attribute>
			<xsl:attribute name="OrderDate">
					<xsl:value-of select="$order/_ord:PlacedDate" />
				</xsl:attribute>
		<xsl:if test="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction/_ord:BillingAddress/_wcf:EmailAddress1/_wcf:Value">
				<xsl:attribute name="CustomerEMailID">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction/_ord:BillingAddress/_wcf:EmailAddress1/_wcf:Value" />
				</xsl:attribute>
			</xsl:if>	
			<OrderLines>
				<xsl:for-each select="$order/_ord:OrderItem">
					<OrderLine>
						<xsl:choose>
							<xsl:when test="contains('-', _ord:OrderItemIdentifier/_wcf:UniqueID)">
								<xsl:attribute name="PrimeLineNo">
									<xsl:value-of select="substring-before(_ord:OrderItemIdentifier/_wcf:UniqueID,'-')" />
								</xsl:attribute>
								<xsl:attribute name="SubLineNo">
									<xsl:value-of select="substring-after(_ord:OrderItemIdentifier/_wcf:UniqueID, '-')" />
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="PrimeLineNo">
									<xsl:value-of select="_ord:OrderItemIdentifier/_wcf:UniqueID" />
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:attribute name="OrderedQty">
							<xsl:value-of select="_ord:Quantity" />
						</xsl:attribute>
						<xsl:attribute name="FillQuantity">
							<xsl:value-of select="_ord:Quantity" />
						</xsl:attribute>
						<xsl:attribute name="CarrierServiceCode">
							<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingMode/_ord:ShippingModeIdentifier/_ord:ExternalIdentifier/_ord:ShipModeCode" />
						</xsl:attribute>
						<xsl:attribute name="ShipNode">
							<xsl:value-of select="_ord:FulfillmentCenter/_ord:FulfillmentCenterIdentifier/_wcf:Name" />
						</xsl:attribute>
						<xsl:attribute name="ReqShipDate">
							<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:RequestedShipDate" />
						</xsl:attribute>
						<xsl:attribute name="BOMXML">
							<xsl:value-of select="_ord:OrderItemConfiguration" />
						</xsl:attribute>
						
						<xsl:choose>
							<xsl:when
								test="_ord:OrderItemShippingInfo/_ord:ShippingMode/_ord:ShippingModeIdentifier/_ord:ExternalIdentifier/_ord:ShipModeCode = 'PickupInStore'">
								<xsl:attribute name="DeliveryMethod">PICK</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="DeliveryMethod">SHP</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						
						<OrderLineReservations>
							<OrderLineReservation>
								<xsl:attribute name="ItemID">
									<xsl:value-of select="_ord:CatalogEntryIdentifier/_wcf:ExternalIdentifier/_wcf:PartNumber" />
								</xsl:attribute>
								<xsl:attribute name="Node">
									<xsl:value-of select="_ord:FulfillmentCenter/_ord:FulfillmentCenterIdentifier/_wcf:Name" />
								</xsl:attribute>
								<xsl:attribute name="ReservationID">
									<xsl:text>WC_</xsl:text><xsl:value-of select="$order/_ord:OrderIdentifier/_wcf:UniqueID" />
								</xsl:attribute>
								<xsl:attribute name="Quantity">
									<xsl:value-of select="_ord:Quantity" />
								</xsl:attribute>
								<xsl:attribute name="UnitOfMeasure">
									<xsl:choose>
										<xsl:when test="_ord:Quantity/@uom='C62'">EACH</xsl:when>
										<xsl:when test="_ord:Quantity/@uom">
											<xsl:value-of select="_ord:Quantity/@uom" />
										</xsl:when>
										<xsl:otherwise>EACH</xsl:otherwise>
									</xsl:choose>
								</xsl:attribute>
							</OrderLineReservation>
							<xsl:for-each select="_ord:OrderItemComponent">
								<OrderLineReservation>
									<xsl:attribute name="ItemID">
										<xsl:value-of select="_ord:CatalogEntryIdentifier/_wcf:ExternalIdentifier/_wcf:PartNumber" />
									</xsl:attribute>
									<xsl:attribute name="Node">
										<xsl:value-of select="../_ord:FulfillmentCenter/_ord:FulfillmentCenterIdentifier/_wcf:Name" />
									</xsl:attribute>
									<xsl:attribute name="ReservationID">
										<xsl:text>WC_</xsl:text><xsl:value-of select="$order/_ord:OrderIdentifier/_wcf:UniqueID" />
									</xsl:attribute>
									<xsl:attribute name="Quantity">
										<xsl:value-of select="number(_ord:Quantity)*number(../_ord:Quantity)" />
									</xsl:attribute>
									<xsl:attribute name="UnitOfMeasure">
										<xsl:choose>
											<xsl:when test="_ord:Quantity/@uom='C62'">EACH</xsl:when>
											<xsl:when test="_ord:Quantity/@uom">
												<xsl:value-of select="_ord:Quantity/@uom" />
											</xsl:when>
											<xsl:otherwise>EACH</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
								</OrderLineReservation>
							</xsl:for-each>
						</OrderLineReservations>
														
						<Item>
							<xsl:attribute name="ItemID">
								<xsl:value-of select="_ord:CatalogEntryIdentifier/_wcf:ExternalIdentifier/_wcf:PartNumber" />
							</xsl:attribute>
							<xsl:attribute name="UnitOfMeasure">
								<xsl:choose>
									<xsl:when test="_ord:Quantity/@uom='C62'">EACH</xsl:when>
									<xsl:when test="_ord:Quantity/@uom">
										<xsl:value-of select="_ord:Quantity/@uom" />
									</xsl:when>
									<xsl:otherwise>EACH</xsl:otherwise>
								</xsl:choose>
							</xsl:attribute>
						</Item>
						<PersonInfoShipTo>
							<xsl:attribute name="FirstName">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:ContactName/_wcf:FirstName" />
							</xsl:attribute>
							<xsl:attribute name="LastName">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:ContactName/_wcf:LastName" />
							</xsl:attribute>
							<xsl:attribute name="AddressLine1">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:AddressLine[1]" />
							</xsl:attribute>
							<xsl:attribute name="AddressLine2">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:AddressLine[2]" />
							</xsl:attribute>
							<xsl:attribute name="AddressLine3">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:AddressLine[3]" />
							</xsl:attribute>
							<xsl:attribute name="City">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:City" />
							</xsl:attribute>
							<xsl:attribute name="State">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:StateOrProvinceName" />
							</xsl:attribute>
							<xsl:attribute name="Country">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:Country" />
							</xsl:attribute>
							<xsl:attribute name="ZipCode">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:Address/_wcf:PostalCode" />
							</xsl:attribute>
							<xsl:attribute name="EMailID">
								<xsl:value-of select="_ord:OrderItemShippingInfo/_ord:ShippingAddress/_wcf:EmailAddress1/_wcf:Value" />
							</xsl:attribute>							                  
						</PersonInfoShipTo>
						<LinePriceInfo>
							<xsl:attribute name="UnitPrice">
								<xsl:value-of select="_ord:OrderItemAmount/_wcf:UnitPrice/_wcf:Price" />
							</xsl:attribute>
							<xsl:attribute name="ListPrice">
								<xsl:value-of select="_ord:OrderItemAmount/_wcf:UnitPrice/_wcf:Price" />
							</xsl:attribute>
							<xsl:attribute name="RetailPrice">
								<xsl:value-of select="_ord:OrderItemAmount/_wcf:UnitPrice/_wcf:Price" />
							</xsl:attribute>
							<xsl:attribute name="IsLinePriceForInformationOnly">N</xsl:attribute>
							<xsl:attribute name="PricingQuantityStrategy">FIX</xsl:attribute>
							<xsl:attribute name="IsPriceLocked">Y</xsl:attribute>
						</LinePriceInfo>
						<LineCharges>
							<xsl:variable name="amount" select="sum(_ord:OrderItemAmount/_wcf:Adjustment/_wcf:Amount)" />
							<LineCharge>
								<xsl:attribute name="ChargeCategory">Discount</xsl:attribute>
								<xsl:attribute name="ChargePerLine">
									<xsl:value-of select="$amount * ($amount &gt;= 0) - $amount * ($amount &lt; 0)" />
								</xsl:attribute>
							</LineCharge>															
							<LineCharge>
								<xsl:attribute name="ChargeCategory">Shipping</xsl:attribute>
								<xsl:attribute name="ChargeName">Shipping Charge</xsl:attribute>
								<xsl:attribute name="ChargePerLine">
										<xsl:value-of select="_ord:OrderItemAmount/_wcf:ShippingCharge" />
								</xsl:attribute>
							</LineCharge>										
						</LineCharges>		
						<LineTaxes>
							<LineTax>
								<xsl:attribute name="ChargeCategory">Price</xsl:attribute>
								<xsl:attribute name="Tax">
										<xsl:value-of select="_ord:OrderItemAmount/_wcf:SalesTax" />
								</xsl:attribute>
								<xsl:attribute name="TaxName">Sales Tax</xsl:attribute>
							</LineTax>
							<LineTax>
								<xsl:attribute name="ChargeCategory">Shipping</xsl:attribute>
								<xsl:attribute name="Tax">
										<xsl:value-of select="_ord:OrderItemAmount/_wcf:ShippingTax" />
								</xsl:attribute>
								<xsl:attribute name="TaxName">Shipping Tax</xsl:attribute>
							</LineTax>
						</LineTaxes>								
					</OrderLine>
				</xsl:for-each>
			</OrderLines>
			<PersonInfoBillTo>
				<xsl:attribute name="Title">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:ContactName/_wcf:PersonTitle" />
				</xsl:attribute>
				<xsl:attribute name="FirstName">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:ContactName/_wcf:FirstName" />
				</xsl:attribute>
				<xsl:attribute name="MiddleName">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:ContactName/_wcf:MiddleName" />
				</xsl:attribute>
				<xsl:attribute name="LastName">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:ContactName/_wcf:LastName" />
				</xsl:attribute>
				<xsl:attribute name="AddressLine1">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Address/_wcf:AddressLine[1]" />
				</xsl:attribute>
				<xsl:attribute name="AddressLine2">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Address/_wcf:AddressLine[2]" />
				</xsl:attribute>
				<xsl:attribute name="AddressLine3">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Address/_wcf:AddressLine[3]" />
				</xsl:attribute>
				<xsl:attribute name="City">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Address/_wcf:City" />
				</xsl:attribute>
				<xsl:attribute name="State">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Address/_wcf:StateOrProvinceName" />
				</xsl:attribute>
				<xsl:attribute name="Country">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Address/_wcf:Country" />
				</xsl:attribute>
				<xsl:attribute name="ZipCode">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Address/_wcf:PostalCode" />
				</xsl:attribute>
				<xsl:attribute name="DayPhone">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Telephone1/_wcf:Value" />
				</xsl:attribute>
				<xsl:attribute name="EveningPhone">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Telephone2/_wcf:Value" />
				</xsl:attribute>
				<xsl:attribute name="EMailID">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:EmailAddress1/_wcf:Value" />
				</xsl:attribute>
				<xsl:attribute name="AlternateEmailID">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:EmailAddress2/_wcf:Value" />
				</xsl:attribute>
				<xsl:attribute name="DayFaxNo">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Fax1/_wcf:Value" />
				</xsl:attribute>
				<xsl:attribute name="EveningFaxNo">
					<xsl:value-of select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:Fax2/_wcf:Value" />
				</xsl:attribute>
			</PersonInfoBillTo>
			
			<PaymentMethods>
				<xsl:for-each select="$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction">
					<PaymentMethod>
						<xsl:if test="_ord:SequenceNumber">
							<xsl:attribute name="ChargeSequence">
								<xsl:value-of select="_ord:SequenceNumber" />
							</xsl:attribute>
						</xsl:if>
						<xsl:choose>
							<!-- Check -->
							<xsl:when test="_ord:PaymentMethod/_ord:PaymentMethodName='Check'">
								<xsl:attribute name="CheckNo">
									<xsl:value-of select="_ord:ProtocolData[@name='_token']" />
								</xsl:attribute>
								<xsl:attribute name="DisplayPaymentReference1">
									<xsl:value-of select="_ord:ProtocolData[@name='_display_value']" />
								</xsl:attribute>
								<xsl:attribute name="PaymentReference1">
									<xsl:value-of select="_ord:ProtocolData[@name='_token']" />
								</xsl:attribute>
								<xsl:attribute name="PaymentReference2">
									<xsl:value-of select="_ord:Amount" />
								</xsl:attribute>
								<xsl:attribute name="PaymentType">CHECK</xsl:attribute>
							</xsl:when>
							<!-- Credit card payment methods -->
							<xsl:when test="_ord:ProtocolData[@name='cc_brand']">
								<xsl:attribute name="CreditCardExpDate">
									<xsl:value-of select="_ord:ProtocolData[@name='expire_month']" /><xsl:value-of select="_ord:ProtocolData[@name='expire_year']" />
								</xsl:attribute>
								<xsl:attribute name="CreditCardNo">
									<xsl:value-of select="_ord:ProtocolData[@name='_token']" />
								</xsl:attribute>
								<xsl:attribute name="CreditCardType">
									<xsl:value-of select="_ord:ProtocolData[@name='cc_brand']" />
								</xsl:attribute>
								<xsl:attribute name="DisplayCreditCardNo">
									<xsl:value-of select="_ord:ProtocolData[@name='_display_value']" />
								</xsl:attribute>
								<xsl:attribute name="FirstName">
									<xsl:value-of select="_ord:BillingAddress/_wcf:ContactName/_wcf:FirstName" />
								</xsl:attribute>
								<xsl:attribute name="LastName">
									<xsl:value-of select="_ord:BillingAddress/_wcf:ContactName/_wcf:LastName" />
								</xsl:attribute>
								<xsl:attribute name="MiddleName">
									<xsl:value-of select="_ord:BillingAddress/_wcf:ContactName/_wcf:MiddleName" />
								</xsl:attribute>
								<xsl:attribute name="PaymentType">CREDIT_CARD</xsl:attribute>
							</xsl:when>
							<!-- Line of credit -->
							<xsl:when test="_ord:PaymentMethod/_ord:PaymentMethodName='LineOfCredit'">
								<xsl:attribute name="CustomerAccountNo">
									<xsl:value-of select="_ord:ProtocolData[@name='_token']" />
								</xsl:attribute>
								<xsl:attribute name="DisplayCustomerAccountNo">
									<xsl:value-of select="_ord:ProtocolData[@name='_display_value']" />
								</xsl:attribute>
								<xsl:attribute name="PaymentType">CUSTOMER_ACCOUNT</xsl:attribute>
							</xsl:when>
							<!-- Other payment methods -->
							<xsl:otherwise>
								<xsl:choose>
									<xsl:when
							test="_ord:ProtocolData[@name='_token']">
										<xsl:attribute name="DisplayPaymentReference1">
											<xsl:value-of select="_ord:ProtocolData[@name='_display_value']" />
										</xsl:attribute>
										<xsl:attribute name="PaymentReference1">
											<xsl:value-of select="_ord:ProtocolData[@name='_token']" />
										</xsl:attribute>
									</xsl:when>
									<xsl:otherwise>
										<xsl:attribute name="DisplayPaymentReference1">
											<xsl:value-of select="substring(_ord:UniqueID,string-length(_ord:UniqueID)-3,4)" />
										</xsl:attribute>
										<xsl:attribute name="PaymentReference1">
											<xsl:value-of select="_ord:UniqueID" />
										</xsl:attribute>										
									</xsl:otherwise>
								</xsl:choose>
								<!-- Assumption: SSFS payment type key == WC payment method name -->
								<xsl:attribute name="PaymentType">
									<xsl:value-of select="_ord:PaymentMethod/_ord:PaymentMethodName" />
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:attribute name="MaxChargeLimit">
							<xsl:value-of select="_ord:Amount" />
						</xsl:attribute>
						<xsl:attribute name="UnlimitedCharges">N</xsl:attribute>
						<PaymentDetailsList>
							<!-- Financial transactions associated with the payment instruction -->
							<xsl:for-each select="$order/_ord:OrderPaymentInfo/_ord:FinancialTransaction[_ord:PaymentInstructionID=current()/_ord:UniqueID]">
								<PaymentDetails>
									<xsl:choose>
										<xsl:when test="_ord:TransactionType='Approve' or _ord:TransactionType='0'">
											<xsl:attribute name="AuthAvs">
												<xsl:value-of select="_ord:AvsCode" />
											</xsl:attribute>
											<xsl:attribute name="AuthCode">
												<xsl:value-of select="_ord:ReferenceNumber" />
											</xsl:attribute>
											<xsl:attribute name="AuthReturnCode">
												<xsl:value-of select="_ord:ResponseCode" />
											</xsl:attribute>
											<!-- Assumption: auth time == last update -->
											<xsl:attribute name="AuthTime">
												<xsl:value-of select="_ord:LastUpdate" />
											</xsl:attribute>
											<xsl:choose>
												<xsl:when test="_ord:ExpirationTime">
													<xsl:attribute name="AuthorizationExpirationDate">
														<xsl:value-of select="_ord:ExpirationTime" />
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="AuthorizationExpirationDate">
														<xsl:text>2500-01-01T00:00:00Z</xsl:text>
													</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:choose>
												<xsl:when test="_ord:ReferenceNumber">
													<xsl:attribute name="AuthorizationID">
														<xsl:value-of select="_ord:ReferenceNumber" />
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="AuthorizationID">
														<xsl:value-of select="_ord:MerchantOrderNumber" />
													</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:attribute name="CVVAuthCode">
												<xsl:value-of select="_ord:TransactionExtensionData[@name='cc_cvc_response']" />
											</xsl:attribute>
											<xsl:attribute name="ChargeType">AUTHORIZATION</xsl:attribute>
										</xsl:when>
										<!-- Assumption: WC transaction type 'ApproveAndDeposit' is mapped to SSFS charge type 'CHARGE' -->
										<xsl:when test="_ord:TransactionType='Deposit' or _ord:TransactionType='1' or _ord:TransactionType='ApproveAndDeposit' or _ord:TransactionType='2'">
											<xsl:choose>
												<xsl:when test="_ord:ReferenceNumber">
													<xsl:attribute name="AuthorizationID">
														<xsl:value-of select="_ord:ReferenceNumber" />
													</xsl:attribute>
												</xsl:when>
												<xsl:otherwise>
													<xsl:attribute name="AuthorizationID">
														<xsl:value-of select="_ord:MerchantOrderNumber" />
													</xsl:attribute>
												</xsl:otherwise>
											</xsl:choose>
											<xsl:attribute name="ChargeType">CHARGE</xsl:attribute>
										</xsl:when>
									</xsl:choose>
									<xsl:choose>
										<xsl:when test="_ord:Status='Success' or _ord:Status='2'">
											<xsl:attribute name="ProcessedAmount">
												<xsl:value-of select="_ord:RequestAmount" />
											</xsl:attribute>
											<xsl:attribute name="RequestProcessed">Y</xsl:attribute>
										</xsl:when>
										<xsl:when test="_ord:Status='Failed' or _ord:Status='3'">
											<xsl:attribute name="ProcessedAmount">0</xsl:attribute>
											<xsl:attribute name="RequestProcessed">Y</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
											<xsl:attribute name="ProcessedAmount">0</xsl:attribute>
											<xsl:attribute name="RequestProcessed">N</xsl:attribute>
										</xsl:otherwise>
									</xsl:choose>
									<xsl:attribute name="RequestAmount">
										<xsl:value-of select="_ord:RequestAmount" />
									</xsl:attribute>
									<xsl:attribute name="TranRequestTime">
										<xsl:value-of select="_ord:RequestTime" />
									</xsl:attribute>
									<xsl:attribute name="TranReturnCode">
										<xsl:value-of select="_ord:ResponseCode" />
									</xsl:attribute>
								</PaymentDetails>
							</xsl:for-each>
						</PaymentDetailsList>
						<xsl:if test="_ord:BillingAddress/_wcf:ContactInfoIdentifier/_wcf:UniqueID!=$order/_ord:OrderPaymentInfo/_ord:PaymentInstruction[1]/_ord:BillingAddress/_wcf:ContactInfoIdentifier/_wcf:UniqueID">
							<PersonInfoBillTo>
								<xsl:attribute name="Title">
									<xsl:value-of select="_ord:BillingAddress/_wcf:ContactName/_wcf:PersonTitle" />
								</xsl:attribute>
								<xsl:attribute name="FirstName">
									<xsl:value-of select="_ord:BillingAddress/_wcf:ContactName/_wcf:FirstName" />
								</xsl:attribute>
								<xsl:attribute name="MiddleName">
									<xsl:value-of select="_ord:BillingAddress/_wcf:ContactName/_wcf:MiddleName" />
								</xsl:attribute>
								<xsl:attribute name="LastName">
									<xsl:value-of select="_ord:BillingAddress/_wcf:ContactName/_wcf:LastName" />
								</xsl:attribute>
								<xsl:attribute name="AddressLine1">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Address/_wcf:AddressLine[1]" />
								</xsl:attribute>
								<xsl:attribute name="AddressLine2">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Address/_wcf:AddressLine[2]" />
								</xsl:attribute>
								<xsl:attribute name="AddressLine3">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Address/_wcf:AddressLine[3]" />
								</xsl:attribute>
								<xsl:attribute name="City">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Address/_wcf:City" />
								</xsl:attribute>
								<xsl:attribute name="State">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Address/_wcf:StateOrProvinceName" />
								</xsl:attribute>
								<xsl:attribute name="Country">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Address/_wcf:Country" />
								</xsl:attribute>
								<xsl:attribute name="ZipCode">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Address/_wcf:PostalCode" />
								</xsl:attribute>
								<xsl:attribute name="DayPhone">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Telephone1/_wcf:Value" />
								</xsl:attribute>
								<xsl:attribute name="EveningPhone">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Telephone2/_wcf:Value" />
								</xsl:attribute>
								<xsl:attribute name="EMailID">
									<xsl:value-of select="_ord:BillingAddress/_wcf:EmailAddress1/_wcf:Value" />
								</xsl:attribute>
								<xsl:attribute name="AlternateEmailID">
									<xsl:value-of select="_ord:BillingAddress/_wcf:EmailAddress2/_wcf:Value" />
								</xsl:attribute>
								<xsl:attribute name="DayFaxNo">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Fax1/_wcf:Value" />
								</xsl:attribute>
								<xsl:attribute name="EveningFaxNo">
									<xsl:value-of select="_ord:BillingAddress/_wcf:Fax2/_wcf:Value" />
								</xsl:attribute>
							</PersonInfoBillTo>
						</xsl:if>
					</PaymentMethod>
				</xsl:for-each>
			</PaymentMethods>
			
		</Order>
		
	</xsl:template>
	
</xsl:stylesheet>
