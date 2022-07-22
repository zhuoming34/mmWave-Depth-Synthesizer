%%% top level control for scenes of maximum 3 objects
close all;clear;clc;
addpath('functions_main'); addpath('functions_helper'); addpath('functions_sph2cart');
%%% ----------------------------------------------------------------- %%%


N_object = 2; % number of objects: 1-obj1, 2-obj1&2, 3-obj1&2&3

obj1_name = "desk";
obj2_name = "car";
obj3_name = "rbarm";

% these indices can be a single number or a list of number
% e.g. 1; 1:4; [2,5,8]
obj1_idxs = 4; 
obj2_idxs = 1;
obj3_idxs = 1;

str_idx = 1; % index to start from
stp_idx = 1; % index to stop by


%%% ----------------------------------------------------------------- %%%
info_idx = strcat(" from placement <",num2str(str_idx),"> to <",num2str(stp_idx),">");
disp(string(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm:ss z'))); 
fprintf("Number of objects: %d\n",N_object);
fldr_cap = 500; % folder capacity for grouping results
tStart = tic; % start timer
for obj1_idx = obj1_idxs
    info_obj1 = strcat("Generate data for <",obj1_name," #",num2str(obj1_idx),">");
    if N_object == 1
        disp(strcat(info_obj1,info_idx));
        CreateResultFolder_v1(obj1_name,obj1_idx,str_idx,stp_idx,fldr_cap); 
        main_solo(obj1_name, obj1_idx, str_idx, stp_idx); 
    else  
        for obj2_idx = obj2_idxs 
            info_obj2 = strcat(" and <",obj2_name," #",num2str(obj2_idx),">");
            if N_object == 2       
                disp(strcat(info_obj1,info_obj2,info_idx));
                CreateResultFolder_v2(obj1_name,obj1_idx,obj2_name,obj2_idx,...
                    str_idx,stp_idx,fldr_cap); 
                main_duo(obj1_name,obj1_idx,obj2_name,obj2_idx,str_idx,stp_idx);
            else 
                for obj3_idx = obj3_idxs
                    info_obj3 = strcat(" and <",obj3_name," #",num2str(obj3_idx),">");
                    if N_object == 3  
                        disp(strcat(info_obj1,info_obj2,info_obj3,info_idx));
                        CreateResultFolder_v3(obj1_name,obj1_idx,...
                            obj2_name,obj2_idx,obj3_name,obj3_idx,...
                            str_idx,stp_idx,fldr_cap);
                        main_trio(obj1_name, obj1_idx,obj2_name,obj2_idx,...
                            obj3_name, obj3_idx, str_idx, stp_idx);
                    else
                        error("Exceed the maximum allowed number of objects")
                    end
                end
            end
        end
    end
end
dispElpTime(tStart); % stop timer and display elapsed time