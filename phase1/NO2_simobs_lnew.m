% Hour-Average Concentration of NO2(unit:ppbV) from Simulation...
% on 1000hPa/Ground
% Compared with Observation Datasets
% Date: 2022-04-10
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
% Read CMAQ Output
% ==================================

ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_simple.nc'; % Note here to modify
% ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_O33d.nc';

NO2 = squeeze(ncread(ncFile,'NO2')); % NO2(lon,lat,tstep)
nDays = size(NO2,3)/24; % get the length of tstep to calculate days number

NO2 = squeeze(nanmean(NO2(53:55,:,:),1));
NO2 = squeeze(nanmean(NO2(62:63,:),1));


% ==================================
% Read Observation Data
% ==================================

load(string(DataPath)+'chemdata_2021.mat');
nsite=594:598;
NO2_o(1,24,365)=0;

for i=1:5
    NO2_o(i,:,:)=chemdata(:,:,nsite(i),8);
end
for i=1:5
    for j=1:24
        for k=1:nDays
            NO2_ob(i,j,k)=NO2_o(i,j,k+80); % NO2_obs(site,hour,day)
        end
    end
end

NO2_obs=reshape(NO2_ob,5,144);
NO2_obs=squeeze(nanmean(NO2_obs,1));

% ==================================
% Plot
% ==================================

% set Time step
t=1:144;

figure
% set(gca,'position',[100,100,550,360],'visible','on');
% set(gca,'visible','on');
plot(t,NO2_obs*22.4/48,'-ok');
hold on;
plot(t+8,NO2,'-xb');

axis([0,145,0,40]);
set(gca,'XTick',[0:12:144]);
set(gca,'YTick',[0:10:40]);
xlabel('Tstep');
ylabel('Concentration of NO2(ppbv)');
h=legend('OBS','SIM','Location','NorthWest','fontsize',10);
set(h,'Box','off');
grid on;
title(['NO2\_0322-0327'],'fontsize',15);

path = ['D:/files/Master/02学术/Case/Shaog03/fig_lines/NOx_Ground_simobs']; % Note here to modify
print(gcf,'-dtiff','-r600',path)

Program_Ends_at=datetime('now')
