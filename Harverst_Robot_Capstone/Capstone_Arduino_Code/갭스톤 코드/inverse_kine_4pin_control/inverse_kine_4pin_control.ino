#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#define SERVO2 0
#define SERVO3 1
#define SERVO4 2

int degMin = 0;
int degMax = 180;
int pulseMin = 150;  // 0도
int pulseMax = 600;  // 180도

void setup() {
  Serial.begin(9600);
  pwm.begin();
  pwm.setPWMFreq(50);
  delay(10);
  Serial.println("준비 완료");
}

void loop() {
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    int d1 = input.substring(0, input.indexOf(',')).toInt();
    int d2 = input.substring(input.indexOf(',') + 1, input.lastIndexOf(',')).toInt();
    int d3 = input.substring(input.lastIndexOf(',') + 1).toInt();

    setServo(SERVO2, d1);
    setServo(SERVO3, d2);
    setServo(SERVO4, d3);

    Serial.println("동작 완료");
  }
}

void setServo(uint8_t ch, int degree) {
  degree = constrain(degree, degMin, degMax);
  int pulse = map(degree, degMin, degMax, pulseMin, pulseMax);
  pwm.setPWM(ch, 0, pulse);
}