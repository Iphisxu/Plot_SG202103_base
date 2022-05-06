% Hour-Average Concentration of O3(unit:ppbV) from Simulation...
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

O3 = squeeze(ncread(ncFile,'O3')); % O3(lon,lat,tstep)
nDays = size(O3,3)/24; % get the length of tstep to calculate days number

O3 = squeeze(nanmean(O3(53:55,:,:),1));
O3 = squeeze(nanmean(O3(62:63,:),1));


% ==================================
% Read Observation Data
% ==================================

load(string(DataPath)+'chemdata_2021.mat');
nsite=594:598;
O3_o(1,24,365)=0;

for i=1:5
    O3_o(i,:,:)=chemdata(:,:,nsite(i),10);
end
for i=1:5
    for j=1:24
        for k=1:nDays
            O3_ob(i,j,k)=O3_o(i,j,k+80); % O3_obs(site,hour,day)
        end
    end
end

O3_obs=reshape(O3_ob,5,144);
O3_obs=squeeze(nanmean(O3_obs,1));

% ==================================
% Plot
% ==================================

% set Time step
t=1:144;

figure
% set(gca,'position',[100,100,550,360],'visible','on');
% set(gca,'visible','on');
plot(t,O3_obs*22.4/48,'-ok');
hold on;
plot(t+8,O3,'-xb');

axis([0,145,0,120]);
set(gca,'XTick',[0:12:144]);
set(gca,'YTick',[0:30:120]);
xlabel('Tstep');
ylabel('Concentration of O3(ppbv)');
h=legend('OBS','SIM','Location','NorthWest','fontsize',10);
set(h,'Box','off');
grid on;
title(['O3\_0322-0327'],'fontsize',15);

path = ['D:/files/Master/02学术/Case/Shaog03/fig_lines/O3_Ground_simobs']; % Note here to modify
print(gcf,'-dtiff','-r600',path)

Program_Ends_at=datetime('now')
