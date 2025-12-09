// 센서 1 핀
const int trigPin1 = 8;
const int echoPin1 = 9;

// 센서 2 핀
const int trigPin2 = 10;
const int echoPin2 = 11;

void setup() {
  Serial.begin(9600);

  pinMode(trigPin1, OUTPUT);
  pinMode(echoPin1, INPUT);

  pinMode(trigPin2, OUTPUT);
  pinMode(echoPin2, INPUT);
}

void loop() {
  long duration1, distance1;
  long duration2, distance2;

  // 센서 1 거리 측정
  digitalWrite(trigPin1, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin1, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin1, LOW);
  duration1 = pulseIn(echoPin1, HIGH);
  distance1 = (duration1 * 340 / 10000) / 2;

  // 센서 2 거리 측정
  digitalWrite(trigPin2, LOW);
  delayMicroseconds(2);
  digitalWrite(trigPin2, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin2, LOW);
  duration2 = pulseIn(echoPin2, HIGH);
  distance2 = (duration2 * 340 / 10000) / 2;

  // 시리얼 출력
  Serial.print("센서 1 거리: ");
  Serial.print(distance1);
  Serial.print(" cm\t");

  Serial.print("센서 2 거리: ");
  Serial.print(distance2);
  Serial.println(" cm");

  delay(500); // 측정 간격
}
