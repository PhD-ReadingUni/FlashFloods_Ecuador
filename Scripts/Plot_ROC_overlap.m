%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_ROC.m plots the ROC curves for all lead times, all forecasting 
% systems, and all regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
StepF = 72;
Acc = 12;
EFFCI = 6;
RegionName = "Costa";
Region = 1;
PlotRegion = "-o";
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN = "Data/Processed/HR_FAR_";
DirOUT = "Data/Figures/ROC_overl_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Plotting the Area Under the ROC Curve (AURC)
disp("Plotting the ROC curves")

% Setting some general parameters
AccSTR = num2str(Acc,"%03.f");
Steps = (12:6:246);
indStepF = find(Steps == StepF);

% Creating output directory
DirOUT_temp = strcat(Git_repo, "/", DirOUT, AccSTR, "/EFFCI", num2str(EFFCI,'%02.f'));
if ~exist(DirOUT_temp, "dir")
    mkdir(DirOUT_temp)
end


% Plotting the ROC curves
disp(strcat(" - Considering the flood reports with EFFCI>=",num2str(EFFCI)))
figure('visible','off') 

ENS_PercCDF = 85;
ENS_PercCDFcolour = [126/255,47/255,142/255];
ENS_SystemFC = "ENS";
FileIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/", ENS_SystemFC, "/EFFCI", num2str(EFFCI,"%02.f"), "/Perc", num2str(ENS_PercCDF,"%02.f"), "/HR_FAR_CI_", RegionName, ".mat");
disp(FileIN_temp)
load(FileIN_temp)
HR = [0; HR_AllSteps(:,indStepF); 1];
FAR = [0; FAR_AllSteps(:,indStepF); 1];
hold on
plot(FAR, HR, PlotRegion, "LineWidth", 1, "Color", ENS_PercCDFcolour, "MarkerFaceColor", ENS_PercCDFcolour, "MarkerSize", 4)

ecpoint_PercCDF = 99;
ecpoint_PercCDFcolour = [217/255,83/255,25/255];
ecpoint_SystemFC = "ecPoint";
FileIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/", ecpoint_SystemFC, "/EFFCI", num2str(EFFCI,"%02.f"), "/Perc", num2str(ecpoint_PercCDF,"%02.f"), "/HR_FAR_CI_", RegionName, ".mat");
disp(FileIN_temp)
load(FileIN_temp)
HR = [0; HR_AllSteps(:,indStepF); 1];
FAR = [0; FAR_AllSteps(:,indStepF); 1];
hold on
plot(FAR, HR, PlotRegion, "LineWidth", 1, "Color", ecpoint_PercCDFcolour, "MarkerFaceColor", ecpoint_PercCDFcolour, "MarkerSize", 4)

hold on
plot([0,1], [0,1], "k-", "LineWidth", 1)

xlim([0 1])
ylim([0,1])
set(gca,'FontSize',15);
grid on

% Saving the AURC
FileOUT = strcat(DirOUT_temp, "/ROC_over_", num2str(StepF,'%03.f'), "_", RegionName, ".tiff");
print(gcf,"-dtiff", "-r500",FileOUT)