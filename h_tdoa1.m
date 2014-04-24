% h(t,x,u;th)
%  x: The position of the unknown object: [x y t0]
%  th: input [x1 y1 x2 y2 ... bias1 bias2 ... v] 

function h = h_tdoa1( t, x, u, th )
    count = 1;
    v = th(22);

    for i = 1:7
        sensorpos1 = [th((i-1)*2+1) th((i-1)*2+2)]';
     	bias1 = th(14+i);
    	h(count) = sqrt((sensorpos1(1)-x(1)).^2 + (sensorpos1(2)-x(2)).^2)/v + x(3)/v;
    	count = count+1;
    end
    h = h';
end

