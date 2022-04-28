close all;clear;clc;
addpath('functions_main'); addpath('functions_helper'); addpath('functions_sph2cart');

object_name = "cart";

start_idx = 501; % index to start from
stop_idx = 501; % index to stop by

for CAD_idx = 1
    
    CreateResultFolder(object_name,CAD_idx,start_idx,stop_idx); % create related folders
    
    disp(string(datetime('now','TimeZone','local','Format','yyyy-MM-dd HH:mm:ss z'))); 
    disp(strcat("Generate data for <", object_name, " #", num2str(CAD_idx), ...
    "> from placement <", num2str(start_idx), "> to <", num2str(stop_idx), ">"));
    
    tStart = tic; % start timer
    main(object_name, CAD_idx, start_idx, stop_idx); % save with grouping by index
    dispElpTime(tStart); % stop timer and display elapsed time
    
end
