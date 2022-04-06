%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_ROC.m plots the ROC curves for all lead times, all forecasting 
% systems, and all regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
StepF_S = 72;
StepF_F = 72;
Disc_StepF = 6;
Acc = 12;
EFFCI_list = [6];
PercCDF_list = [85,99];
SystemFC_list = ["ENS", "ecPoint"];
PlotSystemFC_list = ["r", "b"];
Region_list = [1,2];
RegionName_list = ["Costa", "Sierra"];
PlotRegion_list = ["-o","--o"];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN = "Data/Processed/HR_FAR_";
DirOUT = "Data/Figures/ROC_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Plotting the Area Under the ROC Curve (AURC)
disp("Plotting the ROC curves")

% Setting some general parameters
AccSTR = num2str(Acc,"%03.f");


% Plotting the ROC curves
for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI threshold to consider
    EFFCI = EFFCI_list(indEFFCI);
    disp(" ")
    disp(strcat(" - Considering the flood reports with EFFCI>=",num2str(EFFCI)))
    
    for indPercCDF = 1 : length(PercCDF_list)
        
        % Selecting the rainfall event to verify
        PercCDF = PercCDF_list(indPercCDF);
        disp(strcat("  - Considering rainfall events >= (PercCDF=", num2str(PercCDF), "th percentile)"))
        
        % Creating output directory
        DirOUT_temp = strcat(Git_repo, "/", DirOUT, AccSTR, "/EFFCI", num2str(EFFCI,'%02.f'), "/Perc", num2str(PercCDF,"%02.f"));
        if ~exist(DirOUT_temp, "dir")
            mkdir(DirOUT_temp)
        end
        
        % Selecting the StepF to plot
        indStepF = 1;
        
        for StepF = StepF_S : Disc_StepF : StepF_F
            
            figure('visible','off')
        
            for indRegion = 1 : length(Region_list)
                
                % Selecting the region to consider
                Region = Region_list(indRegion);
                RegionName = RegionName_list(indRegion);
                PlotRegion = PlotRegion_list(indRegion);
                
                for indSystemFC = 1 : length(SystemFC_list)
                    
                    % Selecting the forecasting system to consider
                    SystemFC = SystemFC_list(indSystemFC);
                    PlotSystemFC = PlotSystemFC_list(indSystemFC);
                    
                    % Reading the HRs and FARs
                    FileIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/", SystemFC, "/EFFCI", num2str(EFFCI,"%02.f"), "/Perc", num2str(PercCDF,"%02.f"), "/HR_FAR_CI_", RegionName, ".mat");
                    load(FileIN_temp)
                    
                    HR = [HR_AllSteps(:,indStepF); 1];
                    FAR = [FAR_AllSteps(:,indStepF); 1];
                    
                    % Plotting the ROC curves
                    hold on
                    plot(FAR, HR, strcat(PlotSystemFC,PlotRegion), "LineWidth", 1.5, 'MarkerFaceColor', PlotSystemFC, "MarkerSize", 4)
                    
                end
                
                hold on
                plot([0,1], [0,1], "k-", "LineWidth", 1)
                
                xlim([0 1])
                ylim([0,1])
                set(gca,'FontSize',15);
                grid on
                
                % Saving the AURC
                FileOUT = strcat(DirOUT_temp, "/ROC_", num2str(StepF,'%03.f'), ".tiff");
                print(gcf,"-dtiff", "-r500",FileOUT)
            
            end
            
            indStepF = indStepF + 1;
            
        end
        
    end
    
end