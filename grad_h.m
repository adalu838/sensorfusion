% h(t,x(t),u(t);th)
%  x: The position of the unknown object: [x y]
%  u: ??
%  th: input [x1 y1 bias1 x2 y2 bias2 ... x7 y7 bias7 v] 

function h = grad_h( x, th )
    count = 1;
    v = th(22);
    
    for i = 1:7
        for j = (i+1):7
            sensorpos1 = [th((i-1)*2+1) th((i-1)*2+2)]';
            sensorpos2 = [th((j-1)*2+1) th((j-1)*2+2)]';
            h(count,1) = ((-2*(sensorpos1(1)-x(1)))/sqrt(sum((sensorpos1-x).^2)) + (2*(sensorpos2(1)-x(1)))/sqrt(sum((sensorpos2-x).^2)))/v;
            h(count,2) = ((-2*(sensorpos1(2)-x(2)))/sqrt(sum((sensorpos1-x).^2)) + (2*(sensorpos2(2)-x(2)))/sqrt(sum((sensorpos2-x).^2)))/v;
            count = count+1;
        end
    end
    %h = h';
end

