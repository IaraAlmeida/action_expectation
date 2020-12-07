 function [Y_fake_points, YMatrix_NN] = imu4tom(X1, YMatrix1)

createfigure1(X1, YMatrix1);
title('Raw Values');

YMatrix_N = YMatrix1 - min(YMatrix1(:));
YMatrix_N = YMatrix_N ./ max(YMatrix_N(:));

createfigure1(X1, YMatrix_N);
title('Normalized Values');

for a = 1:length(X1)-1 
    delta1(a, :) = YMatrix_N(a+1, :)- YMatrix_N(a, :); 
end

for a = 2:length(X1)-1 
    delta2(a, :) = YMatrix_N(a-1, :)- YMatrix_N(a, :); 
end

[imu_turn1, which_imu1] = find(delta1>=0.3);
[imu_turn2, which_imu2] = find(delta2>=0.3);

which_imu = [which_imu1; which_imu2];
imu_turn = [imu_turn1; imu_turn2];
imu_turn = unique(imu_turn);

Y_fake_points = zeros(size(YMatrix1));
Y_fake_points(imu_turn, which_imu) = 0.2;
nirs_data.imuturnevent = Y_fake_points;

createfigure1(X1, YMatrix_N);
hold on;
plot(X1, Y_fake_points(:, 3), 'color', 'k');  
title('Normalized Values with IMU jitters identified');
grid on;

collapse = [imu_turn which_imu];

YMatrix_C = YMatrix1;
for val = (1:3)
    pair_ind = find(collapse(:,2)==val);
    pair_1 = pair_ind(1:2:end)
    pair_2 = pair_ind(2:2:end)
    %% introduce here better way of finding single points. This code doesn't
    %work for single points
    if pair_ind ~= 0
        if rem(length(pair_ind), 2) == 0
            pair_ind = pair_ind;
            f = 1
        else
            pair_ind = [pair_ind; pair_ind(end)+1]
            imu_turn = [imu_turn; imu_turn(end)+1]
            f=2
            if pair_2 ~= 0
                pair_2   = [pair_2; pair_2(end)+1]
                f = 3
            else
                pair_2   = [pair_1(end)+1]
                f = 4
            end
        end
    end
    %%
    pair_imu   = [imu_turn(pair_1) imu_turn(pair_2)];
    
    for p = 1:size(pair_imu, 1)
        if p == 1 %odd must adapt
       
            YMatrix_C(pair_imu(p,1)+1 : pair_imu(p,2), val) = ...
            YMatrix1( pair_imu(p,1)+1 : pair_imu(p,2) , val) - ...
            (...
            YMatrix1(pair_imu(p, 1)+1, val) - ...
            YMatrix1(pair_imu(p, 1), val) ...
            );
        
        else
            
            YMatrix_C(pair_imu(p,1) : pair_imu(p,2), val) = ...
            YMatrix1( pair_imu(p,1) : pair_imu(p,2) , val) + ...
            (...
            YMatrix1(pair_imu(p, 1)-1, val) - ...
            YMatrix1(pair_imu(p, 1), val) ...
            );
        end
            
        
        
    end
end

createfigure1(X1, YMatrix_C);
hold on; 
title('Values with IMU jitters corrected');
grid on;

 
YMatrix_NN = YMatrix_C - median(YMatrix_C(:, 1:3));
createfigure1(X1, YMatrix_NN);
title('Corrected for Median Displacement');

