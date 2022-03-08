function dispElpTime(tStart)
    elapsedTime = toc(tStart);
    elapsedDay = elapsedTime/60/60/24;
    elapsedHrs = mod(elapsedDay,1)*24;
    elapsedMin = mod(elapsedHrs,1)*60;
    elapsedSec = mod(elapsedMin,1)*60;
    disp(strcat("Total Elapsed Time: ", num2str(floor(elapsedDay)), " day(s), ",...
        num2str(floor(elapsedHrs)), " hour(s), ", num2str(floor(elapsedMin)), ...
        " min(s), ", num2str(elapsedSec), " sec(s), "));
end
