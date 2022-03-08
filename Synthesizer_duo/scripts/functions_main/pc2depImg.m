% 01/21/2021
% generate 2d depth image from camera reflector point cloud
% with perspective projection
%close all; clear; clc;
% --------------------------------------
% https://support.stereolabs.com/hc/en-us/articles/360007395634-What-is-the-camera-focal-length-and-field-of-view-
% zed mini image output resolution of HD720
% width = 1280, height = 720, pixel number = 1280*720
% has a focal length of 700 pixels
% pixel size of 0.004mm
% field of view: fov = 2*arctan(pixelNumber/(2*focalLength))*(180/pi)
% VFOV = 54deg, HFOV = 85deg
% "The focus distance is fixed. All objects at distances from 28cm out to infinity will be sharp"
% depth range = [0.1, 15] meters
function [DepthImg, ColorMap] = pc2depImg(visible_cart_v_dep)
    %format shortg; clk0 = clock; disp("Start generating depth images"); disp(clk0);
    %addpath('functions');
    variable_library_scene;
    variable_library_camera;
    
    ptCloud = visible_cart_v_dep;
    pc_x = ptCloud(:,1); pc_y = ptCloud(:,2); pc_z = ptCloud(:,3);
    
    % perspective projection
    proj_y = linspace(focalL,focalL,size(pc_y,1))'; % focal length
    proj_ratio = pc_y./proj_y;
    proj_x = -pc_x./proj_ratio;
    proj_z = -pc_z./proj_ratio;

    
    % remove pts that out of bound
    if (min(proj_x)<-ppH/2 || max(proj_x)>ppH/2 || min(proj_z)<-ppV/2 || max(proj_z)>ppV/2)
        disp("removing out-of-bound points");
        proj_pts = [proj_x,proj_y,proj_z];
        pt_mark = zeros(size(proj_pts,1),1); % mark the points in projection plane
        for i = 1:size(proj_pts,1)
            if (proj_x(i)<-ppH/2 || proj_x(i)>ppH/2 || proj_z(i)<-ppV/2 || proj_z(i)>ppV/2 )
                continue;
            end
            pt_mark(i) = 1;
        end
        visible_ptCloud_idx = find(pt_mark);
        visible_ptCloud = zeros(size(visible_ptCloud_idx,1),3);
        visible_ptCloud_pp = zeros(size(visible_ptCloud_idx,1),3); % pts on projection plane
        for i = 1:size(visible_ptCloud_idx,1)
            visible_ptCloud(i) = ptCloud(visible_ptCloud_idx(i));
            visible_ptCloud_pp(i) = proj_pts(visible_ptCloud_idx(i));
        end
        pc_x = visible_ptCloud(:,1); pc_y = visible_ptCloud(:,2); pc_z = visible_ptCloud(:,3);
        proj_x = visible_ptCloud_pp(:,1); proj_y = visible_ptCloud_pp(:,2); proj_z = visible_ptCloud_pp(:,3);
    %else
        %disp("no point is out of bound");
    end
    

    % ---- depth calculation ----
    d = sqrt(pc_x.^2 + pc_y.^2 + pc_z.^2);
    %sn_d = sqrt(sn_x.^2 + sn_y.^2 + sn_z.^2);

    % grid construction
    xl = -ppH/2; xr = ppH/2; zb = -ppV/2; zt = ppV/2;
    xx = linspace(xr,xl,N_pixel_col); zz = linspace(zb,zt,N_pixel_row);
    [X,Z] = meshgrid(xx,zz);
    grid_centers = [X(:),Z(:)];

    % classification
    clss = knnsearch(grid_centers,[proj_x,proj_z]); 
    % defintion of local statistic
    local_stat = @(x)min(x); 
    %local_stat = @(x)mean(x); 
    % data_grouping
    class_stat = accumarray(clss,d,[N_pixel_row*N_pixel_col 1],local_stat);
    % 2D reshaping
    class_stat_M  = reshape(class_stat , size(X)); 
    % Force un-filled cells to the brightest color
    % add limits at front and back
    %s1 = size(class_stat_M,1);
    %s2 = size(class_stat_M,2);
    %class_stat_M(1,s2/2) = r1; % 0.1m
    %class_stat_M(s1,s2/2) = r2; % 15.0m
    class_stat_M (class_stat_M == 0) = cam_range_max;% max(max(class_stat_M));
    % flip image horizontally and vertically
    I0 = class_stat_M;
    %I0 = class_stat_M(end:-1:1,end:-1:1);
    %I0 = class_stat_M(end:-1:1,:);
    %I0 = class_stat_M(:,end:-1:1); % flip image horizontally

    % normalize pixel values to [0,1]
    %max_dep = max(max(I0)),    min_dep = min(min(I0))
    %I = ( I0 - min(min(I0)) ) ./ ( max(max(I0)) - min(min(I0)) );
    I = ( I0 - cam_range_min ) ./ ( cam_range_max - cam_range_min );
    
    % extend and crop to the same size of scene
    % usually N_col_l = N_col_r
    N_col_l = ceil(abs((scene_x_proj(3)-xl))/(pxSize/1000));
    N_col_r = ceil(abs((scene_x_proj(1)-xr))/(pxSize/1000));
    N_row_b = ceil(abs((scene_z_proj(1)-zt))/(pxSize/1000));
    N_row_t = ceil(abs((scene_z_proj(2)-zb))/(pxSize/1000));
    if scene_x_proj(3) <= xl || scene_x_proj(1) >= xr
        col_l = ones(N_pixel_row,N_col_l); col_r = ones(N_pixel_row,N_col_r); % extend
        Ic = [col_l,I,col_r];
        N_col = N_pixel_col + N_col_l + N_col_r;
    else
        Ic = I(:,N_col_l+1:end-N_col_r); % crop
        N_col = N_pixel_col - N_col_l - N_col_r;
    end

    if scene_z_proj(1) >= zt % positive on projection plane
        row_b = ones(N_row_b,N_col); % extend
        Ib = [Ic;row_b];
        N_row = N_pixel_row + N_row_b;
    else
        Ib = Ic(1:end-N_row_b,:); % crop
        N_row = N_pixel_row - N_row_b;
    end

    if scene_z_proj(2) <= zb % negative on projection plane
        row_t = ones(N_row_t,N_col); % extend
        It = [row_t;Ic];
        N_row = N_row + N_row_t;
    else
        It = Ib(N_row_t+1:end,:); % crop
        N_row = N_row - N_row_t;
    end
    %I2 = [col_l,[I(N_row_t+1:end,:);row_b],col_r];
    I2 = It;

    % saving images
    Dep1 = abs(I - 1)*255;
    Dep2 = abs(I2 - 1)*255;
    reszImg = imresize(Dep2, [128,128]);
    cmap1 = jet; cmap2 = gray;

    DepthImg = Dep1;
    ColorMap = cmap2;
    % gray-scaled original-size depth image
    %outputBaseFileName1 = strcat(outaddr1,"cam",num2str(cam),SLASH,num2str(idx),".png");
    %outputBaseFileName1 = strcat(outaddr1,num2str((idx+os-1)*4+1 + cam+camos-1),".png");
    %imwrite(Dep1, cmap2, outputBaseFileName1); 
