%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_DistWT.m plots the distirbution of WTs in "La Costa" and "La Sierra"
% regions.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear
clc

% INPUT PARAMETERS
StepF = 30;
Acc = 12;
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN = "Data/Processed/WT_";
DirOUT = "Data/Figures/DistWT_";
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


% Plotting and saving the distribution of WTs
figure
bar((1:n), WTC_NormCounts)
xticks(1:n)
xticklabels(XTickLabels)
xlim([0 (n+1)])
ylim([0 20])
grid off
ax = gca;
ax.FontSize = 15;
ax.GridAlpha = 0.5;
FileOUT = strcat(Git_repo, "/", DirOUT, num2str(Acc,"%03.f"), "/DistWT_Costa_", num2str(StepF,"%03.f"), ".tiff");
print(gcf,"-dtiff", "-r500",FileOUT)

figure
bar((1:n), WTS_NormCounts)
xticks(1:n)
xticklabels(XTickLabels)
xlim([0 (n+1)])
ylim([0 20])
grid off
ax = gca;
ax.FontSize = 15;
ax.GridAlpha = 0.5;
FileOUT = strcat(Git_repo, "/", DirOUT, num2str(Acc,"%03.f"), "/DistWT_Sierra_", num2str(StepF,"%03.f"), ".tiff");
print(gcf,"-dtiff", "-r500",FileOUT)