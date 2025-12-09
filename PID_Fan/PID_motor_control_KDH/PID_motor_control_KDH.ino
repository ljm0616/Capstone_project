#include <LiquidCrystal_I2C.h>
#include <Wire.h>

LiquidCrystal_I2C lcd(0x27,16,2);

int rpm_ip;
const int PWMPin = 9;
int PWMvalue = 0;
const int MstartstopPin = 7;
int Mstart = HIGH;
int Mstop = LOW;
const int dirPin = 8;
int rotationCW = HIGH;
int rotationCCW = LOW;
const int FG1Pin = 2;

volatile unsigned long countFG1 = 0;

unsigned long previousRotationCountFG1 = 0;
unsigned long previousTime = 0;
long RPM;
unsigned long timeSpace;

double kp = 0.012885;
double ki = 0.00003;
double kd = 0;

double error, cumError, rateError, lastError;

void InterruptCount() {
  countFG1++;
}

void setup() {
  Serial.begin(9600);
  pinMode(PWMPin, OUTPUT);
  pinMode(MstartstopPin, OUTPUT);
  pinMode(dirPin, OUTPUT);
  pinMode(FG1Pin, INPUT);
  attachInterrupt(digitalPinToInterrupt(FG1Pin), InterruptCount, RISING);

  digitalWrite(MstartstopPin, Mstart);
  digitalWrite(dirPin, rotationCW);
  analogWrite(PWMPin, PWMvalue);
  previousTime = millis();

  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.home();
}

void loop() {
  unsigned long currentTime = millis();
  timeSpace = currentTime - previousTime;
  if (Serial.available() > 0) {
    rpm_ip = Serial.parseInt(); // Serial 입력값을 목표 RPM으로 설정
  }
  if (timeSpace >= 100) {
    unsigned long rotationCount = countFG1 / 12; 
    RPM = (countFG1 * 60000) / (12 * timeSpace);
    int pidOutput = CPID(rpm_ip);  
    PWMvalue = constrain(pidOutput, 0, 255);
    analogWrite(PWMPin, PWMvalue);
    previousTime = currentTime;
    countFG1 = 0; 

    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("RPM: ");
    lcd.print(RPM);

    lcd.setCursor(0, 1);
    lcd.print("Target: ");
    lcd.print(rpm_ip);
  }
}

// PID 제어 함수
int CPID(int currentRPM) {
  error = currentRPM - RPM;  
  cumError += error * timeSpace;
  rateError = (error - lastError) / timeSpace;
  double out = kp * error + ki * cumError + kd * rateError;
  lastError = error; 
  Serial.print(" rpm = ");
  Serial.print(RPM);
  Serial.print(" error = ");
  Serial.println(error);

  return out;
}
