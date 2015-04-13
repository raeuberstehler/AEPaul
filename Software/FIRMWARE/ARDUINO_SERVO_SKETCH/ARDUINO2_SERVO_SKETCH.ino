
#include <Servo.h>
Servo servoMain;
int readPin = 8;

void setup()
{
   servoMain.attach(9); // servo on digital pin 9
   pinMode(readPin, INPUT); // set laserout from second Arduino as INPUT
   
}

void loop()
{
  if (readPin = HIGH) {
    servoMain.write(120);  // Turn Servo Left to 45 degrees
  }
  else {
    seroMain.write(0);
}
