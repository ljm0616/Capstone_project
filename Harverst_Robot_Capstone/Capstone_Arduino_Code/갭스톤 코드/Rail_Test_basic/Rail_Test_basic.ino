const int stepPin = 3;
const int dirPin = 2;
const int enablePin = 4; 

void setup() {
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(enablePin, OUTPUT);

  digitalWrite(enablePin, LOW);
  digitalWrite(dirPin, LOW); // 회전 방향 설정
}

void loop() {
  digitalWrite(stepPin, HIGH);
  delayMicroseconds(280); // 펄스 길이 조절, 속도 조절 가능
  digitalWrite(stepPin, LOW);
  delayMicroseconds(280);

  // 방향 바꾸고 싶으면 dirPin HIGH/LOW 바꾸기
}
