/* 
  Light an LED display 
    five segment high digit only has segments b&c and +/-
    eight segment low digit has segments a,b,c,d,e,f & g.
    both digits have decimal points.
*/

// Seven segment LEDs Using 13 pins on the Arduino.

int ledDigitOne[] = {0,1,2,3,4};
int ledDigitTwo[] = {5,6,7,8,9,10,11,12};

const boolean ON = HIGH;
//Define on as HIGH (this is because we use a common cathode RGB LED 
//(common pins are connected to gnd)
const boolean OFF = LOW;
                
//Define off as HIGH

//Predefined Numbers for digit1
const boolean ALL_1[] = {ON, ON, ON, ON, ON};
const boolean PLUS[] = {OFF,ON,OFF,OFF,OFF};
const boolean PLUS1[] = {OFF,ON,ON,ON,OFF};
const boolean MINUS[] = {ON,OFF,OFF,OFF,OFF};
const boolean MINUS1[] = {ON,OFF,ON,ON,OFF};

// with the decimal point lit
const boolean PLUSDOT[] = {OFF,ON,OFF,OFF,ON};
const boolean PLUS1DOT[] = {OFF,ON,ON,ON,ON};
const boolean MINUSDOT[] = {ON,OFF,OFF,OFF,ON};
const boolean MINUS1DOT[] = {ON,OFF,ON,ON,ON};
const boolean OFF_1[] = {OFF, OFF, OFF, OFF, OFF};

//Predefined Number for digit2
// See http://en.wikipedia.org/wiki/Seven-segment_display#Numbers_to_7-segment-code
const boolean ZERO[] = {ON,ON,ON,ON,ON,ON,OFF,OFF};
const boolean ONE[] = {OFF,ON,ON,OFF,OFF,OFF,OFF,OFF};
const boolean TWO[] = {ON,ON,OFF,ON,ON,OFF,ON,OFF};
const boolean THREE[] = {ON,ON,ON,ON,OFF,OFF,ON,OFF};
const boolean FOUR[] = {OFF,ON,ON,OFF,OFF,ON,ON,OFF};
const boolean FIVE[] = {ON,OFF,ON,ON,OFF,ON,ON,OFF};
const boolean SIX[] = {ON,OFF,ON,ON,ON,ON,ON,OFF};
const boolean SEVEN[] = {ON,ON,ON,OFF,OFF,OFF,OFF,OFF};
const boolean EIGHT[] = {ON,ON,ON,ON,ON,ON,ON,OFF};
const boolean NINE[] = {ON,ON,ON,ON,OFF,ON,ON,OFF};

// with the decimal point lit
const boolean ZERODOT[] = {ON,ON,ON,ON,ON,ON,OFF,ON};
const boolean ONEDOT[] = {OFF,ON,ON,OFF,OFF,OFF,OFF,ON};
const boolean TWODOT[] = {ON,ON,OFF,ON,ON,OFF,ON,ON};
const boolean THREEDOT[] = {ON,ON,ON,ON,OFF,OFF,ON,ON};
const boolean FOURDOT[] = {OFF,ON,ON,OFF,OFF,ON,ON,ON};
const boolean FIVEDOT[] = {ON,OFF,ON,ON,OFF,ON,ON,ON};
const boolean SIXDOT[] = {ON,OFF,ON,ON,ON,ON,ON,ON};
const boolean SEVENDOT[] = {ON,ON,ON,OFF,OFF,OFF,OFF,ON};
// EIGHTDOT == ALL_2
const boolean EIGHTDOT[] = {ON,ON,ON,ON,ON,ON,ON,ON};
const boolean NINEDOT[] = {ON,ON,ON,ON,OFF,ON,ON,ON};

const boolean OFF_2[] = {OFF,OFF,OFF,OFF,OFF,OFF,OFF,OFF};

//An Array that stores the predefined numbers 
//(allows us to later randomly display a number)

const boolean* NumberS_1[] = {MINUS1, MINUS, PLUS, PLUS1};
const boolean* NumberS_2[] = {ZERO,ONE,TWO,THREE,FOUR,FIVE,SIX,SEVEN,EIGHT,NINE};
//--- eof RGBL - RGB Digital Preamble

void setup(){
  for(int i = 0; i < 5; i++){
    pinMode(ledDigitOne[i], OUTPUT);
    //Set the five LED pins as outputs
  }
  for(int i = 0; i < 8; i++){
    pinMode(ledDigitTwo[i], OUTPUT);
    //Set the eight LED pins as outputs
  }
}

void loop(){
     setNamed_1(ledDigitOne,OFF_1);
     for (int i1 = 0;i1 < 4;i1++) {
       setNamed_1(ledDigitOne,NumberS_1[i1]);
       if (i1 == 0){
         // Minus1 count down from -19 to -10
         for (int i2 = 9; i2 >-1; i2--){
           setNamed_2(ledDigitTwo,NumberS_2[i2]);
           delay(1000);
         }
       }
       if (i1 == 1){
         // count down from -9 to -1
         for (int i2 = 9; i2 >0; i2--){
           setNamed_2(ledDigitTwo,NumberS_2[i2]);
           delay(1000);
         }         
       } 
       if (i1 > 1) {
         // count up from 0 to 9 and up from 10 to 19
         for (int i2 = 0; i2 <10; i2++){
           setNamed_2(ledDigitTwo,NumberS_2[i2]);
           delay(1000);
         }
       }
     }
}

void setNumber_1(int* led, boolean* number)
{
 for(int i = 0; i < 5; i++){
   digitalWrite(led[i], number[i]);
 }
}

void setNumber_2(int* led, boolean* number)
{
 for(int i = 0; i < 8; i++){
   digitalWrite(led[i], number[i]);
 }
}

/* A version of setNumber that allows for using const boolean numbers*/

void setNamed_1(int* led, const boolean* number){
  boolean tempLED_1[] = {number[0], number[1], number[2], number[3], number[4]};
  setNumber_1(led, tempLED_1);
}

void setNamed_2(int* led, const boolean* number){
  boolean tempLED_2[] = {number[0], number[1], number[2], number[3], 
                         number[4], number[5], number[6], number[7]};
  setNumber_2(led, tempLED_2);
}
