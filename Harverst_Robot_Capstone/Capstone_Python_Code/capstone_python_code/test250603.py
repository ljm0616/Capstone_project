import numpy as np
import serial
import time

# --- 아두이노 시리얼 포트 연결 (COM 포트 번호는 환경에 따라 수정)
arduino = serial.Serial(port='COM3', baudrate=9600, timeout=1)
time.sleep(2)  # 아두이노 초기화 대기

# --- 링크 길이 (단위: mm)
L1 = 0
L2 = 126
L3 = 126
L4 = 195

# --- 목표 위치 설정 (x, z)
px = 110
py = 0  # 2D 평면 상 문제이므로 무시
pz = 200

# --- Step 1: 목표점에서 L4 방향 고려한 보정 계산
r_total = np.sqrt(px**2 + py**2)
z_total = pz - L1
theta234 = np.arctan2(z_total, r_total)  # L4 방향

# --- Step 2: Wrist (L2, L3 끝점) 좌표 계산
r_wrist = r_total - L4 * np.cos(theta234)
z_wrist = z_total - L4 * np.sin(theta234)

# --- Step 3: L2+L3로 Wrist 도달 가능한지 확인
d_sq = r_wrist**2 + z_wrist**2
cos_theta3 = (d_sq - L2**2 - L3**2) / (2 * L2 * L3)

if abs(cos_theta3) > 1:
    raise ValueError("⚠️ 목표 위치는 로봇팔 작업 공간 밖입니다.")

# --- Step 4: θ3, θ2, θ4 계산 (elbow-down 기준)
sin_theta3 = -np.sqrt(1 - cos_theta3**2)
theta3 = np.arctan2(sin_theta3, cos_theta3)

k1 = L2 + L3 * np.cos(theta3)
k2 = L3 * np.sin(theta3)
theta2 = np.arctan2(z_wrist, r_wrist) - np.arctan2(k2, k1)

theta4 = theta234 - theta2 - theta3

# --- Step 5: 각도 변환 (라디안 → 도), 0~180° 보정
def clamp(deg):
    return max(0, min(180, deg))

theta2_deg = clamp(np.rad2deg(theta2))        # MG996R 수직 기준 안 맞춰도 됨
theta3_deg = clamp(np.rad2deg(theta3) + 90)   # -90도 기준 보정
theta4_deg = clamp(np.rad2deg(theta4) + 90)   # -90도 기준 보정

# --- 출력 확인
print("✅ 서보모터 보정 각도:")
print(f"θ2 = {theta2_deg:.2f}°")
print(f"θ3 = {theta3_deg:.2f}°")
print(f"θ4 = {theta4_deg:.2f}°")

# --- 아두이노로 전송
msg = f"{int(theta2_deg)},{int(theta3_deg)},{int(theta4_deg)}\n"
arduino.write(msg.encode())
print("📤 전송 메시지:", msg.strip())

# --- 아두이노 응답 확인
response = arduino.readline().decode().strip()
print("📥 아두이노 응답:", response)
