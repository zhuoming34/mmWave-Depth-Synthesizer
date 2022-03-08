%%% 02/17/2022
close all;clear;clc;
addpath('functions_main'); addpath('functions_helper'); addpath('functions_Sph2Cart');

object1_name = "car";
object2_name = "rbarm";

start_idx = 1; % index to start from
stop_idx = 20; % index to stop by
%N_placement = 500; % number of scenes to generate

for CAD1_idx = 1
    
    for CAD2_idx = 1
    
        disp(strcat("Generating data for ", object1_name, " #", num2str(CAD1_idx), ...
            " and ", object2_name, " #", num2str(CAD2_idx), ...
        " from idx ", num2str(start_idx), " to ", num2str(stop_idx)));

        %CreateResultFolder(object_name,CAD_idx); % create single folder for storage
        CreateResultFolder_v2(object1_name,CAD1_idx,object2_name,CAD2_idx); % create multiple folders

        tStart = tic; % start timer

        %main(object_name, CAD_idx, start_idx, stop_idx); % save all indices under the same folder 
        main_v2(object1_name, CAD1_idx, object2_name, CAD2_idx, start_idx, stop_idx); % save with grouping by index

        dispElpTime(tStart); % stop timer and display elapsed time
        
    end 
    
end
