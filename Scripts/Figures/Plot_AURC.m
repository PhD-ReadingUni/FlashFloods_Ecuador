%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_AURC.m plots the Area Under the Roc Curve (AURC) for all lead times,
% all forecasting systems considered and all Ecuador regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
StepF_S = 18;
StepF_F = 240;
Disc_StepF = 6;
Acc = 12;
EFFCI_list = [6];
Perc_CDF_RainFF_list = [75];
SystemFC_list = ["ENS","ecPoint"];
SystemFCPlot_list = ["r","b"];
Region_list = [1,2];
RegionName_list = ["Costa", "Sierra"];
RegionPlot_list = ["o-","o--"];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN_CT = "Data/Processed/CT_";
DirOUT_AURC = "Data/Figures/AURC_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plotting the Area Under the Roc Curve (AURC)
disp("Plotting Areas Under the Roc Curve (AURC)")

for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI to consider
    EFFCI = EFFCI_list(indEFFCI);
    disp(" ")
    disp(strcat(" - Plotting AURC for EFFCI>", num2str(EFFCI)))
    
    % Defining the output directory
    DirOUT_temp = strcat(Git_repo, "/", DirOUT_AURC, num2str(Acc), "h/EFFCI_", num2str(EFFCI,'%02d'));
    if ~exist(DirOUT_temp, "dir")
        mkdir(DirOUT_temp)
    end
    
    for indPercCDF = 1 : length(Perc_CDF_RainFF_list)
        
        % Selecting the percentile that defines the rainfall threshold
        PercCDF = Perc_CDF_RainFF_list(indPercCDF);
        disp(strcat("   - PercCDF=", num2str(PercCDF)))
        
        % Initiating the figure that will contain the ROC plot and the
        % variable that will contain the plot legend
        %fig = figure('visible','off');
        figure
        LegendNames = {};
        
        for indSystemFC = 1 :length(SystemFC_list)
            
            % Selecting the forecasting system to consider
            SystemFC = SystemFC_list(indSystemFC);
            SystemFCPlot = SystemFCPlot_list(indSystemFC);
            
            for indRegion = 1 : length(Region_list)
                
                % Selecting the region to consider
                Region = Region_list(indRegion);
                RegionName = RegionName_list(indRegion);
                RegionPlot = RegionPlot_list(indRegion);
                
                % Defining the number of ensemble members (EM) in the
                % considered forecasting systems
                if strcmp(SystemFC, "ENS")
                    NumEM = 51;
                elseif strcmp(SystemFC, "ecPoint")
                    NumEM = 99;
                end
                
                % Computing the AURC
                NumStepF = length(StepF_S:Disc_StepF:StepF_F);
                AURC = zeros(NumStepF,1);
                indStepF = 1;
                for StepF = StepF_S : Disc_StepF : StepF_F
                    
                    % Reading the contingency table
                    File_CT = strcat(Git_repo, "/", DirIN_CT, num2str(Acc), "h/", SystemFC, "/EFFCI_", num2str(EFFCI,'%02d'), "/PercCDF_", num2str(PercCDF,'%02d') , "/CT_", RegionName, "_", num2str(StepF,'%03d'), ".csv");
                    [H,FA,M,CN] = import_CT(File_CT);
                    
                    % Computing HR and FAR for ecPoint
                    HR = [1; (H ./ (H + M))];
                    FAR  = [1; (FA ./ (FA + CN))];
                    
                    % Computing the AURC
                    AURC_temp = 0;
                    for i = NumEM : -1 : 2
                        j = i - 1;
                        b = HR(j);
                        B = HR(i);
                        h = FAR(j)-FAR(i);
                        AURC_temp = AURC_temp + ((B + b) * h / 2);
                    end
                    
                    AURC(indStepF,1) = AURC_temp;
                    indStepF = indStepF + 1;
                    
                end
                
                % Plotting the AURC
                TypeCurve = strcat(SystemFCPlot,RegionPlot);
                plot((StepF_S:Disc_StepF:StepF_F)', AURC, TypeCurve, "LineWidth", 1, 'MarkerFaceColor', SystemFCPlot)
                hold on
                
                % Building legend
                legend_temp = strcat(SystemFC, ", ", RegionName);
                LegendNames = [LegendNames, {legend_temp}];
                
            end
            
            % Adding metadata to the plot
            plot([StepF_S,StepF_F],[0.5,0.5], "k-")
            xticks((StepF_S:Disc_StepF:StepF_F)')
            ylim([0.4,1])
            xlim([StepF_S StepF_F])
            title([strcat("AURC (PercCDF = ", num2str(PercCDF,'%02d'), "th percentile)"), strcat("EFFCI >= ",num2str(EFFCI,'%02d'))],'FontSize',16)
            xlabel("End 12-h accumulation period (hours)",'FontSize',14)
            ylabel("AURC",'FontSize',14)
            legend(LegendNames, 'Location','southeast','FontSize',14)
            grid on
            
            % Saving the figures as .eps
            FileOUT = strcat(DirOUT_temp, "/AURC_PercCDF_", num2str(PercCDF,'%02d'), ".eps");
            %saveas(fig, FileOUT, "epsc")
            
        end
        
    end
    
end