mqsicreateconfigurableservice TESTNODE_eugene -c TCPIPServer -o TCPIPTutorialServerCF -n Port -v 7778
mqsicreateconfigurableservice TESTNODE_eugene -c TCPIPClient -o TCPIPTutorialClientCF -n Port,Hostname,MinimumConnections,MaximumConnections -v 7778,localhost,5,10 
