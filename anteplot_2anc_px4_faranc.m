close all;
clear all;

mobAntOff =[0.172, 0.283, 0.004;
            0.182, -0.280, -0.006;
            -0.376, -0.293, 0.003;
            -0.386, 0.262, 0.000]';
  
% niv20170802 forward
ancPos = [3.474, -0.369, 1.733;
          3.461, 0.625, 1.77]';
      
% Translating the coordinate from UWB frame to vicon frame      
ancPos = [-ancPos(2, :);
          ancPos(1, :);
          ancPos(3, :)];
     
ancAntOff = [0, 0, 0;
             0, 0, 0;
             0, 0, 0;
             0, 0, 0]';

centerOffset = [0.1; 0.0; -0.07];

flightdata = csvread('bagcsv/niv20170812_G2.csv', 1, 0);
setpoints = csvread('pathG.csv'); setpoints = setpoints';

%--Trimming data
t = flightdata(:, 1)' - flightdata(1, 1);

tstart = 38.5;
tend = 245.5;

% G2 data
tstart = 42;
tend = 203;

I = find( t > tstart & t < tend);
flightdata = flightdata(I, :);
%--Trimming data

[K, ~] = size(flightdata);

t = flightdata(:, 1)';
t = t - t(1);

ttakeoff = t(1);
tlanding = t(end);

vcP = flightdata(:, 2:4)';

vcV = flightdata(:, 5:7)';
vcEul = flightdata(:, 8:10)';
vcDCM = zeros(3, 3, K);

px4P = flightdata(:, 11:13)';
px4P = [-px4P(2, :); px4P(1, :); px4P(3, :)];
px4V = flightdata(:, 14:16)';
px4V = [-px4V(2, :); px4V(1, :); px4V(3, :)];

px4Eul = flightdata(:, 17:19)';
px4Lidar = flightdata(:, 20)';

corflow = flightdata(:, 21:23)';
flowpsr = flightdata(:, 24)';

figure('name', '3D Pos', 'position', [865 200 400 400], 'color', [1 1 1]);
hold on;
plot3(vcP(1, :), vcP(2, :), vcP(3, :), 'r', 'linewidth', 1);
plot3(px4P(1, :), px4P(2, :), px4P(3, :), 'b', 'linewidth', 1);
plot3(setpoints(1, :), setpoints(2, :), setpoints(3, :), 'g', 'linewidth', 1);
set(gca, 'DataAspectRatio', [1 1 1], 'fontsize', 14);
xlim([-2, 3]);
ylim([-2.5, 2.5]);
zlim([0, 1]);
ylb = ylabel('$y\ [m]$', 'interpreter', 'latex');
xlabel('$x\ [m]$', 'interpreter', 'latex');
zlabel('$z\ [m]$', 'interpreter', 'latex');

grid on;

ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

figure('name', 'Position','position', [1278 100 840 630], 'color', [1 1 1]);
subplot(3, 1, 1);
plot(t, vcP(1, :), 'r', t, px4P(1, :), 'b');
grid on;
ylim([-2.5, 2.5]);
set(gca, 'XTick',t(1):20:t(end));
xlabel('$\mathrm{Time}\ [s]$', 'interpreter', 'latex', 'fontsize', 14);
ylabel('$\mathrm{Position}\ x\ [m]$', 'interpreter', 'latex', 'fontsize', 14);
lghd = legend('$\mathrm{Vicon}$', '$\mathrm{Estimate}$');
set(lghd, 'interpreter', 'latex', 'fontsize', 14, 'position', [0.5360 0.8102 0.2117 0.1057]);
set(gca, 'fontsize', 16);  
grid on;

subplot(3, 1, 2);
plot(t, vcP(2, :), 'r', t, px4P(2, :), 'b');
grid on;
ylim([-2.5, 2.5]);
set(gca, 'XTick',t(1):20:t(end));
xlabel('$\mathrm{Time}\ [s]$', 'interpreter', 'latex', 'fontsize', 14);
ylabel('$\mathrm{Position}\ y\ [m]$', 'interpreter', 'latex', 'fontsize', 14);
set(gca, 'fontsize', 16);  

subplot(3, 1, 3);
plot(t, vcP(3, :), 'r', t, px4P(3, :), 'b');
grid on;
ylim([0, 1.5]);
set(gca, 'XTick',t(1):20:t(end));
xlabel('$\mathrm{Time}\ [s]$', 'interpreter', 'latex', 'fontsize', 14);
ylabel('$\mathrm{Position}\ z\ [m]$', 'interpreter', 'latex', 'fontsize', 14);
set(gca, 'fontsize', 16);  


