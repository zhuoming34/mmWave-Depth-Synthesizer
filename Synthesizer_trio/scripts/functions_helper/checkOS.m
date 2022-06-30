function SLASH = checkOS()
    if ismac
        %disp("Running on Mac platform")
        SLASH = "/";
    elseif isunix
        %disp("Running on Linux platform")
        SLASH = "/";
    elseif ispc
        %disp("Running on Windows platform")
        SLASH = "\";
    else
        error('Platform not supported')
    end
end