/*
Author : J.M. Lietaer, Belgium, Europe - jmlietaer (at) gmail (dot) com
 Date written : February 22, 2010
 Program : Proof of concept - DCF77 - Read data from a DCF77 module and display date/time
 System : Arduino Duemilanove ATMEGA328
 Software : Arduino IDE 0018 on Apple Mac OS X 10.6.2
 Tested with : Pollin DCF1 - article number 810054
 Information : Please feel free to comment and suggest improvements
 Released under : Creative Commons Attribution - Share Alike 2.0 Belgium License
 
 Amended: 04/02/2012 Dougie Lawson
 Added a one second timer.
 Changed the format of the output.
 Cleaned up the day of the week (didn't like that case/select).
 
 Amended: 05/02/2012 Dougie Lawson
 Removed the IF statement for the timezone.
 Timezone is now done by indexing an array.
 */


#include <MsTimer2.h>
#define TICKER 1000
#define DCF77 A1

int DCF77value = 0; 
int DCF77data = 0; 
int DCF77start = 0; 
int DCF77tick = 0; 
int DCF77signal[60]; 
int DCF77count = 0; 
int DCF77dw = 0;
int DCF77tz = 0;

char* DofW[] = { 
  "-Unk-", " Mon ", " Tue ", " Wed ", " Thu ", " Fri ", " Sat ", " Sun "};

char* tzone[] = {
  "     ", " CEST", " CET "};  

int day = 0;
int month = 0;
int yy2 = 0;

int hh = 0;
int mm = 0;
int ss = 0;

void DCF() {
  if (ss < 59) {
    ss++;
    displayTime();
  }
}

void setup() {
  MsTimer2::set(TICKER,DCF);
  Serial.begin(9600);
  pinMode(13,OUTPUT);
}

void loop() {

  DCF77value = analogRead(DCF77);

  if (DCF77value >= 200) {

    if (DCF77data == 0) {

      DCF77start = millis();

      if (DCF77start - DCF77tick > 1200) {

        DCF77dw = DCF77signal[42] * 1 + DCF77signal[43] * 2 + DCF77signal[44] * 4;
        day = (DCF77signal[36] * 1 + DCF77signal[37] * 2 + DCF77signal[38] * 4 + DCF77signal[39] * 8 + DCF77signal[40] * 10 + DCF77signal[41] * 20);
        month = (DCF77signal[45] * 1 + DCF77signal[46] * 2 + DCF77signal[47] * 4 + DCF77signal[48] * 8 + DCF77signal[49] * 10);
        yy2 = (DCF77signal[50] * 1 + DCF77signal[51] * 2 + DCF77signal[52] * 4 + DCF77signal[53] * 8 + DCF77signal[54] * 10 + DCF77signal[55] * 20 + DCF77signal[56] * 40 + DCF77signal[57] * 80);
        hh = (DCF77signal[29] * 1 + DCF77signal[30] * 2 + DCF77signal[31] * 4 + DCF77signal[32] * 8 + DCF77signal[33] * 10 + DCF77signal[34] * 20);
        mm = (DCF77signal[21] * 1 + DCF77signal[22] * 2 + DCF77signal[23] * 4 + DCF77signal[24] * 8 + DCF77signal[25] * 10 + DCF77signal[26] * 20 + DCF77signal[27] * 40);
        DCF77tz = (DCF77signal[17] * 1 + DCF77signal[18] * 2);

        ss = 0;            // reset seconds
        DCF77count = 0;    // reset bit array counter
        MsTimer2::start(); // start the seconds timer.

        displayTime();

      }
      else {

        if (DCF77start - DCF77tick > 850) {
          DCF77signal[DCF77count] = 0;
          digitalWrite(13,LOW);

        }
        else {

          if (DCF77start - DCF77tick < 850) {

            if (DCF77start - DCF77tick > 650) {
              DCF77signal[DCF77count] = 1;
              digitalWrite(13,HIGH);

            }

          }

        }

        if (DCF77start - DCF77tick > 650) {
          DCF77count = DCF77count + 1;          
        }

      }

    }

    DCF77data = 1;
    DCF77tick = millis();

  }
  else {

    DCF77data = 0;
  }

}

void displayTime() {

  Serial.print("DCF77:\t");

  // Day of the week
  Serial.print(DofW[DCF77dw]);
  Serial.print("\t");

  // dd/mm/20yy
  if (day < 10) Serial.print("0");
  Serial.print(day);
  Serial.print("/");
  if (month < 10) Serial.print("0");
  Serial.print(month);
  Serial.print("/20");             // Change me in 2100 :-)
  if (yy2 < 10) Serial.print("0"); // will never get run ...
  Serial.print(yy2);
  Serial.print("\t");

  // hh:mm:ss
  if (hh < 10) Serial.print("0");
  Serial.print(hh);
  Serial.print(":");
  if (mm < 10) Serial.print("0");
  Serial.print(mm);
  Serial.print(":");
  if (ss < 10) Serial.print("0");
  Serial.print(ss);
  Serial.print("\t");

  // timezone
  Serial.println(tzone[DCF77tz]);

}

