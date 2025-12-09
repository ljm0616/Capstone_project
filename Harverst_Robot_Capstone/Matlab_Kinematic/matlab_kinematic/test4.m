clearvars
close all
clc

% --- 링크 길이 (단위 mm)
L2 = 126;
L3 = 126;
L4 = 195;

% --- 목표 위치
px = 200;
py = 0;  % 평면 문제
pz = 200;

% --- Step 1: 목표 벡터
r_total = sqrt(px^2 + py^2);
z_total = pz;

% --- Step 2: End-effector 방향 각도
theta234 = atan2(z_total, r_total);

% --- Step 3: Wrist 좌표 계산 (L4 보정)
r_wrist = r_total - L4 * cos(theta234);
z_wrist = z_total - L4 * sin(theta234);

% --- Step 4: Wrist 도달 가능성 검사
d_sq = r_wrist^2 + z_wrist^2;
cos_theta3 = (d_sq - L2^2 - L3^2) / (2 * L2 * L3);

% --- [1] 범위 초과 시 가장 가까운 값으로 보정
if cos_theta3 > 1
    cos_theta3 = 1;
elseif cos_theta3 < -1
    cos_theta3 = -1;
end

% --- [2] θ3 계산 (elbow-down 기준)
sin_theta3 = -sqrt(1 - cos_theta3^2);
theta3 = atan2(sin_theta3, cos_theta3);

% --- [3] θ2 계산
k1 = L2 + L3 * cos(theta3);
k2 = L3 * sin(theta3);
theta2 = atan2(z_wrist, r_wrist) - atan2(k2, k1);

% --- [4] θ4 계산
theta4 = theta234 - theta2 - theta3;

% --- [5] 서보모터 각도로 변환
theta2_servo = 180-rad2deg(theta2);
theta3_servo = 90-rad2deg(theta3) + 90;
theta4_servo = 90-rad2deg(theta4) + 90;

% --- [6] 범위 검사 후 보정
theta2_servo = max(0, min(180, theta2_servo));
theta3_servo = max(0, min(180, theta3_servo));
theta4_servo = max(0, min(180, theta4_servo));

fprintf("🔧 서보모터 각도:\n");
fprintf("θ2 = %.2f°, θ3 = %.2f°, θ4 = %.2f°\n", ...
    theta2_servo, theta3_servo, theta4_servo);

% --- 순기구학으로 검증
t2 = deg2rad(theta2_servo);
t3 = deg2rad(theta3_servo - 90);  % 보정 해제
t4 = deg2rad(theta4_servo - 90);

c2 = cos(t2); s2 = sin(t2);
c23 = cos(t2 + t3); s23 = sin(t2 + t3);
c234 = cos(t2 + t3 + t4); s234 = sin(t2 + t3 + t4);

p0 = [0; 0; 0];
p1 = p0;
p2 = p1 + [L2*c2; 0; L2*s2];
p3 = p2 + [L3*c23; 0; L3*s23];
p4 = p3 + [L4*c234; 0; L4*s234];

fprintf("\n✅ 순기구학 결과 검증:\n");
fprintf("요청 위치: X=%.1f, Z=%.1f\n", px, pz);
fprintf("도달 위치: X=%.1f, Z=%.1f\n", p4(1), p4(3));

% --- 시각화
figure
plot3([p0(1) p2(1) p3(1) p4(1)], [0 0 0 0], [p0(3) p2(3) p3(3) p4(3)], '-o', 'LineWidth', 2)
grid on
axis equal
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')
title('보정된 역기구학 시각화 (서보모터 각도 제한 반영)')
view(45, 30)
text(p4(1), 0, p4(3), 'End-effector', 'FontSize', 10)
