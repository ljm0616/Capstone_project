clearvars
close all
clc

% --- 로봇팔 링크 길이 (단위: mm)
L2 = 126;   % 첫 번째 링크
L3 = 126;   % 두 번째 링크
L4 = 195;   % 세 번째 링크
L5 = 0;     % End-effector용 추가 보정 길이

% --- 목표 위치 (End-effector 최종 위치, mm 단위)
px = 50;     % X방향
py = 0;     % Y방향
pz = 300;   % Z방향 (베이스 기준, L1 제거됨)

% --- 역기구학 계산 (Y축 회전 기준)
r_eff = sqrt(px^2 + py^2);
z_eff = pz;

% L5 보정: End-effector가 향하는 방향 반대로 L5 만큼 보정
r = r_eff - L5;
z = z_eff;

% 목표점까지 거리
d = sqrt(r^2 + z^2);

% --- θ3 계산 (cos법칙)
c3 = (d^2 - L2^2 - L3^2) / (2 * L2 * L3);
c3 = max(min(c3, 1), -1);   % 범위 제한
s3 = -sqrt(1 - c3^2);       % 접힘 방향
theta3 = atan2(s3, c3);

% --- θ2 계산
alpha = atan2(z, r);
cbeta = (L2^2 + d^2 - L3^2) / (2 * L2 * d);
cbeta = max(min(cbeta, 1), -1);
sbeta = sqrt(1 - cbeta^2);
beta = atan2(sbeta, cbeta);
theta2 = alpha + beta;

% --- θ4 자동 계산 (End-effector가 목표 pz에 도달하도록)
z_partial = L2*sin(theta2) + L3*sin(theta2 + theta3);
z_remain = pz - z_partial;

% 역삼각함수로 θ4 계산 (θ234 = asin(남은 높이 / L4))
% 유효성 검사
if abs(z_remain / L4) <= 1
    theta234 = asin(z_remain / L4);
    theta4 = theta234 - (theta2 + theta3);  % 최종 θ4 계산
else
    error('목표 위치에 도달할 수 없습니다. z_remain/L4가 1을 초과함');
end

% --- θ5 계산 (End-effector 수직 유지)
theta5 = - (theta2 + theta3 + theta4);

% --- MG996R 서보모터 기준 각도 변환 (90도가 수직 기준)
theta2_servo = rad2deg(theta2) + 90;
theta3_servo = rad2deg(theta3) + 90;
theta4_servo = rad2deg(theta4) + 90;
theta5_servo = rad2deg(theta5) + 90;

% --- 출력
fprintf('서보모터 각도 (deg):\n');
fprintf('θ2 = %.2f°, θ3 = %.2f°, θ4 = %.2f°, θ5 = %.2f°\n', ...
    theta2_servo, theta3_servo, theta4_servo, theta5_servo);

% --- 순기구학 위치 계산
c2 = cos(theta2);         s2 = sin(theta2);
c23 = cos(theta2+theta3); s23 = sin(theta2+theta3);
c234 = cos(theta2+theta3+theta4); s234 = sin(theta2+theta3+theta4);
c2345 = cos(theta2+theta3+theta4+theta5); s2345 = sin(theta2+theta3+theta4+theta5);

% 조인트 위치
p0 = [0; 0; 0];  % 베이스
p1 = p0;                          % 첫 관절 위치 (L1 제거되어 p0와 동일)
p2 = p1 + [L2*c2; 0; L2*s2];
p3 = p2 + [L3*c23; 0; L3*s23];
p4 = p3 + [L4*c234; 0; L4*s234];
p5 = p4 + [L5*c2345; 0; L5*s2345];

% --- 시각화
figure
plot3([p0(1) p1(1)], [p0(2) p1(2)], [p0(3) p1(3)], 'r-o', 'LineWidth', 2)
hold on
plot3([p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], 'g-o', 'LineWidth', 2)
plot3([p2(1) p3(1)], [p2(2) p3(2)], [p2(3) p3(3)], 'b-o', 'LineWidth', 2)
plot3([p3(1) p4(1)], [p3(2) p4(2)], [p3(3) p4(3)], 'c-o', 'LineWidth', 2)
plot3([p4(1) p5(1)], [p4(2) p5(2)], [p4(3) p5(3)], 'm-o', 'LineWidth', 2)
grid on
axis equal
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')
title('4자유도 로봇팔 역기구학 시각화 (L1 제거)')
view(45, 30)
text(p5(1), p5(2), p5(3), 'End-effector', 'FontSize', 10)
