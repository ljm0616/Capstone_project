import serial
import time
import math

# --- 링크 길이 (mm)
L1 = 0
L2 = 126
L3 = 126
L4 = 195

def solve_IK(px, pz):
    r = abs(px)
    z = pz - L1
    d = math.hypot(r, z)

    for sgn in [-1, 1]:
        try:
            c3 = (d**2 - L2**2 - L3**2) / (2 * L2 * L3)
            if abs(c3) > 1:
                continue
            s3 = sgn * math.sqrt(1 - c3**2)
            theta3 = math.atan2(s3, c3)

            alpha = math.atan2(z, r)
            cbeta = (L2**2 + d**2 - L3**2) / (2 * L2 * d)
            sbeta = math.sqrt(1 - cbeta**2)
            beta = math.atan2(sbeta, cbeta)
            theta2 = alpha + beta

            theta4 = - (theta2 + theta3)

            # 서보 각도 (도)
            theta2_deg = 180 - math.degrees(theta2)
            theta3_deg = 90 - math.degrees(theta3)
            theta4_deg = 90 - math.degrees(theta4)

            if all(0 <= a <= 180 for a in [theta2_deg, theta3_deg, theta4_deg]):
                return round(theta2_deg, 2), round(theta3_deg, 2), round(theta4_deg, 2)
        except:
            continue
    return None

# --- 목표 위치
px_target = 200
pz_target = 200

# --- 미세 조정 탐색
found = False
for dx in range(-5, 6):
    for dz in range(-5, 6):
        px = px_target + dx
        pz = pz_target + dz
        angles = solve_IK(px, pz)
        if angles:
            theta2, theta3, theta4 = angles
            found = True
            break
    if found:
        break

if not found:
    print("도달 불가. 대체 위치 계산 중...")
    max_reach = L2 + L3
    angle = math.atan2(pz_target, px_target)
    px = max_reach * math.cos(angle)
    pz = max_reach * math.sin(angle)
    theta2, theta3, theta4 = solve_IK(px, pz)

print(f"[도달 위치] px={px+195}, pz={pz}")
print(f"[서보 각도] theta2={theta2}°, theta3={theta3}°, theta4={theta4}°")

# --- 아두이노에 시리얼 전송
try:
    ser = serial.Serial('COM3', 9600)  # 포트 확인 필요
    time.sleep(2)  # 포트 안정화 대기
    gripper_angle = 70  # 열림
    send_str = f"{int(theta2)},{int(theta3)},{int(theta4)},{gripper_angle}\n"
    ser.write(send_str.encode())
    print("→ 전송 완료:", send_str)
    ser.close()
except Exception as e:
    print("Serial 통신 오류:", e)
