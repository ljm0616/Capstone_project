clearvars
close all
clc

% --- 로봇팔 링크 길이 (단위: mm)
L1 = 0;   % 베이스 높이
L2 = 126;
L3 = 126;
L4 = 195;

% --- 목표 위치 (End-effector의 최종 위치, mm 단위)-그리퍼부분전 모터위치로 감 여기서 +195해야함
px = 100;   % X방향 
py = 0;     % Y방향 (사용 안함)
pz = 100;   % Z방향 (높이)

% --- 역기구학 계산 (Y축 회전 기준)
% 1. 평면 거리 계산 (XY평면에서 X만 고려)
r = sqrt(px^2 + py^2);
z = pz - L1;

% 2. 목표점까지의 거리
d = sqrt(r^2 + z^2);

% 3. θ3 계산 (cos법칙)
c3 = (d^2 - L2^2 - L3^2) / (2 * L2 * L3);
s3 = -sqrt(1 - c3^2);  % 접힘 방향 선택
theta3 = atan2(s3, c3);

% 4. θ2 계산
alpha = atan2(z, r);
cbeta = (L2^2 + d^2 - L3^2) / (2 * L2 * d);
sbeta = sqrt(1 - cbeta^2);
beta = atan2(sbeta, cbeta);
theta2 = alpha + beta;

% 5. θ4 계산 (엔드이펙터 평행 유지)
theta4 = - (theta2 + theta3);

% --- MG996R 서보모터 기준 각도 변환 (90도가 수직 기준)
theta2_servo = 180-rad2deg(theta2) ;
theta3_servo = 90-rad2deg(theta3) ;
theta4_servo = 90-rad2deg(theta4) ;

% --- 출력
fprintf('서보모터 각도 (deg):\n');
fprintf('theta2 = %.2f°, theta3 = %.2f°, theta4 = %.2f°\n', ...
    theta2_servo, theta3_servo, theta4_servo);

% --- 순기구학으로 위치 검증
c2 = cos(theta2); s2 = sin(theta2);
c23 = cos(theta2 + theta3); s23 = sin(theta2 + theta3);
c234 = cos(theta2 + theta3 + theta4); s234 = sin(theta2 + theta3 + theta4);

% 조인트 위치
p0 = [0; 0; 0];
p1 = [0; 0; L1];
p2 = p1 + [L2*c2; 0; L2*s2];
p3 = p2 + [L3*cos(theta2 + theta3); 0; L3*sin(theta2 + theta3)];
p4 = p3 + [L4*cos(theta2 + theta3 + theta4); 0; L4*sin(theta2 + theta3 + theta4)];

% --- 시각화
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
title('Y축 회전기반 역기구학 결과')

view(45, 30)
text(p4(1), p4(2), p4(3), 'End-effector', 'FontSize', 10)
