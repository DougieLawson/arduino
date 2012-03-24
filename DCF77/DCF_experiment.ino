/*

 Experiment
 
 */

#include <SPI.h>
#include <Ethernet.h>
#include <PubSubClient.h>
#include <stdlib.h>
#include <string.h>

// Update these with values suitable for your network.
byte mac[] = {
  0x98, 0xD6, 0xBB, 0xC6, 0x70, 0x3E}; 
//byte server[] = { 10, 1, 1, 4 };
char domain[] = "test.mosquitto.org";
//char domain[] = "the-doctor.darkside-internet.bogus";

void callback(char* topic, byte* payload, unsigned int length) {
}

PubSubClient client(domain, 1883, callback);

#define DCF77 A5
#define DEBUG 0

int DCF77value = 0; 
int DCF77data = 0; 
int DCF77start = 0; 
int DCF77tick = 0; 
boolean DCF77signal[62]; 
int DCF77count = 0; 
int i;
String MQTTbuffer;
char MQTTtext[128];
int bcd;
char bcdString[3];
char* DofW[] = { 
  "   ", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"};
char* TZon[] = {
  "UNK ", "CEST", "CET ","UNK "};

#if DEBUG > 1
void debug(char* label) {
  Serial.print(label);
  Serial.print("\t");
  Serial.print(DCF77value);
  Serial.print("\t");
  Serial.print(DCF77data);
  Serial.print("\t");
  Serial.print(DCF77start-DCF77tick);
  Serial.print("\t");
  Serial.print(DCF77count);
  Serial.print("\t");
  Serial.println(i);  
}
#endif

void displayTime() {

#if DEBUG
  Serial.print("TZ:");
  Serial.print(BCDtoDecimal(17,2));
  Serial.print("\tmm:"); 
  Serial.print(BCDtoDecimal(21,7));
  Serial.print("\thh:");
  Serial.print(BCDtoDecimal(29,6));
  Serial.print("\tday:");
  Serial.print(BCDtoDecimal(36,6));
  Serial.print("\tdw:");
  Serial.print(BCDtoDecimal(42,3));
  Serial.print("\tmth:");
  Serial.print(BCDtoDecimal(45,5));
  Serial.print("\tyy:");
  Serial.print(BCDtoDecimal(50,8));
  Serial.print("\tParity:");
  Serial.println(BCDtoDecimal(60,3));
#endif

  MQTTbuffer ="TZ:";
  bcd = BCDtoDecimal(17,2);
  MQTTbuffer+=TZon[bcd];
  MQTTbuffer +=" hh:mm:"; 
  bcd = BCDtoDecimal(29,6);
  sprintf(bcdString,"%02d",bcd);
  MQTTbuffer +=bcdString;
  MQTTbuffer +=":";
  bcd = BCDtoDecimal(21,7);
  sprintf(bcdString,"%02d",bcd);
  MQTTbuffer +=bcdString;
  MQTTbuffer +=" dd/mm/yy:";
  bcd = BCDtoDecimal(36,6);
  sprintf(bcdString,"%02d",bcd);
  MQTTbuffer +=bcdString;
  MQTTbuffer +="/";
  bcd = BCDtoDecimal(45,5);
  sprintf(bcdString,"%02d",bcd);
  MQTTbuffer +=bcdString;
  MQTTbuffer +="/";
  bcd = BCDtoDecimal(50,8);
  sprintf(bcdString,"%02d",bcd);
  MQTTbuffer +=bcdString;
  MQTTbuffer +=" dw:";
  bcd = BCDtoDecimal(42,3);
  MQTTbuffer += DofW[bcd];

#if DEBUG
  Serial.print("** ");
#endif

  MQTTbuffer += " **";
  for (i = 16; i < 63; i++) {

#if DEBUG
    Serial.print(DCF77signal[i]);
#endif

    MQTTbuffer += DCF77signal[i];
  }

#if DEBUG
  Serial.println(" **");
#endif

  MQTTbuffer += "** Parity:";
  MQTTbuffer +=BCDtoDecimal(60,3);

  MQTTbuffer.toCharArray(MQTTtext,128);

#if DEBUG
  for (int i = 0; i < 128; i ++) {
    Serial.print(MQTTtext[i],HEX);
  }
  Serial.println(" **");
#endif

  if (client.connect("arduinoClient")) {
    client.publish("arduino/DCF77",MQTTtext);
    client.disconnect();
  }

}

int BCDtoDecimal(int startBit, int count) {
  int b = 1;
  int result = 0;
  for (int i = 0; i < count; i++) {
    int offset = i + startBit;
    result += DCF77signal[offset] * b;
    b *= 2;
    if (b == 16) b = 10;
  }

  return result;
}

void setup()
{ 
  analogReference(EXTERNAL);

#if DEBUG
  Serial.begin(9600);
#endif

  DCF77signal[59] = 0; // bit 59 always zero
  Ethernet.begin(mac);
  //if (client.connect("arduinoClient")) {
  //  client.publish("arduino/DCF77","Hello World!");
  //  client.disconnect();
  //}
}

void loop() {
  DCF77value = analogRead(DCF77);
  if (DCF77value >= 200) {
    if (DCF77data == 0) {
      DCF77start = millis();

#if DEBUG > 3 
      debug("   data==0");
#endif

      if (DCF77start - DCF77tick > 1200) {

#if DEBUG > 2
        debug("st-ti>1200");
#endif

        DCF77count=0; 
        // 58th bit was missing
        if (DCF77start - DCF77tick < 1800) {

#if DEBUG > 2
          debug("st-ti<1800");
#endif

          DCF77signal[58] = 1; 
        }
        else {

#if DEBUG > 2
          debug("[58]else:0");
#endif

          DCF77signal[58] = 0;
        }  

        if (DCF77signal[20] == 1) {

#if DEBUG > 2
          debug("  sig[20]");
#endif

          DCF77signal[60] = 0;
          for (int i = 36; i < 59; i++) {
            DCF77signal[60] ^= DCF77signal[i]; 
          }
          DCF77signal[61] = 0;
          for (int i = 29; i < 36; i++) {
            DCF77signal[61] ^= DCF77signal[i];
          }
          DCF77signal[62] = 0;
          for (int i = 21; i < 29; i++) {
            DCF77signal[62] ^= DCF77signal[i];
          }
        }
        else {
          DCF77signal[60] = 1;
          DCF77signal[61] = 1;
          DCF77signal[62] = 1;
        }

        /*bcd = BCDtoDecimal(60,3); 
         if (bcd ==0)*/        displayTime();        

      }
      else {

#if DEBUG > 2
        debug("     else:1");
#endif

        if (DCF77start - DCF77tick > 850) {

#if DEBUG > 1
          debug("st-ti>850:0");
#endif

          DCF77signal[DCF77count] = 0;
        }
        else {

#if DEBUG > 2
          debug("     else:2");
#endif

          if (DCF77start - DCF77tick < 850) {

#if DEBUG > 2
            debug("st-ti<850:2");
#endif

            if (DCF77start - DCF77tick > 650) {

#if DEBUG > 1 
              debug("st-ti>650:1");
#endif

              DCF77signal[DCF77count] = 1;
            }
          }
        }
        if (DCF77start - DCF77tick > 650) {

#if DEBUG > 2
          debug("st-ti>650:2");
#endif

          DCF77count++;          
        }
      }
    }

#if DEBUG > 3 
    debug("   millis");
#endif

    DCF77data = 1;
    DCF77tick = millis();
  }
  else {
    DCF77data = 0;
  }
}

