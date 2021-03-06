function CreateResultFolder(object_name,CAD_idx)
    SLASH = checkOS();
    
    % All results folder
    result_folder = strcat("..",SLASH,"results");
    if ~exist(result_folder, 'dir')
        mkdir(result_folder);
    end
    
    % Specific object result folder
    object_folder = strcat(result_folder,SLASH,object_name,"_",num2str(CAD_idx));
    if ~exist(object_folder, 'dir')
        mkdir(object_folder);
    end
    
    % depth image result folder
    fig_folder = strcat(object_folder,SLASH,"fig");
    if ~exist(fig_folder, 'dir')
        mkdir(fig_folder);
    end  
    fig_org_folder = strcat(fig_folder,SLASH,"1280x720");
    if ~exist(fig_org_folder, 'dir')
        mkdir(fig_org_folder);
    end  
    for view = 1:4
        view_folder = strcat(fig_org_folder,SLASH,"cam",num2str(view));
        if ~exist(view_folder, 'dir')
            mkdir(view_folder);
        end
    end
    
    % Cartesian intensity result folder
    cart_folder = strcat(object_folder,SLASH,"cartHeat");
    if ~exist(cart_folder, 'dir')
        mkdir(cart_folder);
    end
    for view = 1:4
        view_folder = strcat(cart_folder,SLASH,"cam",num2str(view));
        if ~exist(view_folder, 'dir')
            mkdir(view_folder);
        end
    end   
    
end