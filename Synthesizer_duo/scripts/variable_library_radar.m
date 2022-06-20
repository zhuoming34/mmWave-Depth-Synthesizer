% Revised radar variables, with configuration used in mmWave Studio
% 2020/11/20

%% radar Field of View (FoV)
N_RX_az = 64;%24; % number of receiver (RX) in azimuth
N_RX_el = 32;%64; % # RX in elevation
phi_res_deg = 2/N_RX_az/pi*180; %4.77deg %1; % azimuth resolution = degree
theta_res_deg = 2/N_RX_el/pi*180; %1.79deg %1; % elevation resolution = degree

radar_FoV_deg = [30,149;75,104]; % [58,121;76,107]; % azimuth and elevation field of view
radar_FoV_rad = radar_FoV_deg/180*pi; % angular FoV in radian
radar_FoV_rho = [0,10+0.2011];% [3,15-0.125]; % range field of view

N_phi = 64; %64; % number of azimuth bins in the output radar heatmap
N_theta = 64; %32; % number of elevation bins in the output radar heatmap
%N_phi = ceil((radar_FoV_deg(1,2)- radar_FoV_deg(1,1))/phi_res_deg); %64; % number of azimuth bins in the output radar heatmap
%N_theta = ceil((radar_FoV_deg(2,2)- radar_FoV_deg(2,1))/theta_res_deg); %32; % number of elevation bins in the output radar heatmap

phi_deg = linspace(radar_FoV_deg(1,1),radar_FoV_deg(1,2),N_phi); % azimuth axis of the output radar heatmap in degree
theta_deg = linspace(radar_FoV_deg(2,1),radar_FoV_deg(2,2),N_theta); % elevation axis of the output radar heatmap in degree
phi = phi_deg/180*pi; % in rad
theta = theta_deg/180*pi;

%% FMCW radar parameters
c = 3e8; % speed of light
fc = 60*1e9; % radar center frequeny?? 
lambda = c/fc; % radar wavelength

%BW = 1.2e9; % FMCW bandwidth = 1.2 GHz
BW = 3987.61e6; % Bandwidth = 3987.61MHz
fc = 60*1e9+BW/2; % radar center frequeny 62GHz
rho_res = c/2/BW; % range resolution, 3.8cm for 3987.61MHz
%Ts = 0.8e-3; % FMCW sweep time = 0.8ms
%As = BW/Ts; % FMCW frequency sweep slope
As = 29.982e12; % Hz/s, 29.982MHz/us
%Rs = 5e5; % Baseband sampling rate = 500kHz
Rs = 2047e3; %2047ksps

%N_FFT = Ts*Rs; % FFT length / number of range bins
N_FFT = 256; % use the number directly here. 257 to have 256 bins, first one is all 0's
N_FFT = N_FFT + 1;
Ts = N_FFT/Rs; % FMCW sweep tim
range_bin = linspace(0,(Rs-Rs/N_FFT),N_FFT) /As *c /2; % range axis 
% TI's eqn does not need to -Rs/N_FFT, difference -> 4cm less in max range,
% and distributed into each range bin
range_bin_FoV = find((range_bin >= radar_FoV_rho(1))&(range_bin <= radar_FoV_rho(2))); % select range bins in the range field of view
rho =  range_bin(range_bin_FoV); % range axis of output radar heatmap
N_rho = length(rho); % number of range bins in the output radar heatmap

%% antenna array

% 11/21, TX_pos is used in simulate_radar_signal.m function
% lambda = 5mm
% 1/7/22, tx pos below is for array pattern of IWR6843ISK
tx_pos_x = -( 3*lambda + ((N_RX_az-1)/2) * (lambda/2))/1000; % m
tx_pos_y = 0;
tx_pos_z = -( ((N_RX_el-1)/2) * (lambda/2) )/1000; % m
TX_pos = [tx_pos_x, tx_pos_y, tx_pos_z]; % TX antenna position [0.44,0,0]
% For our custombuilt radar, TX is placed 44cm to the right of the origin (RX array center)

array_size = [N_RX_az,N_RX_el]; %[24,64]; %[40,40]; % antenna array size / number of elements on the x and z axis
array_size2 = [N_RX_az,2]; %[24,2];
array_gap = [2.5e-3,2.5e-3]; % antenna element spacing, 2.5mm

array_x_idx = (1:array_size(1))-ceil(array_size(1)/2);
array_x_idx = array_x_idx.';
array_z_idx = (1:array_size(2))-ceil(array_size(2)/2);

array_x_idx2 = (1:array_size2(1))-ceil(array_size2(1)/2);
array_x_idx2 = array_x_idx2.';
array_z_idx2 = (1:array_size2(2))-ceil(array_size2(2)/2);

% number of snapshots for generating 3d intensity maps
heatmap_scale = "full"; % "full" for full-scale, "2ss" for two-snapshot
  