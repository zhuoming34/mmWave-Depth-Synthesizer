% 01/27/2021
% extract physical points from a depth image 
% and convert it into a 3d intensity map
%close all; clear; clc;

addr = ".\cart\2\1280x720\";

rotate2d =  @(x, M) (x(:, 1:2) * M);
sensor_ang_deg = [0,-90,-180,-270]; % orietation
dy = 2.25; % meter
dz = 0.8;
depth_max = 4; % maximum 15m
depth_min = 0.1; %m
plot_W = 4.5; plot_L = 4.5; plot_H = 2; % m

for idx = 501
    all_pts = [];
    figure(1)
    for cam = 1:4

        filename_img = strcat(addr,"cam",num2str(cam),"\",num2str(idx),'.png');
        orgImg = imread(filename_img); % read depth image
        pxsize = 0.04/1000; % m, pixel size
        f = 700*pxsize; % m, focal length
        numr = size(orgImg,1); numc = size(orgImg,2); % resolution of actual image

        % ----- select pixels for objects -----

        % find the center of image
        if mod(numr,2)==0
           row_ctr = numr/2;
        else
            row_ctr = (numr-1)/2;   
        end

        if mod(numc,2)==0
            col_ctr = numc/2;
        else
            col_ctr = (numc-1)/2;
        end

        depthcolor = linspace(depth_max,depth_min,256);
        depthval = zeros(numr*numc,1); % depth values at every pixel
        xyz = zeros(numr*numc,3);
        y = -f;
        i = 1;
        for col = 1:numc
            if col <= col_ctr
                x = (col_ctr + 1 - col)*pxsize;
            else
                x = (col-col_ctr)*pxsize*(-1);
            end
            for row = 1:numr
                if row <= row_ctr
                    z = (row_ctr + 1 - row)*pxsize*(-1);
                else
                    z = (row-row_ctr)*pxsize;
                end
                xyz(i,:) = [x,y,z];
                depthval(i) = depthcolor(orgImg(row,col)+1);
                i = i + 1;
            end 
        end

        orgImg2 = reshape(orgImg, [numr*numc,1]);
        %objidx = find(orgImg);
        objidx = find(orgImg2);
        %obj = orgImg(objidx);
        objxyz = xyz(objidx,:);
        objdep = depthval(objidx); % depth value of object only

        % for diy depth image only
        if min(objdep)/mean(objdep) < 0.05
           minidx = find(objdep==min(objdep));
           objdep(minidx) = 0;
           objidx2 = find(objdep);
           objxyz = objxyz(objidx2,:);
           objdep = objdep(objidx2);
        end

        % ----- reverse perspective projection -----
        realxyz = zeros(size(objxyz));
        for i = 1:size(objxyz,1)
           x = objxyz(i,1);
           z = objxyz(i,3);
           m_sq = x^2 + z^2;
           d = sqrt(m_sq + f^2);
           ratio = objdep(i)/d;
            real_x = (-1)*ratio*x;
            real_y = ratio*f;
            real_z = (-1)*ratio*z;
           realxyz(i,:) = [real_x,real_y,real_z]; % physical point cloud
        end
        %disp(cam)
        
        rotate_angle_rad = sensor_ang_deg(cam)/180*pi;
        rotation_matrix = [cos(rotate_angle_rad), -sin(rotate_angle_rad); sin(rotate_angle_rad), cos(rotate_angle_rad)]; % create rotation matrix
        
        realxyz(:,2) = realxyz(:,2) - dy;
        realxyz(:,3) = realxyz(:,3) + dz;
        realxyz(:,1:2) = rotate2d(realxyz, rotation_matrix);
        
        all_pts = [all_pts;realxyz];
        
        switch cam
            case 1         
                subplot(221); 
            case 2
                subplot(222); 
            case 3
                subplot(223);
            case 4
                subplot(224);
        end

        scatter3(realxyz(:,1),realxyz(:,2),realxyz(:,3),0.5,'filled','k');
        xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); axis equal;
        title(strcat("cam",num2str(cam)));
        xlim([-plot_W/2 plot_W/2]),ylim([-plot_L/2 plot_L/2]),zlim([0,plot_H]);
        set(gca,'FontSize',8);  
   
    end
    %disp(idx)
    figure(2);
    scatter3(all_pts(:,1),all_pts(:,2),all_pts(:,3),0.5,'filled','k');
    xlabel('x (m)'); ylabel('y (m)'); zlabel('z (m)'); axis equal;
    title("combined");
    xlim([-plot_W/2 plot_W/2]),ylim([-plot_L/2 plot_L/2]),zlim([0,plot_H]);
    set(gca,'FontSize',8);  
end
disp("done")

