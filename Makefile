RELEASE_ZIP=selenium-server.zip
SELENIUM_SERVER_JAR_URL=http://selenium-release.storage.googleapis.com/2.46/selenium-server-standalone-2.46.0.jar
CHROME_DRIVER_URL=http://chromedriver.storage.googleapis.com/2.15/chromedriver_win32.zip
# NB do not download the 64-bit version of the IE Driver. As IE is 32-bit
#     application (at least on Wnidows 2012R2). If you do, then sending keys to
#     the browser will be very slow...
IE_DRIVER_URL=http://selenium-release.storage.googleapis.com/2.46/IEDriverServer_Win32_2.46.0.zip

SELENIUM_SERVER_JAR=selenium-server.jar
CHROME_DRIVER_ZIP=chromedriver_win32.zip
CHROME_DRIVER_EXE=chromedriver.exe
IE_DRIVER_ZIP=IEDriverServer.zip
IE_DRIVER_EXE=IEDriverServer.exe

all: $(RELEASE_ZIP) Test.class

Test.class: $(SELENIUM_SERVER_JAR) Test.java
	javac -cp $(SELENIUM_SERVER_JAR) Test.java

$(RELEASE_ZIP): $(SELENIUM_SERVER_JAR) $(CHROME_DRIVER_EXE) $(IE_DRIVER_EXE)
	rm -f $@
	zip -9 $@ \
		selenium-server-hub.cmd \
		selenium-server-node.cmd \
		hubConfig.json \
		nodeConfig.json \
		$(SELENIUM_SERVER_JAR) \
		$(CHROME_DRIVER_EXE) \
		$(IE_DRIVER_EXE)

$(SELENIUM_SERVER_JAR):
	curl -o $@ $(SELENIUM_SERVER_JAR_URL)

$(CHROME_DRIVER_EXE):
	curl -O $(CHROME_DRIVER_URL)
	unzip -j $(CHROME_DRIVER_ZIP) $@

$(IE_DRIVER_EXE):
	curl -o $(IE_DRIVER_ZIP) $(IE_DRIVER_URL)
	unzip -j $(IE_DRIVER_ZIP) $@

clean:
	rm -f $(SELENIUM_SERVER_JAR)
	rm -f $(CHROME_DRIVER_ZIP) $(CHROME_DRIVER_EXE)
	rm -f $(IE_DRIVER_ZIP) $(IE_DRIVER_EXE)
	rm -f $(RELEASE_ZIP)
	rm -f *.class screenshot.png

run-hub: $(JAR) $(SELENIUM_SERVER_JAR)
	cmd /c selenium-server-hub.cmd

run-node: $(JAR) $(SELENIUM_SERVER_JAR) $(CHROME_DRIVER_EXE)
	cmd /c selenium-server-node.cmd
