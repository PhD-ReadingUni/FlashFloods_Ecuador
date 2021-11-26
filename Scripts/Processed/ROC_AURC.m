% ROC_AURC.m plots the ROC curve for a given lead time and the area under
% the roc curve (AURC) for all lead times.

% INPUT PARAMETERS
StepF_S = 12;
StepF_F = 246;
Disc_StepF = 12;
Acc = 12;
ThrEFFCI = 6;
RainThr_Perc = 95;
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN = "Data/Processed/CT_";
Sub_DirIN = "Annual2020";
DirOUT_AURC = "Data/Figures/AURC/Annual2020";
DirOUT_ROC = "Data/Figures/ROC/Annual2020";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


ThrEFFCI_STR = num2str(ThrEFFCI,'%02d');
AURC = [];

for StepF = StepF_S : Disc_StepF : StepF_F
    
    StepFSTR =  num2str(StepF,'%03d');
    FileName = strcat(Git_repo, "/", DirIN, num2str(Acc), "h/", Sub_DirIN, "/EFFCI", ThrEFFCI_STR, "/Perc", num2str(RainThr_Perc), "/CT_", StepFSTR, ".csv");
    [H,FA,M,CN] = import_CT(FileName);
    
    % Compute FAR and HR
    HR = H ./ (H+M);
    FAR  = FA ./ (FA+CN);
    HR = [HR; 1];
    FAR = [FAR; 1];
    
    % Compute AURC
    AURC_temp = 0;
    for i = 1 : (length(HR)-1)
        j = i + 1;
        b = HR(i);
        B = HR(j);
        h = FAR(j)-FAR(i);
        AURC_temp = AURC_temp + ((B+b)*h/2);
    end
    AURC = [AURC; AURC_temp];
        
    % Plot the ROC curve
    figure 
    plot(FAR,HR, "bo-", "LineWidth", 2)
    hold on
    plot([0,1], [0,1], "k-")
    title(strcat("ecPoint-Rainfall ROC (StepF=",num2str(StepF), ")"))
    xlabel("False Alarm Rate")
    ylabel("Hit Rate")
    
end

figure
plot((StepF_S:Disc_StepF:StepF_F)', AURC, "ro-", "LineWidth", 2)
hold on
plot([0,250],[0.6,0.6], "k-")
xticks((StepF_S:Disc_StepF:StepF_F)')
title(strcat("Area Under the Roc Curve - Perc=", num2str(RainThr_Perc), " - EFFCI>=", num2str(ThrEFFCI)))
xlabel("Step at the end of the accumulation period")
ylabel("AURC [-]")
ylim([0.5,1])