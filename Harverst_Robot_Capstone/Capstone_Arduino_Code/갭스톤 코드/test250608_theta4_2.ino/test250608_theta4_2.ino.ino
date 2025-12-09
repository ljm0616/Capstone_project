#include <Adafruit_PWMServoDriver.h>
#include <Wire.h>

Adafruit_PWMServoDriver pwm = Adafruit_PWMServoDriver();

#define SERVOMIN  64   // 약 500 μs
#define SERVOMAX  512  // 약 2500 μs

bool firstCommandReceived = false;  // 최초 명령 여부 확인용

uint16_t angleToPulse(int angle) {
  angle = constrain(angle, 0, 180);
  return map(angle, 0, 180, SERVOMIN, SERVOMAX);
}

void setServoAngle(uint8_t channel, int angle) {
  pwm.setPWM(channel, 0, angleToPulse(angle));
}

void setup() {
  Serial.begin(9600);
  pwm.begin();
  pwm.setPWMFreq(50);  // 50Hz
  delay(10);

  Serial.println("READY");
}

void loop() {
  if (Serial.available()) {
    if (firstCommandReceived) {
      // 최초 명령 수신 후라면 무시
      Serial.println("[!] 명령 무시: 이미 최초 명령 처리됨");
      Serial.readStringUntil('\n');  // 입력 버퍼 비우기
      return;
    }

    String input = Serial.readStringUntil('\n');
    input.trim();

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

    Serial.print("→ 최초 받은 각도: ");
    for (int i = 0; i < 4; i++) {
      Serial.print(angles[i]);
      Serial.print(" ");
      setServoAngle(i, angles[i]);
    }
    Serial.println();

    firstCommandReceived = true;  // 플래그 설정
  }
}
