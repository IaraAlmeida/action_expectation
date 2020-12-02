load('C:\Users\Daphne\Desktop\PilotTommasoAugust\Oxy4_2_mat\S_Npred_01.mat')

answer1 = questdlg('Where was your Brite?', ...
	'Position Options', ...
	'Top of Head','Forehead','Other');

answer2 = questdlg('Which ADC channels carry your Brite?', ...
	'If you do not know, check nirs_data.ADlabel', ...
	'1 2 3','5 6 7', 'Other');

% Handle response
switch answer1
    case 'Top of Head'
        disp([answer1 'Coming right up.'])
        
        switch answer2
            case '1 2 3'
                data_vals = nirs_data.ADvalues(:, 1:3);
                
                case '5 6 7'
                data_vals = nirs_data.ADvalues(:, 5:7);
        end

        %For Brite Top of Head
        
        [imu_error_indexes, corrected_imu] = imu4tom(nirs_data.time, data_vals);

        cor_imu(:, 1) = - corrected_imu(:,2);
        cor_imu(:, 2) = - corrected_imu(:,3);
        cor_imu(:, 3) = - corrected_imu(:,1);
        
        createfigure1(nirs_data.time, cor_imu);
        title('Corrected for Head Position Cz');
        
    case 'Forehead'
        disp([answer1 'Coming right up.'])
        dessert = 2;
        
        switch answer2
            case '1 2 3'
                data_vals = nirs_data.ADvalues(:, 1:3);
                case '5 6 7'
                data_vals = nirs_data.ADvalues(:, 5:7);
        end
        
        %For Brite Forehead
        
        [imu_error_indexes, corrected_imu] = imu4tom(nirs_data.time, data_vals);
        
        cor_imu(:, 1) = corrected_imu(:,1);
        cor_imu(:, 2) = - corrected_imu(:,2);
        cor_imu(:, 3) = - corrected_imu(:,3);
        
        createfigure1(nirs_data.time, cor_imu);
        title('Corrected for Head Position Forehead');
        
    case 'Other'
        disp('There is no correction for your position!')
        disp('Contact iara@artinis.com to improve this function')
        disp('Anyway, here are the values for a Brite at the Standard Back of the head')
        
        [imu_error_indexes_brite1, corrected_imu_brite1] = imu4tom(nirs_data.time, nirs_data.ADvalues(:, 1:3));
        [imu_error_indexes_brite2, corrected_imu_brite2] = imu4tom(nirs_data.time, nirs_data.ADvalues(:, 1:3));

end



