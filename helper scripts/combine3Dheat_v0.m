close all; clear; clc;
SLASH = checkOS();

disp("combine 3d heat")
obj_name = "cart";
obj_idx = 1;
str_idx = 1; stp_idx = 1;
plc_range = str_idx:stp_idx;
scene_lim = [-0.75, 0.75; 1.5, 3; -0.8, 1]; %[x1,x2 ;y1,y2; z1,z2]
vis = "on";

saveimg = 0; % 1 => save plots, 0 => no saving
addr0 = strcat("..",SLASH,"results",SLASH,obj_name,"_",num2str(obj_idx),SLASH);
loadaddr = strcat(addr0,"cartHeat",SLASH);
saveaddr = strcat(addr0,"combined",SLASH);
if ~exist(saveaddr, 'dir')
    mkdir(saveaddr);
end

% bring object up and to the center
if (scene_lim(3,1) < 0)
    scene_lim(3,2) = scene_lim(3,2) - scene_lim(3,1);
    scene_lim(3,1) = scene_lim(3,1) - scene_lim(3,1);
end
if (scene_lim(2,1) > 0)
    y_length = scene_lim(2,2) - scene_lim(2,1);
    scene_lim(2,1) = -y_length/2;
    scene_lim(2,2) = y_length/2;
end

