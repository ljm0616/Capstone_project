import numpy as np
import serial
import time

# --- 아두이노 시리얼 포트 연결
arduino = serial.Serial(port='COM3', baudrate=9600, timeout=1)
time.sleep(2)

# --- 링크 길이 (단위 mm)
L2 = 126
L3 = 126
L4 = 195

# --- 목표 위치 (평면 문제, Y는 무시)
px = 0
py = 0
pz = 445

# Step 1: 목표 벡터 길이
r_total = np.sqrt(px**2 + py**2)
z_total = pz

# Step 2: L4 방향 고정
theta234 = np.arctan2(z_total, r_total)

# Step 3: L4 보정된 wrist 위치
r_wrist = r_total - L4 * np.cos(theta234)
z_wrist = z_total - L4 * np.sin(theta234)

# Step 4: L2 + L3로 도달 가능한지 확인
d_sq = r_wrist**2 + z_wrist**2
cos_theta3 = (d_sq - L2**2 - L3**2) / (2 * L2 * L3)

if abs(cos_theta3) > 1:
    raise ValueError("목표점 도달 불가: L2+L3로 wrist 도달 불가")

# θ3 계산 (elbow down)
sin_theta3 = -np.sqrt(1 - cos_theta3**2)
theta3 = np.arctan2(sin_theta3, cos_theta3)

# θ2 계산
k1 = L2 + L3 * np.cos(theta3)
k2 = L3 * np.sin(theta3)
theta2 = np.arctan2(z_wrist, r_wrist) - np.arctan2(k2, k1)

# θ4 계산
theta4 = theta234 - theta2 - theta3

# 서보모터 각도로 변환 및 보정
def clamp(deg):
    return max(0, min(180, deg))

theta2_deg = clamp(np.rad2deg(theta2))
theta3_deg = clamp(np.rad2deg(theta3) + 90)
theta4_deg = clamp(np.rad2deg(theta4) + 90)

# 출력 확인
print(f"θ2: {theta2_deg:.2f}, θ3: {theta3_deg:.2f}, θ4: {theta4_deg:.2f}")

# 아두이노로 전송
msg = f"{int(theta2_deg)},{int(theta3_deg)},{int(theta4_deg)}\n"
arduino.write(msg.encode())
response = arduino.readline().decode().strip()
print("Arduino 응답:", response)