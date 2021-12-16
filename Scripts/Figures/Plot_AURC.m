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
EFFCI_list = [1,6,10];
Perc_CDF_RainFF_list = [75,85,90,95,98,99];
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
for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI to consider
    EFFCI = EFFCI_list(indEFFCI);
    
    % Defining the output directory
    DirOUT_temp = strcat(Git_repo, "/", DirOUT_AURC, num2str(Acc), "h/EFFCI", num2str(ThrEFFCI,'%02d'));
    mkdir(DirOUT_temp)
    
    for indPercRT = 1 : length(Perc_CDF_RainFF_list)
        
        % Selecting the percentile that defines the rainfall threshold
        PercRT = Perc_CDF_RainFF_list(indPercRT);
        PercRT_STR = num2str(PercRT,'%02d');
        disp(strcat("Plotting AURC for EFFCI>", num2str(ThrEFFCI), " and RainThr(PercRT=", num2str(PercRT), ")"))
                
        % Importing the rainfall thresholds
        FileIN_RT_Costa = strcat(Git_repo, "/", DirIN_RT, "/RainThr_2019_EFFCI", num2str(ThrEFFCI,'%02d'), "_Costa.csv");
        [Ps_Costa,RTs_Costa] = import_RainThr(FileIN_RT_Costa);
        RT_Costa = RTs_Costa(Ps_Costa==PercRT);
        
        FileIN_RT_Sierra = strcat(Git_repo, "/", DirIN_RT, "/RainThr_2019_EFFCI", num2str(ThrEFFCI,'%02d'), "_Sierra.csv");
        [Ps_Sierra,RTs_Sierra] = import_RainThr(FileIN_RT_Sierra);
        RT_Sierra = RTs_Sierra(Ps_Sierra==PercRT);
        
        
        % Creating the variable that will store the AURC
        NumStepF = length(StepF_S:Disc_StepF:StepF_F);
        AURC_ENS = zeros(NumStepF,2);
        AURC_PR = zeros(NumStepF,2);
        
        
        % Computing the AURC
        indStepF = 1;
        for StepF = StepF_S : Disc_StepF : StepF_F
            
            StepFSTR =  num2str(StepF,'%03d');
            
            % Read contingency tables for ecPoint
            File_PR_Costa = strcat(Git_repo, "/", DirIN_CT, num2str(Acc), "h/ecPoint//EFFCI", ThrEFFCI_STR, "/Perc", PercRT_STR, "/CT_Costa_", StepFSTR, ".csv");
            [H_PR_Costa,FA_PR_Costa,M_PR_Costa,CN_PR_Costa] = import_CT(File_PR_Costa);
            
            File_PR_Sierra = strcat(Git_repo, "/", DirIN_CT, num2str(Acc), "h/ecPoint/EFFCI", ThrEFFCI_STR, "/Perc", PercRT_STR, "/CT_Sierra_", StepFSTR, ".csv");
            [H_PR_Sierra,FA_PR_Sierra,M_PR_Sierra,CN_PR_Sierra] = import_CT(File_PR_Sierra);
            
            % Read contingency tables for ENS
            File_ENS_Costa = strcat(Git_repo, "/", DirIN_CT, num2str(Acc), "h/ENS/EFFCI", ThrEFFCI_STR, "/Perc", PercRT_STR, "/CT_Costa_", StepFSTR, ".csv");
            [H_ENS_Costa,FA_ENS_Costa,M_ENS_Costa,CN_ENS_Costa] = import_CT(File_ENS_Costa);
            
            File_ENS_Sierra = strcat(Git_repo, "/", DirIN_CT, num2str(Acc), "h/ENS/EFFCI", ThrEFFCI_STR, "/Perc", PercRT_STR, "/CT_Sierra_", StepFSTR, ".csv");
            [H_ENS_Sierra,FA_ENS_Sierra,M_ENS_Sierra,CN_ENS_Sierra] = import_CT(File_ENS_Sierra);
            
            
            % Compute HR and FAR for ecPoint
            HR_PR_Costa = H_PR_Costa ./ (H_PR_Costa + M_PR_Costa);
            FAR_PR_Costa  = FA_PR_Costa ./ (FA_PR_Costa + CN_PR_Costa);
            HR_PR_Costa = [1; HR_PR_Costa];
            FAR_PR_Costa = [1; FAR_PR_Costa];
            
            HR_PR_Sierra = H_PR_Sierra ./ (H_PR_Sierra + M_PR_Sierra);
            FAR_PR_Sierra  = FA_PR_Sierra ./ (FA_PR_Sierra + CN_PR_Sierra);
            HR_PR_Sierra = [1; HR_PR_Sierra];
            FAR_PR_Sierra = [1; FAR_PR_Sierra];
            
            % Compute HR and FAR for ENS
            HR_ENS_Costa = H_ENS_Costa ./ (H_ENS_Costa + M_ENS_Costa);
            FAR_ENS_Costa  = FA_ENS_Costa ./ (FA_ENS_Costa + CN_ENS_Costa);
            HR_ENS_Costa = [1; HR_ENS_Costa];
            FAR_ENS_Costa = [1; FAR_ENS_Costa];
            
            HR_ENS_Sierra = H_ENS_Sierra ./ (H_ENS_Sierra + M_ENS_Sierra);
            FAR_ENS_Sierra  = FA_ENS_Sierra ./ (FA_ENS_Sierra + CN_ENS_Sierra);
            HR_ENS_Sierra = [1; HR_ENS_Sierra];
            FAR_ENS_Sierra = [1; FAR_ENS_Sierra];
            
            
            % Compute the AURC
            AURC_ENS_Costa = 0;
            AURC_ENS_Sierra = 0;
            NumENS = 51;
            for i = NumENS : -1 : 2
                
                j = i - 1;
                
                b_Costa = HR_ENS_Costa(j);
                B_Costa = HR_ENS_Costa(i);
                h_Costa = FAR_ENS_Costa(j)-FAR_ENS_Costa(i);
                AURC_ENS_Costa = AURC_ENS_Costa + ((B_Costa + b_Costa) * h_Costa / 2);
                
                b_Sierra = HR_ENS_Sierra(j);
                B_Sierra = HR_ENS_Sierra(i);
                h_Sierra = FAR_ENS_Sierra(j)-FAR_ENS_Sierra(i);
                AURC_ENS_Sierra = AURC_ENS_Sierra + ((B_Sierra + b_Sierra) * h_Sierra / 2);
                
            end
            AURC_ENS(indStepF,1) = AURC_ENS_Costa;
            AURC_ENS(indStepF,2) = AURC_ENS_Sierra;
            
            AURC_PR_Costa = 0;
            AURC_PR_Sierra = 0;
            NumPR = 99;
            for i = NumPR : -1 : 2
                
                j = i - 1;
                
                b_Costa = HR_PR_Costa(j);
                B_Costa = HR_PR_Costa(i);
                h_Costa = FAR_PR_Costa(j)-FAR_PR_Costa(i);
                AURC_PR_Costa = AURC_PR_Costa + ((B_Costa + b_Costa) * h_Costa / 2);
                
                b_Sierra = HR_PR_Sierra(j);
                B_Sierra = HR_PR_Sierra(i);
                h_Sierra = FAR_PR_Sierra(j)-FAR_PR_Sierra(i);
                AURC_PR_Sierra = AURC_PR_Sierra + ((B_Sierra + b_Sierra) * h_Sierra / 2);
                
            end
            AURC_PR(indStepF,1) = AURC_PR_Costa;
            AURC_PR(indStepF,2) = AURC_PR_Sierra;
            
            indStepF = indStepF + 1;
            
        end
        
        
        % Plotting the AURC for ecPoint and ENS
        fig = figure('visible','off');
        
        plot((StepF_S:Disc_StepF:StepF_F)', AURC_ENS(:,1), "ro-", "LineWidth", 2, 'MarkerFaceColor','r')
        hold on
        plot((StepF_S:Disc_StepF:StepF_F)', AURC_PR(:,1), "bo-", "LineWidth", 2, 'MarkerFaceColor','b')
        hold on
        plot((StepF_S:Disc_StepF:StepF_F)', AURC_ENS(:,2), "ro--", "LineWidth", 2, 'MarkerFaceColor','r')
        hold on
        plot((StepF_S:Disc_StepF:StepF_F)', AURC_PR(:,2), "bo--", "LineWidth", 2, 'MarkerFaceColor','b')
        hold on
        plot([12,72],[0.5,0.5], "k-")
        
        title([strcat("AURC (PercRT = ", PercRT_STR, "th percentile)"), strcat("EFFCI >= ",ThrEFFCI_STR)],'FontSize',16)
        xlabel("End 12-h accumulation period (hours)",'FontSize',14)
        ylabel("AURC",'FontSize',14)
        legend(strcat("ENS, RT(Costa) >= ",num2str(round(RT_Costa,1)), " mm/", num2str(Acc), "h)"),strcat("ecPoint, RT(Costa) >= ",num2str(round(RT_Costa,1)), " mm/", num2str(Acc), "h)"),strcat("ENS, RT(Sierra) >= ",num2str(round(RT_Sierra,1)), " mm/", num2str(Acc), "h)"),strcat("ecPoint, RT(Sierra) >= ",num2str(round(RT_Sierra,1)), " mm/", num2str(Acc), "h)"), 'Location','southeast','FontSize',11)
        legend('boxoff')
        xticks((StepF_S:Disc_StepF:StepF_F)')
        ylim([0.3,1])
        xlim([StepF_S StepF_F])
        
        % Save the figures as .eps
        FileOUT = strcat(DirOUT_temp, "/AURC_PercRT", PercRT_STR, ".eps");
        saveas(fig, FileOUT, "epsc")
        
    end
    
    disp(" ")    
    
end