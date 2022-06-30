%%% label different objects: 0=background, 1=object1, 2=object2
%%% 06/09/22: ver1.0: assuming objects are not overlapping each other
function labels = labelingImg_trio(pointCloud_1, pointCloud_2, pointCloud_3)
    %format shortg; clk0 = clock; disp("Start generating depth images"); disp(clk0);
    %addpath('functions');
    variable_library_scene;
    variable_library_camera;
    
    ptCloud_1 = pointCloud_1;
    ptCloud_2 = pointCloud_2;
    ptCloud_3 = pointCloud_3;
    
    pc_x_1 = ptCloud_1(:,1); pc_y_1 = ptCloud_1(:,2); pc_z_1 = ptCloud_1(:,3);
    pc_x_2 = ptCloud_2(:,1); pc_y_2 = ptCloud_2(:,2); pc_z_2 = ptCloud_2(:,3);
    pc_x_3 = ptCloud_3(:,1); pc_y_3 = ptCloud_3(:,2); pc_z_3 = ptCloud_3(:,3);
    
    % perspective projection
    proj_y_1 = linspace(focalL,focalL,size(pc_y_1,1))'; % focal length
    proj_ratio_1 = pc_y_1./proj_y_1;
    proj_x_1 = -pc_x_1./proj_ratio_1;
    proj_z_1 = -pc_z_1./proj_ratio_1;

    proj_y_2 = linspace(focalL,focalL,size(pc_y_2,1))'; % focal length
    proj_ratio_2 = pc_y_2./proj_y_2;
    proj_x_2 = -pc_x_2./proj_ratio_2;
    proj_z_2 = -pc_z_2./proj_ratio_2;
    
    proj_y_3 = linspace(focalL,focalL,size(pc_y_3,1))'; % focal length
    proj_ratio_3 = pc_y_3./proj_y_3;
    proj_x_3 = -pc_x_3./proj_ratio_3;
    proj_z_3 = -pc_z_3./proj_ratio_3;
    
    % remove pts that out of bound
    if (min(proj_x_1)<-ppH/2 || max(proj_x_1)>ppH/2 || min(proj_z_1)<-ppV/2 || max(proj_z_1)>ppV/2)
        disp("removing out-of-bound points of CAD 1");
        proj_pts_1 = [proj_x_1,proj_y_1,proj_z_1];
        pt_mark_1 = zeros(size(proj_pts_1,1),1); % mark the points in projection plane
        for i = 1:size(proj_pts_1,1)
            if (abs(proj_x_1(i))>ppH/2 || abs(proj_z_1(i))>ppV/2)
                continue;
            end
            pt_mark_1(i) = 1;
        end
        visible_ptCloud_idx_1 = find(pt_mark_1);
        disp(strcat(num2str(size(proj_pts_1,1)-size(visible_ptCloud_idx_1,1))," points have been removed."));
        visible_ptCloud_1 = zeros(size(visible_ptCloud_idx_1,1),3);
        visible_ptCloud_pp_1 = zeros(size(visible_ptCloud_idx_1,1),3); % pts on projection plane
        for i = 1:size(visible_ptCloud_idx_1,1)
            visible_ptCloud_1(i,:) = ptCloud_1(visible_ptCloud_idx_1(i),:);
            visible_ptCloud_pp_1(i,:) = proj_pts_1(visible_ptCloud_idx_1(i),:);
        end
        pc_x_1 = visible_ptCloud_1(:,1); pc_y_1 = visible_ptCloud_1(:,2); pc_z_1 = visible_ptCloud_1(:,3);
        proj_x_1 = visible_ptCloud_pp_1(:,1); proj_y_1 = visible_ptCloud_pp_1(:,2); proj_z_1 = visible_ptCloud_pp_1(:,3);
    %else
        %disp("no point is out of bound");
    end
    
    if (min(proj_x_2)<-ppH/2 || max(proj_x_2)>ppH/2 || min(proj_z_2)<-ppV/2 || max(proj_z_2)>ppV/2)
        disp("removing out-of-bound points of CAD 2");
        proj_pts_2 = [proj_x_2,proj_y_2,proj_z_2];
        pt_mark_2 = zeros(size(proj_pts_2,1),1); % mark the points in projection plane
        for i = 1:size(proj_pts_2,1)
            if (abs(proj_x_2(i))>ppH/2 || abs(proj_z_2(i))>ppV/2)
                continue;
            end
            pt_mark_2(i) = 1;
        end
        visible_ptCloud_idx_2 = find(pt_mark_2);
        disp(strcat(num2str(size(proj_pts_2,1)-size(visible_ptCloud_idx_2,1))," points have been removed."));
        visible_ptCloud_2 = zeros(size(visible_ptCloud_idx_2,1),3);
        visible_ptCloud_pp_2 = zeros(size(visible_ptCloud_idx_2,1),3); % pts on projection plane
        for i = 1:size(visible_ptCloud_idx_2,1)
            visible_ptCloud_2(i,:) = ptCloud_2(visible_ptCloud_idx_2(i),:);
            visible_ptCloud_pp_2(i,:) = proj_pts_2(visible_ptCloud_idx_2(i),:);
        end
        pc_x_2 = visible_ptCloud_2(:,1); pc_y_2 = visible_ptCloud_2(:,2); pc_z_2 = visible_ptCloud_2(:,3);
        proj_x_2 = visible_ptCloud_pp_2(:,1); proj_y_2 = visible_ptCloud_pp_2(:,2); proj_z_2 = visible_ptCloud_pp_2(:,3);
    %else
        %disp("no point is out of bound");
    end 
    
    if (min(proj_x_3)<-ppH/2 || max(proj_x_3)>ppH/2 || min(proj_z_3)<-ppV/2 || max(proj_z_3)>ppV/2)
        disp("removing out-of-bound points of CAD 3");
        proj_pts_3 = [proj_x_3,proj_y_3,proj_z_3];
        pt_mark_3 = zeros(size(proj_pts_3,1),1); % mark the points in projection plane
        for i = 1:size(proj_pts_3,1)
            if (abs(proj_x_3(i))>ppH/2 || abs(proj_z_3(i))>ppV/2)
                continue;
            end
            pt_mark_3(i) = 1;
        end
        visible_ptCloud_idx_3 = find(pt_mark_3);
        disp(strcat(num2str(size(proj_pts_3,1)-size(visible_ptCloud_idx_3,1))," points have been removed."));
        visible_ptCloud_3 = zeros(size(visible_ptCloud_idx_3,1),3);
        visible_ptCloud_pp_3 = zeros(size(visible_ptCloud_idx_3,1),3); % pts on projection plane
        for i = 1:size(visible_ptCloud_idx_3,1)
            visible_ptCloud_3(i,:) = ptCloud_3(visible_ptCloud_idx_3(i),:);
            visible_ptCloud_pp_3(i,:) = proj_pts_3(visible_ptCloud_idx_3(i),:);
        end
        pc_x_3 = visible_ptCloud_3(:,1); pc_y_3 = visible_ptCloud_3(:,2); pc_z_3 = visible_ptCloud_3(:,3);
        proj_x_3 = visible_ptCloud_pp_3(:,1); proj_y_3 = visible_ptCloud_pp_3(:,2); proj_z_3 = visible_ptCloud_pp_3(:,3);
    %else
        %disp("no point is out of bound");
    end 
    
    
    % ---- depth calculation ----
    d1 = sqrt(pc_x_1.^2 + pc_y_1.^2 + pc_z_1.^2);
    d2 = sqrt(pc_x_2.^2 + pc_y_2.^2 + pc_z_2.^2);
    d3 = sqrt(pc_x_3.^2 + pc_y_3.^2 + pc_z_3.^2);
    d1_min = min(d1); d2_min = min(d2); d3_min = min(d3);
    
    % grid construction
    xl = -ppH/2; xr = ppH/2; zb = -ppV/2; zt = ppV/2;
    xx = linspace(xr,xl,N_pixel_col); zz = linspace(zb,zt,N_pixel_row);
    [X,Z] = meshgrid(xx,zz);
    grid_centers = [X(:),Z(:)];
    %disp(xl), disp(xr), disp(zb), disp(zt)
    %grid_centers(1,:)
    labels = zeros(N_pixel_row,N_pixel_col);
    
    % classification
    clss_1 = knnsearch(grid_centers,[proj_x_1,proj_z_1]); 
    clss_2 = knnsearch(grid_centers,[proj_x_2,proj_z_2]);
    clss_3 = knnsearch(grid_centers,[proj_x_3,proj_z_3]);
    
    if d1_min > d2_min % d1 > d2
        if d1_min > d3_min % d1 > (d2 ? d3) 
            labels(clss_1) = 1;
            if d2_min > d3_min % d1 > d2 > d3
                labels(clss_2) = 2;
                labels(clss_3) = 3;
            else % d1 > d3 > d2
                labels(clss_3) = 3;
                labels(clss_2) = 2;
            end
        else % d3 > d1 > d2
            labels(clss_3) = 3;
            labels(clss_1) = 1;
            labels(clss_2) = 2;
        end
    else % d2 > d1
        if d2_min > d3_min % d2 > (d1 ? d3) 
            labels(clss_2) = 2;
            if d1_min > d3_min % d2 > d1 > d3
                labels(clss_1) = 1;
                labels(clss_3) = 3;
            else % d2 > d3 > d1
                labels(clss_3) = 3;
                labels(clss_1) = 1;
            end
        else % d3 > d2 > d1
            labels(clss_3) = 3;
            labels(clss_2) = 2;
            labels(clss_1) = 1;
        end
    end
    
    %labels = abs(labels - 1)*255;
    %labels = labels*255;
end