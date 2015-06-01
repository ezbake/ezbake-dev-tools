Local Accumulo
===

Overview
---
A significant part of this code was stolen from the MiniclusterRunner. The purpose is to bundle it into a jar
with dependencies and remove the required configuration file just to make running it a bit easier.  

Starts Accumulo Zookeeper on port 12181 and will shutdown if anyone connects to 4445

Usage
---
Start (takes the authorizations as a space-separated list): 
    `java -Xmx512m -jar local-accumulo-jar-with-dependencies.jar U C S USA &`
    
To connect with shell, use the following command: 
    `accumulo shell -zh localhost:12181 -zi miniInstance -u root`     

Kill:
    `telnet localhost 4445`  -OR-
    `kill -SIGTERM <original pid>`
   