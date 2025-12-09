clearvars
close all
clc

% 링크 길이 (단위: mm)
L1 = 43;    % 원래 4.3 cm
L2 = 126;   % 원래 12.6 cm
L3 = 126;   % 원래 12.6 cm
L4 = 195;   % 원래 19.5 cm

% 세타 입력값 (MG996R 기준: 90도가 수직)
theta2_input = 90;  % > 90 → Y+ 방향으로 굽힘
theta3_input = 90;
theta4_input = 100;

% 보정 (90도 기준에서 시작)
theta2 = deg2rad(theta2_input - 90);
theta3 = deg2rad(theta3_input - 90);
theta4 = deg2rad(theta4_input - 90);

% --- 회전 및 이동 행렬 함수 정의 ---
trotz = @(theta) [cos(theta), -sin(theta), 0, 0;
                  sin(theta),  cos(theta), 0, 0;
                           0,           0, 1, 0;
                           0,           0, 0, 1];

troty = @(theta) [cos(theta), 0, sin(theta), 0;
                          0, 1,          0, 0;
                 -sin(theta), 0, cos(theta), 0;
                          0, 0,          0, 1];

transl = @(x, y, z) [1, 0, 0, x;
                     0, 1, 0, y;
                     0, 0, 1, z;
                     0, 0, 0, 1];

% ----- Forward Kinematics -----
T01 = transl(0, 0, L1);                         % Base to Joint1 (Z축 상승)
T12 = troty(theta2) * transl(0, 0, L2);         % Joint1 to Joint2 (Z방향 → Y방향 회전)
T23 = troty(theta3) * transl(0, 0, L3);         % Joint2 to Joint3
T34 = troty(theta4) * transl(0, 0, L4);         % Joint3 to End-effector

% 전체 좌표계 계산
T02 = T01 * T12;
T03 = T02 * T23;
T04 = T03 * T34;

% ----- 관절 위치 추출 -----
p0 = [0; 0; 0];
p1 = T01(1:3, 4);
p2 = T02(1:3, 4);
p3 = T03(1:3, 4);
p4 = T04(1:3, 4);

% ----- 3D 시각화 -----
figure
plot3([p0(1) p1(1)], [p0(2) p1(2)], [p0(3) p1(3)], 'r-o', 'LineWidth', 2)
hold on
plot3([p1(1) p2(1)], [p1(2) p2(2)], [p1(3) p2(3)], 'g-o', 'LineWidth', 2)
plot3([p2(1) p3(1)], [p2(2) p3(2)], [p2(3) p3(3)], 'b-o', 'LineWidth', 2)
plot3([p3(1) p4(1)], [p3(2) p4(2)], [p3(3) p4(3)], 'm-o', 'LineWidth', 2)

grid on
axis equal
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')
title('MG996R 로봇팔: θ > 90도 → Y+ 방향 굽힘 (단위: mm)')

% 시점
view(40, 30)

% 포인트 라벨
text(p4(1), p4(2), p4(3), 'End-Effector', 'FontSize', 10, 'Color', 'k')
