function CreateResultFolder_v3(obj1_name, CAD1_idx, obj2_name, CAD2_idx,...
    obj3_name, CAD3_idx, start_idx, stop_idx, sec_size)
    SLASH = checkOS();
    %sec_size = 500; % Default: 500 datasets each section
    
    % All results folder
    result_folder = strcat("..",SLASH,"results");
    if ~exist(result_folder, 'dir')
        mkdir(result_folder);
    end
    
    % Specific object result folder
    object_folder = strcat(result_folder,SLASH,obj1_name,num2str(CAD1_idx),...
        "-",obj2_name,num2str(CAD2_idx),"-",obj3_name,num2str(CAD3_idx));
    if ~exist(object_folder, 'dir')
        mkdir(object_folder);
    end
    
    for section = ceil(start_idx/sec_size) : ceil(stop_idx/sec_size)
        % index section folder
        section_folder = strcat(object_folder,SLASH,num2str(section));
    
        % depth image result folder
        fig_folder = strcat(section_folder,SLASH,"fig");
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

        % image label result folder
        lbl_folder = strcat(section_folder,SLASH,"label");
        if ~exist(lbl_folder, 'dir')
            mkdir(lbl_folder);
        end
        for view = 1:4
            view_folder = strcat(lbl_folder,SLASH,"cam",num2str(view));
            if ~exist(view_folder, 'dir')
                mkdir(view_folder);
            end
        end
        
        % Cartesian intensity result folder
        cart_folder = strcat(section_folder,SLASH,"cartHeat");
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
    
end