%{
    % colored scaled depth image
    outputBaseFileName2 = strcat(outaddr2,"cam",num2str(cam),SLASH,num2str(idx),".png");
    %outputBaseFileName2 = strcat(outaddr2,num2str((idx+os-1)*4+1 + cam+camos-1),".png");
    imwrite(Dep2, cmap1, outputBaseFileName2); 

    % colored 128x128 scaled depth image
    outputBaseFileName3 = strcat(outaddr3,"cam",num2str(cam),SLASH,num2str(idx),".png");
    %outputBaseFileName3 = strcat(outaddr3,num2str((idx+os-1)*4+1 + cam+camos-1),".png");
    imwrite(reszImg, cmap1, outputBaseFileName3);

    % gray 128x128 scaled depth image
    outputBaseFileName4 = strcat(outaddr4,"cam",num2str(cam),SLASH,num2str(idx),".png");
    %outputBaseFileName4 = strcat(outaddr4,num2str((idx+os-1)*4+1 + cam+camos-1),".png");
    imwrite(reszImg, cmap2, outputBaseFileName4); 
%}
    %disp(strcat(num2str(idx+os)," - ", num2str(cam+camos)));
    %disp(strcat("Depth: Model ", num2str(CAD_idxs),", placement ", num2str(idx),", camera ",num2str(cam), ": done"));
    %clk = clock; disp(clk); 
    %disp("finished generating depth images")
    %%

end