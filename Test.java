import org.openqa.selenium.By;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;

import java.io.FileOutputStream;
import java.net.URL;

public class Test {
    public static void main(String[] args) throws Exception {
        if (args.length != 1) {
            System.err.println("Usage: <webdriver port>");
            System.exit(1);
            return;
        }

        RemoteWebDriver driver = new RemoteWebDriver(new URL("http://localhost:" + args[0] + "/wd/hub"), DesiredCapabilities.chrome());
        try {
            // Print details.
            System.out.printf("WebDriver Capabilities: %s\n", driver.getCapabilities().toString());

            // Open Google.
            driver.navigate().to("http://www.google.com");

            // Find the text input element by its name.
            WebElement query = driver.findElement(By.name("q"));

            // Enter something to search for.
            query.sendKeys("Hello World");

            // Now submit the form. WebDriver will find the form for us from the element.
            query.submit();

            // Print page title.
            System.out.printf("Page title is: %s\n", driver.getTitle());

            // Take screenshot.
            byte[] png = driver.getScreenshotAs(OutputType.BYTES);
            FileOutputStream stream = new FileOutputStream("screenshot.png");
            stream.write(png);
            stream.close();
        } finally {
            driver.close();
        }
    }
}
