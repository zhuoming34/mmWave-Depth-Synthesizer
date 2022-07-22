% plot heatmaps of 256x64x64
close all; clear; clc;
format shortg; clk0 = clock; disp("Start"); disp(clk0);
SLASH = checkOS();
disp("save 3d heat from each cam")
obj_name = "car";
CAD_idx = 1;
str_idx = 1; stp_idx = 100;
plc_range = str_idx:stp_idx;
scene_sz = [4,4,3]; % [WxLxH] in [x,y,z]

xlb = "x(m)"; ylb = "y(m)"; zlb = "z(m)";
vis = "off";
addr0 = strcat("..",SLASH,"results",SLASH,obj_name,"_",num2str(CAD_idx));   
for vib = 1 
    if vib == 0
        vib_postfix = "n"; disp("vibration off");
    else
        vib_postfix = "v"; disp("vibration on");
    end
    addr1 = strcat(addr0,vib_postfix,SLASH,"1",SLASH);
    addr = strcat(addr1,"cartHeat",SLASH);
    saveaddr = strcat(addr1,"plots",SLASH);
    if ~exist(saveaddr, 'dir')
        mkdir(saveaddr);
    end

    for plc_idx = plc_range
        for cam = 1:4

            %load(strcat(addr,"cam",num2str(cam),'.mat'));
            load(strcat(addr,"cam",num2str(cam),SLASH,num2str(plc_idx),'.mat'));
            % heatmap_ct, 256x64x64, y*x*z

            switch cam
                case 0
                    Lb1 = xlb; Lb2 = zlb; Lb3 = ylb;
                    XL = -scene_sz(1)/2; XH = scene_sz(1)/2; 
                    YL = 0; YH = scene_sz(3); % TBD 
                    ZL = -scene_sz(2)/2; ZH = scene_sz(2)/2;   
                case 1
                    Lb1 = xlb; Lb2 = ylb; Lb3 = zlb;
                    XL = -scene_sz(1)/2; XH = scene_sz(1)/2; 
                    YL = -scene_sz(2)/2; YH = scene_sz(2)/2; 
                    ZL = 0; ZH = scene_sz(3);   
                case 2
                    Lb1 = ylb; Lb2 = xlb; Lb3 = zlb;
                    XL = -scene_sz(2)/2; XH = scene_sz(2)/2; 
                    YL = scene_sz(1)/2; YH = -scene_sz(1)/2; 
                    ZL = 0; ZH = scene_sz(3);  
                case 3
                    Lb1 = xlb; Lb2 = ylb; Lb3 = zlb;
                    XL = scene_sz(1)/2; XH = -scene_sz(1)/2; 
                    YL = scene_sz(2)/2; YH = -scene_sz(2)/2; 
                    ZL = 0; ZH = scene_sz(3);         
                case 4
                    Lb1 = ylb; Lb2 = xlb; Lb3 = zlb;
                    XL = scene_sz(2)/2; XH = -scene_sz(2)/2; 
                    YL = -scene_sz(1)/2; YH = scene_sz(1)/2; 
                    ZL = 0; ZH = scene_sz(3);  
                case 5
                    Lb1 = '1'; Lb2 = '2'; Lb3 = '3';
                    XL = 0; XH = 0; YL = 0; YH = 0; ZL = 0; ZH = 0; 
                case 6
                    Lb1 = '1'; Lb2 = '2'; Lb3 = '3';
                    XL = 0; XH = 0; YL = 0; YH = 0; ZL = 0; ZH = 0; 
                case 7
                    Lb1 = '1'; Lb2 = '2'; Lb3 = '3';
                    XL = 0; XH = 0; YL = 0; YH = 0; ZL = 0; ZH = 0; 
                case 8
                    Lb1 = '1'; Lb2 = '2'; Lb3 = '3';
                    XL = 0; XH = 0; YL = 0; YH = 0; ZL = 0; ZH = 0; 
            end

            %% scale maps

            div = floor(log10(max(max(max(heatmap_ct))))) - 2;
            heatmap_ct_1 = heatmap_ct/(10^div);
            heatmap_ct_1 = log(heatmap_ct_1+1);

            threshold = max(max(max(heatmap_ct_1)))*0.01;
            heatmap_ct_1(heatmap_ct_1<=threshold) = 0;

            %% plots and save
            
            tlt = strcat(obj_name," ",num2str(CAD_idx), " placement ", num2str(plc_idx));
            if vib == 0
                subtlt = strcat("cam ", num2str(cam)," w/o vibration");
            else
                subtlt = strcat("cam ", num2str(cam)," w/ vibration");
            end

            f0 = show_slice_heat_3d256(heatmap_ct_1,Lb1,Lb2,Lb3,XL,XH,YL,YH,ZL,ZH,tlt,subtlt,vis);
            %
            f1 = show_heatmap2d_cart2_3(heatmap_ct_1,Lb1,Lb2,Lb3,XL,XH,YL,YH,ZL,ZH,tlt,subtlt,vis);

            prefix = strcat("Car_1_Placement_",num2str(plc_idx),"_Cam_",num2str(cam),"_",vib_postfix,"_");

            %saveaddr = strcat(saveaddr0,num2str(cam),'/');

            %savefig(f0,strcat(saveaddr,prefix,"heatmap3d.fig"),'compact');
            saveas(f0, strcat(saveaddr,prefix,'heatmap3d_preview'), 'png');
            
            %savefig(f1,strcat(saveaddr,prefix,"3view.fig"),'compact');
            saveas(f1, strcat(saveaddr,prefix,'3view'), 'png');
            
            if vis == "off"
                close(f0);close(f1);
            end
            
            disp(strcat(num2str(plc_idx),'-',num2str(cam)))
            clk = clock; disp(clk);

        end
        %disp("loaded")
    end
