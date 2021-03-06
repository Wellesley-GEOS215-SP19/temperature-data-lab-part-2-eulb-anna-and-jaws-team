%% Anna Gaskill and Jocelyn "Jaws" Reahl
% February 12, 2019
%% Load in a list of all 18 stations and their corresponding latitudes and longitudes
load GlobalStationsLatLon.mat

%% Calculate the linear temperature trends over the historical observation period for all 18 station
% You will do this using a similar approach as in Part 1 of this lab, but
% now implementing the work you did last week within a function that you
% can use to loop over all stations in the dataset

%Set the beginning year for the more recent temperature trend
RecentYear = 1960; %you can see how your results change if you vary this value

%Initialize arrays to hold slope and intercept values calculated for all stations
P_all = NaN*zeros(length(sta),2); %example of how to do this for the full observational period
P_recent = NaN*zeros(length(sta), 2);

%Use a for loop to calculate the linear trend over both the full
%observational period and the time from RecentYear (i.e. 1960) to today
%using the function StationTempObs_LinearTrend
for i = 1:length(sta)
    [P_all(i,:), P_recent(i,:)] = StationTempObs_LinearTrend(sta(i), RecentYear);
end
%% Plot global maps of station locations
%Example code, showing how to plot the locations of all 18 stations
figure(1); clf
worldmap('World');
load coastlines;
plotm(coastlat,coastlon);
plotm(lat,lon,'m.','markersize',15);
title('Locations of stations with observational temperature data');

%%
%Follow the model above, now using the function scatterm rather than plotm
%to plot symbols for all 18 stations colored by the rate of temperature
%change from RecentYear to present (i.e. the slope of the linear trendline)
figure(2); clf
worldmap('World');
plotm(coastlat, coastlon);
scatterm(lat, lon, 50, P_recent(:,1), 'filled');
title('Rate of Temperature Change from 1960 to Present');
cmocean('thermal');
colorbar();

%Extension option: again using scatterm, plot the difference between the
%local rate of temperature change (plotted above) and the global mean rate
%of temperature change over the same period (from your analysis of the
%global mean temperature data in Part 1 of this lab).
%Data visualization recommendation - use the colormap "balance" from the
%function cmocean, which is a good diverging colormap option
Globalmeanrate = mean(P_recent(:,1));
figure(3); clf
worldmap('World');
plotm(coastlat, coastlon);
scatterm(lat, lon, 50, P_recent(:,1)-Globalmeanrate, 'filled');
title('Difference Between Local and Global Rate of Change');
cmocean('balance', 'pivot',0);
colorbar;

%% Now calculate the projected future rate of temperature change at each of these 18 stations
% using annual mean temperature data from GFDL model output following the
% A2 scenario (here you will call the function StationModelProjections,
% which you will need to open and complete)

%Use the function StationModelProjections to loop over all 18 stations to
%extract the linear rate of temperature change over the 21st century at
%each station
% Initialize arrays to hold all the output from the for loop you will write
% below
baseline_model = NaN*zeros(length(sta), 2);
tempAnnMeanAnomaly = NaN*zeros(length(sta),94);
P = NaN*zeros(length(sta),2);
%%
% Write a for loop that will use the function StationModelProjections to
% extract from the model projections for each station:
% 1) the mean and standard deviation of the baseline period
% (2006-2025) temperatures, 2) the annual mean temperature anomaly, and 3)
% the slope and y-intercept of the linear trend over the 21st century
for i = 1:length(sta)
    [baseline_model(i,:), tempAnnMeanAnomaly(i,:), P(i,:)] = StationModelProjections(sta(i));
end
%% Plot a global map of the rate of temperature change projected at each station over the 21st century
figure(4); clf
worldmap('World');
plotm(coastlat, coastlon);
scatterm(lat, lon, 50, P(:,1), 'filled');
%title('Projected Rate of Temperature Change 2006-2099');
cmocean('thermal');
colorbar()

%% Plot a global map of the interannual variability in annual mean temperature at each station
%as determined by the baseline standard deviation of the temperatures from
%2005 to 2025
figure(5); clf
worldmap('World');
plotm(coastlat, coastlon);
scatterm(lat, lon, 50, baseline_model(:,2), 'filled');
%title('Projected Interannual Variability 2006-2025');
cmocean('thermal');
colorbar();

%% Calculate the time of emergence of the long-term change in temperature from local variability
%There are many ways to make this calcuation, but here we will compare the
%linear trend over time (i.e. the rate of projected temperature change
%plotted above) with the interannual variability in the station's
%temperature, as determined by the baseline standard deviation

%Calculate the year of long-term temperature signal emergence in the model
%projections, calculated as the time (beginning from 2006) when the linear
%temperature trend will have reached 2x the standard deviation of the
%temperatures from the baseline period
emergencetime = NaN*zeros(18, 1);

for i = 1:length(sta)
    filename = ['model' num2str(sta(i)) '.csv'];
    stationdata = readtable(filename);
    x = stationdata.Year;
    y = stationdata.AnnualMeanTemperature;
    Praw = polyfit(x, y, 1);
    linear_trend = Praw(1)*x + Praw(2);
    emergencetime(i) = (baseline_model(i,1) + 2*baseline_model(i,2) - Praw(2))/Praw(1);
end

%%
%Plot a global map showing the year of emergence
figure(6); clf
worldmap('World');
plotm(coastlat, coastlon);
scatterm(lat, lon, 50, emergencetime, 'filled');
%title('Year of Emergence');
cmocean('solar', 'negative');
colorbar;
