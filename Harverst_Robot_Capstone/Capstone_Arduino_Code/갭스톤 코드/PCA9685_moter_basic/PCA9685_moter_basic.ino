#include <Adafruit_PWMServoDriver.h>
#include <Wire.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

// MG996R에 맞는 펄스 폭 (대략 500~2500μs에 해당하는 값)
#define SERVOMIN  102   // 약 500μs
#define SERVOMAX  512   // 약 2500μs

// 각도를 펄스로 변환
uint16_t angleToPulse(int angle) {
  return map(angle, 0, 180, SERVOMIN, SERVOMAX);
}

// 특정 서보에 각도 지정
void setServoAngle(uint8_t channel, int angle) {
  pwm.setPWM(channel, 0, angleToPulse(angle));
}

void setup() {
  Serial.begin(9600);
  pwm.begin();
  pwm.setPWMFreq(50);  // MG996R도 50Hz로 동작

  delay(10);

  // 초기 각도 설정
  setServoAngle(0, 90);
  setServoAngle(1, 90);
  setServoAngle(2, 90);
  setServoAngle(3, 90);
}

void loop() {
  setServoAngle(2, 120); // 35열림 90~ 닫힘
  delay(5000);

  //setServoAngle(2, 120); //0,1 번 90도 기준 170 설정 시 직각 
  //delay(500);

  //setServoAngle(1, 110);//170도 기준 직각
  //delay(500);

  //setServoAngle(0, 100);
  //delay(500);

  // 모두 0도로 복귀
  //setServoAngle(0, 0);
  //setServoAngle(1, 0);
  //setServoAngle(2, 0);
  //setServoAngle(3, 0);
  //delay(2000);
}
