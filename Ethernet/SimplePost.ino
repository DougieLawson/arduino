#include <SPI.h> // needed in Arduino 0019 or later
#include <Ethernet.h>
#include <Twitter.h>

// The includion of EthernetDNS is not needed in Arduino IDE 1.0 or later.
// Please uncomment below in Arduino IDE 0022 or earlier.
//#include <EthernetDNS.h>


// Ethernet Shield Settings
byte mac[] = {   
  0xf2, 0xb3, 0x2f, 0x1d, 0xb5, 0xc9};


// If you don't specify the IP address, DHCP is used(only in Arduino 1.0 or later).


// Your Token to Tweet (http basic auth - base64 encoded userid:password
// which is insecure but OK because this all runs on my tightly controlled LAN )

Twitter twitter("************************");  // <=== CHANGE ME ===

// Message to post
char msg[] = "Hello, World! I'm Arduino!";

void setup()
{
  delay(1000);
  //  Ethernet.begin(mac, ip);
  // or you can use DHCP for autoomatic IP address configuration.
  Ethernet.begin(mac);
  Serial.begin(9600);

  Serial.println("connecting ...");
  if (twitter.post(msg)) {
    // Specify &Serial to output received response to Serial.
    // If no output is required, you can just omit the argument, e.g.
    // int status = twitter.wait();
    int status = twitter.wait(&Serial);
    if (status == 200) {
      Serial.println("OK.");
    } 
    else {
      Serial.print("failed : code ");
      Serial.println(status);
    }
  } 
  else {
    Serial.println("connection failed.");
  }
}

void loop()
{
}