for plc_idx = plc_range
    for cam = 1:4
        load(strcat(loadaddr,"cam",num2str(cam),SLASH,num2str(plc_idx),".mat"));
        % heatmap_ct, 256x64x64, y*x*z
        % expand to 256x256x256
        heat_256 = zeros(256);
        r = 256/64;
        for y = 1:256
            for x = 1:64
                for z = 1:64
                    heat_256(y,x*r-r+1:x*r,z*r-r+1:z*r) = ones(r)*heatmap_ct(y,x,z);
                end
            end
        end
        %disp(heat_256(1,:,:))
        switch cam
            case 0
                heat_pm = permute(heat_256,[1 3 2]); % y*z*x
                heat_rt = rot90(heat_pm,-1);
                heatmap_ct0 = permute(heat_rt,[1 3 2]);
            case 1
                heatmap_ct1 = heat_256;
            case 2
                heatmap_ct2 = rot90(heat_256,-1);
            case 3
                heatmap_ct3 = rot90(heat_256,2);
            case 4
                heatmap_ct4 = rot90(heat_256,-3);
        end
        %plottitle = strcat('cam ', num2str(cam));
        %heatmap_ct = log(heatmap_ct + 1);
        %show_slice_heat_3d(heatmap_ct,plottitle) 
        %heatmap_ct = rot90(heatmap_ct,2);
        %show_slice_heat_3d(heatmap_ct,plottitle) 
    end
    disp(strcat("loaded placement ", plc_idx))

    %{
    for cam = 4
        plottitle = strcat('cam ', num2str(cam));
        heatmap_ct = heatmap_ct4;%log(heatmap_ct1 + 1);
        show_slice_heat_3d(heatmap_ct,plottitle)
        %show_heatmap2d_cart3(heatmap_ct1) 
    end
    %}
    %% combine maps
    method_sel = 2;
    sz = 64; disp(strcat("Cube size = ", num2str(sz)))

    if method_sel == 1
        % method 1: summing
        method = "Sum";
        %heatmap_ct_comb = heatmap_ct0 + heatmap_ct1 + heatmap_ct2 + heatmap_ct3 + heatmap_ct4;
        heatmap_ct_comb = heatmap_ct1 + heatmap_ct2 + heatmap_ct3 + heatmap_ct4;
    elseif method_sel == 2
        % method 2: max value
        method = "Max"; disp(strcat("Method = ",method));
        heatmap_ct_comb = zeros(256,256,256);
        for y = 1:256
            for x = 1:256
                for z = 1:256
                    %heatmap_ct_comb(y,x,z) = max([heatmap_ct0(y,x,z),heatmap_ct1(y,x,z),heatmap_ct2(y,x,z),heatmap_ct3(y,x,z),heatmap_ct4(y,x,z)]);
                    heatmap_ct_comb(y,x,z) = max([heatmap_ct1(y,x,z),heatmap_ct2(y,x,z),heatmap_ct3(y,x,z),heatmap_ct4(y,x,z)]);
                end
            end
        end
    end
    %}

    if sz ~= 256
        heatmap_ct_comb = shrinkCube(heatmap_ct_comb, sz);
    end

    div = floor(log10(max(max(max(heatmap_ct_comb))))) - 2;
    heatmap_ct_comb = heatmap_ct_comb/(10^div);
    heatmap_ct_comb = log(heatmap_ct_comb+1);

    %threshold = max(max(max(heatmap_ct_comb)))*0.01;
    %heatmap_ct_comb(heatmap_ct_comb<=threshold)=0;
    %show_heatmap2d_cart3(heatmap_ct) 

    %%

    ftitle = strcat(obj_name," ",num2str(obj_idx)," placement ", num2str(plc_idx));
    if vib == 0
        fsubtlt = strcat("Combined (",method,", ",num2str(sz),"^3), w/o vibration");
    else
        fsubtlt = strcat("Combined (",method,", ",num2str(sz),"^3), w/ vibration");
    end
    f0 = show_slice_heat_3d(heatmap_ct_comb,scene_lim,sz,ftitle,fsubtlt,vis);
    f0p = f0.Position;
    f0.Position = [f0p(1),f0p(2),f0p(3),f0p(4)*0.6];

    f1 = show_heatmap2d_cart4(heatmap_ct_comb,scene_lim,sz,ftitle,fsubtlt,vis);
    %f1.Position(1) = f1.Position(1) / 3;
    %f1.Position(2) = f1.Position(2) / 2;
    %f1.Position(3) = f1.Position(3) * 2;
    %f1p = f1.Position;
    %f1.Position = [f1p(1),f1p(2),f1p(3),f1p(3)/2];
    %screenSize = get(0, 'screensize');
    %f1.Position = [0, (screenSize(4)-screenSize(3)/3)/2, screenSize(3), screenSize(3)/3];
    %show_slice_heat_3d(heatmap_ct1,"combined",256)

    prefix = strcat(obj_name,"_",num2str(obj_idx),"_placement_", num2str(plc_idx),"_",vib_postfix,"_");

    szt = strcat('(',num2str(sz),'x',num2str(sz),'x',num2str(sz),')');
    if saveimg == 1
        %save(strcat(saveaddr,prefix,'combined_heatmap3d_',method,'_',szt,'.mat'),'heatmap_ct_comb');
        %savefig(f0,strcat(saveaddr,prefix,'combined_heatmap3d_',method,'_',szt,'.fig'),'compact');
        saveas(f0,strcat(saveaddr,prefix,'combined_heatmap3d_',method,'_',szt,'_preview'),'png');
        %savefig(f1,strcat(saveaddr,prefix,'combined_3view_',method,'_',szt,'.fig'),'compact');
        saveas(f1,strcat(saveaddr,prefix,'combined_3view_',method,'_',szt),'png');
        disp("saved")       
    end

    if vis == "off"
       close(f0); close(f1);
    end

end
    
