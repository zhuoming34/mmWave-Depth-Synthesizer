%%% 02/17/2022
close all;clear;clc;
addpath('functions_main'); addpath('functions_helper'); addpath('functions_Sph2Cart');

object_name = "car";

start_idx = 1; % index to start from
stop_idx = 2; % index to stop by
%N_placement = 500; % number of scenes to generate

for CAD_idx = 1
    
    disp(strcat("Generating data for ", object_name, " #", num2str(CAD_idx), ...
    " from idx ", num2str(start_idx), " to ", num2str(stop_idx)));
    
    %CreateResultFolder(object_name,CAD_idx); % create single folder for storage
    CreateResultFolder_v2(object_name,CAD_idx); % create multiple folders
    
    tStart = tic; % start timer
    
    %main(object_name, CAD_idx, start_idx, stop_idx); % save all indices under the same folder 
    main_v2(object_name, CAD_idx, start_idx, stop_idx); % save with grouping by index
    
    dispElpTime(tStart); % stop timer and display elapsed time
    
end
