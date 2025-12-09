clearvars
close all
clc

% --- 로봇팔 링크 길이 (단위: mm)
L1 = 0;
L2 = 126;
L3 = 126;
L4 = 195;

% --- 목표 위치 (End-effector 기준 → 전 모터 기준으로 변환)
px_target = 200;
py = 0;
pz_target = 200;

% --- 역기구학 함수 정의
function [theta2s, theta3s, theta4s, success] = solveIK(px, pz, L1, L2, L3, L4)
    r = sqrt(px^2);
    z = pz - L1;
    d = sqrt(r^2 + z^2);
    success = false;

    for sgn = [-1, 1]
        c3 = (d^2 - L2^2 - L3^2) / (2 * L2 * L3);
        if abs(c3) > 1, continue; end
        s3 = sgn * sqrt(1 - c3^2);
        theta3 = atan2(s3, c3);

        alpha = atan2(z, r);
        cbeta = (L2^2 + d^2 - L3^2) / (2 * L2 * d);
        sbeta = sqrt(1 - cbeta^2);
        beta = atan2(sbeta, cbeta);
        theta2 = alpha + beta;

        theta4 = - (theta2 + theta3);

        % 서보 변환
        theta2_servo = 180 - rad2deg(theta2);
        theta3_servo = 90  - rad2deg(theta3);
        theta4_servo = 90  - rad2deg(theta4);

        if all([theta2_servo, theta3_servo, theta4_servo] >= 0 & ...
               [theta2_servo, theta3_servo, theta4_servo] <= 180)
            success = true;
            theta2s = theta2_servo;
            theta3s = theta3_servo;
            theta4s = theta4_servo;
            return;
        end
    end

    theta2s = NaN; theta3s = NaN; theta4s = NaN;
end

% 1단계: 미세 조정 범위 내에서 가능한 좌표 탐색
search_range = -5:1:5;
found = false;

for dx = search_range
    for dz = search_range
        px = px_target + dx;
        pz = pz_target + dz;
        [theta2_s, theta3_s, theta4_s, ok] = solveIK(px, pz, L1, L2, L3, L4);
        if ok
            found = true;
            best_px = px;
            best_pz = pz;
            break
        end
    end
    if found, break, end
end

% 2단계: 불가능한 경우, 가장 가까운 도달 가능한 위치 찾기
if ~found
    disp('[!] 미세 조정으로도 도달 가능한 해를 찾지 못했습니다.');
    % 최대 도달 반경
    max_reach = L2 + L3;
    angle = atan2(pz_target, px_target);
    best_px = max_reach * cos(angle);
    best_pz = max_reach * sin(angle);
    [theta2_s, theta3_s, theta4_s, ~] = solveIK(best_px, best_pz, L1, L2, L3, L4);
    disp('[대체 위치 사용]');
end

% --- 최종 결과 출력
fprintf('\n[최종 도달 위치: (%.1f, %.1f)]\n', best_px, best_pz);
fprintf('theta2 = %.2f°, theta3 = %.2f°, theta4 = %.2f°\n', ...
        theta2_s, theta3_s, theta4_s);

% --- 순기구학 시각화
theta2 = deg2rad(180 - theta2_s);
theta3 = deg2rad(90 - theta3_s);
theta4 = deg2rad(90 - theta4_s);

c2 = cos(theta2); s2 = sin(theta2);
c23 = cos(theta2 + theta3); s23 = sin(theta2 + theta3);
c234 = cos(theta2 + theta3 + theta4); s234 = sin(theta2 + theta3 + theta4);

p0 = [0; 0; 0];
p1 = [0; 0; L1];
p2 = p1 + [L2*c2; 0; L2*s2];
p3 = p2 + [L3*c23; 0; L3*s23];
p4 = p3 + [L4*c234; 0; L4*s234];

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
title('도달 가능한 위치에 대한 로봇팔 시각화')
text(p4(1), p4(2), p4(3), 'End-effector', 'FontSize', 10)
