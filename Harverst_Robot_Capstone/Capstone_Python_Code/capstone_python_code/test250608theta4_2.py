import math
import serial
import time

# --- 로봇팔 링크 길이 (단위: mm)
L1 = 0
L2 = 126
L3 = 126
L4 = 195

# --- 목표 위치
px_target = 50
pz_target = 200
gripper_angle = 80  # 기본값 (열림: 35, 닫힘: 120)

# --- 포트 설정
arduino_port = 'COM3'  #  필요 시 변경
baud_rate = 9600

def solve_IK(px, pz, L1, L2, L3, L4):
    r = abs(px)
    z = pz - L1
    d = math.hypot(r, z)

    for sgn in [-1, 1]:
        c3 = (d**2 - L2**2 - L3**2) / (2 * L2 * L3)
        if abs(c3) > 1:
            continue
        s3 = sgn * math.sqrt(1 - c3**2)
        theta3 = math.atan2(s3, c3)

        alpha = math.atan2(z, r)
        cbeta = (L2**2 + d**2 - L3**2) / (2 * L2 * d)
        if cbeta**2 > 1:
            continue
        sbeta = math.sqrt(1 - cbeta**2)
        beta = math.atan2(sbeta, cbeta)
        theta2 = alpha + beta
        theta4 = - (theta2 + theta3)

        theta2_deg = 180 - math.degrees(theta2)
        theta3_deg = 90  - math.degrees(theta3)
        theta4_deg = 90  - math.degrees(theta4)

        if all(0 <= x <= 180 for x in [theta2_deg, theta3_deg, theta4_deg]):
            return theta2_deg, theta3_deg, theta4_deg, True

    return None, None, None, False

# --- 미세 조정 범위 탐색
found = False
for dx in range(-5, 6):
    for dz in range(-5, 6):
        px = px_target + dx
        pz = pz_target + dz
        theta2, theta3, theta4, ok = solve_IK(px, pz, L1, L2, L3, L4)
        if ok:
            best_px, best_pz = px, pz
            found = True
            break
    if found:
        break

# --- 대체 위치 계산
if not found:
    print("[!] 미세 조정으로도 도달 가능한 해를 찾지 못했습니다.")
    max_reach = L2 + L3
    angle = math.atan2(pz_target, px_target)
    best_px = max_reach * math.cos(angle)
    best_pz = max_reach * math.sin(angle)
    theta2, theta3, theta4, ok = solve_IK(best_px, best_pz, L1, L2, L3, L4)
    if ok:
        print("[대체 위치 사용]")
    else:
        print("[!] 대체 위치도 실패했습니다.")
        theta2 = theta3 = theta4 = None

# --- 결과 출력 및 전송
if None not in [theta2, theta3, theta4]:
    print(f"\n[최종 도달 위치: ({195+best_px:.1f}, {best_pz:.1f})]")
    print(f"theta2 = {theta2:.2f}°, theta3 = {theta3:.2f}°, theta4 = {theta4:.2f}°")

    try:
        ser = serial.Serial(arduino_port, baud_rate, timeout=2)
        time.sleep(2)  # 포트 안정화 대기

        cmd = f"{int(theta2)},{int(theta3)},{int(theta4)},{int(gripper_angle)}\n"
        ser.write(cmd.encode())
        print("→ 아두이노로 전송됨:", cmd.strip())
        ser.close()
    except Exception as e:
        print("[!] 시리얼 전송 오류:", e)

else:
    print("\n[!] 유효한 역기구학 해를 찾지 못했기 때문에 아두이노로 전송하지 않음.")
