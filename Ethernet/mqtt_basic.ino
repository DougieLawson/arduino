/*
 Basic MQTT example 
 
 - connects to an MQTT server
 - publishes "hello world" to the topic "outTopic"
 - subscribes to the topic "inTopic"
 */

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>
#include <stdlib.h>
#include <string.h>

// Update these with values suitable for your network.
byte mac[] = {
  0xf2, 0xb3, 0x2f, 0x1d, 0xb5, 0xc9};
byte server[] = { 
  10, 1, 1, 4 };

float temp = 0;
float oldTemp = 0;
int light = 0;
int len;
char tempstr[7];
char MQTTbuffer[120];

#define TempPin A3
#define LightPin A1

void callback(char* topic, byte* payload, int length) {
  // handle message arrived
  Serial.println("Callback");
  Serial.print("Topic:");
  Serial.println(topic);
  Serial.print("Length:");
  Serial.println(length);
  Serial.print("Payload:");
  Serial.write(payload,length);
  Serial.println();
}

PubSubClient client(server, 1883, callback);

void setup()
{
  Serial.begin(9600);
  Ethernet.begin(mac);
  if (client.connect("arduinoClient")) {
    client.publish("outTopic","hello world");
    client.subscribe("inTopic");
  }
}

void loop()
{
  client.loop();
  light = analogRead(LightPin);
  temp = analogRead(TempPin);
  temp *= 5;
  temp /= 1023;
  temp -= 0.5;
  temp *= 100;
  dtostrf(temp, 6, 2, tempstr);
  if (temp != oldTemp) {
    len = sprintf (MQTTbuffer, "Temp: %s , Light: %d ", tempstr, light);
    Serial.println(MQTTbuffer);
    client.publish("outTopic",MQTTbuffer);
    oldTemp = temp;
  }
  delay(10000);


  //  Serial.print("Light:");
  //  Serial.println(light);
  //  Serial.print("Temp:");
  //  Serial.println(temp);
}



