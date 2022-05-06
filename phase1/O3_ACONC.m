% Plot Average Molar Mixing Ratio of O3(unit:ppmV) from Netcdf using Matlab
% Date: 2022-04-04
% Edited by Evan
% ==================================
clc
clear
close all

Program_Starts_at=datetime('now')

% ==================================
% Read gridfile
% ==================================
DataPath='F:/Data/';
Grid='CN9';
GridName='CN9GD_98X74'; % Note here to modify
GridFile = string(DataPath)+'GRIDCRO2D_2021076.nc'; % Note here to modify
close

lat = ncread(GridFile,'LAT');
lon = ncread(GridFile,'LON');  

% ==================================
% Read shapefile
% ==================================

% Read China province line
ChinaL=shaperead('D:/files/Master/02学术/Plot_Boundary/全国省级、地市级、县市级行政区划shp/全国省级、地市级、县市级行政区划shp/bou2_4l.shp');
bou2_4lx=[ChinaL(:).X];
bou2_4ly=[ChinaL(:).Y];

% ==================================
% Read CMAQ output
% ==================================

ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_simple.nc'; % Note here to modify
% ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_O33d.nc';

O3 = squeeze(ncread(ncFile,'O3')); % O3(lon,lat,tstep)
nDays = size(O3,3)/24; % get the length of tstep to calculate days number
O3 = reshape(O3,98,74,24,nDays); % O3(lon,lat,hour,day)

% ==================================
% Plot
% ==================================

% we want O3 at 8,10,12,14,16,18h in every single day
% convert local time to GMT
hour=[0,2,4,6,8,10];
for i=1:nDays
    for j=1:6
        figure
        % set figure location on the screen, and size.[Xcenter Ycenter width height]
        set(gcf,'position',[100,100,800,600],'visible','off');
        axes('position', [0.06,0.05,0.84,0.9]);
        m_proj('Mercator','lon',[109 117.4],'lat',[20.3 25.6]);
        m_pcolor(lon,lat,O3(:,:,hour(j)+1,i));
        colormap(jet);
        hold on;
        % plot China province line
        m_plot(bou2_4lx,bou2_4ly,'k','linewidth',1.5);
        %  set coast line resolution
        m_gshhs_i('color',[0 0 0],'linewidth',1);
        m_grid('box','fancy');
        % draw colorbar
        clim = [0 120]; % Note here to modify
        h=colorbar();caxis(clim);
        set(get(h,'Title'),'string','ppbV','fontsize',15); % set colorbar title & units
        set(h,'Position', [0.93, 0.1, 0.03, 0.8]); % set colorbar position
        % title
        % title(['O_3-',datestr(datenum(2021,3,22),'yyyy-mm-dd')],'fontsize',17);
        title(['O_3-','2021-03-',num2str(i+22-1),'-',num2str(hour(j)+8)],'fontsize',17); % Note here to modify

        path = ['D:/files/Master/02学术/Case/Shaog3/fig_combine/O3/O3_03-',num2str(i+22-1),'-',num2str(hour(j)+8)]; % Note here to modify
        print(gcf,'-dtiff','-r600',path)
    end
end
Program_Ends_at=datetime('now')
