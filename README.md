This is [Selenium Server](http://www.seleniumhq.org/) for Windows packaged in a easy to use Vagrant project.

This setups a Vagrant environment with:

* Windows.
* Selenium Server.
* Chrome.
* Firefox.
* Internet Explorer.
* [Boxstarter](http://boxstarter.org/) to install [Chocolatey](http://chocolatey.org/) packages.


# Notes

* Selenium Server is automatically run on a auto-logon session. As such, you cannot logoff from it.
  * I had to do it this way because [I failed to run Selenium Server as a Windows Service](https://github.com/rgl/selenium-server-windows-service).
* Selenium Server runs in the `selenium-server` account, a non-Administrator account.


# Build

You need to pre-install:

* [Sane shell environment on Windows](http://blog.ruilopes.com/sane-shell-environment-on-windows.html).
* [windows_2012_r2 Vagrant base box](http://blog.ruilopes.com/using-packer-vagrant-and-boxstarter-to-create-windows-environments.html).
* unzip (install with `mingw-get install msys-unzip`).
* [Curl](http://curl.haxx.se/download.html) for [Windows](http://www.paehl.com/open_source/?CURL_7.42.1).

To build run:

    build.sh

If everything goes as expected, you should now have a working Selenium Server inside a Vagrant environment.

You can now point your `RemoteWebDriver` client to http://localhost:4444/wd/hub. See the [Test.java](Test.java) file for an example.

To shut it down run:

    vagrant halt

To start it again run:

    vagrant up

And thats it! Feel free to poke around and modify any of the files to fit your use-case. Let me known how it works for you!
