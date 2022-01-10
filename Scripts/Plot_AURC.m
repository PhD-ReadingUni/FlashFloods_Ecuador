%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_AURC.m plots the Area Under the Roc Curve (AURC) for all lead times,
% all forecasting systems considered and all Ecuador regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
StepF_S = 12;
StepF_F = 12;
Disc_StepF = 6;
Acc = 12;
EFFCI_list = [1];
PercCDF_list = [85];
SystemFC_list = ["ENS", "ecPoint"];
NumEM_list = [51,99];
SystemFCPlot_list = ["r", "b"];
Region_list = [1,2];
RegionName_list = ["Costa", "Sierra"];
RegionPlot_list = ["o-","o--"];
NumBS = 1000;
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN_CT = "Data/Processed/CT_";
DirOUT_AURC = "Data/Figures/AURC_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Plotting the Area Under the ROC Curve (AURC)
disp("Plotting Areas Under the Roc Curve (AURC)")

DirIN = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador/Data/Processed/CT_012/ecPoint/EFFCI01/Perc85/Costa/012";
FileIN_H = strcat(DirIN, "/CT_BS_H.csv");
FileIN_FA = strcat(DirIN, "/CT_BS_FA.csv");
FileIN_M = strcat(DirIN, "/CT_BS_M.csv");
FileIN_CN = strcat(DirIN, "/CT_BS_CN.csv");

H = import_CT_BS(FileIN_H,"H",1000);
FA = import_CT_BS(FileIN_FA,"FA",1000);
M = import_CT_BS(FileIN_M,"M",1000);
CN = import_CT_BS(FileIN_CN,"CN",1000);

HR = H ./ (H + M);
FAR = FA ./ (FA + CN);


% Computing HR and FAR for ecPoint
for indBS = 1 : (BS+1)
    
    temp_HR = [HR(:,indBS); 1];
    temp_FAR = [FAR(:,indBS); 1];
    
    figure
    plot(temp_FAR,temp_HR,"o-")
    hold on
    plot([0,1],[0,1],"-k")
    
    % Computing the AURC
    AURC_temp = 0;
    NumPoints = length(temp_HR);
    for i = 1 : (NumPoints-1)
        j = i + 1;
        b = temp_HR(i);
        B = temp_HR(j);
        h = temp_FAR(j)-temp_FAR(i);
        AURC_temp = AURC_temp + (((B + b) * h) / 2);
    end
    
end



























% 
% for indEFFCI = 1 : length(EFFCI_list)
%     
%     % Selecting the EFFCI to consider
%     EFFCI = EFFCI_list(indEFFCI);
%     disp(" ")
%     disp(strcat(" - Plotting AURC for EFFCI>", num2str(EFFCI)))
%     
%     % Defining the output directory
%     DirOUT_temp = strcat(Git_repo, "/", DirOUT_AURC, num2str(Acc), "h/EFFCI", num2str(EFFCI,'%02d'));
%     if ~exist(DirOUT_temp, "dir")
%         mkdir(DirOUT_temp)
%     end
%     
%     for indPercCDF = 1 : length(Perc_CDF_RainFF_list)
%         
%         % Selecting the percentile that defines the rainfall threshold
%         PercCDF = Perc_CDF_RainFF_list(indPercCDF);
%         disp(strcat("   - PercCDF=", num2str(PercCDF)))
%         
%         % Initiating the figure that will contain the ROC plot and the
%         % variable that will contain the plot legend
%         %fig = figure('visible','off');
%         figure
%         LegendNames = {};
%         
%         for indSystemFC = 1 :length(SystemFC_list)
%             
%             % Selecting the forecasting system to consider
%             SystemFC = SystemFC_list(indSystemFC);
%             SystemFCPlot = SystemFCPlot_list(indSystemFC);
%             disp(SystemFC)
%             
%             
%             for indRegion = 1 : length(Region_list)
%                 
%                 % Selecting the region to consider
%                 Region = Region_list(indRegion);
%                 RegionName = RegionName_list(indRegion);
%                 RegionPlot = RegionPlot_list(indRegion);
%                 disp(Region)
%                 
%                 
%                 % Defining the number of ensemble members (EM) in the
%                 % considered forecasting systems
%                 if strcmp(SystemFC, "ENS")
%                     NumEM = 51;
%                 elseif strcmp(SystemFC, "ecPoint")
%                     NumEM = 99;
%                 end
%                 
%                 % Computing the AURC
%                 NumStepF = length(StepF_S:Disc_StepF:StepF_F);
%                 AURC = zeros(NumStepF,1);
%                 indStepF = 1;
%                 
%                 for StepF = StepF_S : Disc_StepF : StepF_F
%                     disp(StepF)
%                     
%                     % Average plot
%                     NumDays_list = (1:NumDays);
%                     H = zeros(NumEM,1);
%                     FA = zeros(NumEM,1);
%                     M = zeros(NumEM,1);
%                     CN = zeros(NumEM,1);
%                     
%                     for indDays = 1 : NumDays
%                         
%                         Day = NumDays_list(indDays);
%                         
%                         % Reading the contingency table
%                         File_CT = strcat(Git_repo, "/", DirIN_CT, num2str(Acc, "%03.f"), "/", SystemFC, "/EFFCI", num2str(EFFCI,'%02d'), "/Perc", num2str(PercCDF,'%02d') , "/", RegionName, "/", num2str(StepF,'%03d'), "/CT_Day", num2str(Day, "%03.f"), ".csv");
%                         [H_temp,FA_temp,M_temp,CN_temp] = import_CT(File_CT);
%                         H = H + H_temp;
%                         FA = FA + FA_temp;
%                         M = M + M_temp;
%                         CN = CN + CN_temp;
%                         
%                     end
%                         
%                     
%                 
%                 % Plotting the AURC
%                 TypeCurve = strcat(SystemFCPlot,RegionPlot);
%                 plot((StepF_S:Disc_StepF:StepF_F)', AURC, TypeCurve, "LineWidth", 1, 'MarkerFaceColor', SystemFCPlot)
%                 hold on
%                 
%                 % Building legend
%                 legend_temp = strcat(SystemFC, ", ", RegionName);
%                 LegendNames = [LegendNames, {legend_temp}];
%                 
%             end
%             
%             % Adding metadata to the plot
%             plot([StepF_S,StepF_F],[0.5,0.5], "k-")
%             xticks((StepF_S:Disc_StepF:StepF_F)')
%             ylim([0,1])
%             xlim([StepF_S StepF_F])
%             title([strcat("AURC (PercCDF = ", num2str(PercCDF,'%02d'), "th percentile)"), strcat("EFFCI >= ",num2str(EFFCI,'%02d'))],'FontSize',16)
%             xlabel("End 12-h accumulation period (hours)",'FontSize',14)
%             ylabel("AURC",'FontSize',14)
%             %legend(LegendNames, 'Location','southeast','FontSize',12)
%             grid on
%             
% %             % Saving the figures as .eps
% %             FileOUT = strcat(DirOUT_temp, "/AURC_PercCDF_", num2str(PercCDF,'%02d'), ".eps");
% %             saveas(fig, FileOUT, "epsc")
% %             
%         end
%         
%     end
%     
% end