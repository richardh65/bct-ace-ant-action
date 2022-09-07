/**
 =================================================================
  Licensed Materials - Property of IBM

  WebSphere Commerce

  (C) Copyright IBM Corp. 2011 All Rights Reserved.

  US Government Users Restricted Rights - Use, duplication or
  disclosure restricted by GSA ADP Schedule Contract with
  IBM Corp.
 =================================================================
**/
package com.ibm.sterling.MB.integration;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.Properties;

import com.ibm.broker.javacompute.MbJavaComputeNode;
import com.ibm.broker.plugin.MbElement;
import com.ibm.broker.plugin.MbException;
import com.ibm.broker.plugin.MbMessage;
import com.ibm.broker.plugin.MbMessageAssembly;
import com.ibm.broker.plugin.MbOutputTerminal;

public class SSFSAPIsExport_sendAvailabilityChange_CSVFileOut extends
		MbJavaComputeNode {

	public void evaluate(MbMessageAssembly assembly) throws MbException {
		MbOutputTerminal out = getOutputTerminal("out");
	//	MbOutputTerminal alt = getOutputTerminal("alternate");

		MbMessage message = assembly.getMessage();

		// ----------------------------------------------------------
		// Add user code below
		MbElement XMLNSCElement = message.getRootElement().getLastChild();
		MbElement CSVFormatElement = XMLNSCElement.getFirstElementByPath("CSVFormat");
		String CSVFormatValue = (String) CSVFormatElement.getValue();
		
		try {
			
			Properties prop = new Properties();
			prop.load(getClass().getResourceAsStream("MediationModule.properties"));
			BufferedWriter fileout = new BufferedWriter(new FileWriter(prop.getProperty("CSVFilePath"), true)); 
			fileout.write(CSVFormatValue);
		    fileout.newLine();
		    fileout.close();
		} catch (IOException e) {
		}

		// End of user code
		// ----------------------------------------------------------

		// The following should only be changed
		// if not propagating message to the 'out' terminal

		out.propagate(assembly);
	}

}
