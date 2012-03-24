/*
 MQTT send temp/light level receive LED colour 
 
 - connects to an MQTT server
 - publishes temp/light to the topic "outTopic"
 - subscribes to the topic "inTopic" and sets multiLED
 */

#define pinR 4 
#define pinG 3
#define pinB 2
#define TempPin A3
#define LightPin A1
#define DEBUG 0

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>
#include <stdlib.h>
#include <string.h>

// Update these with values suitable for your network.
byte mac[] = {
  0x98, 0xD6, 0xBB, 0xC6, 0x70, 0x3E}; 
//byte server[] = { 10, 1, 1, 4 };

char domain[] = "the-doctor.darkside-internet.bogus";

byte off[] = "OFF";
byte red[] = "RED";
byte white[] = "WHITE";
byte blue[] = "BLUE";
byte green[]= "GREEN";
byte yellow[]= "YELLOW";
byte magenta[]= "MAGENTA";
byte cyan[]= "CYAN";

float temp = 0;
float oldTemp = 0;
int light = 0;
int len;
char tempstr[7];
char MQTTbuffer[120];
int ledDigitalOne[] = {
  pinR, pinG, pinB};

const boolean ON = LOW; 
//Define on as LOW (this is because we use a common Anode RGB LED (common pin is connected to +5 volts)
const boolean OFF = HIGH;

//Define off as HIGH//Predefined Colours
const boolean RED[] = {
  ON, OFF, OFF};    
const boolean GREEN[] = {
  OFF, ON, OFF}; 
const boolean BLUE[] = {
  OFF, OFF, ON}; 
const boolean YELLOW[] = {
  ON, ON, OFF}; 
const boolean CYAN[] = {
  OFF, ON, ON}; 
const boolean MAGENTA[] = {
  ON, OFF, ON}; 
const boolean WHITE[] = {
  ON, ON, ON}; 
const boolean BLACK[] = {
  OFF, OFF, OFF}; 

//An Array that stores the predefined colours (allows us to later randomly display a colour)

const boolean* ColourS[] = {
  RED, GREEN, BLUE, YELLOW, CYAN, MAGENTA, WHITE, BLACK};



/* Sets an led to any colour
 led - a three element array defining the three colour pins 
 (led[0] = redPin, led[1] = greenPin, led[2] = bluePin)
 colour - a three element boolean array (colour[0] = red 
 value (LOW = on, HIGH = off), colour[1] = green value, colour[2] =blue value)*/

void setColour(int* led, boolean* colour) {
#if DEBUG
  Serial.print("setColour");
#endif 
  for(int i = 0; i < 3; i++){
#if DEBUG
    Serial.print(" LED:");
    Serial.print(led[i]);
    Serial.print(" Colour:");
    Serial.print(colour[i]);
#endif 
    digitalWrite(led[i], colour[i]); 
  } 
#if DEBUG
  Serial.println();
#endif
}

/* A version of setColour that allows for using const boolean colours*/

void setNamedColour(int* led, const boolean* colour){ 
  boolean tempColour[] = {
    colour[0], colour[1], colour[2]                }; 
  setColour(led, tempColour);
}


void callback(char* topic, byte* payload, unsigned int length) { 
  // handle message arrived
#if DEBUG 
  Serial.println("Callback"); 
  Serial.print("Topic:"); 
  Serial.println(topic); 
  Serial.print("Length:"); 
  Serial.println(length); 
  Serial.print("Payload:");
  Serial.write(payload,length); 
  Serial.println();
#endif

  if (!memcmp(payload,off,length)) setNamedColour(ledDigitalOne, BLACK);
  if (!memcmp(payload,red,length)) setNamedColour(ledDigitalOne, RED);  
  if (!memcmp(payload,blue,length)) setNamedColour(ledDigitalOne, BLUE); 
  if (!memcmp(payload,green,length)) setNamedColour(ledDigitalOne, GREEN);
  if (!memcmp(payload,yellow,length)) setNamedColour(ledDigitalOne, YELLOW); 
  if (!memcmp(payload,cyan,length)) setNamedColour(ledDigitalOne, CYAN);
  if (!memcmp(payload,magenta,length)) setNamedColour(ledDigitalOne, MAGENTA);
  if (!memcmp(payload,white,length)) setNamedColour(ledDigitalOne, WHITE);

}

PubSubClient client(domain, 1883, callback);

void setup() { 
  for(int i = 0; i < 3; i++){ 
    pinMode(ledDigitalOne[i], OUTPUT); 
  } 

  analogReference(EXTERNAL); 
#if DEBUG
  Serial.begin(9600);
#endif 
  Ethernet.begin(mac); 
  if (client.connect("arduinoClient")) { 
    client.publish("outTopic","hello world"); 
    client.subscribe("inTopic"); 
  } 
}

void loop()
{
  client.loop(); // check MQTT
  light = analogRead(LightPin);
  temp = analogRead(TempPin);
  temp *= 3.3; // ARef voltage 
  temp /= 1024;
  temp -= 0.5;
  temp *= 100;
  dtostrf(temp, 6, 2, tempstr);
  if (temp != oldTemp) {
    len = sprintf (MQTTbuffer, "Temp: %s , Light: %d ", tempstr, light);
#if DEBUG
    Serial.println(MQTTbuffer);
#endif
    client.publish("outTopic",MQTTbuffer);
    oldTemp = temp;
  }
  delay(1000);
}


