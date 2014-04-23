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
        alpha = alpha*0.2;
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

%plot(plot_values(1,:),plot_values(2,:), 'ko-');
end

plot(traj(1,:),traj(2,:), 'ok');
% hold on;
% plot(sensors, 'thind', [1 2 3 4 5 6 7 8 9 10 11 12 13 14])
% clc;