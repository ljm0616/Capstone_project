#include <Adafruit_PWMServoDriver.h>
#include <Wire.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

// MG996R 서보용 PWM 범위 (실측 기반, 필요시 조정)
#define SERVOMIN  64   // 약 500 μs
#define SERVOMAX  512   // 약 2500 μs

// 각도를 PWM 펄스로 변환
uint16_t angleToPulse(int angle) {
  angle = constrain(angle, 0, 180);
  return map(angle, 0, 180, SERVOMIN, SERVOMAX);
}

// 특정 서보모터에 각도 설정 함수
void setServoAngle(uint8_t channel, int angle) {
  pwm.setPWM(channel, 0, angleToPulse(angle));
}

void setup() {
  Serial.begin(9600);
  pwm.begin();
  pwm.setPWMFreq(50);  // MG996R은 50Hz 사용
  delay(10);

  Serial.println("READY");

  // 초기 각도 설정
  setServoAngle(0, 60);  // theta2
  setServoAngle(1, 140);  // theta3
  setServoAngle(2, 140);  // theta4
  setServoAngle(3, 60);  // gripper
}

void loop() {
  if (Serial.available()) {
    String input = Serial.readStringUntil('\n');
    input.trim();  // 개행 제거

    if (input.length() == 0) return;

    char buf[32];
    input.toCharArray(buf, sizeof(buf));

    int angles[4] = {90, 90, 90, 90};  // 기본값
    int idx = 0;

    char* token = strtok(buf, ",");
    while (token != NULL && idx < 4) {
      angles[idx++] = atoi(token);
      token = strtok(NULL, ",");
    }

    // 디버깅 출력
    Serial.print("받은 각도: ");
    for (int i = 0; i < 4; i++) {
      Serial.print(angles[i]);
      Serial.print(" ");
    }
    Serial.println();

    // 각도 적용
    for (int i = 0; i < 4; i++) {
      setServoAngle(i, angles[i]);  // 채널 0~3
    }
  }
}
