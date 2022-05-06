% Hour-Average Concentration of O3(unit:ppbV) from Simulation...
% on Vertical Section
% Date: 2022-04-25
% Edited by Evan
% ==================================
clc
clear
close all

Program_Starts_at=datetime('now')

%% Read Data
% ==================================
% Read Gridfile
% ==================================
DataPath='F:/Data/';
Grid='CN9';
GridName='CN9GD_98X74'; % Note here to modify
GridFile = string(DataPath)+'GRIDCRO2D_2021076.nc'; % Note here to modify
close

lat = ncread(GridFile,'LAT');
lon = ncread(GridFile,'LON');  

% ==================================
% Read WRF & CMAQ Output
% ==================================

timestep=1:72;

wrfFile=string(DataPath)+'wrf/wrfout_d02.nc'; % timestep=145,032200-032800
wwind = ncread(wrfFile,'W'); % wwind(lon_grid=222,lat_grid=162,layer=39,time=145)
wwind = wwind(:,:,1:32,73:144);
wwind = squeeze(nanmean(wwind(72:75,:,:,:),1));
wwind = squeeze(nanmean(wwind(99:100,:,:),1)); % wwind(layer,timestep)
% wwind = reshape(wwind,162,22,24,6); % wwind(lat,layer,hour,day)
w_horizonal = zeros(size(wwind));
layer=1:32;

lon_u = ncread(wrfFile,'XLONG');
lat_u = ncread(wrfFile,'XLAT');

% ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_simple.nc'; % Note here to modify
cmaqFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_O33d.nc';

O3 = ncread(cmaqFile,'O3'); % O3(lon,lat,layer,tstep)
nDays = size(O3,4)/24; % get the length of tstep to calculate days number
O3 = squeeze(O3(:,:,1:32,73:144));
O3 = squeeze(nanmean(O3(53:55,:,:,:),1));
O3 = squeeze(nanmean(O3(62:63,:,:),1)); % O3(layer,timestep)
% O3 = reshape(O3,22,24,nDays); % O3(layer,hour,day)

[X,Y]=meshgrid(timestep,layer);

%% Plot figure
% ==================================
% Plot
% ==================================

% level=...
% [1000,998.005,995.820,993.445,990.880,988.125,...
% 985.180,981.665,977.485,972.545,966.655,959.625,...
% 951.360,941.575,929.985,916.400,900.345,881.535,...
% 859.495,833.845,804.015,771.715,736.755,703.885,...
% 658.950,616.200,570.980,523.575,474.365,423.730,...
% 372.335,320.750,270.020,221.095,175.780,135.785,...
% 101.490,72.895,50]

scale=1.2;

figure
set(gcf,'position',[0 0 800 600],'visible','on');
ax=axes('color','none');
contourf(X,Y,O3,'edgecolor','none');
caxis([0,120]);
color=colormap(turbo);
hc=colorbar('ytick',0:30:120,'fontsize',10);
ylabel(hc,'ppbv','fontsize',10);
% shading flat
hold on

w=quiver(X(1:2:32,1:3:72),Y(1:2:32,1:3:72),w_horizonal(1:2:32,1:3:72),wwind(1:2:32,1:3:72),'k');

% set axis
xlim([1 72]);
ylim([1 32]);
set(ax,'Xtick',[1:24:72],'Xticklabel',[25:27]);
set(ax,'Ytick',[1:5:33],'Yticklabel',[1000 990 966 916 800 616 370]);
xlabel('Date','FontSize',12,'FontWeight','bold');
ylabel('Pressure(hPa)','FontSize',12,'FontWeight','bold');
grid off
title(['O_3 vertical in Shaoguan'],'fontsize',12,'FontWeight','bold');

path = ['D:/files/Master/02学术/Case/Shaog03/NEW/vertical_point_high']; % Note here to modify
print(gcf,'-dtiff','-r600',path)



Program_Ends_at=datetime('now')
