%%% ---------------------------------------------------------------- %%%
%%% --------------------- Depth camera related --------------------- %%% 
%%% ---------------------------------------------------------------- %%%
rng(0) % set a seed for random vibrations in variable libraries
variable_library_scene; % load scenario setting 

N_pixel_col = 1280; N_pixel_row = 720;
focalL_px = 700; % focal lenght in pixel
pxSize = 0.004; % mm
focalL = focalL_px*pxSize/1000; % 2.8mm -> 0.0028m
ppH = N_pixel_col*pxSize/1000; ppV = N_pixel_row*pxSize/1000; % % projection plane size in m
cam_range_min = 0.1; 


cam_range_max = ceil(sqrt(SLE(1,2)^2 + SLE(2,2)^2) + max(abs(SLE(3,1)),SLE(3,2))^2);
if cam_range_max > 15.0
    cam_range_max = 15.0; % max depth by zed mini is 15m
end

% HFOV~=85deg, VFOV~=54deg, on ZED mini with HD720 
cam_hfov = 2*atan(N_pixel_col/2/focalL_px); cam_vfov = 2*atan(N_pixel_row/2/focalL_px); % rad
cam_hfov_deg = cam_hfov/pi*180; cam_vfov_deg = cam_vfov/pi*180;
cam_res_deg = atan(1/focalL_px); % one pixel length / focal lenght
%cam_lim_horz = range_lim_max*tan(cam_hfov/2); cam_lim_vert = range_lim_max*tan(cam_vfov/2); % max range the camera covers

%% Dynamic transform / vibration settings    
% 'x(left-right), y(front-back), z(up-down),'
vibration_mode_cam = '000'; 
%vibr_x_stdev = 2.0144; vibr_y_stdev = 1.2906; vibr_z_stdev = 3.1884; % mm
vibr_x_stdev = 1.6666; vibr_y_stdev = 1.6666; vibr_z_stdev = 3.3333; % mm

vibr_x_err = 0; vibr_y_err = 0; vibr_z_err = 0;
if vibration_mode_cam(1) == '1'
   vibr_x_err = normrnd(0,vibr_x_stdev/1000);
end

if vibration_mode_cam(2) == '1'
   vibr_y_err = normrnd(0,vibr_y_stdev/1000);
end

if vibration_mode_cam(3) == '1'
   vibr_z_err = normrnd(0,vibr_z_stdev/1000);
end


%%% settings below (for scene cropping and resizing) 
%%% are not used since 01/28/2022 (DeepPoint)

%%% --------------------------------------------------------------- %%%
%%% ------------- Depth image related senario setting ------------- %%% 
%%% --------------------------------------------------------------- %%%
% scene 2D plane boundary for depth image
scene_corners = [SLE(1),SLE(2),SLE(3); SLE(1),SLE(2),SLE(6);
                SLE(4),SLE(2),SLE(3); SLE(4),SLE(2),SLE(6)]; 
            %[-1,1.5,-0.5; -1,1.5,1.5;  1,1.5,-0.5; 1,1.5,1.5]; % dresser
scene_x = scene_corners(:,1); 
scene_y = scene_corners(:,2); 
scene_z = scene_corners(:,3);

% scene projection
scene_y_proj = linspace(focalL,focalL,size(scene_y,1))'; % focal length
scene_ratio = scene_y./scene_y_proj;
scene_x_proj = -scene_x./scene_ratio;
scene_z_proj = -scene_z./scene_ratio;
