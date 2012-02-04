/*
  */
  
const int LEDCount = 8;    // the number of LEDs in the bar graph
int LEDPins[] = { 2, 3, 4, 5, 6, 7, 8, 9 };   // an array of pin numbers to which LEDs are attached


void setup() {
  // loop over the pin array and set them all to output:
  for (int thisLED = 0; thisLED < LEDCount; thisLED++) {
    pinMode(LEDPins[thisLED], OUTPUT); 
  }
}

void loop() {
 for (int i = 0; i < 256; i++) {
//   int val = bin2BCD(i);
 int val = i;
   lightLEDs(val);
   delay(500);
   turnOffLEDs();
 }
}

int bin2BCD(int binval) {
 return ( ( ( (binval/10) << 4) &0xF0) | ((binval % 10) &0x0F) );  
}

void turnOffLEDs(){
  for (int thisLED = 0; thisLED < LEDCount; thisLED++) {
    digitalWrite(LEDPins[thisLED],LOW);
  }
}

void lightLEDs(int value) {
  int div = 256;
  for (int thisLED = LEDCount; thisLED >= 0; thisLED--) {    
    if (value >= div) {
      value -= div;
      digitalWrite(LEDPins[thisLED],HIGH);
    } else {
      digitalWrite(LEDPins[thisLED],LOW);
    }
    div /= 2;
  } 
}
