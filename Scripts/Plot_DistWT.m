%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_DistWT.m plots the distirbution of WTs in "La Costa" and "La Sierra"
% regions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear
clc

% INPUT PARAMETERS
StepF = 18;
Acc = 12;
Git_repo = "C:/Users/FatimaPillosu/OneDrive/Desktop/GitHub_PhD/FlashFlood_Ecuador";
FileIN = "Data/Processed/WTs_";
DirOUT = "Data/Figures/WTs_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Reading the WTs codes and counts for "La Costa" and "La Sierra"
FileIN_C = strcat(Git_repo, "/", FileIN, num2str(Acc,"%03.f"), "/WTs_Costa_", num2str(StepF,"%03.f"), ".csv");
FileIN_S = strcat(Git_repo, "/", FileIN, num2str(Acc,"%03.f"), "/WTs_Sierra_", num2str(StepF,"%03.f"), ".csv");
WTC = import_WT(FileIN_C); 
WTS = import_WT(FileIN_S);

% Plotting the WT counts
WTC_codes = WTC(:,1);
WTC_NormCounts = WTC(:,2) / sum(WTC(:,2)) * 100;
WTC_codes1 = WTC_codes(WTC_NormCounts>2);

WTS_codes = WTS(:,1);
WTS_NormCounts = WTS(:,2) / sum(WTS(:,2)) * 100;
WTS_codes1 = WTS_codes(WTS_NormCounts>=1 & WTS_NormCounts<1000);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plotting the WT distributions

% Creating the tick labels for the x-axis
n = length(WTC_codes);
XTickLabels = {};
for i = 1 : n
    WT_code_temp = WTC_codes(i);
    if WT_code_temp==11111 || WT_code_temp==21111 || WT_code_temp==31111 || WT_code_temp==41111
        XTickLabels = [XTickLabels, num2str(WT_code_temp)];
    else
        XTickLabels = [XTickLabels, " "];
    end
end



% Plotting the distribution
figure
bar((1:n), WTC_NormCounts)
xticks(1:n)
xticklabels(XTickLabels)
xlim([0 (n+1)])
ylim([0 20])
grid off

figure
bar((1:n), WTS_NormCounts)
xticks(1:n)
xticklabels(XTickLabels)
xlim([0 (n+1)])
ylim([0 20])
grid off