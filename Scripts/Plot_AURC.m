%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_AURC.m plots the Area Under the Roc Curve (AURC) for all lead times,
% all forecasting systems, and all regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
StepF_S = 12;
StepF_F = 246;
Disc_StepF = 6;
Acc = 12;
EFFCI_list = [1,6,10];
PercCDF_list = [85,90,95,98,99];
SystemFC_list = ["ENS", "ecPoint"];
PlotSystemFC_list = ["r", "b"];
Region_list = [1,2];
RegionName_list = ["Costa", "Sierra"];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN = "Data/Processed/HR_FAR_";
DirOUT = "Data/Figures/AURC_";
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
            
            figure('visible','off')
            
            for indSystemFC = 1 : length(SystemFC_list)
                
                % Selecting the forecasting system to consider
                SystemFC = SystemFC_list(indSystemFC);
                PlotSystemFC = PlotSystemFC_list(indSystemFC);
                
                % Reading the HRs and FARs
                FileIN_temp = strcat(Git_repo, "/", DirIN, AccSTR, "/", SystemFC, "/EFFCI", num2str(EFFCI,"%02.f"), "/Perc", num2str(PercCDF,"%02.f"), "/HR_FAR_CI_", RegionName, ".mat");
                load(FileIN_temp)
                [m,n] = size(HR_AllSteps);
                
                % Computing the AURC
                AURC = zeros(1,n);
                AURC_low = zeros(1,n);
                AURC_up = zeros(1,n);
                
                for p = 1 : n
                    
                    HR = [HR_AllSteps(:,p); 1];
                    FAR = [FAR_AllSteps(:,p); 1];
                    
                    HR_low = [HR_lowCI_AllSteps(:,p); 1];
                    HR_up = [HR_upCI_AllSteps(:,p); 1];
                    FAR_low = [FAR_lowCI_AllSteps(:,p); 1];
                    FAR_up = [FAR_upCI_AllSteps(:,p); 1];
                    
                    for i = 1 : m
                        
                        j = i + 1;
                        
                        b = HR(i);
                        B = HR(j);
                        h = FAR(j)-FAR(i);
                        AURC(1,p) = AURC(1,p) + ((b+B)*h/2);
                        
                        b = HR_low(i);
                        B = HR_low(j);
                        h = FAR_low(j)-FAR_low(i);
                        AURC_low(1,p) = AURC_low(1,p) + ((b+B)*h/2);
                        
                        b = HR_up(i);
                        B = HR_up(j);
                        h = FAR_up(j)-FAR_up(i);
                        AURC_up(1,p) = AURC_up(1,p) + ((b+B)*h/2);
        
                    end
    
                end
                                
                % Plotting the AURC
                hold on
                StepF2_list = [StepF_list,fliplr(StepF_list)];
                inBetween = [AURC_low, fliplr(AURC_up)];
                hold on
                fill(StepF2_list, inBetween, PlotSystemFC, "FaceAlpha", 0.1, 'LineStyle','none')
                
                hold on
                plot(StepF_list, AURC, strcat(PlotSystemFC,"x-"), "LineWidth", 0.5, 'MarkerFaceColor', PlotSystemFC, "Linewidth", 1)
                
            end
            
            hold on
            plot([StepF_S,StepF_F], [0.5,0.5], "k-", "Linewidth", 2)
            
            xlim([StepF_S,StepF_F])
            xticks(StepF_list)
            xticklabels(XTickLabels)
            ylim([0.4,1])
            
            ax = gca;
            ax.FontSize = 15;
            ax.GridAlpha = 0.5;
            grid on
            
            % Saving the AURC
            FileOUT = strcat(DirOUT_temp, "/AURC_Perc", num2str(PercCDF,"%02.f"), "_", RegionName, ".tiff");
            print(gcf,"-dtiff", "-r500",FileOUT)
            
        end
        
    end
    
end