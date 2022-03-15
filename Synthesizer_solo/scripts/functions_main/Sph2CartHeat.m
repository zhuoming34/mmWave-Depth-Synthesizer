% convert radar heatmap in hawkeye synthesizer
% from spherical coordinates (r,theta,phi)to cartesian coordinates (x,y,z)
function heatmap_ct = Sph2CartHeat(view_idx,radar_heatmap_sph,threshold_factor)
    %close all; clear; clc;
    %format shortg; clk0 = clock; disp("Start converting 3D intensity maps"); disp(clk0);  
    variable_library_scene;
    variable_library_radar;
    %addpath("functions_Sph2Cart");
   
    if view_idx == 0
        scene_lim = scene_lim_top; %[-3, 3; 4, 7; -3, 3]; %[-3, 3; 4.5, 7.5; -3, 3]; %
    elseif view_idx >= 5
        scene_lim = scene_lim_corner; %[-3*sqrt(2), 3*sqrt(2); 5-3*sqrt(2), 5+3*sqrt(2); -1.25, 1.75];
    else
        scene_lim = scene_lim_edge; %[-1, 1; 1.5, 3.5; -0.5, 1.5];
    end

    heatmap = radar_heatmap_sph;%_noisy; % rho*azimuth*elevation

    % match intensity values to corresponding points
    radar_heat = matchHeat(heatmap,N_phi,N_rho,N_theta);

    % gets points whose intensities are larger than the threshold
    threshold = max(max(max(heatmap)))*threshold_factor;
    idx_heat_fl = find(radar_heat >= threshold);
    pt_heat_fl = zeros(size(idx_heat_fl,1),3);
    heat_fl = zeros(size(idx_heat_fl,1),1);
    for i = 1:size(idx_heat_fl,1)
        pt_heat_fl(i,:) = ct_coord(idx_heat_fl(i),:);
        heat_fl(i) = radar_heat(idx_heat_fl(i));
    end

    % no filtering
    %pt_heat_fl = ct_coord;
    %heat_fl = radar_heat;
    %x_hf = pt_heat_fl(:,1); y_hf = pt_heat_fl(:,2); z_hf = pt_heat_fl(:,3);

    % convert heatmap from spherical to cartesian coordinate system
    heatmap_ct = sph2cart_heat(scene_lim,N_x_heat,N_y_heat,N_z_heat,pt_heat_fl,heat_fl);
    %save(strcat(saveaddr,'cam',num2str(cam),'/',num2str(idx),'.mat'), 'heatmap_ct');
    %disp(strcat("Cart: Model ", num2str(CAD_idxs),", placement ", num2str(idx),", camera ",num2str(cam), ": done"));

    % disp('finished converting 3D intensity maps');

end