figure('name', 'Velocity','position', [1278 100 840 630], 'color', [1 1 1]);
subplot(3, 1, 1);
plot(t, vcV(1, :), 'r', t, px4V(1, :), 'b', t, corflow(1, :).*vcP(3, :), 'g');
grid on;
ylim([-0.6, 0.6]);
set(gca, 'XTick',t(1):20:t(end));
xlabel('$\mathrm{Time}\ [s]$', 'interpreter', 'latex', 'fontsize', 14);
ylabel('$\mathrm{Velocity}\ x\ [m/s]$', 'interpreter', 'latex', 'fontsize', 14);
lghd = legend('$\mathrm{Vicon}$', '$\mathrm{Estimate}$', '$\mathrm{Optical Flow}$');
set(lghd, 'interpreter', 'latex', 'fontsize', 14, 'position', [0.5360 0.8102 0.2117 0.1057]);
set(gca, 'fontsize', 16);  
grid on;

subplot(3, 1, 2);
plot(t, vcV(2, :), 'r', t, px4V(2, :), 'b', t, -corflow(2, :).*vcP(3, :), 'g');
grid on;
ylim([-0.6, 0.6]);
set(gca, 'XTick',t(1):20:t(end));
xlabel('$\mathrm{Time}\ [s]$', 'interpreter', 'latex', 'fontsize', 14);
ylabel('$\mathrm{Velocity}\ y\ [m/s]$', 'interpreter', 'latex', 'fontsize', 14);
set(gca, 'fontsize', 16);  

subplot(3, 1, 3);
plot(t, vcV(3, :), 'r', t, px4V(3, :), 'b');
grid on;
ylim([-0.25, 0.25]);
set(gca, 'XTick',t(1):20:t(end));
xlabel('$\mathrm{Time}\ [s]$', 'interpreter', 'latex', 'fontsize', 14);
ylabel('$\mathrm{Velocity}\ z\ [m/s]$', 'interpreter', 'latex', 'fontsize', 14);
set(gca, 'fontsize', 16);  

figure('name', 'Pos. Err', 'position', [2626 64 840 630]);
plot(t, abs(vcP(1, :) - px4P(1, :)), 'r', t, abs(vcP(2, :) - px4P(2, :)), 'g', t, abs(vcP(3, :) - px4P(3, :)), 'b');
ylim([0, 0.5]);

rmsex = rms(vcP(1, :) - px4P(1, :));
rmsey = rms(vcP(2, :) - px4P(2, :));
rmsez = rms(vcP(3, :) - px4P(3, :));

stdx = std(vcP(1, :) - px4P(1, :));
stdy = std(vcP(2, :) - px4P(2, :));
stdz = std(vcP(3, :) - px4P(3, :));

rmsevx = rms(vcV(1, :) - px4V(1, :));
rmsevy = rms(vcV(2, :) - px4V(2, :));
rmsevz = rms(vcV(3, :) - px4V(3, :));

stdvx = std(vcV(1, :) - px4V(1, :));
stdvy = std(vcV(2, :) - px4V(2, :));
stdvz = std(vcV(3, :) - px4V(3, :));

