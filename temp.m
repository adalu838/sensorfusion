clearvars A
clearvars b
clearvars x
sample = 2;
sensors = sensors_good;

%A = zeros(15,2);
%b = zeros(15,1);
figure(2)
axis([0 150 0 100])
for t = 1:80
    sample = t;
    k = 1;
    for m = 3:7
        j = 2;
        %for j = (m+1):7

            t_m0 = tphat(sample,m)-tphat(sample,1) - (bias(m) - bias(1));
            t_j0 = tphat(sample,j)-tphat(sample,1) - (bias(j) - bias(1));

            A(k,1) = 2*sensors(m,1)/(v*t_m0) - 2*sensors(j,1)/(v*t_j0);
            A(k,2) = 2*sensors(m,2)/(v*t_m0) - 2*sensors(j,2)/(v*t_j0);
            b(k) = - (v*t_m0 - v*t_j0 - (sensors(m,1)^2 + sensors(m,2)^2)/(v*t_m0) + (sensors(j,1)^2 + sensors(j,2)^2)/(v*t_j0));

            k = k+1;
        %end
    end
    x(:,t) = (A'*A)\A'*b';
    plot(x(1,:),x(2,:), '*')
    axis([0 150 0 100])
    %pause;
end


