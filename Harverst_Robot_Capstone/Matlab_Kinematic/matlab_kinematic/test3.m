clearvars
close all
clc

% --- 링크 길이 (단위 mm)
L2 = 126;
L3 = 126;
L4 = 195;

% --- 목표 위치
px = 100;
py = 0;    % 평면 문제라 py는 무시
pz = 300;

% --- Step 1: 목표 벡터 길이
r_total = sqrt(px^2 + py^2);
z_total = pz;

% Step 2: L4로 끝방향 맞추기 위한 보정 (벡터 방향)
theta234 = atan2(z_total, r_total);

% Step 3: L4 보정된 목표 지점
r_wrist = r_total - L4*cos(theta234);
z_wrist = z_total - L4*sin(theta234);

% Step 4: L2, L3로 wrist 위치에 도달 가능한지 확인
d_sq = r_wrist^2 + z_wrist^2;
cos_theta3 = (d_sq - L2^2 - L3^2) / (2 * L2 * L3);

if abs(cos_theta3) > 1
    error('목표점에 도달할 수 없습니다. L2+L3로 wrist까지 도달 불가');
end

% --- θ3 계산
sin_theta3 = -sqrt(1 - cos_theta3^2);   % elbow-down
theta3 = atan2(sin_theta3, cos_theta3);

% --- θ2 계산
k1 = L2 + L3 * cos(theta3);
k2 = L3 * sin(theta3);
theta2 = atan2(z_wrist, r_wrist) - atan2(k2, k1);

% --- θ4 계산
theta4 = theta234 - theta2 - theta3;

% --- 서보모터 각도 변환 (MG996R 기준)
theta2_servo = rad2deg(theta2);
theta3_servo = rad2deg(theta3) + 90;
theta4_servo = rad2deg(theta4) + 90;

fprintf("서보모터 각도:\n");
fprintf("θ2 = %.2f°, θ3 = %.2f°, θ4 = %.2f°\n", ...
    theta2_servo, theta3_servo, theta4_servo);

% --- 순기구학으로 검증
c2 = cos(theta2); s2 = sin(theta2);
c23 = cos(theta2 + theta3); s23 = sin(theta2 + theta3);
c234 = cos(theta2 + theta3 + theta4); s234 = sin(theta2 + theta3 + theta4);

p0 = [0; 0; 0];
p1 = p0;
p2 = p1 + [L2*c2; 0; L2*s2];
p3 = p2 + [L3*c23; 0; L3*s23];
p4 = p3 + [L4*c234; 0; L4*s234];  % End-effector 위치

% 검증 출력
fprintf("\n검증 (Forward Kinematics):\n");
fprintf("목표 위치:   X=%.2f, Z=%.2f\n", px, pz);
fprintf("도달 위치:   X=%.2f, Z=%.2f\n", p4(1), p4(3));

% --- 시각화
figure
plot3([p0(1) p2(1) p3(1) p4(1)], [0 0 0 0], [p0(3) p2(3) p3(3) p4(3)], '-o', 'LineWidth', 2)
grid on
axis equal
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')
title('정확한 역기구학 결과 시각화')
view(45, 30)
text(p4(1), 0, p4(3), 'End-effector', 'FontSize', 10)
