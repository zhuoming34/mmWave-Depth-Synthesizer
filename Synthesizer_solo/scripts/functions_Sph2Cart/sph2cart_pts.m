% convert points into cartesian coordinates
function [x_ct,y_ct,z_ct] = sph2cart_pts(N_phi,N_rho,N_theta)
    c = 3e8; % speed of light 
    %BW = 3987.61e6; % Bandwidth = 3987.61MHz
    Fs = 2047e3;
    sweep_slope = 29.982e+12; % Hz/s
    %rho_res = c/2/BW; % in m, range resolution, 3.8cm for 3987.61MHz
    rho_min = 0; rho_max = Fs*c/2/sweep_slope; % range, m
    phi_min = 30; phi_max = 150; % azimuth, deg
    theta_min = 75; theta_max = 105; % elevation, deg
    % get corresponding positions of each cell
    ticks_phi = linspace(phi_min,phi_max,N_phi); % azimuth axis of the output radar heatmap in degree
    ticks_theta = linspace(theta_min,theta_max,N_theta);
    ticks_rho = linspace(rho_min,rho_max,N_rho);
    ticks_phi = ticks_phi/180*pi;
    ticks_theta = ticks_theta/180*pi;
    % to use sph2cart, theta is the elevation angle from x-y plane
    ticks_theta_top = pi/2 - ticks_theta(1:32);
    ticks_theta_bottom = -(ticks_theta(33:64) - pi/2);
    ticks_theta = [ticks_theta_top,ticks_theta_bottom];

    N_cell = N_phi*N_theta*N_rho;
    sp_coord = zeros(N_cell,3);
    idx_sp_coord = 1;
    for idx_rho = 1:N_rho
        for idx_phi = 1:N_phi
            for idx_theta = 1:N_theta
                sp_coord(idx_sp_coord,:) = [ticks_rho(idx_rho),ticks_phi(idx_phi),ticks_theta(idx_theta)];
                idx_sp_coord = idx_sp_coord + 1;
            end
        end
    end
    [x_ct,y_ct,z_ct] = sph2cart(sp_coord(:,2),sp_coord(:,3),sp_coord(:,1)); % [x,y,z] = sph2cart(azimuth,elevation,r)
end