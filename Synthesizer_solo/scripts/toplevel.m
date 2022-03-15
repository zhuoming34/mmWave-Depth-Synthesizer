close all;clear;clc;
addpath('functions_main'); addpath('functions_helper'); addpath('functions_sph2cart');

object_name = "chair";

start_idx = 779; % index to start from
stop_idx = 779; % index to stop by

for CAD_idx = 8
    
    disp(strcat("Generating data for ", object_name, " #", num2str(CAD_idx), ...
    " from idx ", num2str(start_idx), " to ", num2str(stop_idx)));
    
    CreateResultFolder(object_name,CAD_idx,start_idx,stop_idx); % create related folders
    
    tStart = tic; % start timer
    
    main(object_name, CAD_idx, start_idx, stop_idx); % save with grouping by index
    
    dispElpTime(tStart); % stop timer and display elapsed time
    
end
