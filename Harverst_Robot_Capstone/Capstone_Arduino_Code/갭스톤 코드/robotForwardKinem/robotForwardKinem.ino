#include <Wire.h>
#include <Adafruit_PWMServoDriver.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#define SERVO2 0  // shoulder
#define SERVO3 1  // elbow
#define SERVO4 2  // wrist

int degMin = 0;
int degMax = 180;

int servoMin = 150;  // 0도
int servoMax = 600;  // 180도

void setup() {
  Serial.begin(9600);
  pwm.begin();
  pwm.setPWMFreq(50);  // 50Hz for servo

  Serial.println("준비 완료");
}

void loop() {
  if (Serial.available()) {
    String data = Serial.readStringUntil('\n');
    int theta2 = data.substring(0, data.indexOf(',')).toInt();
    int theta3 = data.substring(data.indexOf(',') + 1, data.lastIndexOf(',')).toInt();
    int theta4 = data.substring(data.lastIndexOf(',') + 1).toInt();

    setServoDeg(SERVO2, theta2);
    setServoDeg(SERVO3, theta3);
    setServoDeg(SERVO4, theta4);

    Serial.println("동작 완료");
  }
}

void setServoDeg(uint8_t channel, int degree) {
  degree = constrain(degree, degMin, degMax);
  int pulse = map(degree, degMin, degMax, servoMin, servoMax);
  pwm.setPWM(channel, 0, pulse);
}
