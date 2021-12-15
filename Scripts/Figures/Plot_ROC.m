% Plot_ROC.m plots the ROC curve for a given lead time

clear
clc
close all

% INPUT PARAMETERS
StepF_S = 12;
StepF_F = 72;
Disc_StepF = 6;
Acc = 12;
ThrEFFCI_list = [1,6,10];
PercRT_list = [75,85,90,95,98,99];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN_RT = "Data/Processed/RainThr";
DirIN_CT = "Data/Processed/CT_";
DirOUT_ROC = "Data/Figures/ROC_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Plotting the ROC curves
for indEFFCI = 1 : length(ThrEFFCI_list)
    
    % Selecting the EFFCI rainfall threshold
    ThrEFFCI = ThrEFFCI_list(indEFFCI);
    ThrEFFCI_STR = num2str(ThrEFFCI,'%02d');
    
    for indPercRT = 1 : length(PercRT_list)
        
        % Selecting the percentile that defines the rainfall threshold
        PercRT = PercRT_list(indPercRT);
        PercRT_STR = num2str(PercRT,'%02d');
        disp(strcat("Plotting ROC for EFFCI>", num2str(ThrEFFCI), " and RainThr(PercRT=", num2str(PercRT), ")"))
        
        
        % Importing the rainfall thresholds
        FileIN_RT_Costa = strcat(Git_repo, "/", DirIN_RT, "/RainThr_2019_EFFCI", num2str(ThrEFFCI,'%02d'), "_Costa.csv");
        [Ps_Costa,RTs_Costa] = import_RainThr(FileIN_RT_Costa);
        RT_Costa = RTs_Costa(Ps_Costa==PercRT);
        
        FileIN_RT_Sierra = strcat(Git_repo, "/", DirIN_RT, "/RainThr_2019_EFFCI", num2str(ThrEFFCI,'%02d'), "_Sierra.csv");
        [Ps_Sierra,RTs_Sierra] = import_RainThr(FileIN_RT_Sierra);
        RT_Sierra = RTs_Sierra(Ps_Sierra==PercRT);
        
        
        % Defining the output directory
        DirOUT_temp = strcat(Git_repo, "/", DirOUT_ROC, num2str(Acc), "h/EFFCI", ThrEFFCI_STR, "/Perc", PercRT_STR);
        mkdir(DirOUT_temp)
        
        for StepF = StepF_S : Disc_StepF : StepF_F
            
            StepFSTR =  num2str(StepF,'%03d');
            disp(strcat(" - StepF=",StepFSTR))
            
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
            
            
            % Plot the ROC curves for ecPoint and ENS
            fig = figure('visible','off');
            
            plot(FAR_ENS_Costa,HR_ENS_Costa, "ro-", "LineWidth", 2, 'MarkerFaceColor','r')
            hold on
            plot(FAR_PR_Costa,HR_PR_Costa, "bo-", "LineWidth", 2, 'MarkerFaceColor','b')
            hold on
            plot(FAR_ENS_Sierra,HR_ENS_Sierra, "ro--", "LineWidth", 2, 'MarkerFaceColor','r')
            hold on
            plot(FAR_PR_Sierra,HR_PR_Sierra, "bo--", "LineWidth", 2, 'MarkerFaceColor','b')
            hold on
            plot([0,1], [0,1], "k-")
            
            title([strcat("ROC (PercRT = ", PercRT_STR, "th percentile)"), strcat("EFFCI >= ",ThrEFFCI_STR, " - StepF = ", num2str(StepF), "h")],'FontSize',16)
            xlabel("False Alarm Rate",'FontSize',14)
            ylabel("Hit Rate",'FontSize',14)
            legend(strcat("ENS, RT(Costa) >= ",num2str(round(RT_Costa,1)), " mm/", num2str(Acc), "h)"),strcat("ecPoint, RT(Costa) >= ",num2str(round(RT_Costa,1)), " mm/", num2str(Acc), "h)"),strcat("ENS, RT(Sierra) >= ",num2str(round(RT_Sierra,1)), " mm/", num2str(Acc), "h)"),strcat("ecPoint, RT(Sierra) >= ",num2str(round(RT_Sierra,1)), " mm/", num2str(Acc), "h)"), 'Location','southeast','FontSize',11)
            legend('boxoff')
            
            
            % Save the figures as .eps
            FileOUT = strcat(DirOUT_temp, "/ROC_", StepFSTR, ".eps");
            saveas(fig, FileOUT, 'epsc')
            
        end
        
    end
end