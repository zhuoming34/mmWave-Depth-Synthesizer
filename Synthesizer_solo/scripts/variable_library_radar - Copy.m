% Revised radar variables, with configuration used in mmWave Studio
% 2022/03/12: added vibration errors
% 2022/03/14: removed snapshot setting, use #RX of elevation instead
% 2022/06/07: updated vibration errors, and fix problem in rho direction

%% user-defined variables
N_RX_az = 10; %24; % number of receiver (RX) in azimuth
N_RX_el = 2; %64; % # RX in elevation

N_sample = 256; % Number of ADC samples, or range bins in output radar heatmap
N_phi = 64; % number of azimuth bins in output radar heatmap
N_theta = 64; % number of elevation bins in output radar heatmap

azi_FOV = 60; % azimuth FOV in degrees
elv_FOV = 60; % elevation FOV in degrees

array_gap = [2.5e-3,2.5e-3]; % antenna element spacing in [x,z], 2.5mm

% Dynamic transform / vibration settings    
% 'horizontal(left-right), horizontal(front-back), virtical(up-down)'
vibration_mode_radar = '000'; 
% standard deviation at every step
vibr_azi_stdev = 2.0144; vibr_rho_stdev = 1.2906; vibr_elv_stdev = 3.1884; % mm
vibr_height_stdev = 15.6425;

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
array_rho_m = repmat(range_bin.',[1,array_size(1),array_size(2)]);

%%
% azimuth/x direction
if vibration_mode_radar(1) == '1'
    %vibr_azi_err = normrnd(0,vibr_azi_stdev/1000, [N_RX_az,N_RX_el]);
    array_x_err = zeros([N_RX_az,N_RX_el]); 
    acum_err_x = 0; %accumulated error
    cur_x = array_x_m(1,1);
    % from lower-left to upper-right
    for x_idx = 1:array_size(1)
        if mod(x_idx,2) == 1 % odd col, bottom-up
            lim_lower = 1; lim_upper = array_size(2); direction = 1;
        else % even col, top-down
            lim_lower = array_size(2); lim_upper = 1; direction = -1;
        end     
        for z_idx = lim_lower:direction:lim_upper
            acum_err_x = acum_err_x + normrnd(0,vibr_azi_stdev/1000);
            array_x_err(x_idx,z_idx) = cur_x + acum_err_x;
        end
        if z_idx == lim_upper
            cur_x = cur_x + array_gap(1); % move to next column
        end        
    end
    array_x_m = array_x_err;
end

% range/y direction
if vibration_mode_radar(2) == '1'
    array_rho_m_err = zeros(size(array_rho_m)); % 256 x Azi x Elv
    rho_err = zeros(size(range_bin));
    acum_err_y = 0; %accumulated error
    for x_idx = 1:array_size(1)
        if mod(x_idx,2) == 1 % odd col, bottom-up
            lim_lower = 1; lim_upper = array_size(2); direction = 1;
        else % even col, top-down
            lim_lower = array_size(2); lim_upper = 1; direction = -1;
        end 
        for z_idx = lim_lower:direction:lim_upper
            %vibr_rho_err = normrnd(0,vibr_rho_stdev/1000); % apply same error to all bins
            acum_err_y = acum_err_y + normrnd(0,vibr_rho_stdev/1000);
            array_rho_m_err(:,x_idx,z_idx) = range_bin.' + acum_err_y; % 256x1
        end
    end
    %array_rho_m_err(find(array_rho_m_err<0)) = 0;
    array_rho_m = array_rho_m_err;
end

% elevation/z direction
if vibration_mode_radar(3) == '1'
    %vibr_elv_err = normrnd(0,vibr_elv_stdev/1000, [N_RX_az,N_RX_el]);
    array_z_err = zeros([N_RX_az,N_RX_el]); 
    acum_err_z = 0; %accumulated error
    cur_z = array_z_m(1,1);
    % from lower-left to upper-right
    for x_idx = 1:array_size(1)
        if mod(x_idx,2) == 1 % odd col, bottom-up
            lim_lower = 1; lim_upper = array_size(2); direction = 1;
        else % even col, top-down
            lim_lower = array_size(2); lim_upper = 1; direction = -1;
        end     
        for z_idx = lim_lower:direction:lim_upper
            acum_err_z = acum_err_z + normrnd(0,vibr_elv_stdev/1000);
            array_z_err(x_idx,z_idx) = cur_z + acum_err_z;
            if z_idx ~= lim_upper
                cur_z = cur_z + array_gap(2)*direction; % next ideal position
            end 
        end
       
    end
    array_z_m = array_z_err;
end
