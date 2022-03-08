%%% 03/03/2022
%%% Combine two CAD models
function main_v2(obj1_name, CAD1_idx, obj2_name, CAD2_idx, start_idx, stop_idx)
    % e.g. 2021 1 10 21 16 28, = Jan 10th, 9:16:28pm
    %format shortg; clk0 = clock; disp(clk0);
    SLASH = checkOS(); % slashes are different in Mac/Linux("/") and Windows("\") for file paths
    
    %addpath('functions_main');
    variable_library_scene;
    variable_library_radar;
    
    disp(strcat("Size of antenna array: ", num2str(N_RX_az), "x", num2str(N_RX_el)));
    disp(strcat("Scale of 3d maps: ", heatmap_scale));
    
    %%  
    %obj_addr = strcat("..",SLASH,"results",SLASH, obj1_name, "_", num2str(CAD1_idx));
    obj_addr = strcat("..",SLASH,"results",SLASH,obj1_name,num2str(CAD1_idx),"-",obj2_name,num2str(CAD2_idx));
    
    % load the surface model
    cart_v_1 = load(strcat("..",SLASH,"CAD",SLASH,obj1_name,"_",num2str(CAD1_idx),".mat")).cart_v;
    cart_v_2 = load(strcat("..",SLASH,"CAD",SLASH,obj2_name,"_",num2str(CAD2_idx),".mat")).cart_v;

    % CAD models are loaded as point clouds of size N_pt by 3, where N_pt
    % is the number of points and 3 values are the cartesian coordinates
    % unit is mm

    % store point cloud in pc (point cloud) structure
    % 1st CAD
    cad1_v_origin = cad_v_struct;     cad1_v_origin.CAD_idx = CAD1_idx;
    cad1_v_origin.cart_v = cart_v_1;   cad1_v_origin.N_pt = length(cart_v_1);
    cad1_v_origin.lim = [min(cart_v_1);max(cart_v_1)]; % find the limits in all three dimensions 
    % 8 vertices of the bounding box of the point cloud
    %[bbox1_x, bbox1_y, bbox1_z] = meshgrid(cad1_v.lim(:,1),cad1_v.lim(:,2),cad1_v.lim(:,3)); 
    %cad1_v.bbox = [bbox1_x(:), bbox1_y(:), bbox1_z(:)]; 
    
    % 2nd CAD
    cad2_v_origin = cad_v_struct;     cad2_v_origin.CAD_idx = CAD2_idx;
    cad2_v_origin.cart_v = cart_v_2;   cad2_v_origin.N_pt = length(cart_v_2);
    cad2_v_origin.lim = [min(cart_v_2);max(cart_v_2)]; % find the limits in all three dimensions 
    % 8 vertices of the bounding box of the point cloud
    %[bbox2_x, bbox2_y, bbox2_z] = meshgrid(cad2_v.lim(:,1),cad2_v.lim(:,2),cad2_v.lim(:,3)); 
    %cad2_v.bbox = [bbox2_x(:), bbox2_y(:), bbox2_z(:)]; 
    
    clear cart_v_1 cart_v_2 bbox N_pt car_idx;

    for kso = start_idx:stop_idx
        ks = kso;
        rng(ks);
        result_addr = strcat(obj_addr,SLASH,num2str(ceil(ks/500)));
        for cs = 1:4
            if cs ~= 5
                view_idx = cs; 
                cad1_v = cad1_v_origin;
                cad2_v = cad2_v_origin;
                %scene_v = cad1_v_origin;
                %% Rotate
                if view_idx == 1
                    new_rotate = rotate_ang(randi(length(rotate_ang))); % randomly select a rotation angle and store it in the pc structure
                    cad1_v.rotate = new_rotate;
                    cad2_v.rotate = new_rotate;
                    %car_scene_v.rotate = mod(car_scene_v.rotate*(randi(1)*2-1),180);
                else
                    cad1_v.rotate = new_rotate + sensor_ang_deg(view_idx);
                    cad2_v.rotate = new_rotate + sensor_ang_deg(view_idx);
                end

                % inline function for 2D rotation
                rotate2d =  @(x, M) (x(:, 1:2) * M);
                
                rotate_angle_rad_1 = cad1_v.rotate/180*pi;
                rotation_matrix_1 = [cos(rotate_angle_rad_1), -sin(rotate_angle_rad_1); sin(rotate_angle_rad_1), cos(rotate_angle_rad_1)]; % create rotation matrix

                rotate_angle_rad_2 = cad2_v.rotate/180*pi;
                rotation_matrix_2 = [cos(rotate_angle_rad_2), -sin(rotate_angle_rad_2); sin(rotate_angle_rad_2), cos(rotate_angle_rad_2)]; % create rotation matrix

                cad1_v.cart_v(:,1:2) = rotate2d(cad1_v.cart_v, rotation_matrix_1); % rotate the point cloud 
                %cad1_v.bbox(:,1:2) = rotate2d(cad1_v.bbox, rotation_matrix_1); % rotate the bounding box
                cad1_v.lim = [min(cad1_v.cart_v);max(cad1_v.cart_v)]; % update the limits in all three dimensions

                cad2_v.cart_v(:,1:2) = rotate2d(cad2_v.cart_v, rotation_matrix_2); % rotate the point cloud 
                %cad2_v.bbox(:,1:2) = rotate2d(cad2_v.bbox, rotation_matrix_2); % rotate the bounding box
                cad2_v.lim = [min(cad2_v.cart_v);max(cad2_v.cart_v)]; % update the limits in all three dimensions                
                
                %% Translation
                translate_x_rng1 = (translate_lim_1(1,1)-cad1_v.lim(1,1)) : translate_x_res : (translate_lim_1(1,2)-cad1_v.lim(2,1)); % range of translation along x axis
                translate_y_rng1 = (translate_lim_1(2,1)-cad1_v.lim(1,2)) : translate_y_res : (translate_lim_1(2,2)-cad1_v.lim(2,2)); % range of translation along y axis
                
                translate_x_rng2 = (translate_lim_2(1,1)-cad2_v.lim(1,1)) : translate_x_res : (translate_lim_2(1,2)-cad2_v.lim(2,1)); % range of translation along x axis
                translate_y_rng2 = (translate_lim_2(2,1)-cad2_v.lim(1,2)) : translate_y_res : (translate_lim_2(2,2)-cad2_v.lim(2,2)); % range of translation along y axis
                
                %disp('trans lim')disp(translate_lim)disp('car scene lim') disp(car_scene_v.lim)disp('trans x rng')disp(translate_x_rng)disp('trans y rng')disp(translate_y_rng)
                switch view_idx 
                    case 1
                        new_x1 = translate_x_rng1(randi(length(translate_x_rng1))); % randomly select a translation distance along x axis
                        new_y1 = translate_y_rng1(randi(length(translate_y_rng1))); % randomly select a translation distance along y axis
                        translate_x1 = new_x1;  translate_y1 = new_y1;
                        
                        %rng(ks+10); % different translations
                        new_x2 = translate_x_rng2(randi(length(translate_x_rng2)));
                        new_y2 = translate_y_rng2(randi(length(translate_y_rng2)));
                        translate_x2 = new_x2;  translate_y2 = new_y2;
                        
                    case 2               
                        translate_x1 = new_y1 - sensor_y(view_idx);
                        translate_y1 = sensor_x(view_idx) - new_x1;
                        
                        translate_x2 = new_y2 - sensor_y(view_idx);
                        translate_y2 = sensor_x(view_idx) - new_x2;
                        
                    case 3               
                        translate_x1 = -new_x1;
                        translate_y1 = sensor_y(view_idx) - new_y1;
                        
                        translate_x2 = -new_x2;
                        translate_y2 = sensor_y(view_idx) - new_y2;
                        
                    case 4               
                        translate_x1 = sensor_y(view_idx) - new_y1;
                        translate_y1 = -sensor_x(view_idx) + new_x1;
                        
                        translate_x2 = sensor_y(view_idx) - new_y2;
                        translate_y2 = -sensor_x(view_idx) + new_x2;
                        
                end
                translate_z = -height_offset; % move the point cloud down to compensate for the height of our radar 

                % translate
                cad1_v.translate = [translate_x1, translate_y1, translate_z]; % store translation information in the pc structure
                cad1_v.cart_v = cad1_v.cart_v + cad1_v.translate; % translate the point cloud
                
                cad2_v.translate = [translate_x2, translate_y2, translate_z]; % store translation information in the pc structure
                cad2_v.cart_v = cad2_v.cart_v + cad2_v.translate; % translate the point cloud
                
                % combine 2 CADs
                scene_v.cart_v = [cad1_v.cart_v; cad2_v.cart_v];   
                scene_v.N_pt = length(scene_v.cart_v);
                scene_v.lim = [min(scene_v.cart_v);max(scene_v.cart_v)]; % update the limits in all three dimensions
                [bbox_x, bbox_y, bbox_z] = meshgrid(scene_v.lim(:,1),scene_v.lim(:,2),scene_v.lim(:,3)); % 8 vertices of the bounding box of the point cloud
                scene_v.bbox = [bbox_x(:), bbox_y(:), bbox_z(:)]; 

                if view_idx == 1
                    top_view = scene_v.cart_v;
                    %continue;
                end

            else
                view_idx = 0; % top view
                top_view(:,2) = top_view(:,2) - sensor_y(2); % y - 5m to origin
                top_view(:,3) = top_view(:,3) + height_offset; % z + 1.25m to ground
                y0s = top_view(:,2); z0s = top_view(:,3);
                top_view(:,2) = z0s*(-1); top_view(:,3) = y0s; % switch y & z, rotate about x                   
                top_view(:,2) = top_view(:,2) + top_offset;%7000;%7500; % 2+5m high from ground
                
                scene_v.cart_v = top_view;
                scene_v.lim = [min(scene_v);max(scene_v)]; % find the limits in all three dimensions 
                [tbbox_x, tbbox_y, tbbox_z] = meshgrid(scene_v.lim(:,1),scene_v.lim(:,2),scene_v.lim(:,3)); % 8 vertices of the bounding box of the point cloud
                scene_v.bbox = [tbbox_x(:), tbbox_y(:), tbbox_z(:)]; 
            end
         
            % convert unit from mm to m
            scene_v.cart_v = scene_v.cart_v/1000; 
            scene_v.bbox = scene_v.bbox/1000; 
            
            format shortg; clk = clock; disp(clk);
            disp(strcat(obj1_name, " ", num2str(CAD1_idx),", placement ", num2str(ks),", view ", num2str(view_idx)));
        
            %% Modle camera point reflectors in the scene
            disp("Generating depth image")
            [visible_cart_v_dep] = remove_occlusion_v1(scene_v,"cam",0); % remove occluded body of the car for dep image
            %save(strcat(rftaddr,'md_',num2str(CAD_idxs),'_pm_',num2str(ks),"_cam_",num2str(cam),'_CameraReflector','.mat'), 'visible_cart_v_dep');

            [DepthImg, ColorMap] = pc2depImg(visible_cart_v_dep);       
            depOrgFolder = strcat(result_addr,SLASH,"fig",SLASH,"1280x720");
            depthImgName = strcat(depOrgFolder,SLASH,"cam",num2str(view_idx),SLASH,num2str(ks),".png");
            imwrite(DepthImg, ColorMap, depthImgName); 

            %% Modle radar point reflectors in the scene
            disp("Generating radar signal")
            %[visible_cart_v] = remove_occlusion(car_scene_v); % remove occluded body of the car
            [visible_cart_v_rad] = remove_occlusion_v1(scene_v,"rad",0); 
            % reflector for radar signal
            try
                reflector_cart_v = model_point_reflector(visible_cart_v_rad,scene_v.bbox); % model point reflectors that reflect back to the radar receiver
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
            signal_array_noisy = simulate_radar_signal(reflector_cart_v_noisy);
            %save(strcat(sigaddr,'md_',num2str(CAD_idx),'_pm_',num2str(ks),'_cam_',num2str(cam),'_signal_array','.mat'), 'signal_array');
            %save(strcat(sigaddr,'md_',num2str(CAD_idxs),'_pm_',num2str(ks),'_cam_',num2str(cam),'_signal_array_Noisy','.mat'), 'signal_array_noisy');

            %% Generate intensity maps in spherical coordinates
            disp("Generating spherical intensity map")
            %radar_heatmap_sph = genSphHeat(signal_array_noisy, "2ss"); % "full" of "2ss"
            signal_array = signal_array_noisy;
            if (heatmap_scale == "full")
                radar_heatmap_sph = radar_dsp(signal_array);
            elseif (heatmap_scale == "2ss")
                ctr_snapshot = ceil(size(signal_array,3)/2);
                signal_array_2 = signal_array(:,:,ctr_snapshot:ctr_snapshot+1); % 2 snapshots in the middle vertically
                radar_heatmap_sph = radar_dsp2ss(signal_array_2);
            else
                error('Please enter the correct scale of snapshot: "full" or "2ss"');
            end

            %% Convert intensity maps from spherical to Cartesian coordinates
            disp("Generating Cartesian intensity map")
            heatmap_ct = Sph2CartHeat(view_idx,radar_heatmap_sph,threshold_factor);
            saveaddr_heat_ct = strcat(result_addr,SLASH,"cartHeat");
            save(strcat(saveaddr_heat_ct,SLASH,"cam",num2str(view_idx),SLASH,num2str(ks),".mat"),'heatmap_ct');

            % finish
            disp(" ")
            %disp(strcat("Model ", num2str(CAD_idx),", placement ", num2str(ks),", view ", num2str(view_idx), " finished"));
            %clk = clock; disp(clk); %format shortg
        end
    end
end
