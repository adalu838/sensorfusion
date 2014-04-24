clear all;
close all;
%initcourse TSRT14;
addpath sigsys/classes/
addpath sigsys/data/
addpath sigsys/mfiles/
load tphat_calibrate

% Velocity of sound:
v = 34385;
sensors_good =   [80 0; 
                  122 36;
                  100 99;
                  35 99;
                  0 72;
                  0 30;
                  30 0];
sensors_bad =    [0 97; 
                  0 85;
                  0 74;
                  0 56;
                  0 34;
                  0 17;
                  0 0];

clc;
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

pe1 = ndist(zeros(7,1),diag(variance));
pe2 = ndist(zeros(21,1), diag(variance2));

%% Create SENSORMOD object with tdoa1
sensors1 = sensormod('h_tdoa1',[3 0 7 22]);
sensors1.P = zeros(22,22);
sensors1.x0 = [67 52 0];
sensors1.pe = pe1;

% Create SENSORMOD object with tdoa2
sensors2 = sensormod('h_tdoa2',[2 0 21 22]);
sensors2.P = zeros(22,22);
sensors2.x0 = [67 52];
sensors2.pe = pe2;

%% Good configuration
load tphat_good

sensors1.th = [reshape(sensors_good',14,1);
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              34385]';
% Plot
figure(2); clf;
subplot(211);
plot(sensors1, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14])
          
sensors2.th = [reshape(sensors_good',14,1);
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              34385]';
% Plot
figure(2)
subplot(212);
plot(sensors2, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14])

%% Bad configuration
load tphat_bad

sensors1.th = [reshape(sensors_bad',14,1);
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              34385]';
% Plot
figure(2); clf;
subplot(211);
plot(sensors2, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14])
          
sensors2.th = [reshape(sensors_bad',14,1);
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              34385]';
% Plot
figure(2)
subplot(212);
plot(sensors2, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14])
          
%% 4. 
% a) for TDOA measurements using pairwise differences
% Calculate NLS loss function in a grid
%% Good configuration 
goodconf;
figure(3)
for sample = 1
    % Calculate y
    k = 1;
    for i = 1:7
        for j = (i+1):7
            y(k,1) = tphat(sample,i) - bias(i) - tphat(sample,j) + bias(j);
            k = k+1;
        end
    end
    
    % Calculate V
    for x_ = 1:150
        for y_ = 1:100
            d = y - h_tdoa2(0,[x_ y_]', 0, sensors2.th);
            V(y_,x_) = d'*inv(diag(variance2))*d;
        end
    end
    
    subplot(2,1,1);
    contour(V);
    hold on;
    plot(sensors2, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14])
end

% Bad configuration
badconf; 

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
            d = y - h_tdoa2(0,[x_ y_]', 0, sensors2.th);
            V(y_,x_) = d'*inv(diag(variance2))*d;
        end
    end
    
    subplot(2,1,2);
    contour(V);
    hold on;
    plot(sensors2, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14]);
end

%% 5. b) Localisation: Gauss-Newton
%Calculate measurement y
x = [];
sensors1.x0 = [67 52 50];
for sample = 1:89

for i = 1:7
    y(i,1) = tphat(sample,i) - bias(i);
end

yv = sig(y',2);
[shat res] = estimate(sensors1,yv,'thmask', zeros(22,1), 'alg', 'gn');
xhat = sig(shat);
x = [x; xhat.x];
end

figure(4)
plot(x(:,1),x(:,2), '*');

%% 5. d) Localization: TDOA Differences to eliminate r0
goodconf;

sm = exsensor('tdoa2', 7, 1,2);
sm.th = reshape(sensors_good',14,1);
sm.x0 = [67 52]';
sm.pe = pe2;

figure(7)

x = [0 0];

for sample = 1:1:81

    k = 1;
    for i = 1:7
        for j = (i+1):7
            y(k,1) = (tphat(sample,i)-tphat(sample,j))*v;
            k = k+1;
        end
    end

    y_sig = sig(y');
    %y_sig = simulate(sm,1)
    [xhat, shat] = wls(sm, y_sig);
    %xhat = sig(shat)
    xplot2(xhat)
    hold on
    
    x(sample, :) = xhat.x;
end

%% 6. Tracking: Two motion models, EKF.
T = 0.5;

ydata = x;

% Constant velocity model
cvmodel = exlti('cv2d');
cvmodel.R = 400*cvmodel.R;
cvnl = nl(cvmodel);
cvnl.px0 =

yv = sig(ydata,1/T);
xhatv = ekf(cvnl,yv,'R',8);

figure(8)
xplot2(xhatv,'conf',90);
hold on;
plot(ydata(:,1),ydata(:,2),'*r')

%% Coordinated turn model

mm2 = exmotion('ctcv2d');
mm2.x0 = [0.67; 0.52; 0.05; 0; 0];

sm1 = exsensor('gps2d');
mm2 = addsensor(mm2, sm1);
mm2.px0 = 0.01*diag([1 1 1 1 1]);
mm2.pe = ndist([0 0]', 0.003*eye(2));

y = x/100;

xhata = ekf(mm2,sig(y, 2));

figure(9)
clf
xplot2(xhata,'conf',90);
hold on;
plot(x(:,1),x(:,2),'*r')

%% 6. b)

% Create SENSORMOD object with tdoa2
sensors2 = sensormod('h_tdoa2_simple',[2 0 6 22]);
sensors2.P = zeros(22,22);
sensors2.x0 = [67 52];

% Calculate pe for tdoa differences
i = 1;
variance2 = zeros(1,6);
for j = (i+1):7
    variance2(j-1) = variance(i) + variance(j);
end
sensors2.pe = ndist(zeros(6,1), diag(variance2));

goodconf;

x = [0 0];
y = [];
clf;
figure(8)
for sample = 1:1:80
    k = 1;
    i = 1;
    for j = (i+1):7
        y(k) = (tphat(sample,i)-tphat(sample,j));
        k = k+1;
    end

    y_sig = sig(y);
    [xhat, shat] = wls(sensors2, y_sig);
    xplot2(xhat)
    hold on
    
    x(sample, :) = xhat.x;
end

% Use particle filter
cvmodel = exlti('cv2d');
%cvmodel.R = 30*cvmodel.R;
cvnl = nl(cvmodel);

zhat = pf(cvnl, sig(x), 'Np', 50000);
figure(9)
xplot2(zhat);
