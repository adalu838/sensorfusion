clear all;
close all;
%initcourse TSRT14;
addpath Z:\sigsys\classes\
addpath Z:\sigsys\data\
addpath Z:\sigsys\mfiles\
load tphat_calibrate
%% 1. 

m = mean(tphat, 2);
e = tphat - m(:,ones(1,7));

bias = mean(e);
variance = var(e);

for i = 1:7
    subplot(3,3,i);
    [N, l ] = hist(e(:,i) ,20);
    Wb = l(2) - l(1); % Bin width
    Ny = length(e ); % Nr of samples
    bar(l , N /( Ny * Wb ));
    
    hold on;
    pe = ndist(bias(i), variance(i));
    plot(pe)
end
 
%% 2. & 3.

% Calculate pe for all tdoa differences
count = 1;
for i = 1:7
    for j = (i+1):7
        variance2(count) = variance(i) + variance(j);
        count = count+1;
    end
end
pe = ndist(zeros(21,1), diag(variance2));

% Createn SENSORMOD object
sensors = sensormod('h_tdoa',[2 0 21 22]);
sensors.P = zeros(22,22);
% Setup sensors
sensors.th = [80; 0; 
              122; 36;
              100; 99;
              35; 99;
              0; 72;
              0; 30;
              30; 0;
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              34385]';
sensors.x0 = [67 52];
sensors.pe = pe;

% Plot
figure(2)
plot(sensors, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14])

%% 4. 

% a) for TDOA measurements using pairwise differences
% Calculate NLS loss function in a grid
%% Good configuration 
load tphat_good
%% 
for sample = 1
    % Calculate y
    k = 1;
    for i = 1:7
        for j = (i+1):7
            y(k,1) = tphat(sample,i)-tphat(sample,j);
            k = k+1;
        end
    end
    
    % Calculate V
    for x_ = 1:150
        for y_ = 1:100
            d = y - h_tdoa(0,[x_ y_]', 0, sensors.th);
            V(y_,x_) = d'*inv(diag(variance2))*d;
        end
    end
    figure;
    contour(V);
    hold on;
    plot(sensors, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14])
end

%% Bad configuration
load tphat_bad
sensors.th = [0; 97; 
              0; 85;
              0; 74;
              0; 56;
              0; 34;
              0; 17;
              0; 0;
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              34385]';
%% 
for sample = 1:2:20
    % Calculate y
    k = 1;
    for i = 1:7
        for j = (i+1):7
            y(k,1) = tphat(sample,i)-tphat(sample,j);
            k = k+1;
        end
    end
    
    % Calculate V
    for x_ = 1:150
        for y_ = 1:100
            d = y - h_tdoa(0,[x_ y_]', 0, sensors.th)
            V(y_,x_) = d'*inv(diag(variance2))*d;
        end
    end
    figure;
    contour(V);
    hold on;
    plot(sensors, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14]);
end
    
%% 5. Localisation: Gauss-Newton
%Calculate measurement y
traj = [];
for sample = 1:1:89
k = 1;
for i = 1:7
    for j = (i+1):7
        y(k,1) = tphat(sample,i)-tphat(sample,j);
        k = k+1;
    end
end
    
% Arbituary initial condition
x_hat0 = [66 34]';
V_0 = 0;
alpha = 1;
plot_values = [x_hat0];
   
r = 1;
while r < 100
    
    x_hat = x_hat0 + alpha*inv((grad_h(x_hat0,sensors.th))'*inv(diag(variance2))*grad_h(x_hat0,sensors.th))...
            *(grad_h(x_hat0,sensors.th))'*inv(diag(variance2))...
            *(y - h_tdoa(0, x_hat0, 0, sensors.th));
    
    % Calculate V
    d = y - h_tdoa(0,x_hat, 0, sensors.th);
    V = d'*d;
    
    if V > V_0
        alpha = alpha*0.9;
    else
        alpha = 1;
    end
    
    plot_values = [plot_values x_hat];
    r = r + 1;
    
    if abs(x_hat0 - x_hat) < 0.01
        break;
    end
    
    V_0 = V;
    x_hat0 = x_hat;
end
% figure;
% plot(67,52,'r*');
% hold on;
traj = [traj x_hat];
% figure;
% plot(plot_values(1,:),plot_values(2,:), 'ko-');

end

plot(traj(1,:),traj(2,:), 'ok');
hold on;
plot(sensors, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14])
clc;


%% 6. Tracking: Two motion models, EKF.
T = 0.5;

%ydata = traj';

% Constant velocity model
cvmodel = exlti('cv2d');
cvnl = nl(cvmodel);

yv = sig(ydata,1/T);
xhatv = ekf(cvnl,yv, 'R', 100*eye(4));
xcrlbv = crlb(cvnl,yv);

figure;
xplot2(xhatv,'conf',90);

%% Constant acceleration model
camodel = exlti('ca2d');
canl = nl(camodel);

ya = simulate(camodel,10);
xhata = ekf(canl,ya);
xcrlba = crlb(cvnl,ya);

figure;
xplot2(xcrlba, xhata,'conf',90);




