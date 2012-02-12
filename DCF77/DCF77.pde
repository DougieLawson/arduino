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
 
 Amended: 07/02/2012 Dougie Lawson
 Added checksums and found the missing 58th bit.
 
 Amended: 12/02/2012 Dougie Lawson
 Changed date format (yyyy-mm-dd)
 Changed debugging code.
 */


#include <MsTimer2.h>
#define TICKER 1000
#define DCF77 A5
#define DEBUG 0

int DCF77value = 0; 
int DCF77data = 0; 
int DCF77start = 0; 
int DCF77tick = 0; 
boolean DCF77signal[60]; 
int DCF77count = 0; 
boolean DCF77timer = 0;


int dateParity = 0;
int hourParity = 0;
int minParity = 0;

char* DofW[] = { 
  "-Unk-", " Mon ", " Tue ", " Wed ", " Thu ", " Fri ", " Sat ", " Sun "};

char* tzone[] = {
  "     ", " CEST", " CET "};  

int dw = 0;
int tz = 0;

int day = 0;
int month = 0;
int yy2 = 0;

int hh = 0;
int mm = 0;
int ss = 0;

void DCF() {
  if (ss < 60) {
    displayTime();
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

void setup() {
  MsTimer2::set(TICKER,DCF);
  DCF77timer = 0;
  Serial.begin(9600);
  pinMode(13,OUTPUT);
}

void loop() {

  DCF77value = analogRead(DCF77);

  if (DCF77value >= 200) {

    if (DCF77data == 0) {

      DCF77start = millis();
#if DEBUG > 1  
      if (DCF77count < 10) Serial.print("0");
      Serial.print(DCF77count);
      Serial.print(":");
      Serial.print(DCF77start - DCF77tick);
      if (DCF77count == 15 || DCF77count == 30 || DCF77count == 45) Serial.println();
      else Serial.print("\t"); 
#endif
      if (DCF77start - DCF77tick > 1200) {

        // 58th bit was missing
        if (DCF77start - DCF77tick < 1800) 
          DCF77signal[58] = 1; 
        else DCF77signal[58] = 0;
        displayTime();

        if (DCF77signal[20] == 1) {

          tz = BCDtoDecimal(17, 2);
          mm = BCDtoDecimal(21, 7);   
          hh = BCDtoDecimal(29, 6);
          day = BCDtoDecimal(36, 6);          
          dw = BCDtoDecimal(42, 3);
          month = BCDtoDecimal(45, 5);
          yy2 = BCDtoDecimal(50, 8);

          dateParity = 0;
          for (int i = 36; i < 59; i++) {
            dateParity ^= DCF77signal[i]; 
          }

          hourParity = 0;
          for (int i = 29; i < 36; i++) {
            hourParity ^= DCF77signal[i];
          }

          minParity = 0;
          for (int i = 21; i < 29; i++) {
            minParity ^= DCF77signal[i];
          }
#if DEBUG >= 1 
          Serial.print("DCF77signal: ");
          for (int i = 15; i < 21; i++) {
            Serial.print(DCF77signal[i],BIN);
          }
          Serial.print(" 15:20(F) ");
          for (int i = 21; i < 29; i++) {
            Serial.print(DCF77signal[i],BIN);
          }
          Serial.print(" 21:28(Mi) ");
          Serial.print(minParity);
          Serial.print(" MP ");
          for (int i = 29; i < 36; i++) {
            Serial.print(DCF77signal[i],BIN);
          }
          Serial.print(" 29:35(H) ");
          Serial.print(hourParity);
          Serial.print(" HP ");
          for (int i = 36; i < 42; i++) {
            Serial.print(DCF77signal[i],BIN);
          }

          Serial.print(" 36:41(D) ");
          for (int i = 42; i < 45; i++) {
            Serial.print(DCF77signal[i],BIN);
          }
          Serial.print(" 42:44(dw) ");
          for (int i = 45; i < 50; i++) {
            Serial.print(DCF77signal[i],BIN);
          }
          Serial.print(" 45:49(Mo) ");
          for (int i = 50; i < 59; i++) {
            Serial.print(DCF77signal[i],BIN);
          }
          Serial.print(" 50:58(Y) ");
          Serial.print(dateParity);
          Serial.println(" DP");
#endif

        } 
        else {
          mm++;
          if (mm > 59) {
            hh++; 
            mm =0;
          }
        }

        ss = 0;            // reset seconds
        DCF77count = 0;    // reset bit array counter
        if (!DCF77timer) {
          MsTimer2::start(); // start the seconds timer.
          DCF77timer = 1;
        }

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

  if (!dateParity && !hourParity && !minParity) {
    Serial.print("DCF77:\t");
  } 
  else {
    Serial.print("DCF77: p/e: D:");
    Serial.print(dateParity);
    Serial.print(" H:");
    Serial.print(hourParity);
    Serial.print(" M:");
    Serial.print(minParity);
    Serial.print("\t");
    MsTimer2::stop();
    DCF77timer = 0;
  }

  // Day of the week
  Serial.print(DofW[dw]);
  Serial.print("\t");

  // 20yy-mm-dd
  Serial.print("20");             // Change me in 2100 :-)
  if (yy2 < 10) Serial.print("0"); // will never get run ...
  Serial.print(yy2);
  Serial.print("-");
  if (month < 10) Serial.print("0");
  Serial.print(month);
  Serial.print("-");
  if (day < 10) Serial.print("0");
  Serial.print(day);
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
  Serial.print(tzone[tz]);
  Serial.println();
  ss++;
}
