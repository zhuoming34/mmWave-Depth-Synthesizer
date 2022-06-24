%SLASH = checkOS(); % slashes are different in Mac/Linux("/") and Windows("\") for file paths
rng(0) % set a seed for random vibrations in variable libraries

%%% -------------------------------------------------------------- %%%
%%% ------------------- Scenario setup related ------------------- %%%
%%% -------------------------------------------------------------- %%%

% sensor positions
sensor_x = [0,5000,0,-5000]; % mm
sensor_y = [0,5000,10000,5000]; % mm
sensor_ang_deg = [0,90,180,270]; % orietation

height_offset = 1250; % mm, height of sensors on the ground
top_offset = 7000;  % mm, height of sensor for top-view

% angle of rotation for every model
rotate_ang_coarse = [0:5:360];%[5:5:175]; % [0,90]=head left, [90,180]=head right
rotate_ang_fine = [-5:5];
rotate_ang = [];
for k_rotate_ang_fine = rotate_ang_fine
    rotate_ang = [rotate_ang,rotate_ang_coarse+k_rotate_ang_fine];
end
rotate_ang = sort(rotate_ang);

%translate_lim = [-1000, 1000; 1500, 3500]; % limits of the translation along the x and y axis
translate_lim = [-2000, 2000; 3000, 7000]; % limits of the translation along the x and y axis
translate_x_res = 10; %500; % resolution of translation along the x axis unit: mm
translate_y_res = 10; %500; % resolution of translation along the y axis unit: mm


%%% --------------------------------------------------------------- %%%    
%%% -------------- Intensity maps conversion related -------------- %%%
%%% --------------------------------------------------------------- %%%
% size of 3D intensity maps in Cartesian
N_x_heat= 64; N_y_heat = 256; N_z_heat = 64;
heatmap_ceiling = 1750; %mm
% for filtering, a percentage of max intensity value will be dropped
threshold_factor = 5; % unit: percent 
threshold_factor = threshold_factor/100;

% scene 3D space boundary
% [x1,x2; y1,y2; z1,z2]
scene_lim_edge = [translate_lim(1,1), translate_lim(1,2); ...
                  translate_lim(2,1), translate_lim(2,2); ...
                  -height_offset, heatmap_ceiling]; 
              
scene_lim_edge = scene_lim_edge/1000;         
SLE = scene_lim_edge;
scene_lim_top = [SLE(1), SLE(4); ceil(top_offset/1000/2), top_offset/1000; SLE(1), SLE(4)];
scene_lim_corner = [SLE(1)*sqrt(2), SLE(4)*sqrt(2); 
    (sensor_x(2)-SLE(4))*sqrt(2), (sensor_x(2)+SLE(4))*sqrt(2); 
    SLE(3), SLE(6)];

%%% --------------------------------------------------------------- %%%
%%% -------------------- Point Cloud Structure -------------------- %%% 
%%% --------------------------------------------------------------- %%%

% structure of point cloud and information of the car CAD model
car_v_struct = struct('cart_v',[], ... % cartesian coordinates vector
                'sph_v',[], ... % spherical coordinates vector
                'N_pt',0, ... % # of points in the model
                'bbox',[], ... % bounding box of the car 
                'lim',[], ... % min and max xyz coordinates
                'CAD_idx',0, ...
                'rotate',[], ... % degree rotated
                'translate',[]); % distance translated

