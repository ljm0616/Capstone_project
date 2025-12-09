clearvars
close all
clc

% --- 링크 길이 (단위 mm)
L2 = 126;
L3 = 126;
L4 = 195;

% --- 원래 목표 위치 (End-effector 기준)
px_target = 120;
pz_target = 100;

% --- 유틸리티 함수: IK 계산
function [theta2_servo, theta3_servo, theta4_servo, success, p4] = solveIK(px, pz, L2, L3, L4)
    r_total = sqrt(px^2);
    z_total = pz;

    % Step 1: 엔드이펙터 방향 각도
    theta234 = atan2(z_total, r_total);

    % Step 2: Wrist 좌표 보정
    r_wrist = r_total - L4 * cos(theta234);
    z_wrist = z_total - L4 * sin(theta234);
    d_sq = r_wrist^2 + z_wrist^2;

    cos_theta3 = (d_sq - L2^2 - L3^2) / (2 * L2 * L3);

    % Step 3: 코사인 범위 제한
    if cos_theta3 < -1 || cos_theta3 > 1
        success = false;
        theta2_servo = NaN; theta3_servo = NaN; theta4_servo = NaN;
        p4 = [NaN; 0; NaN];
        return
    end

    % elbow-down 방식
    sin_theta3 = -sqrt(1 - cos_theta3^2);
    theta3 = atan2(sin_theta3, cos_theta3);

    % Step 4: theta2
    k1 = L2 + L3 * cos(theta3);
    k2 = L3 * sin(theta3);
    theta2 = atan2(z_wrist, r_wrist) - atan2(k2, k1);

    % Step 5: theta4
    theta4 = theta234 - theta2 - theta3;

    % Step 6: 서보모터 각도로 변환
    theta2_servo = 180-rad2deg(theta2);
    theta3_servo = 90-rad2deg(theta3);
    theta4_servo = 90-rad2deg(theta4);

    % Step 7: 범위 확인
    if all([theta2_servo, theta3_servo, theta4_servo] >= 0 & ...
           [theta2_servo, theta3_servo, theta4_servo] <= 180)
        success = true;

        % 순기구학으로 위치 계산
        t2 = deg2rad(theta2_servo);
        t3 = deg2rad(theta3_servo - 90);
        t4 = deg2rad(theta4_servo - 90);

        c2 = cos(t2); s2 = sin(t2);
        c23 = cos(t2 + t3); s23 = sin(t2 + t3);
        c234 = cos(t2 + t3 + t4); s234 = sin(t2 + t3 + t4);

        p2 = [L2 * c2; 0; L2 * s2];
        p3 = p2 + [L3 * c23; 0; L3 * s23];
        p4 = p3 + [L4 * c234; 0; L4 * s234];
    else
        success = false;
        theta2_servo = NaN; theta3_servo = NaN; theta4_servo = NaN;
        p4 = [NaN; 0; NaN];
    end
end

% --- 1단계: ±5mm 탐색
range = -5:1:5;
found = false;

for dx = range
    for dz = range
        px = px_target + dx;
        pz = pz_target + dz;
        [t2s, t3s, t4s, success, p4_sol] = solveIK(px, pz, L2, L3, L4);
        if success
            found = true;
            best_px = px;
            best_pz = pz;
            theta2_servo = t2s;
            theta3_servo = t3s;
            theta4_servo = t4s;
            p4 = p4_sol;
            break
        end
    end
    if found, break, end
end

% --- 2단계: 가장 가까운 도달 가능 위치
if ~found
    fprintf('[!] 미세 보정 실패 → 최대 도달 거리로 조정\n');
    max_reach = L2 + L3 + L4;
    angle = atan2(pz_target, px_target);
    best_px = max_reach * cos(angle);
    best_pz = max_reach * sin(angle);

    [theta2_servo, theta3_servo, theta4_servo, ~, p4] = solveIK(best_px, best_pz, L2, L3, L4);
end

% --- 결과 출력
fprintf('\n📌 목표 위치: X=%.1f, Z=%.1f\n', px_target, pz_target);
fprintf('🔍 실제 도달 위치: X=%.1f, Z=%.1f\n', p4(1), p4(3));
fprintf('🎯 서보모터 각도:\nθ2 = %.2f°, θ3 = %.2f°, θ4 = %.2f°\n', ...
        theta2_servo, theta3_servo, theta4_servo);

% --- 시각화
p0 = [0; 0; 0];
p1 = p0;
t2 = deg2rad(theta2_servo);
t3 = deg2rad(theta3_servo - 90);
t4 = deg2rad(theta4_servo - 90);

p2 = p1 + [L2 * cos(t2); 0; L2 * sin(t2)];
p3 = p2 + [L3 * cos(t2 + t3); 0; L3 * sin(t2 + t3)];
p4 = p3 + [L4 * cos(t2 + t3 + t4); 0; L4 * sin(t2 + t3 + t4)];

figure
plot3([p0(1) p2(1) p3(1) p4(1)], [0 0 0 0], [p0(3) p2(3) p3(3) p4(3)], '-o', 'LineWidth', 2)
grid on
axis equal
xlabel('X (mm)')
ylabel('Y (mm)')
zlabel('Z (mm)')
title('서보모터 제한 포함 역기구학 시각화')
view(45, 30)
text(p4(1), 0, p4(3), 'End-effector', 'FontSize', 10)
