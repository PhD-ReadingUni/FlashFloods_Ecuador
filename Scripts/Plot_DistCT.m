%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_DistCT.m plots the distribution of the elements of the contingency
% table (H/FA/M/CN) for each step
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
clear
clc

% INPUT PARAMETERS
StepF_S = 12;
StepF_F = 246;
Disc_StepF = 6;
Acc = 12;
EFFCI_list = [6];
PercCDF_list = [85,99];
SystemFC_list = ["ENS", "ecPoint"];
Region_list = [1,2];
RegionName_list = ["Costa", "Sierra"];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN = "Data/Processed/HR_FAR_";
DirOUT = "Data/Figures/DistCT_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Plotting the Area Under the ROC Curve (AURC)
disp("Plotting Areas Under the Roc Curve (AURC)")

% Setting some general parameters
StepF_list = (StepF_S : Disc_StepF : StepF_F);
AccSTR = num2str(Acc,"%03.f");

XTickLabels = {};
for i = 1 : length(StepF_list)
    if mod(i,2) ~= 0
        XTickLabels = [XTickLabels, num2str(StepF_list(i))];
    else
        XTickLabels = [XTickLabels, " "];
    end
end


% Plotting the AURC
for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI threshold to consider
    EFFCI = EFFCI_list(indEFFCI);
    disp(" ")
    disp(strcat(" - Considering the flood reports with EFFCI>=",num2str(EFFCI)))
    
    % Creating output directory
    DirOUT_temp = strcat(Git_repo, "/", DirOUT, AccSTR, "/EFFCI", num2str(EFFCI,'%02.f'));
    if ~exist(DirOUT_temp, "dir")
        mkdir(DirOUT_temp)
    end
    
    for indPercCDF = 1 : length(PercCDF_list)
        
        % Selecting the rainfall event to verify
        PercCDF = PercCDF_list(indPercCDF);
        disp(strcat("  - Considering rainfall events >= (PercCDF=", num2str(PercCDF), "th percentile)"))

        for indRegion = 1 : length(Region_list)
            
            % Selecting the region to consider
            Region = Region_list(indRegion);
            RegionName = RegionName_list(indRegion);
            disp(strcat("    - Considering the '", RegionName, "' region"))
            
            H_MostExtr = [];
            FA_MostExtr = [];
            M_MostExtr = [];
            CN_MostExtr = [];
            
            for indSystemFC = 1 : length(SystemFC_list)
                
                % Selecting the forecasting system to consider
                SystemFC = SystemFC_list(indSystemFC);
                
                % Reading the HRs and FARs
                FileIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/", SystemFC, "/EFFCI", num2str(EFFCI,"%02.f"), "/Perc", num2str(PercCDF,"%02.f"), "/HR_FAR_CI_", RegionName, ".mat");
                load(FileIN_temp)
                
                % Compute the average of H/FA/M/CN for all probabilities
                H_MostExtr = [H_MostExtr, H_AllSteps(end,:)'];
                FA_MostExtr = [FA_MostExtr, FA_AllSteps(end,:)'];
                M_MostExtr = [M_MostExtr, M_AllSteps(end,:)'];
                CN_MostExtr = [CN_MostExtr, CN_AllSteps(end,:)'];
                
            end
            
            % Plotting and saving the distributions for H/FA/M/CN
            figure('position', [100,100,1100,500])
            hb = bar(StepF_list, H_MostExtr);
            hb(1).FaceColor = 'r';
            hb(2).FaceColor = 'b';
            xlim([StepF_S-6,StepF_F+6])
            xticks(StepF_list)
            xticklabels(XTickLabels)
            ylim([0 100])
            grid on
            ax=gca;
            ax.GridAlpha=0.5;
            ax.FontSize = 20;
            FileOUT = strcat(DirOUT_temp, "/H_", num2str(PercCDF,"%02.f"), "_", RegionName, ".tiff");
            print(gcf,"-dtiff", "-r500",FileOUT)
            
            figure('position', [100,100,1100,500])
            hb = bar(StepF_list, FA_MostExtr);
            hb(1).FaceColor = 'r';
            hb(2).FaceColor = 'b';
            xlim([StepF_S-6,StepF_F+6])
            xticks(StepF_list)
            xticklabels(XTickLabels)
            ylim([0 5*100000])
            grid on
            ax=gca;
            ax.GridAlpha=0.5;
            ax.FontSize = 20;
            FileOUT = strcat(DirOUT_temp, "/FA_", num2str(PercCDF,"%02.f"), "_", RegionName, ".tiff");
            print(gcf,"-dtiff", "-r500",FileOUT)
            
            figure('position', [100,100,1100,500])
            hb = bar(StepF_list, M_MostExtr);
            hb(1).FaceColor = 'r';
            hb(2).FaceColor = 'b';
            xlim([StepF_S-6,StepF_F+6])
            xticks(StepF_list)
            xticklabels(XTickLabels)
            ylim([0 60])
            grid on
            ax=gca;
            ax.GridAlpha=0.5;
            ax.FontSize = 20;
            FileOUT = strcat(DirOUT_temp, "/M_", num2str(PercCDF,"%02.f"), "_", RegionName, ".tiff");
            print(gcf,"-dtiff", "-r500",FileOUT)
            
            figure('position', [100,100,1100,500])
            hb = bar(StepF_list, CN_MostExtr);
            hb(1).FaceColor = 'r';
            hb(2).FaceColor = 'b';
            xlim([StepF_S-6,StepF_F+6])
            xticks(StepF_list)
            xticklabels(XTickLabels)
            ylim([0 3*100000])
            grid on
            ax=gca;
            ax.GridAlpha=0.5;
            ax.FontSize = 20;
            FileOUT = strcat(DirOUT_temp, "/CN_", num2str(PercCDF,"%02.f"), "_", RegionName, ".tiff");
            print(gcf,"-dtiff", "-r500",FileOUT)
            
        end
        
    end
    
end