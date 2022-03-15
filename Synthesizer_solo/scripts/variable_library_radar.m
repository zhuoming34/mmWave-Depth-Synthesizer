% Revised radar variables, with configuration used in mmWave Studio
% 2022/03/12: added vibration errors
% 2022/03/14: removed snapshot setting, use #RX of elevation instead

%% user-defined variables
N_RX_az = 24; %24; % number of receiver (RX) in azimuth
N_RX_el = 2; %64; % # RX in elevation

N_sample = 256; % Number of ADC samples, or range bins in output radar heatmap
N_phi = 64; % number of azimuth bins in output radar heatmap
N_theta = 64; % number of elevation bins in output radar heatmap

azi_FOV = 120; % azimuth FOV in degrees
elv_FOV = 60; % elevation FOV in degrees

array_gap = [2.5e-3,2.5e-3]; % antenna element spacing, 2.5mm

% Dynamic transform / vibration settings    
% 'horizontal(left-right), horizontal(front-back), virtical(up-down)'
vibration_mode_radar = '000'; 
vibr_azi_lim = 2.5; vibr_rho_lim = 2.5; vibr_elv_lim = 2.5; % mm


%% FMCW radar parameters
c = 3e8; % speed of light
Fs = 60*1e9; % radar start frequeny
Rs = 2047e3; % sampling rate
%idleTime = 100e-6; % 100us
RampEndTime = 133e-6; % 133us
%ADCvalidStartTime = 6e-6; % 6us
As = 29.982e12; % sweep_slope, Hz/s, 29.982MHz/us
%As = BW/RampEndTime; % FMCW frequency sweep slope

lambda = c/Fs; % radar wavelength
BW = As*RampEndTime; %3987.61e6; % Bandwidth = 3987.61MHz, max 4e9;
fc = Fs + BW/2; % radar center frequeny 62GHz
Ts = N_sample/Rs; % FMCW sweep time, ADC sampling time


%% radar Field of View (FoV)
phi_min = 90-azi_FOV/2; phi_max = 90+azi_FOV/2; % azimuth, deg
theta_min = 90-elv_FOV/2; theta_max = 90+elv_FOV/2; % elevation, deg
rho_min = 0; rho_max = Rs*c/2/As; % range, m

phi_res_deg = 2/N_RX_az/pi*180; %4.77deg %1; % azimuth resolution = degree
theta_res_deg = 2/N_RX_el/pi*180; %1.79deg %1; % elevation resolution = degree
%rho_res = c/2/BW; % in m, range resolution, 3.8cm for 3987.61MHz
rho_res = c/2/(As*Ts); % in m, 4cm since cannot use whole BW due to ADC start time

radar_FoV_deg = [phi_min, phi_max; theta_min, theta_max]; % [58,121;76,107]; % azimuth and elevation field of view
radar_FoV_rad = radar_FoV_deg/180*pi; % angular FoV in radian
radar_FoV_rho = [rho_min,rho_max];% [3,15-0.125]; % range field of view

%N_phi = ceil((radar_FoV_deg(1,2)- radar_FoV_deg(1,1))/phi_res_deg); %64; % number of azimuth bins in the output radar heatmap
%N_theta = ceil((radar_FoV_deg(2,2)- radar_FoV_deg(2,1))/theta_res_deg); %32; % number of elevation bins in the output radar heatmap

phi_deg = linspace(radar_FoV_deg(1,1),radar_FoV_deg(1,2),N_phi); % azimuth axis of the output radar heatmap in degree
theta_deg = linspace(radar_FoV_deg(2,1),radar_FoV_deg(2,2),N_theta); % elevation axis of the output radar heatmap in degree
phi = phi_deg/180*pi; % in rad
theta = theta_deg/180*pi;

range_bin = linspace(0,(Rs-Rs/N_sample),N_sample) /As *c /2; % range axis 
range_bin_FoV = find((range_bin >= radar_FoV_rho(1))&(range_bin <= radar_FoV_rho(2))); % select range bins in the range field of view
rho =  range_bin(range_bin_FoV); % range axis of output radar heatmap
N_rho = length(rho); % number of range bins in the output radar heatmap


%% find spherical voxel center points coordinates and convert them into cartesian
[x_ct,y_ct,z_ct] = sph2cart_pts(N_phi,phi_min,phi_max,N_theta,theta_min,theta_max,N_rho,rho_min,rho_max);
ct_coord = [x_ct,y_ct,z_ct];
[azi_coord,elv_coord,rho_coord] = cart2sph(x_ct,y_ct,z_ct);
sp_coord = [azi_coord,elv_coord,rho_coord];


%% antenna array
tx_pos_x = -( 3*lambda + ((N_RX_az-1)/2) * (lambda/2))/1000; % m
tx_pos_y = 0;
tx_pos_z = -( ((N_RX_el-1)/2) * (lambda/2) )/1000; % m
TX_pos = [tx_pos_x, tx_pos_y, tx_pos_z]; 

% Hawkeye's example
% TX antenna position [0.44,0,0]
% For our custombuilt radar, TX is placed 44cm to the right of the origin (RX array center)

array_size = [N_RX_az,N_RX_el]; %[24,64]; %[40,40]; % antenna array size / number of elements on the x and z axis


array_x_idx = (1:array_size(1))-ceil(array_size(1)/2);
array_x_idx = array_x_idx.';
array_z_idx = (1:array_size(2))-ceil(array_size(2)/2);

array_x_m = repmat(array_x_idx*array_gap(1),1,array_size(2));
array_z_m = repmat(array_z_idx*array_gap(2),array_size(1),1);

if vibration_mode_radar(1) == '1'
   vibr_azi_err = normrnd(0,vibr_azi_lim/1000/3, [N_RX_az,N_RX_el]);
   array_x_m = array_x_m + vibr_azi_err;
end

if vibration_mode_radar(2) == '1'
   %vibr_err2 = normrnd(0,vibr2_lim/1000/3, size(rho));
   vibr_rho_err = normrnd(0,vibr_rho_lim/1000/3); % apply same error to all bins
   rho = rho + vibr_rho_err;
end

if vibration_mode_radar(3) == '1'
   vibr_elv_err = normrnd(0,vibr_elv_lim/1000/3, [N_RX_az,N_RX_el]);
   array_z_m = array_z_m + vibr_elv_err;
end

%{
%{
% number of snapsihots for generating 3d intensity maps
% snapshot => virtical scan (row of antenna array), refer to SuperRF
heatmap_scale = 1; % a number n (>=2) for n-snapshot, 1 for full-scale
if heatmap_scale > N_RX_el
    disp("!! Wrong heatmap scale is entered !!");
    error("#snapshot exceeds #antenna in elevation direction!");
end
%}
%{
while heatmap_scale > N_RX_el
    disp("!! Wrong heatmap scale is entered !!");
    disp("Enter a number n (>=2) for n-snapshot, 1 for full-scale.");
    heatmap_scale = input("Re-enter your scale mode: ");
end
%}
%{
if (heatmap_scale == 1 || heatmap_scale == N_RX_el) 
    array_size = [N_RX_az,N_RX_el]; %[24,64]; %[40,40]; % antenna array size / number of elements on the x and z axis
else
    array_size = [N_RX_az, heatmap_scale]; %[24,2]; 
end
%}
%}
  