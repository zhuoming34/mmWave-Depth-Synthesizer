%%% 02/17/2022: Combine functions in all stages, modified some variable names 
%%% 03/12/2022: added vibration error, minor function update
%%% 06/08/2022: updated logging function
function main_solo(object_name, CAD_idx, start_idx, stop_idx)
    %format shortg; clk0 = clock; disp(clk0);
    SLASH = checkOS(); % slashes are different in Mac/Linux("/") and Windows("\") for file paths
    
    %addpath('functions_main');
    % load libraries
    variable_library_scene;
    variable_library_radar;
    variable_library_camera;
    
    %% logging
    atnaInfo=strcat("Size of antenna array: ",num2str(N_RX_az),"x",num2str(N_RX_el)); disp(atnaInfo);
    vibrInfo=strcat("Vibration mode: Radar->",vibration_mode_radar,", Camera->",vibration_mode_cam); disp(vibrInfo);
    logFile = strcat("..",SLASH,"results",SLASH,object_name,"_",num2str(CAD_idx),SLASH,"log.txt");
    logging(logFile, object_name, CAD_idx, N_RX_az, N_RX_el, atn_bdl,...
    vibration_mode_radar, vibr_azi_stdev, vibr_rho_stdev, vibr_elv_stdev,...
    vibration_mode_cam, vibr_x_stdev, vibr_y_stdev, vibr_z_stdev,...
    N_sample, N_phi, N_theta, N_y_heat, N_x_heat, N_z_heat, N_pixel_col, N_pixel_row,...
    azi_FOV, phi_res_deg, elv_FOV, theta_res_deg, rho_max, rho_res,...
    cam_hfov_deg, cam_vfov_deg, cam_res_deg, cam_range_min, cam_range_max,...
    sensor_x, sensor_y, height_offset, top_offset, sensor_ang_deg, translate_lim,...
    heatmap_ceiling, threshold_factor);
    %type(logFile);
    
    %%  
    obj_addr = strcat("..",SLASH,"results",SLASH, object_name, "_", num2str(CAD_idx));

    % load the surface model
    cart_v = load(strcat("..",SLASH,"CAD",SLASH,object_name,"_",num2str(CAD_idx),".mat")).cart_v;

    % CAD models are loaded as point clouds of size N_pt by 3, where N_pt
    % is the number of points and 3 values are the cartesian coordinates
    % unit is mm

    % store point cloud in pc (point cloud) structure
    car_v = car_v_struct;
    car_v.CAD_idx = CAD_idx;
    car_v.N_pt = length(cart_v);
    car_v.cart_v = cart_v;
    car_v.lim = [min(cart_v);max(cart_v)]; % find the limits in all three dimensions 
    [bbox_x, bbox_y, bbox_z] = meshgrid(car_v.lim(:,1),car_v.lim(:,2),car_v.lim(:,3)); % 8 vertices of the bounding box of the point cloud
    car_v.bbox = [bbox_x(:), bbox_y(:), bbox_z(:)]; 
    clear cart_v bbox N_pt car_idx;
    car1_v_origin = car_v;

    for kso = start_idx:stop_idx
        ks = kso;
        rng(ks);
        result_addr = strcat(obj_addr,SLASH,num2str(ceil(ks/500)));
        for cs = 1:4                    
            if cs ~= 5
                view_idx = cs; 
                car_scene_v = car1_v_origin;
                %% Rotate
                if view_idx == 1
                    new_rotate = rotate_ang(randi(length(rotate_ang))); % randomly select a rotation angle and store it in the pc structure
                    car_scene_v.rotate = new_rotate;
                     %car_scene_v.rotate = mod(car_scene_v.rotate*(randi(1)*2-1),180);
                else
                    car_scene_v.rotate = new_rotate + sensor_ang_deg(view_idx);
                end

                % inline function for 2D rotation
                rotate2d =  @(x, M) (x(:, 1:2) * M);
                rotate_angle_rad = car_scene_v.rotate/180*pi;
                rotation_matrix = [cos(rotate_angle_rad), -sin(rotate_angle_rad); sin(rotate_angle_rad), cos(rotate_angle_rad)]; % create rotation matrix

                car_scene_v.cart_v(:,1:2) = rotate2d(car_scene_v.cart_v, rotation_matrix); % rotate the point cloud 
                car_scene_v.bbox(:,1:2) = rotate2d(car_scene_v.bbox, rotation_matrix); % rotate the bounding box
                car_scene_v.lim = [min(car_scene_v.cart_v);max(car_scene_v.cart_v)]; % update the limits in all three dimensions
                %% Translation
                translate_x_rng = (translate_lim(1,1)-car_scene_v.lim(1,1)) : translate_x_res : (translate_lim(1,2)-car_scene_v.lim(2,1)); % range of translation along x axis
                translate_y_rng = (translate_lim(2,1)-car_scene_v.lim(1,2)) : translate_y_res : (translate_lim(2,2)-car_scene_v.lim(2,2)); % range of translation along y axis
                %disp('trans lim')disp(translate_lim)disp('car scene lim') disp(car_scene_v.lim)disp('trans x rng')disp(translate_x_rng)disp('trans y rng')disp(translate_y_rng)
                switch view_idx 
                    case 1
                        new_x = translate_x_rng(randi(length(translate_x_rng))); % randomly select a translation distance along x axis
                        new_y = translate_y_rng(randi(length(translate_y_rng))); % randomly select a translation distance along y axis
                        translate_x = new_x;
                        translate_y = new_y;
                    case 2               
                        translate_x = new_y - sensor_y(view_idx);
                        translate_y = sensor_x(view_idx) - new_x;
                    case 3               
                        translate_x = -new_x;
                        translate_y = sensor_y(view_idx) - new_y;
                    case 4               
                        translate_x = sensor_y(view_idx) - new_y;
                        translate_y = -sensor_x(view_idx) + new_x;
                end
                translate_z = -height_offset; % move the point cloud down to compensate for the height of our radar 

                % translate
                car_scene_v.translate = [translate_x, translate_y, translate_z]; % store translation information in the pc structure
                car_scene_v.cart_v = car_scene_v.cart_v + car_scene_v.translate; % translate the point cloud
                car_scene_v.bbox = car_scene_v.bbox + car_scene_v.translate; % translate the bounding box
                car_scene_v.lim = [min(car_scene_v.cart_v);max(car_scene_v.cart_v)]; % update the limits in all three dimensions

                if view_idx == 1
                    cam_top = car_scene_v.cart_v;
                    %continue;
                end

            else
                view_idx = 0; % top view
                cam_top(:,2) = cam_top(:,2) - sensor_y(2); % y - 5m to origin
                cam_top(:,3) = cam_top(:,3) + height_offset; % z + 1.25m to ground
                y0s = cam_top(:,2); z0s = cam_top(:,3);
                cam_top(:,2) = z0s*(-1); cam_top(:,3) = y0s; % switch y & z, rotate about x                   
                cam_top(:,2) = cam_top(:,2) + top_offset;%7000;%7500; % 2+5m high from ground

                car_scene_v.cart_v = cam_top;
                car_scene_v.lim = [min(car_scene_v.cart_v);max(car_scene_v.cart_v)];
                [tbbox_x, tbbox_y, tbbox_z] = meshgrid(car_scene_v.lim(:,1),car_scene_v.lim(:,2),car_scene_v.lim(:,3)); % 8 vertices of the bounding box of the point cloud
                car_scene_v.bbox = [tbbox_x(:), tbbox_y(:), tbbox_z(:)]; 
            end

            % convert unit from mm to m
            car_scene_v.cart_v = car_scene_v.cart_v/1000; 
            car_scene_v.bbox = car_scene_v.bbox/1000; 
        
            %% display status
            %format shortg; clk = clock; disp(clk);
            disp(" ");disp(string(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm:ss z')));
            disp(strcat(object_name, " ", num2str(CAD_idx),", placement ", num2str(ks),", view ", num2str(view_idx)));
            
            %% Modle camera point reflectors in the scene
            disp("Generating depth image")
            [visible_cart_v_dep] = remove_occlusion_v1(car_scene_v,"cam",0); % remove occluded body of the car for dep image
            %save(strcat(rftaddr,'md_',num2str(CAD_idxs),'_pm_',num2str(ks),"_cam_",num2str(cam),'_CameraReflector','.mat'), 'visible_cart_v_dep');

            % vibration errors
            depPtCloud = visible_cart_v_dep;
            depPtCloud = depPtCloud + [vibr_x_err, vibr_y_err, vibr_z_err]; 
    
            DepthImg = pc2depImg(depPtCloud);       
            ColorMap = gray;
            depOrgFolder = strcat(result_addr,SLASH,"fig",SLASH,"1280x720");
            depthImgName = strcat(depOrgFolder,SLASH,"cam",num2str(view_idx),SLASH,num2str(ks),".png");
            imwrite(DepthImg, ColorMap, depthImgName); 

            %% Modle radar point reflectors in the scene
            disp("Generating radar signal")
            %[visible_cart_v] = remove_occlusion(car_scene_v); % remove occluded body of the car
            [visible_cart_v_rad] = remove_occlusion_v1(car_scene_v,"rad",0); 
            % reflector for radar signal
            try
                reflector_cart_v = model_point_reflector(visible_cart_v_rad,car_scene_v.bbox); % model point reflectors that reflect back to the radar receiver
            catch
                disp('error'); %continue;
            end
            %if isempty(reflector_cart_v)
            %    continue;
            %end
            %save(strcat(rftaddr,'md_',num2str(CAD_idx),'_pm_',num2str(ks),'_cam_',num2str(cam),'_RadarReflector','.mat'), 'reflector_cart_v');

            %% Add environmental noise
            [evnoise] = add_evn_noise();
            reflector_cart_v_noisy = [reflector_cart_v;evnoise];              
            %save(strcat(rftaddr,'md_',num2str(CAD_idxs),'_pm_',num2str(ks),'_cam_',num2str(cam),'_RadarReflector','.mat'), 'reflector_cart_v');
            %save(strcat(rftaddr,'md_',num2str(CAD_idxs),'_pm_',num2str(ks),'_cam_',num2str(cam),'_RadarReflectorNoisy','.mat'), 'reflector_cart_v_noisy');

            %% Simualte received radar signal in the receiver antenna array        
            %signal_array = simulate_radar_signal(reflector_cart_v);
            signal_array_noisy = simulate_radar_signal_v2(reflector_cart_v_noisy);
            %save(strcat(sigaddr,'md_',num2str(CAD_idx),'_pm_',num2str(ks),'_cam_',num2str(cam),'_signal_array','.mat'), 'signal_array');
            %save(strcat(sigaddr,'md_',num2str(CAD_idxs),'_pm_',num2str(ks),'_cam_',num2str(cam),'_signal_array_Noisy','.mat'), 'signal_array_noisy');

            %% Generate intensity maps in spherical coordinates
            disp("Generating spherical intensity map")
            %radar_heatmap_sph = genSphHeat(signal_array_noisy, "2ss"); % "full" of "2ss"
            %signal_array = signal_array_noisy;
            radar_heatmap_sph = radar_dsp(signal_array_noisy);
			%radar_heatmap_sph = round(radar_heatmap_sph,4);

            %% Convert intensity maps from spherical to Cartesian coordinates
            disp("Generating Cartesian intensity map")
            heatmap_ct = Sph2CartHeat(view_idx,radar_heatmap_sph,threshold_factor);
            saveaddr_heat_ct = strcat(result_addr,SLASH,"cartHeat");
            save(strcat(saveaddr_heat_ct,SLASH,"cam",num2str(view_idx),SLASH,num2str(ks),".mat"),'heatmap_ct');

            % finish
            %disp(" ")
            %disp(strcat("Model ", num2str(CAD_idx),", placement ", num2str(ks),", view ", num2str(view_idx), " finished"));
            %clk = clock; disp(clk); %format shortg
        end
    end
end


