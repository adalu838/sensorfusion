% h(t,x,u;th)
%  x: The position of the unknown object: [x y t0]
%  th: input [x1 y1 x2 y2 ... bias1 bias2 ... v] 

function h = h_tdoa2( t, x, u, th )
    count = 1;
    v = th(22);
    
    for i = 1:7
        for j = (i+1):7
            sensorpos1 = [th((i-1)*2+1) th((i-1)*2+2)]';
            sensorpos2 = [th((j-1)*2+1) th((j-1)*2+2)]';
            bias1 = th(14+i);
            bias2 = th(14+j);
            h(count) = (sqrt(sum((sensorpos1-x).^2)) - sqrt(sum((sensorpos2-x).^2)))/v + (bias1-bias2);
            count = count+1;
        end
    end
    h = h';
end

