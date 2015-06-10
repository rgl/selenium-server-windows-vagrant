title Selenium Server Node
cd %USERPROFILE%\selenium-server
java -jar selenium-server.jar ^
  -Dwebdriver.chrome.driver=chromedriver.exe ^
  -Dwebdriver.ie.driver=IEDriverServer.exe ^
  -role node ^
  -nodeConfig nodeConfig.json