end
disp("done")

%% test
%heattest = zeros(256,64,64);
%heattest(1:128,1,1) = 1e10;
%show_slice_heat_3d256(heattest,0,'x','y','z',-3,3,-3,3,0,3,'','','on');

%%
% plot 3d heatmap slice
function f = show_slice_heat_3d256(heatmap_ct,Lb1,Lb2,Lb3,XL,XH,YL,YH,ZL,ZH,tlt,subtlt,vis)
    m = size(heatmap_ct, 2); % az
    n = size(heatmap_ct, 3); % el
    l = size(heatmap_ct, 1); % rg
    yi = linspace(1,l,l); % range
    xi = linspace(1,m,m); % azimuth
    zi = linspace(1,n,n); % elevation
    [XX,YY,ZZ] = meshgrid(xi,yi,zi); % [l * m * n]

    xslice = 1:m;    % location of y-z planes
    yslice = 1:l;    % location of x-z plane
    zslice = 1:n;    % location of x-y planes
    
    f = figure('visible', vis);
    %if cam == 0
    %    %f.Position(3) = f.Position(3)*0.5;
    %else
    f.Position(4) = f.Position(4)*0.6;
    %end
    h = slice(XX,YY,ZZ,heatmap_ct,xslice,yslice,zslice);
    title([tlt;subtlt])
    xlabel(Lb1); ylabel(Lb2); zlabel(Lb3);
    xlim([0 64]); ylim([0 256]); zlim([0 64]);

    ticklb1 = num2cell(linspace(XL,XH,5));
    ticklb2 = num2cell(linspace(YL,YH,5));
    ticklb3 = num2cell(linspace(ZL,ZH,5));

    xt = linspace(0,64,5); xticks(xt); 
    xticklabels(ticklb1);
    yt = linspace(0,256,5); yticks(yt); 
    yticklabels(ticklb2);
    zt = linspace(0,64,5); zticks(zt); 
    zticklabels(ticklb3);

    set(h,'EdgeColor','none','FaceColor','flat','FaceAlpha','flat');
    alpha('color'); 
    colorbar; colormap jet;
end

