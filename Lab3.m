clear all;
close all;
%initcourse TSRT14;
addpath Z:\sigsys\classes\
addpath Z:\sigsys\data\
addpath Z:\sigsys\mfiles\
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
sensors.th = [reshape(sensors_good',14,1);
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              v]';
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
for sample = 1:5:80
    % Calculate y
    k = 1;
    for i = 1:7
        for j = (i+1):7
            y(k,1) = tphat(sample,i)-tphat(sample,j);
            k = k+1;
        end
    end
    
    % Calculate V
    for x_ = 1:100
        for y_ = 1:150
            d = y - h_tdoa(0,[x_ y_]', 0, sensors.th);
            V(y_,x_) = d'*inv(diag(variance2))*d;
        end
    end
    figure;
    surface(V)
end

%% Bad configuration
load tphat_bad
sensors.th = [reshape(sensors_bad',14,1);
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              34385]';
%% 
for sample = 1:5:80
    % Calculate y
    k = 1;
    for i = 1:7
        for j = (i+1):7
            y(k,1) = tphat(sample,i)-tphat(sample,j);
            k = k+1;
        end
    end
    
    % Calculate V
    for x_ = 1:100
        for y_ = 1:150
            d = y - h_tdoa(0,[x_ y_]', 0, sensors.th);
            V(y_,x_) = d'*inv(diag(variance2))*d;
        end
    end
    figure;
    surface(V)
end

%% Localization: TDOA approach, Range parameter trilateration
sample = 10;
sensors = sensors_good;

A = zeros(21,2);
b = zeros(21,1);

k = 1;
for m = 1:7
    for j = (i+1):7
        
        t_m0 = (tphat(sample,m)-tphat(sample,0))^2;
        t_j0 = (tphat(sample,j)-tphat(sample,0))^2;
        
        A(k,1) = 2*sensors(m,1)/(v*t_m0) - 2*sensors(j,1)/(v*t_j0);
        A(k,2) = 2*sensors(m,2)/(v*t_m0) - 2*sensors(j,2)/(v*t_j0);
        b(k) = - (v*t_m0 - v*t_j0 - (sensors(m,1)^2 + sensors(m,2)^2)/(v*t_m0) + (sensors(j,1)^2 + sensors(j,2)^2)/(v*t_j0));
        
        k = k+1;
    end
end

x = A\b