disp("finished")
%%
%f1 = show_heatmap2d_cart4(heatmap_ct_comb,scene_lim,sz,ftitle,fsubtlt,vis);
%%
function show_heatmap2d_cart3(heatmap)   
    maxheat = max(max(max(heatmap)));
    figure(); 
    font_size = 8;       
    xt = linspace(1,256,7); yt = linspace(1,256,7); zt = linspace(1,256,17);   

    % Visulize the radar heatmap top view
    radar_heatmap_top = squeeze(max(heatmap,[],3));
    subplot(131); imagesc(radar_heatmap_top);
    title("Top View")
    set(gca,'XDir','normal'); set(gca,'YDir','normal');
    c = colorbar; %title(c,'         x10^1^2')
    colormap jet; %colorcube; %
    caxis([0 maxheat]); %
    xlabel('x(m)'); ylabel('y(m)'); set(gca,'FontSize',font_size);
    xticks(xt); xticklabels({'-3','-2','-1','0','1','2','3'})
    yticks(yt); yticklabels({'2','3','4','5','6','7','8'})
    xlim([1,256]),ylim([1,256])
  
    % Visulize the radar heatmap front view
    radar_heatmap_front = squeeze(max(heatmap,[],1));
    subplot(132); imagesc(radar_heatmap_front.');
    title("Front View")
    %set(gca,'XDir','reverse');
    set(gca,'XDir','normal');set(gca,'YDir','normal');
    c = colorbar; %title(c,'         x10^1^2')
    colormap jet;% colorcube; %
    caxis([0 maxheat]);
    xlabel('x(m)'); ylabel('z(m)'); set(gca,'FontSize',font_size);
    xticks(xt); xticklabels({'-3','-2','-1','0','1','2','3'})
    yticks(zt); 
    yticklabels({'-1.25','-1','-0.75','-0.5','-0.25','-0','0.25',...
        '0.5','0.75','1','1.25','1.5','1.75','2','2.25','2.5','2.75'});
    xlim([1,256]),ylim([1,256])
    
        % Visulize the radar heatmap side view
    radar_heatmap_side = squeeze(max(heatmap,[],2));
    subplot(133); imagesc(radar_heatmap_side.');
    title("Side View")
    set(gca,'XDir','normal');set(gca,'YDir','normal');
    c = colorbar; %title(c,'         x10^1^2')
    colormap jet; %colorcube;%jet; %
    caxis([0 maxheat]); %
    xlabel('y(m)'); ylabel('z(m)'); set(gca,'FontSize',font_size);
    xticks(yt); xticklabels({'2','3','4','5','6','7','8'})
    yticks(zt); 
    yticklabels({'-1.25','-1','-0.75','-0.5','-0.25','-0','0.25',...
        '0.5','0.75','1','1.25','1.5','1.75','2','2.25','2.5','2.75'});
    xlim([1,256]),ylim([1,256])
end

% plot 3d heatmap slice
function f = show_slice_heat_3d(heatmap_ct,scene_lim,sz,tlt,subtlt,vis)
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
    h = slice(XX,YY,ZZ,heatmap_ct,xslice,yslice,zslice);
    title([tlt;subtlt])
    xlabel('x(m)'); ylabel('y(m)'); zlabel('z(m)');
    xlim([0 sz]); ylim([0 sz]); zlim([0,sz]);
    
    xlb = num2cell(linspace(scene_lim(1,1),scene_lim(1,2),5));
    ylb = num2cell(linspace(scene_lim(2,1),scene_lim(2,2),5));
    zlb = num2cell(linspace(scene_lim(3,1),scene_lim(3,2),5));

    xt = linspace(1,sz,5); xticks(xt); xticklabels(xlb);
    yt = linspace(1,sz,5); yticks(yt); yticklabels(ylb);
    zt = linspace(1,sz,5); zticks(zt); zticklabels(zlb);
    
    %set(h,'EdgeColor','none','FaceColor','interp','FaceAlpha','interp');
    set(h,'EdgeColor','none','FaceColor','flat','FaceAlpha','flat');
    %set(h,'EdgeColor','none','FaceColor','flat','FaceAlpha','0.01');
    % set transparency to correlate to the data values.
    alpha('color'); %alpha(h, 0.01);
    colorbar; colormap jet;
end

function f = show_heatmap2d_cart4(heatmap,scene_lim,sz,tlt,subtlt,vis)   
    maxheat = max(max(max(heatmap)));
    
    font_size = 8;          
    xt = linspace(1,sz,5); yt = linspace(1,sz,5); zt = linspace(1,sz,5);
    xlb = num2cell(linspace(scene_lim(1,1),scene_lim(1,2),5));
    ylb = num2cell(linspace(scene_lim(2,1),scene_lim(2,2),5));
    zlb = num2cell(linspace(scene_lim(3,1),scene_lim(3,2),5));
    
    x_len = scene_lim(1,2)-scene_lim(1,1);
    y_len = scene_lim(2,2)-scene_lim(2,1);
    z_len = scene_lim(3,2)-scene_lim(3,1);
    
    lb_1x = xlb; lb_1y = zlb; % front
    lb_2x = ylb; lb_2y = zlb; % side
    lb_3x = xlb; lb_3y = ylb; % top 
    
    f = figure('visible', vis);
    sgt = sgtitle([tlt,subtlt]); sgt.FontSize = 12;
    screenSize = get(0, 'screensize');
    f.Position = [screenSize(3)/5, screenSize(4)/4, screenSize(3)*3/5, screenSize(3)*4/15];
    %fp = f.Position; disp(fp(3)); disp(fp(4))
    
    % Visulize the radar heatmap side view
    radar_heatmap_side = squeeze(max(heatmap,[],2));
    f1 = subplot(131);  imagesc(radar_heatmap_side.');
    f1.Position(4) = f1.Position(4) * 0.6;
    title("Side View")
    set(gca,'XDir','reverse');set(gca,'YDir','normal');
    c = colorbar; %title(c,'         x10^1^2')
    c.Location = 'southoutside';
    colormap jet; %colorcube;%jet; %
    caxis([0 maxheat]); %
    xlabel('y(m)'); ylabel('z(m)'); set(gca,'FontSize',font_size);
    xticks(yt); xticklabels(lb_2x)
    yticks(zt); yticklabels(lb_2y);
    xlim([1,sz]),ylim([1,sz])
    
    
    % Visulize the radar heatmap front view
    radar_heatmap_front = squeeze(max(heatmap,[],1));
    f2 = subplot(132);  imagesc(radar_heatmap_front.');
    f2.Position(4) = f2.Position(4) * 0.6;
    title("Front View")
    %set(gca,'XDir','reverse');
    set(gca,'XDir','normal');set(gca,'YDir','normal');
    c = colorbar; %title(c,'         x10^1^2')
    c.Location = 'southoutside';
    colormap jet;% colorcube; %
    caxis([0 maxheat]);
    xlabel('x(m)'); ylabel('z(m)'); set(gca,'FontSize',font_size);
    xticks(xt); xticklabels(lb_1x)
    yticks(zt); yticklabels(lb_1y);
    xlim([1,sz]),ylim([1,sz])
    

    % Visulize the radar heatmap top view
    radar_heatmap_top = squeeze(max(heatmap,[],3));
    f3 = subplot(133);  imagesc(radar_heatmap_top);
    title("Top View")
    set(gca,'XDir','normal'); set(gca,'YDir','normal');
    c = colorbar; %title(c,'         x10^1^2')
    c.Location = 'southoutside';
    colormap jet; %colorcube; %
    caxis([0 maxheat]); %
    xlabel('x(m)'); ylabel('y(m)'); set(gca,'FontSize',font_size);
    xticks(xt); xticklabels(lb_3x)
    yticks(yt); yticklabels(lb_3y)
    xlim([1,sz]),ylim([1,sz])
    
    %f1p = f1.Position
    %f2p = f2.Position
    
    
    %f1p = f1.Position
    %f1.Position = [f1p(1),f1p(2),f1p(3),f1p(4)*0.6];
    %f2p = f2.Position
    %f2.Position = [f2p(1),f2p(2),f2p(3),f1p(4)*0.6];    
    %f3p = f3.Position;
    %f3.Position = [f3p(1),f3p(2),f3p(3),f3p(4)];
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