uwbD = flightdata(:, end-3)';
ancAntId = floor(flightdata(:, end-2)'/16) + 1;
mobAntId = mod(flightdata(:, end-2)', 16) + 1;
rqstrId = flightdata(:, end)'-1;
rspdrId = flightdata(:, end-1)'+1;

[~, mobAnts] = size(mobAntOff);
[~, ancs] = size(ancPos);

edgeTotal = max(mobAnts*ancs);

f = [];

vcD = zeros(1, K);
vcDCM = zeros(3, 3, K);
px4DCM = zeros(3, 3, K);

px4EulinVC = zeros(3, K);

vcMobAntPos = zeros(3, mobAnts*2, K);
vcAntPosCompact = zeros(3, K);

vcVbody = zeros(3, K);

for k = 1:K
    vcRo = vcEul(1, k);
    vcPi = vcEul(2, k);
    vcYa = vcEul(3, k);
    
    vcRx = [1, 0, 0; 0, cos(vcRo), -sin(vcRo); 0, sin(vcRo), cos(vcRo)];
    vcRy = [cos(vcPi), 0, sin(vcPi); 0, 1, 0; -sin(vcPi), 0, cos(vcPi)];
    vcRz = [cos(vcYa), -sin(vcYa), 0; sin(vcYa), cos(vcYa), 0; 0, 0, 1];
    
    vcDCM(:, :, k) = vcRx*vcRy*vcRz;
    
    px4Ro = px4Eul(1, k);
    px4Pi = px4Eul(2, k);
    px4Ya = px4Eul(3, k);
    
    px4Rx = [1, 0, 0; 0, cos(px4Ro), -sin(px4Ro); 0, sin(px4Ro), cos(px4Ro)];
    px4Ry = [cos(px4Pi), 1, sin(px4Pi); 0, 1, 0; -sin(px4Pi), 0, cos(px4Pi)];
    px4Rz = [cos(px4Ya), -sin(px4Ya), 0; sin(px4Ya), cos(px4Ya), 0; 0, 0, 1];
    
    px4DCM(:, :, k) = [0 1, 0; 1 0 0; 0 0 -1]*px4Rz*px4Ry*px4Rx*[1 0, 0; 0 -1 0; 0 0 -1];
    
    [px4Eul(1, k), px4Eul(2, k), px4Eul(3, k)] = dcm2angle(px4DCM(:, :, k)', 'XYZ');
    [vcEul(1, k), vcEul(2, k), vcEul(3, k)] = dcm2angle(vcDCM(:, :, k)', 'XYZ');
    
    for n=1:2
        for s=1:2
            vcMobAntPos(:, (n-1)*2 + s, k) = vcDCM(:, :, k)*mobAntOff(:, (n-1)*2 + s) + vcP(:, k);
        end
    end
    vcD(k) = norm(vcMobAntPos(:, (rqstrId(k)-1)*2 + mobAntId(k), k)...
                - (ancPos(:, rspdrId(k)) + ancAntOff(:, ancAntId(k))));
    vcAntPosCompact(:, k) = vcMobAntPos(:, (rqstrId(k)-1)*2 + mobAntId(k), k);
    
    vcVbody(:, k) = vcDCM(:, :, k)'*vcV(:, k);
    
    if flowpsr(k) > 40
        corflowvalid(:, k) = corflow(:, k);
    elseif k > 1
        corflowvalid(:, k) = corflowvalid(:, k-1);
    else
        corflowvalid(:, k) = [0; 0; 0];
    end
end


figure('name', 'Angle','position', [1278 100 840 630], 'color', [1 1 1]);
subplot(3, 1, 3);
plot(t, vcEul(1, :)*180/pi, 'r', t, px4Eul(1, :)*180/pi, 'b');
grid on;
ylim([-6, 6]);
set(gca, 'XTick',t(1):20:t(end));
xlabel('$\mathrm{Time}\ [s]$', 'interpreter', 'latex', 'fontsize', 14);
ylabel('$\mathrm{Roll}\ [deg]$', 'interpreter', 'latex', 'fontsize', 14);
set(gca, 'fontsize', 16);  

subplot(3, 1, 2);
plot(t, vcEul(2, :)*180/pi, 'r', t, px4Eul(2, :)*180/pi, 'b');
grid on;
ylim([-6, 6]);
set(gca, 'XTick',t(1):20:t(end));
xlabel('$\mathrm{Time}\ [s]$', 'interpreter', 'latex', 'fontsize', 14);
ylabel('$\mathrm{Pitch}\ [deg]$', 'interpreter', 'latex', 'fontsize', 14);
set(gca, 'fontsize', 16);  

subplot(3, 1, 1);
plot(t, vcEul(3, :)*180/pi, 'r', t, px4Eul(3, :)*180/pi, 'b');
grid on;
ylim([85, 100]);
set(gca, 'XTick',t(1):20:t(end));
xlabel('$\mathrm{Time}\ [s]$', 'interpreter', 'latex', 'fontsize', 14);
ylabel('$\mathrm{Yaw}\ [deg]$', 'interpreter', 'latex', 'fontsize', 14);
lghd = legend('$\mathrm{Vicon}$', '$\mathrm{Estimate}$');
set(lghd, 'interpreter', 'latex', 'fontsize', 14, 'position', [0.5360 0.8102 0.2117 0.1057]);
set(gca, 'fontsize', 16);  

rmseyaw = rms(vcEul(3, :)*180/pi - px4Eul(3, :)*180/pi);
rmsepitch = rms(vcEul(2, :)*180/pi - px4Eul(2, :)*180/pi);
rmseroll = rms(vcEul(1, :)*180/pi - px4Eul(1, :)*180/pi);

stdyaw = std(vcEul(3, :)*180/pi - px4Eul(3, :)*180/pi);
stdpitch = std(vcEul(2, :)*180/pi - px4Eul(2, :)*180/pi);
stdroll = std(vcEul(1, :)*180/pi - px4Eul(1, :)*180/pi);

errsig = round([rmsex, rmsey, rmsez, rmsevx, rmsevy, rmsevz, rmseyaw, rmsepitch, rmseroll;
          stdx, stdy, stdz, stdvx, stdvy, stdvz, stdyaw, stdpitch, stdroll], 3);

figure('name', 'Vels and Flow', 'position', [865 100 560 420]);
subplot(2, 1, 1);
plot(t, vcV(1, :), 'r', t, px4V(1, :), 'g', t, corflow(1, :).*vcP(3, :), 'b');
subplot(2, 1, 2);
plot(t, vcV(2, :), 'r', t, px4V(2, :), 'g', t, -corflow(2, :).*vcP(3, :), 'b');