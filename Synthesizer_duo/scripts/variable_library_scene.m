%N_CAD_car=1; % number of CAD models of cars, max =38
%N_placement = 500; % # of placement we create with every selected car/group of cars
%SLASH = checkOS(); % slashes are different in Mac/Linux("/") and Windows("\") for file paths

%%% -------------------------------------------------------------- %%%
%%% ------------------- Scenario setup related ------------------- %%%
%%% -------------------------------------------------------------- %%%

% sensor positions
sensor_x = [0,3500,0,-3500]; % mm
sensor_y = [0,3500,7000,3500]; % mm
sensor_ang_deg = [0,90,180,270]; % orietation

height_offset = 500; % mm, height of sensors on the ground
top_offset = 7000;  % mm, height of sensor for top-view

% angle of rotation for every model
rotate_ang_coarse = [0:5:360];%[5:5:175]; % [0,90]=head left, [90,180]=head right
rotate_ang_fine = [-5:5];
rotate_ang = [];
for k_rotate_ang_fine = rotate_ang_fine
    rotate_ang = [rotate_ang,rotate_ang_coarse+k_rotate_ang_fine];
end
rotate_ang = sort(rotate_ang);

% limits of the translation along the x and y axis
translate_lim_1 = [-1500, -500; 2000, 3000]; % for 1st CAD
translate_lim_2 = [-500, 1500; 3000, 5000]; % for 2nd CAD

translate_x_res = 10; %500; % resolution of translation along the x axis unit: mm
translate_y_res = 10; %500; % resolution of translation along the y axis unit: mm


%%% --------------------------------------------------------------- %%%    
%%% -------------- Intensity maps conversion related -------------- %%%
%%% --------------------------------------------------------------- %%%
% size of 3D intensity maps in Cartesian
N_x_heat= 64; N_y_heat = 256; N_z_heat = 64;

% scene 3D space boundary
scene_lim_edge = [-1.5, 1.5; 2, 5; -0.5, 1]; % [x1,x2; y1,y2; z1,z2]
SLE = scene_lim_edge;
scene_lim_top = [SLE(1), SLE(4); ceil(top_offset/1000/2), top_offset/1000; SLE(1), SLE(4)];
scene_lim_corner = [SLE(1)*sqrt(2), SLE(4)*sqrt(2); 
    (sensor_x(2)-SLE(4))*sqrt(2), (sensor_x(2)+SLE(4))*sqrt(2); 
    SLE(3), SLE(6)];

% a factor to times the max intensity value for filtering
threshold_factor = 0.05; 


%%% --------------------------------------------------------------- %%%
%%% --------------------- Depth image related --------------------- %%% 
%%% --------------------------------------------------------------- %%%
variable_library_camera;
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


%%% --------------------------------------------------------------- %%%
%%% -------------------- Point Cloud Structure -------------------- %%% 
%%% --------------------------------------------------------------- %%%

% structure of point cloud and information of the CAD model
cad_v_struct = struct('cart_v',[], ... % cartesian coordinates vector
                'sph_v',[], ... % spherical coordinates vector
                'N_pt',0, ... % # of points in the model
                'bbox',[], ... % bounding box of the car 
                'lim',[], ... % min and max xyz coordinates
                'CAD_idx',0, ...
                'rotate',[], ... % degree rotated
                'translate',[]); % distance translated

