%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_ROC.m plots ROC curves for a given lead time, for all forecasting
% systems considered and all Ecuador regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
StepF_S = 18;
StepF_F = 240;
Disc_StepF = 6;
Acc = 12;
EFFCI_list = [1,6,10];
Perc_CDF_RainFF_list = [75,85,90,95,98,99];
SystemFC_list = ["ENS","ecPoint"];
SystemFCPlot_list = ["r","b"];
Region_list = [1,2];
RegionName_list = ["Costa", "Sierra"];
RegionPlot_list = ["o-","o--"];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN_CDF = "Data/Processed/CDF_RainFF_";
DirIN_CT = "Data/Processed/CT_";
DirOUT_ROC = "Data/Figures/ROC_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Plotting the ROC curves
for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI rainfall threshold
    EFFCI = EFFCI_list(indEFFCI);
    
    for indPercCDF = 1 : length(Perc_CDF_RainFF_list)
        
        % Selecting the percentile that defines the rainfall threshold
        PercCDF = Perc_CDF_RainFF_list(indPercCDF);
        disp(strcat("Plotting ROC for EFFCI>", num2str(EFFCI), " and rainfall event greater than (PercCDF=", num2str(PercCDF), ")"))
        
        % Defining the output directory
        DirOUT_temp = strcat(Git_repo, "/", DirOUT_ROC, num2str(Acc), "h/EFFCI", num2str(EFFCI,'%02.f'), "/Perc", num2str(PercCDF,'%02.f'));
        if ~exist(DirOUT_temp)
            mkdir(DirOUT_temp)
        end
        
        for StepF = StepF_S : Disc_StepF : StepF_F
            
            % Selecting the StepF to consider
            StepFSTR =  num2str(StepF,'%03d');
            disp(strcat(" - StepF=",StepFSTR))
            
            % Initiating the figure that will contain the ROC plot and the
            % variable that will contain the plot legend 
            fig = figure('visible','off');
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
            
                    % Reading contingency table
                    File_FC = strcat(Git_repo, "/", DirIN_CT, num2str(Acc), "h/", SystemFC, "/EFFCI", num2str(EFFCI,'%02.f'), "/Perc", num2str(PercCDF,'%02.f'), "/CT_", RegionName, "_", num2str(StepF,'%03.f'), ".csv");
                    [H,FA,M,CN] = import_CT(File_FC);
                    
                    % Compute HR and FAR for ecPoint
                    HR = [1; (H ./ (H + M))];
                    FAR  = [1; (FA ./ (FA + CN))];
                    
                    % Plotting the ROC
                    TypeCurve = strcat(SystemFCPlot,RegionPlot);
                    plot(FAR,HR, TypeCurve, "LineWidth", 1, 'MarkerFaceColor', SystemFCPlot)
                    hold on
                    
                    % Building legend
                    legend_temp = strcat(SystemFC, ", ", RegionName);
                    LegendNames = [LegendNames, {legend_temp}];
                    
                end
                
            end
            
            % Addign metadata to the plot
            plot([0 1], [0,1], "k-")
            title([strcat("ROC (PercCDF = ", num2str(PercCDF), "th percentile)"), strcat("EFFCI >= ",num2str(EFFCI), " - StepF = ", num2str(StepF), "h")],'FontSize',16)
            xlabel("False Alarm Rate",'FontSize',14)
            ylabel("Hit Rate",'FontSize',14)
            legend(LegendNames, 'Location', 'southeast','FontSize',14)
            
            % Save the figures as .eps
            FileOUT = strcat(DirOUT_temp, "/ROC_", StepFSTR, ".eps");
            saveas(fig, FileOUT, 'epsc')
            
        end
        
    end
end