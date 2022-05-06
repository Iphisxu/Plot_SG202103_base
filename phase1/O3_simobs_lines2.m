% Hour-Average Concentration of O3(unit:ppbV) from Simulation...
% on 850hPa
% Compared with Observation Datasets
% Date: 2022-04-09
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

% ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_simple.nc'; % Note here to modify
ncFile=string(DataPath)+'COMBINE_ACONC_'+string(GridName)+'_202103_O33d.nc';

O3 = ncread(ncFile,'O3'); % O3(lon,lat,layer,tstep)
O3_L1=squeeze(O3(:,:,19,:)); % L1=850hPa
O3_L2=squeeze(O3(:,:,20,:)); % L2=800hPa
nDays = size(O3,4)/24; % get the length of tstep to calculate days number
% O3_L1d = reshape(O3_L1,98,74,24,nDays); % O3(lon,lat,hour,day)
% O3_L2d = reshape(O3_L2,98,74,24,nDays); % O3(lon,lat,hour,day)

% ==================================
% Read Observation Data
% ==================================

O3_obs=xlsread('F:/Data/Gaoshanzhan.xlsx','D98:D145');
% O3_obs=reshape(num,24,6);

% ==================================
% Plot
% ==================================

% set Time step
t=1:48;

figure
% set(gca,'position',[100,100,550,360],'visible','on');
% set(gca,'visible','on');
plot(t,O3_obs*22.4/48,'-ok');
hold on;
plot(t+8,squeeze(O3_L1(46,62,73:120)),'-xb');
plot(t+8,squeeze(O3_L2(46,62,73:120)),'-xg');

axis([0,50,0,120]);
set(gca,'XTick',[0:6:48]);
set(gca,'YTick',[0:30:120]);
xlabel('Tstep');
ylabel('Concentration of O3(ppbv)');
h=legend('OBS\_830hPa','SIM\_850hPa','SIM\_800hPa','Location','NorthWest','fontsize',10);
set(h,'Box','off');
grid on;
title(['O3\_0325-0326'],'fontsize',15);

path = ['D:/files/Master/02学术/Case/Shaog03/fig_lines/O3_850hPa_simobs_2']; % Note here to modify
print(gcf,'-dtiff','-r600',path)

Program_Ends_at=datetime('now')
