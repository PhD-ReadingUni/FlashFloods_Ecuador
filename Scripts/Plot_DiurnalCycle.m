%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plot_DiurnalCycle.m plots the diurnal cycles for annual means of ENS and
% ecPoint-Rainfall forecasts in Ecuador
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear
clc

% INPUT PARAMETERS
BaseDateS = "2020-01-01";
BaseDateF = "2020-12-31";
BaseTime = 0;
StepF_S = 12;
StepF_F = 60;
Disc_StepF = 6;
Acc = 12;
SystemFC_list = ["ENS", "ecPoint"];
PlotSystemFC_list = ["r", "b"];
Region_list = [1,2];
RegionName_list = ["Costa", "Sierra"];
PlotRegion_list = [".-",".--"];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Raw/EcuadorMasks/Emask_ENS.csv";
DirIN = "Data/Raw/FC_Emask_Rainfall_";
DirOUT = "Data/Figures/DiurnalCycle_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Setting general input parameters
BaseDateS = datenum(BaseDateS, 'yyyy-mm-dd');
BaseDateF = datenum(BaseDateF, 'yyyy-mm-dd');
BaseTimeSTR = num2str(BaseTime, "%02.f");
AccSTR = num2str(Acc, "%03.f");


% Importing Ecuador's mask
FileIN_Emask = strcat(Git_repo, "/", FileIN_Emask);
Emask = import_Emask(FileIN_Emask);


% Computing annual means for different lead times
StepF_list = StepF_S : Disc_StepF : StepF_F;
NumStep = length(StepF_list);

% Initialize the figure
figure 

for indReg = 1 : length(Region_list)
    
    % Selecting the region to consider
    Region = Region_list(indReg);
    RegionName = RegionName_list(indReg);
    PlotRegion = PlotRegion_list(indReg);
    
    disp(strcat("- Computing the annual mean for the '", RegionName, "' region..."))
    pointer_region = find(Emask(:,3)==Region);
    
    for indSystemFC = 1 : length(SystemFC_list)
        
        % Selecting the forecasting system to consider
        SystemFC = SystemFC_list(indSystemFC);
        PlotSystemFC = PlotSystemFC_list(indSystemFC);
        disp(strcat(" - Computing the annual mean for ", SystemFC))
        
        AnnualMean = zeros(NumStep,1);
        
        for indStepF = 1 : NumStep
            
            % Selecting the step to consider
            StepF = StepF_list(indStepF);
            StepFSTR = num2str(StepF, "%03.f");
            disp(strcat("  - Computing the annual mean for step t+", num2str(StepF)))
            
            AnnualSum = 0;
            NumDays = 0;
            for BaseDate = BaseDateS : BaseDateF
                
                BaseDateSTR =datestr(BaseDate, "yyyymmdd");
                
                FileIN = strcat(Git_repo, "/", DirIN, AccSTR, "/", SystemFC, "/", BaseDateSTR, BaseTimeSTR, "/tp_", AccSTR, "_", BaseDateSTR, "_", BaseTimeSTR, "_", StepFSTR, ".mat");
                
                if isfile(FileIN)
                    load(FileIN)
                    AnnualSum = AnnualSum + FC(:,3:end);
                    NumDays = NumDays + 1;
                end
                
            end
            
            % Computing the annual mean
            AnnualMean_all = AnnualSum / NumDays;
            AnnualMean_region = AnnualMean_all(pointer_region,:);
            AnnualMean_region = AnnualMean_region(:);
            AnnualMean(indStepF) = mean(AnnualMean_region);
            
        end
        
        plot(StepF_list, AnnualMean, strcat(PlotSystemFC,PlotRegion), "LineWidth", 2, 'MarkerSize', 14)
        hold on
        
    end
    
end

% Adding metadat to the plot
xticks(StepF_list)
xlim([StepF_S StepF_F])
grid on   

% Saving plot
FileOUT = strcat(Git_repo, "/", DirOUT, AccSTR, "/DiurnalCycle.eps");
saveas(gcf,FileOUT,"epsc")