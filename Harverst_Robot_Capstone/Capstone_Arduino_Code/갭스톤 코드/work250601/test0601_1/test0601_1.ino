const int stepPin = 3;
const int dirPin = 2;
const int enablePin = 4;
const int magneticRed = 13;    // 빨간 LED가 꼽혀있는 쪽의 마그네틱 센서
const int magneticGreen = 12;  // 초록 LED가 꼽혀있는 쪽의 마그네틱 센서

int rotationCW = LOW;    // 시계방향 - 오른쪽으로 이동
int rotationCCW = HIGH;  // 반시계방향 - 왼쪽으로 이동

int Mstop = HIGH;  // 모터 정지
int Mstart = LOW;  // 모터 동작

// 모터 바퀴 회전 수 초기화
float motor_rotationCount = 0;

// MAP 함수로 회전값을 변환
float motor_rotationMap = 0;

//방향 전환 카운트
int directionChangeCount = 0;

// 모터 회전 속도 조절
void stepMotorPulseLowSpeed();
void stepMotorPulseHighSpeed();

void stepMotorPulseLowSpeed()  //스텝모터 속도 느리
{
  digitalWrite(stepPin, HIGH);
  delayMicroseconds(500);  // 펄스 길이 조절, 속도 조절 가능
  digitalWrite(stepPin, LOW);
  delayMicroseconds(500);
}

void stepMotorPulseHighSpeed()  // 스텝모터속도 빠르게
{
  digitalWrite(stepPin, HIGH);
  delayMicroseconds(150);  // 펄스 길이 조절, 속도 조절 가능
  digitalWrite(stepPin, LOW);
  delayMicroseconds(150);
}

void setup() {
  Serial.begin(9600);
  pinMode(stepPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(enablePin, OUTPUT);
  pinMode(magneticRed, INPUT);    // 빨간 LED 쪽 마그네틱센서 입력받음 설정
  pinMode(magneticGreen, INPUT);  // 초록 LED 쪽 마그네틱센서 입력받음 설정

  digitalWrite(enablePin, Mstart);
  digitalWrite(dirPin, rotationCCW);  // 반시계- 왼쪽

  while (digitalRead(magneticRed) == 0 && digitalRead(magneticGreen) == 0)  // 로봇팔 위치가 중간에 있을때 초기위치인 스텝모터가 있는 곳으로 이동
  {
    Serial.println(digitalRead(magneticRed));
    Serial.println(digitalRead(magneticGreen));
    stepMotorPulseHighSpeed()
  }
  Serial.println("탈출");
}

void loop() {

  int moveRight = digitalRead(magneticRed);
  int moveLeft = digitalRead(magneticGreen);

  int direction = 0;


  if (moveRight == 1 && directionChangeCount == 0) {
    Serial.println("오른쪽으로 이동");
    digitalWrite(dirPin, rotationCW);  // 방향 바꾸고 싶으면 dirPin HIGH/LOW 바꾸기
    directionChangeCount = 1;
    Serial.print("빨간색 led 값 ");
    Serial.println(moveRight);
  } else if (moveLeft == 1 && directionChangeCount == 1) {
    Serial.println("왼쪽으로 이동");
    digitalWrite(dirPin, rotationCCW);  // 방향 바꾸고 싶으면 dirPin HIGH/LOW 바꾸기
    directionChangeCount = 0;
    Serial.print("초록색 led 값 ");
    Serial.println(moveLeft);
  }

  stepMotorPulseHighSpeed();
}
