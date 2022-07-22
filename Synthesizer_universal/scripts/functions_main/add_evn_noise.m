function [evnoise] = add_evn_noise()

    variable_library_radar; % load radar configurations
    
    N_cell = N_phi*N_theta*N_rho;
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

end
