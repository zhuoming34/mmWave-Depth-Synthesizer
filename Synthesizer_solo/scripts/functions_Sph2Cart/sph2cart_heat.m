% match the heatmap into cartesian coordinates
function heatmap_ct = sph2cart_heat(scene_lim,N_x,N_y,N_z,pts,radar_heat)
    x_min = scene_lim(1,1); x_max = scene_lim(1,2);
    y_min = scene_lim(2,1); y_max = scene_lim(2,2);
    z_min = scene_lim(3,1); z_max = scene_lim(3,2);
    xx = linspace(x_min,x_max,N_x);
    yy = linspace(y_min,y_max,N_y);
    zz = linspace(z_min,z_max,N_z);
    % create a meshgrid and assign points to corresponding cubes
    [X,Y,Z] = meshgrid(xx,yy,zz);
    grid_centers = [X(:),Y(:),Z(:)];
    %clss = knnsearch(grid_centers,[x_ct,y_ct,z_ct]); % classification
    % pts = [x_ct,y_ct,z_ct];
    clss = knnsearch(grid_centers,pts,'K',1); % classification
    local_stat = @(x)mean(x); % defintion of local statistic
    %class_stat = accumarray(clss,radar_heat,[numr*numc*256 1],local_stat); % data_grouping
    class_stat = accumarray(clss,radar_heat,[N_x*N_y*N_z 1],local_stat); % data_grouping
    heatmap_ct  = reshape(class_stat , size(X)); % 3D reshaping

    for id_y = 1:N_y
        for id_x = 1:N_x
            for id_z = 1:N_z
                if heatmap_ct(id_y,id_x,id_z) == 0
                    if id_x == 1
                        if id_z == 1
                            heatmap_ct(id_y,id_x,id_z) = (heatmap_ct(id_y,id_x+1,id_z)+heatmap_ct(id_y,id_x,id_z+1))/2;
                        elseif id_z == N_z
                            heatmap_ct(id_y,id_x,id_z) = (heatmap_ct(id_y,id_x+1,id_z)+heatmap_ct(id_y,id_x,id_z-1))/2;
                        else
                            heatmap_ct(id_y,id_x,id_z) = (heatmap_ct(id_y,id_x+1,id_z)+heatmap_ct(id_y,id_x,id_z+1)+heatmap_ct(id_y,id_x,id_z-1))/3;
                        end
                    elseif id_x == N_x
                        if id_z == 1
                            heatmap_ct(id_y,id_x,id_z) = (heatmap_ct(id_y,id_x-1,id_z)+heatmap_ct(id_y,id_x,id_z+1))/2;
                        elseif id_z == N_z
                            heatmap_ct(id_y,id_x,id_z) = (heatmap_ct(id_y,id_x-1,id_z)+heatmap_ct(id_y,id_x,id_z-1))/2;
                        else
                            heatmap_ct(id_y,id_x,id_z) = (heatmap_ct(id_y,id_x-1,id_z)+heatmap_ct(id_y,id_x,id_z+1)+heatmap_ct(id_y,id_x,id_z-1))/3;
                        end
                    else
                        if id_z == 1
                            heatmap_ct(id_y,id_x,id_z) = (heatmap_ct(id_y,id_x+1,id_z)+heatmap_ct(id_y,id_x-1,id_z)+heatmap_ct(id_y,id_x,id_z+1))/3;
                        elseif id_z == N_z
                            heatmap_ct(id_y,id_x,id_z) = (heatmap_ct(id_y,id_x+1,id_z)+heatmap_ct(id_y,id_x-1,id_z)+heatmap_ct(id_y,id_x,id_z-1))/3;
                        else
                            heatmap_ct(id_y,id_x,id_z) = (heatmap_ct(id_y,id_x+1,id_z)+heatmap_ct(id_y,id_x-1,id_z)+heatmap_ct(id_y,id_x,id_z+1)+heatmap_ct(id_y,id_x,id_z-1))/4;
                        end
                    end
                end
            end
        end
    end

end