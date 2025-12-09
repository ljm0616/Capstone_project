#define TRIG_PIN 9
#define ECHO_PIN 10

void setup() {
  Serial.begin(9600);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);
}

void loop() {
  // 1. 초음파 신호 보내기
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  // 2. ECHO 핀에서 신호의 지속 시간 측정
  long duration = pulseIn(ECHO_PIN, HIGH);

  // 3. 거리 계산 (단위: cm)
  float distance = duration * 0.0343 / 2;

  // 4. 결과 출력
  Serial.print("Distance: ");
  Serial.print(distance);
  Serial.println(" cm");

  delay(500);  // 0.5초마다 측정
}
