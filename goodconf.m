% Good configuration
load tphat_good
tphat(1:88,:) = tphat(2:89,:);

sensors1.th = [80; 0; 
              122; 36;
              100; 99;
              35; 99;
              0; 72;
              0; 30;
              30; 0;
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              34385]';
          
sensors2.th = [80; 0; 
              122; 36;
              100; 99;
              35; 99;
              0; 72;
              0; 30;
              30; 0;
              bias(1);bias(2);bias(3);bias(4);bias(5);bias(6);bias(7);
              34385]';