function [evnoise] = add_evn_noise()
    c = 3e8; % speed of light 
    BW = 3987.61e6; % Bandwidth = 3987.61MHz
    Fs = 2047e3;
    sweep_slope = 29.982e+12; % Hz/s
    %rho_res = c/2/BW; % in m, range resolution, 3.8cm for 3987.61MHz

    rho_min = 0; rho_max = Fs*c/2/sweep_slope; % range, m
    phi_min = 30; phi_max = 150; % azimuth, deg
    theta_min = 75; theta_max = 105; % elevation, deg
    N_phi = 64; N_rho = 256; N_theta = 64;

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
    
    evn = zeros(N_cell,1);
    for i = 1:N_cell
        if i < N_cell*0.1
            p = 0;
        elseif i > N_cell*0.1 && i < N_cell*0.2
            p = 1e-5;
        elseif i > N_cell*0.2 && i < N_cell*0.3
            p = 1e-4;
        elseif i > N_cell*0.3 && i < N_cell*0.4
            p = 1e-3;
        elseif i > N_cell*0.4 && i < N_cell*0.6
            p = 1e-3;
        elseif i > N_cell*0.6 && i < N_cell*0.8
            p = 1e-3;
        else
            p = 1e-3;
        end
        if rand(1) < p
            evn(i) = 1;
        end
    end
       
    evnoise_sph = sp_coord(find(evn),:);
    % down-sampling
    samplerate = 60;
    evnoise_sph = evnoise_sph(1:samplerate:end,:);
    
    [x_ct,y_ct,z_ct] = sph2cart(evnoise_sph(:,2),evnoise_sph(:,3),evnoise_sph(:,1)); % [x,y,z] = sph2cart(azimuth,elevation,r)
    evnoise_cart = [x_ct,y_ct,z_ct];
    
    %figure(1);
    %scatter3(x_ct,y_ct,z_ct,1,'filled','k');
    %xlabel("x"), ylabel("y"),zlabel("z")
    %view(0,90)
    
    N_surd = 49; % Number of surrounding pts
    evnoise_cart_surd = zeros(size(evnoise_cart,1)*N_surd,3); % surrounding pts
    sigma = 0.05; % m
    for i = 1:size(evnoise_cart,1)
       for j = 1:N_surd
          x_surd = normrnd(evnoise_cart(i,1),sigma);
          y_surd = normrnd(evnoise_cart(i,2),sigma);
          z_surd = normrnd(evnoise_cart(i,3),sigma);
          evnoise_cart_surd((i-1)*N_surd+j,:) = [x_surd,y_surd,z_surd];
       end
    end
    evnoise = [evnoise_cart;evnoise_cart_surd];
    %evnoise = evnoise(find(evnoise(:,3)>-1.25),:);
    % take points in the ranges of x=[-2,2]*y=[2,5], 
    % x=[-2,-1]*y=[0,2], and x=[1,2]*y=[0,2]
    evnoise1 = evnoise(find(evnoise(:,2)>2),:);
    evnoise2 = evnoise(find(evnoise(:,2)<2),:);
    evnoise3 = evnoise2(find(evnoise2(:,1)<-1),:);
    evnoise4 = evnoise2(find(evnoise2(:,1)>1),:);
    evnoise = [evnoise1;evnoise3;evnoise4];
    evnoise = evnoise(find(evnoise(:,2)<5),:);
    evnoise = evnoise(find(evnoise(:,1)<2),:);
    evnoise = evnoise(find(evnoise(:,1)>-2),:);
    %figure(2);
    %scatter3(evnoise_cart_surd(:,1),evnoise_cart_surd(:,2),evnoise_cart_surd(:,3),1,'filled','k');
    %xlabel("x"), ylabel("y"),zlabel("z")
    %view(0,90)
    
    %figure(3);
    %scatter3(evnoise(:,1),evnoise(:,2),evnoise(:,3),1,'filled','k');
    %xlabel("x"), ylabel("y"),zlabel("z")
    %xlim([-5,5]),ylim([0,15])
    %view(0,90)
end
