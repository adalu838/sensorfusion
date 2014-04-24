% Good configuration
load tphat_good
tphat(1:88,:) = tphat(2:89,:);

sensors1.th = [reshape(sensors_good',14,1);
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              v]';
          
sensors2.th = [reshape(sensors_good',14,1);
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              v]';