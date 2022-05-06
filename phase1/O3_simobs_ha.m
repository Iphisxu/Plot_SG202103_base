% Hour-Average Concentration of O3(unit:ppbV) from Simulation...
% Compared with Observation Datasets
% Date: 2022-04-05
% Edited by Evan
% ==================================
clc
clear
close all

Program_Starts_at=datetime('now')

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
% Read Shapefile
% ==================================

% Read province line
GD=shaperead('D:/files/Master/02学术/Boundary/地形边界/Gdbound/gdboudiv_arc.shp');
HK=shaperead('D:/files/Master/02学术/Boundary/行政边界/HK/HK.shp');
MC=shaperead('D:/files/Master/02学术/Boundary/行政边界/MC/MC.shp');
bou1_4lx=[GD(:).X];
bou1_4ly=[GD(:).Y];
bou1_4mx=[HK(:).X];
bou1_4my=[HK(:).Y];
bou1_4nx=[MC(:).X];
bou1_4ny=[MC(:).Y];

% ==================================
% Read CMAQ Output
% ==================================

ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_simple.nc'; % Note here to modify
% ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_O33d.nc';

O3 = squeeze(ncread(ncFile,'O3')); % O3(lon,lat,tstep)
nDays = size(O3,3)/24; % get the length of tstep to calculate days number
O3 = reshape(O3,98,74,24,nDays); % O3(lon,lat,hour,day)

for i=1:98
    for j=1:74
        for k=1:(24-8+1)
            for l=1:nDays
                O3_moav(i,j,k,l)=nanmean(O3(i,j,k:k+7,l),3); % calculate 8-hour moving average 
            end
        end
    end
end
for i=1:98
    for j=1:74
        for k=1:nDays
            O3_max(i,j,k)=squeeze(max(O3_moav(i,j,:,k))); % calculate MDA8, O3_max(lon,lat,day)
        end
    end
end

% ==================================
% Read Observation Data
% ==================================

load(string(DataPath)+'chemdata_2021.mat');
nlon=lon(1:end,1:end);
nlat=lat(1:end,1:end);
bndryx=[nlon(:,1)',nlon(end,2:end),flipud(nlon(1:end-1,end))',fliplr(nlon(1,1:end-1))];
bndryy=[nlat(:,1)',nlat(end,2:end),flipud(nlat(1:end-1,end))',fliplr(nlat(1,1:end-1))];
nsite=size(site_lat,1);

site_count=1; % number of sites in GD
O3_obs(1,24,365)=0;
slon(1,8784)=0;
slat(1,8784)=0;
for i=1:nsite
    in=inpolygon(site_lon(i),site_lat(i),bndryx,bndryy);
    if in==1
        O3_obs(site_count,:,:)=chemdata(:,:,i,11);
        slon(site_count,:)=site_lon(i,:);
        slat(site_count,:)=site_lat(i,:);
        site_count=site_count+1;
    end
end
for i=1:(site_count-1)  % here site_count-1=144
    for j=1:24
        for k=1:nDays
            O3_obs(i,j,k)=O3_obs(i,j,k+80); % O3_obs(site,hour,day)
        end
    end
end

% ==================================
% Set Boundary
% ==================================

% SIM
ffbsg={'F:/Data/City_Boundary/Guangd'};
fileFolder=fullfile(ffbsg{1});
dirOutput=dir(fullfile(fileFolder,'*.txt'));
tfile={dirOutput.name};
for i=1:21
     [xx,yy]=textread(fullfile(fileFolder,tfile{i}),'%f%f','delimiter', [',',';']);
     sjxy10=inpolygon(lon,lat,xx,yy);
     sjnan10=sjxy10*1;
     prdmat{i}=sjnan10;
end
gd=zeros(98,74);
for i=1:21
    gd=gd+prdmat{i};
end
for i=1:98
    for j=1:74
        if gd(i,j)==0
            gd(i,j)=NaN;
        end
    end
end
gd(42,37)=1;

% OBS
ffbsg={'F:/Data/City_Boundary/Guangd'};
fileFolder=fullfile(ffbsg{1});
dirOutput=dir(fullfile(fileFolder,'*.txt'));
tfile={dirOutput.name};
for i=1:21
     [xx,yy]=textread(fullfile(fileFolder,tfile{i}),'%f%f','delimiter', [',',';']);
     sjxy10=inpolygon(slon,slat,xx,yy);
     sjnan10=sjxy10*1;
     prdmat{i}=sjnan10;
end
gd1=zeros(144,8784);
for i=1:21
    gd1=gd1+prdmat{i};
end
for i=1:144
    for j=1:8784
        if gd1(i,j)==0
            gd1(i,j)=NaN;
        end
    end
end

% ==================================
% Plot
% ==================================

% we want O3 at 8,10,12,14,16,18h in every single day
% convert local time to GMT
hour=[0,2,4,6,8,10];
for i=1:nDays
    for j=1:6
        figure
        set(gcf,'position',[100,100,550,360],'visible','off');
        m_proj('Lambert','lon',[109 118],'lat',[19.5 26.2],'rec','on');
        [~,h]=m_contourf(lon,lat,O3(:,:,hour(j)+1,i).*gd,0:10:120);
        set(h,'edgecolor','none');
        hold on
        mbmin=0;
        mbmax=120;
        pdata=O3_obs(:,hour(j)+1,i).*gd1(:,1)*22.4/48;
        pdata(pdata<mbmin)=mbmin*1.01;
        pdata(pdata>mbmax)=mbmax*0.99;
        % color=WhiteBlueGreenYellowRed(254);
        color=colormap(jet);
        [clength,~]=size(color);
        for k=1:144
            if ~isnan(pdata(k)) % if pdata is not NaN
                m_plot(slon(k,1,1),slat(k,1,1),'o','color','k','markerfacecolor',color(ceil((pdata(k)-mbmin)/(mbmax-mbmin)*clength),:),'markersize',7);
            end
            hold on
        end
        caxis([0,120]);
        % color=WhiteBlueGreenYellowRed(10);
        color=colormap(jet);
        colormap(color(:,:));
        hc=colorbar('ytick',0:30:120,'fontsize',15);
        ylabel(hc,'ppbv','fontsize',15);
        % plot GuangDong province line
        m_plot(bou1_4lx,bou1_4ly,'k','linewidth',0.7);
        m_plot(bou1_4mx,bou1_4my,'k','linewidth',0.7);
        m_plot(bou1_4nx,bou1_4ny,'k','linewidth',0.7);
        %  set coast line resolution
        % m_gshhs_i('color',[0 0 0],'linewidth',0.7);
        m_grid('box','on','tickdir','in','xtick',(110:2:118),'ytick',(20:2:26),'fontsize',15,'linestyle','none');
        title(['O_3 ','2021-03-',num2str(i+22-1),'-',num2str(hour(j)+8)],'fontsize',17);

        Now_printing_figure_on=['2021-03-',num2str(i+22-1),'-',num2str(hour(j)+8)]
        path = ['D:/files/Master/02学术/Case/Shaog03/figure_MO/O3_h/O3_','2021-03-',num2str(i+22-1),'-',num2str(hour(j)+8)]; % Note here to modify
        print(gcf,'-dtiff','-r600',path)
    end
end

Program_Ends_at=datetime('now')