function f = show_heatmap2d_cart2_3(heatmap,Lb1,Lb2,Lb3,XL,XH,YL,YH,ZL,ZH,tlt,subtlt,vis)   
    maxheat = max(max(max(heatmap)));
    
    font_size = 8;          
    xt = linspace(1,64,5); yt = linspace(1,256,5); zt = linspace(1,64,5);
    
    
    ticklb1 = num2cell(linspace(XL,XH,5));
    ticklb2 = num2cell(linspace(YL,YH,5));
    ticklb3 = num2cell(linspace(ZL,ZH,5));
    
    lb_1x = ticklb1; lb_1y = ticklb3; % front
    lb_2x = ticklb2; lb_2y = ticklb3; % side
    lb_3x = ticklb1; lb_3y = ticklb2; % top 
    
    f = figure('visible', vis);
    %screenSize = get(0, 'screensize');
    f.Position(1) = f.Position(1) / 3;
    f.Position(2) = f.Position(2) / 2;
    f.Position(3) = f.Position(3) * 2;
    %f.Position(4) = f.Position(4) * 0.6;
    %suptitle(tlt);
    sgtitle([tlt;subtlt]);
    %set(gcf,'Resize','off')
    
    % Visulize the radar heatmap front view
    radar_heatmap_front = squeeze(max(heatmap,[],1));
    f1 = subplot(132);  imagesc(radar_heatmap_front.');
    %if cam ~= 0
    f1.Position(4) = f1.Position(4)*0.6;
    %end
    title("Front View")
    set(gca,'XDir','normal');set(gca,'YDir','normal');
    c1 = colorbar; 
    c1.Location = 'southoutside';
    colormap jet;
    caxis([0 maxheat]);
    xlabel(Lb1); ylabel(Lb3); set(gca,'FontSize',font_size);
    xticks(xt); xticklabels(lb_1x)
    yticks(zt); yticklabels(lb_1y);
    xlim([1,64]),ylim([1,64])
    
    % Visulize the radar heatmap side view
    radar_heatmap_side = squeeze(max(heatmap,[],2));
    f2 = subplot(131);  imagesc(radar_heatmap_side.');
    %if cam == 0
    %    f2.Position(3) = f2.Position(3)*0.6;
    %else
    f2.Position(4) = f2.Position(4)*0.6;
    %end 
    title("Side View")
    set(gca,'XDir','reverse');set(gca,'YDir','normal');
    c2 = colorbar; 
    c2.Location = 'southoutside';
    colormap jet; 
    caxis([0 maxheat]); 
    xlabel(Lb2); ylabel(Lb3); set(gca,'FontSize',font_size);
    xticks(yt); xticklabels(lb_2x)
    yticks(zt); yticklabels(lb_2y);
    xlim([1,256]),ylim([1,64])
    
    % Visulize the radar heatmap top view
    radar_heatmap_top = squeeze(max(heatmap,[],3));
    f3 = subplot(133);  imagesc(radar_heatmap_top);
    %if cam == 0
    %    f3.Position(3) = f3.Position(3)*0.6;
    %end
    title("Top View")
    set(gca,'XDir','normal'); set(gca,'YDir','normal');
    c3 = colorbar; 
    c3.Location = 'southoutside';
    colormap jet;
    caxis([0 maxheat]);
    xlabel(Lb1); ylabel(Lb2); set(gca,'FontSize',font_size);
    xticks(xt); xticklabels(lb_3x)
    yticks(yt); yticklabels(lb_3y)
    xlim([1,64]),ylim([1,256])

end


function smallCube = shrinkCube(largeCube, p)
    B = largeCube;
    n = length(B);
    %p = 64;
    r = floor(n/p);
    C = zeros(p);
    for y = 1:p
        for x = 1:p
            for z = 1:p      
                C(y,x,z) = mean(mean(mean(B(y*r-r+1:y*r, x*r-r+1:x*r, z*r-r+1:z*r))));
            end
        end
    end
    %disp(C)
    smallCube = C;
end

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
