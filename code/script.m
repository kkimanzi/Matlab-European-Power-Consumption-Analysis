%% 1: Importing the data
% Import the data of:
% - Great Britain (gb), France (fr), Italy (it)
% into seperate tables
gbData = readtable('../data/gb.csv', 'Delimiter', ',');
frData = readtable('../data/fr.csv', 'Delimiter', ',');
itData = readtable('../data/it.csv', 'Delimiter', ',');


%% 2: Cleaning the data
% get a feel of the data
disp ("Summary of Great Britain Data");
summary(gbData)
head(gbData)
disp ("Summary of France Data");
summary(frData)
head(frData)
disp ("Summary of Italy Data");
summary(itData)
head(itData)

% remove and edit columns
gbData = removevars(gbData, "start"); %remove start column
gbData = renamevars(gbData, "xEnd", "end"); %rename end column
% remove time field from the datetime
% to end up with a day
gbData.end = extractBefore(gbData.end, " "); 
% sum loads in a day 
gbData = groupsummary(gbData, "end", "sum");
gbData = renamevars(gbData, ["end","sum_load"], ["day","Britain_Load"]);
gbData = removevars(gbData, "GroupCount");
% convert to datetime object
dateFormat = @(x)(datetime(x,'TimeZone','UTC','Format','dd-MM-yyyy'));
gbData = convertvars(gbData, "day", dateFormat);
gbData = sortrows(gbData, "day"); % sort according to day
disp("Great Britin Data after cleaning")
head(gbData)

% repeat above steps for France and Italy
frData = removevars(frData, "start");
frData = renamevars(frData, "xEnd", "end");
frData.end = extractBefore(frData.end, " "); 
frData = groupsummary(frData, "end", "sum");
frData = renamevars(frData, ["end","sum_load"], ["day","France_Load"]);
frData = removevars(frData, "GroupCount");
dateFormat = @(x)(datetime(x,'TimeZone','UTC','Format','dd-MM-yyyy'));
frData = convertvars(frData, "day", dateFormat);
frData = sortrows(frData, "day");
disp("France Data after cleaning")
head(frData)

itData = removevars(itData, "start");
itData = renamevars(itData, "xEnd", "end");
itData.end = extractBefore(itData.end, " "); 
itData = groupsummary(itData, "end", "sum");
itData = renamevars(itData, ["end","sum_load"], ["day","Italy_Load"]);
itData = removevars(itData, "GroupCount");
dateFormat = @(x)(datetime(x,'TimeZone','UTC','Format','dd-MM-yyyy'));
itData = convertvars(itData, "day", dateFormat);
itData = sortrows(itData, "day");
disp("Italy Data after cleaning")
head(itData)


% ** Combine the columns into a table **
powerConsumption = join(gbData, frData);
powerConsumption = join(powerConsumption, itData);
disp("Joined table for power consumption in Britain, France, and Italy")
head(powerConsumption)

%% 3: Analysis
% (i) Plot the power consumption on line chart
averagedConsumption = table(powerConsumption.day, movmean(powerConsumption.Britain_Load, 20), movmean(powerConsumption.France_Load, 20), movmean(powerConsumption.Italy_Load, 20));
averagedConsumption = renamevars(averagedConsumption,["Var1","Var2","Var3","Var4"],["date", "Britain","France","Italy"]);
%plot
figure
plot(averagedConsumption.date, averagedConsumption{:,2:end})
legend(averagedConsumption.Properties.VariableNames(2:end))
title('Moving Meaned (20-day) Power Consumption')
ylabel("Power Consumed [MW]")

% (ii) How much power does each country consume in a year?
rawYearlyData = renamevars(powerConsumption, "day", "year");
rawYearlyData = convertvars(rawYearlyData, "year", 'string');
% extract year part only from date
rawYearlyData.year = extractAfter(rawYearlyData.year, 6);
yearlyData = groupsummary(rawYearlyData, "year", "sum");
% remove rows for 2020 since incomplete
yearlyData(yearlyData.year == "2020", :) = []; 
% rename and delte columns
yearlyData = removevars(yearlyData, "GroupCount");
yearlyData = renamevars(yearlyData, ["sum_Britain_Load","sum_France_Load","sum_Italy_Load"],["Britain","France","Italy"]);
disp("Yearly power consumption in the countries")
disp(yearlyData)
%plot
figure
bar(yearlyData{:,2:end})
set(gca, 'XtickLabels', yearlyData{:,1})
legend(yearlyData.Properties.VariableNames(2:end))
title('Yealry Power Consumption (MW)')
ylabel("Power Consumed (MW)")

% (iii) What have been the maximum and minimum power consumptions
rangeData = groupsummary(rawYearlyData, "year", {"min","max","range"});
%rangeData(rangeData.YEAR == "2020", :) = [];
disp("Yearly power consumption range (MW)")
disp(rows2vars(rangeData))