%{
%% functions

% plot 2d radar heatmaps in spherical coordinates
function show_heatmap2d(heatmap, cam_rft)
    figure(); 
    font_size = 8;
    
    % Visulize the camera reflectors
    subplot(221); scatter3(cam_rft(:,1),cam_rft(:,2),cam_rft(:,3),10,'filled','k');
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); axis equal;
    xlim([-4 4]); ylim([0 10]); set(gca,'FontSize',font_size);      
    view(15,30)
    
    % Visulize the radar heatmap side view
    radar_heatmap_side = squeeze(max(heatmap,[],2));
    subplot(222); imagesc(radar_heatmap_side.');
    %set(gca,'XDir','reverse');
    colormap jet; %caxis([0 1e11]); %colorbar;
    xlabel('Range'); ylabel('Elevation'); set(gca,'FontSize',font_size);
    
    % Visulize the radar heatmap front view
    radar_heatmap_front = squeeze(max(heatmap,[],1));
    subplot(223); imagesc(radar_heatmap_front.');
    set(gca,'XDir','reverse');
    colormap jet; %caxis([0 1e11]); %colorbar;
    xlabel('Azimuth'); ylabel('Elevation'); set(gca,'FontSize',font_size);
    
    % Visulize the radar heatmap top view
    radar_heatmap_top = squeeze(max(heatmap,[],3));
    subplot(224); imagesc(radar_heatmap_top);
    set(gca,'XDir','reverse'); set(gca,'YDir','normal');
    colormap jet; %caxis([0 1e11]); %colorbar;
    xlabel('Azimuth'); ylabel('Range'); set(gca,'FontSize',font_size);

end

% plot point cloud in cartesian coordinate system
function show_ct_pt(ct_coord)
    font_size = 8;
    figure(); scatter3(ct_coord(:,1),ct_coord(:,2),ct_coord(:,3),1,'filled','k');
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); axis equal;
    xlim([-10 10]); ylim([0 10]); zlim([-5,5]); set(gca,'FontSize',font_size);      
    %view(15,30)
end

% plot 3d heatmap slice
function show_slice_heat_3d(heatmap_ct)
    m = size(heatmap_ct, 2); % az
    n = size(heatmap_ct, 3); % el
    l = size(heatmap_ct, 1); % rg
    xi = linspace(1,l,l); % range
    yi = linspace(1,m,m); % azimuth
    zi = linspace(1,n,n); % elevation
    [XX,YY,ZZ] = meshgrid(yi,xi,zi); % [l * m * n]

    xslice = 1:m;    % location of y-z planes
    yslice = 1:l;    % location of x-z plane
    zslice = 1:n;    % location of x-y planes
    
    figure(); h = slice(XX,YY,ZZ,heatmap_ct,xslice,yslice,zslice);
    xlabel('x(m)'); ylabel('y(m)'); zlabel('z(m)');
    xlim([0 64]); ylim([0 256]); zlim([0,64]);
    xt = linspace(0,64,7); xticks(xt); 
    xticklabels({'-3','-2','-1','0','1','2','3'})
    yt = linspace(0,256,7); yticks(yt); 
    yticklabels({'2','3','4','5','6','7','8'})
    zt = linspace(0,64,13); zticks(zt); 
    zticklabels({'-1.25','-1','-0.75','-0.5','-0.25','-0','0.25',...
        '0.5','0.75','1','1.25','1.5','1.75'});
    %set(h,'EdgeColor','none','FaceColor','interp','FaceAlpha','interp');
    set(h,'EdgeColor','none','FaceColor','flat','FaceAlpha','flat');
    %set(h,'EdgeColor','none','FaceColor','flat','FaceAlpha','0.01');
    % set transparency to correlate to the data values.
    alpha('color'); %alpha(h, 0.01);
    colorbar; colormap jet;
end

% 3d heat scatter
function show_scatter_heat_3d(cam_rft,ct_coord,radar_heat,max_intensity,show_car)
    threshold = max_intensity/10;
    cmap = jet;
    %radar_heat_sort = sort(radar_heat);
    v = rescale(radar_heat, 1, 256); % Nifty trick!
    numValues = length(radar_heat);
    markerColors = zeros(numValues, 3);
    % Now assign marker colors according to the value of the data.
    for k = 1 : numValues
        row = round(v(k));
        markerColors(k, :) = cmap(row, :);
    end
    % filter out low-intensity points
    %max_intensity = max(max(max(heatmap)));
    idx_selected_pt = find(radar_heat>=threshold/50);
    selected_pt = zeros(size(idx_selected_pt,1),3);
    markerColors_select = zeros(size(idx_selected_pt,1),3);
    for i = 1:size(idx_selected_pt,1)
        selected_pt(i,:) = ct_coord(idx_selected_pt(i),:);
        markerColors_select(i,:) = markerColors(idx_selected_pt(i,:),:);
    end
    x_sl = selected_pt(:,1); y_sl = selected_pt(:,2); z_sl = selected_pt(:,3);
    %ct_coord_ds = ct_coord(1:2000:end,:);
    figure(); font_size = 8;
    %scatter3(x_ct,y_ct,z_ct,3,markerColors); hold on;
    scatter3(x_sl,y_sl,z_sl,10,markerColors_select,'filled'); %colorbar();
    colormap(jet); c = colorbar; %caxis([0 1e11]);
    max_tick = strcat(num2str(round(max_intensity/1e12)),'e12');
    c.Ticks = [0 1]; c.TickLabels = {'0',max_tick};
    if show_car == 1
        hold on; 
        %scatter3(ct_coord_ds(:,1),ct_coord_ds(:,2),ct_coord_ds(:,3),0.1,'w'); hold on;
        scatter3(cam_rft(:,1),cam_rft(:,2),cam_rft(:,3),10,'filled','k');
    end
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); axis equal;
    xlim([-10 10]); ylim([0 10]); zlim([-5,5]); set(gca,'FontSize',font_size);
    view(15,15)
end
%}