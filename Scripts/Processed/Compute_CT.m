% Compute_CT.m computes the contingency tables for the flash flood
% verification of ecPoint-Rainfall forecasts in Ecuador

clear 
clc

% INPUT PARAMETERS
BaseDateS = "2020-01-01";
BaseDateF = "2020-12-31";
BaseTimeS = 0;
BaseTimeF = 12;
DiscTime = 12;
StepF_S = 12;
StepF_F = 246;
DiscStep = 6;
Acc = 12;
SystemFC = "ENS";
ThrEFFCI_list = [1,6,10];
PercRT_list = [75,85,90,95,98,99];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileNameIN_Emask = "Data/Processed/EcuadorMasks_ENS/Ecuador_3Regions.csv";
DirIN_RT = "Data/Processed/RainThr";
DirIN_FC = strcat("Data/Processed/",SystemFC);
DirIN_FF = "Data/Processed/ObsFF_";
DirOUT = "Data/Processed/CT_";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: Points that belong to Ecuador's region "Oriente" will not be
% considered in this analysis as there are not many flood reports for that
% region and any analysis might be inconclusive.


% Set generic parameters
dS=datenum(BaseDateS,'yyyy-mm-dd');
dF=datenum(BaseDateF,'yyyy-mm-dd');
AccSTR = num2str(Acc,'%03d');
if strcmp(SystemFC,"ecPoint-Rainfall")
    NumCT = 99;
elseif strcmp(SystemFC,"ENS")
    NumCT = 51;
end


% Import Ecuador's mask
FileIN_Emask = strcat(Git_repo, "/", FileNameIN_Emask);
Emask = import_mask(FileIN_Emask);
pointer_costa = find(Emask(:,3)==1);
pointer_sierra = find(Emask(:,3)==2);
pointer_oriente = find(Emask(:,3)==3);
Emask(pointer_oriente,:) = [];


% Compute the contingency tables 
for indEFFCI = 1 : length(ThrEFFCI_list)
    
    ThrEFFCI = ThrEFFCI_list(indEFFCI);
    ThrEFFCI_STR = num2str(ThrEFFCI,'%02d');
    
    % Import the rainfall thresholds
    FileIN_RainThr = strcat(Git_repo, "/", DirIN_RT, "/RainThr_2019_EFFCI", num2str(ThrEFFCI,'%02d'), "_Costa.csv");
    [Percs_costa,RainThr_costa] = import_RainThr(FileIN_RainThr);
    
    FileIN_RainThr = strcat(Git_repo, "/", DirIN_RT, "/RainThr_2019_EFFCI", num2str(ThrEFFCI,'%02d'), "_Sierra.csv");
    [Percs_sierra,RainThr_sierra] = import_RainThr(FileIN_RainThr);
    
    for indPercRT = 1 : length(PercRT_list)
        
        PercRT = PercRT_list(indPercRT);
        PercSTR = num2str(PercRT,'%02d');
        
        disp(strcat("Considering EFFCI>", num2str(ThrEFFCI), " and RainThr(PercRT=", num2str(PercRT), ")"))
        
        % Select the rainfall threshold correspondent to the considered
        % percentile
        PercRT_costa = RainThr_costa(Percs_costa==PercRT);
        PercRT_sierra = RainThr_sierra(Percs_sierra==PercRT);
        
        % Name of the output directory
        DirOUT_temp = strcat(Git_repo, "/", DirOUT, num2str(Acc), "h/", SystemFC, "/EFFCI", ThrEFFCI_STR, "/Perc", PercSTR);
        mkdir(DirOUT_temp)
        
        for StepF = StepF_S : DiscStep : StepF_F
            
            disp(strcat(" - StepF=", num2str(StepF)))
            StepFSTR =  num2str(StepF,'%03d');
            
            % Create template for the contingency tables
            CT = zeros(NumCT,4);
            CT_costa = CT;
            CT_sierra = CT;
            
            % Compute the contingency tables
            for d = dS : dF
                
                dSTR = datestr(d, 'yyyymmdd');
                
                for t = BaseTimeS : DiscTime : BaseTimeF
                    
                    tSTR = num2str(t,'%02d');
                    
                    FileIN_FC = strcat(Git_repo, "/", DirIN_FC,  "/", dSTR, tSTR, "/tp_", AccSTR, "_", dSTR, "_", tSTR, "_", StepFSTR, ".csv");
                    
                    ValidTime = d + (t/24) + (StepF/24);
                    dVT_STR = datestr(ValidTime, 'yyyymmdd');
                    tVT_STR = datestr(ValidTime, 'HH');
                    FileIN_FF = strcat(Git_repo, "/", DirIN_FF, num2str(Acc), "h/EFFCI", ThrEFFCI_STR, "/ObsFF_", dVT_STR, "_", tVT_STR, ".csv");
                    
                    if isfile(FileIN_FC) && isfile(FileIN_FF)
                        
                        % Read the rainfall forecasts 
                        if strcmp(SystemFC,"ecPoint-Rainfall")
                            FC = import_PR(FileIN_FC);
                        elseif strcmp(SystemFC,"ENS")
                            FC = import_ENS(FileIN_FC);
                        end
                        FC = FC(:,3:end);
                        
                        % Read the flash flood observations
                        FF = import_AccObsFF(FileIN_FF);
                        FF = FF(:,3);
                        
                        
                        %%%%%%%%%% Verification for "All Regions" %%%%%%%%%
                        % Exclude points for Ecuador's region "oriente"
                        FC(pointer_oriente,:) = [];
                        FF(pointer_oriente,:) = [];
                        
                        % Define how many events exceed the rainfall threshold
                        FC_exceed = [FC(pointer_costa,:) >= PercRT_costa; FC(pointer_sierra,:) >= PercRT_sierra];
                        FC_exceed_total = sum(FC_exceed,2);
                        
                        % Define the contingency table
                        for indCT = 1 : NumCT
                            pointer_FC_YES = find(FC_exceed_total>=indCT);
                            pointer_FC_NO = find(FC_exceed_total<indCT);
                            FF_FC_YES = FF(pointer_FC_YES);
                            FF_FC_NO = FF(pointer_FC_NO);
                            CT(indCT,1) = CT(indCT,1) + sum(FF_FC_YES==1); % hits
                            CT(indCT,2) = CT(indCT,2) + sum(FF_FC_YES==0); % false alarms
                            CT(indCT,3) = CT(indCT,3) + sum(FF_FC_NO==1); % misses
                            CT(indCT,4) = CT(indCT,4) + sum(FF_FC_NO==0); % correct negatives
                        end
                        
                        
                        %%%%%%%%%%% Verification for "La Costa" %%%%%%%%%%%
                        FC_costa = FC;
                        FF_costa = FF;
                        FC_costa(pointer_sierra,:) = [];
                        FF_costa(pointer_sierra,:) = [];
                        
                        % Define how many events exceed the rainfall threshold
                        FC_costa_exceed = FC_costa >= PercRT_costa;
                        FC_exceed_total = sum(FC_costa_exceed,2);  

                        % Define the contingency table
                        for indCT = 1 : NumCT
                            pointer_FC_YES = find(FC_exceed_total>=indCT);
                            pointer_FC_NO = find(FC_exceed_total<indCT);
                            FF_FC_YES = FF(pointer_FC_YES);
                            FF_FC_NO = FF(pointer_FC_NO);
                            CT_costa(indCT,1) = CT_costa(indCT,1) + sum(FF_FC_YES==1); % hits
                            CT_costa(indCT,2) = CT_costa(indCT,2) + sum(FF_FC_YES==0); % false alarms
                            CT_costa(indCT,3) = CT_costa(indCT,3) + sum(FF_FC_NO==1); % misses
                            CT_costa(indCT,4) = CT_costa(indCT,4) + sum(FF_FC_NO==0); % correct negatives
                        end
                        
                        
                        %%%%%%%%%%% Verification for "La Sierra" %%%%%%%%%%
                        FC_sierra = FC;
                        FF_sierra = FF;
                        FC_sierra(pointer_costa,:) = [];
                        FF_sierra(pointer_costa,:) = [];
                        
                        % Define how many events exceed the rainfall threshold
                        FC_sierra_exceed = FC_sierra >= PercRT_sierra;
                        FC_exceed_total = sum(FC_sierra_exceed,2);
                        
                        % Define the contingency table
                        for indCT = 1 : NumCT
                            pointer_FC_YES = find(FC_exceed_total>=indCT);
                            pointer_FC_NO = find(FC_exceed_total<indCT);
                            FF_FC_YES = FF(pointer_FC_YES);
                            FF_FC_NO = FF(pointer_FC_NO);
                            CT_sierra(indCT,1) = CT_sierra(indCT,1) + sum(FF_FC_YES==1); % hits
                            CT_sierra(indCT,2) = CT_sierra(indCT,2) + sum(FF_FC_YES==0); % false alarms
                            CT_sierra(indCT,3) = CT_sierra(indCT,3) + sum(FF_FC_NO==1); % misses
                            CT_sierra(indCT,4) = CT_sierra(indCT,4) + sum(FF_FC_NO==0); % correct negatives
                        end
                        
                    end
                    
                end
                
            end
            
            % Saving contingecy table
            CT = array2table(CT,'VariableNames', {'H','FA','M','CN'});
            FileOUT = strcat(DirOUT_temp,"/","CT_All_", StepFSTR, ".csv");
            writetable(CT,FileOUT,'Delimiter',',')
            
            CT_costa = array2table(CT_costa,'VariableNames', {'H','FA','M','CN'});
            FileOUT = strcat(DirOUT_temp,"/","CT_Costa_", StepFSTR, ".csv");
            writetable(CT_costa,FileOUT,'Delimiter',',')
            
            CT_sierra = array2table(CT_sierra,'VariableNames', {'H','FA','M','CN'});
            FileOUT = strcat(DirOUT_temp,"/","CT_Sierra_", StepFSTR, ".csv");
            writetable(CT_sierra,FileOUT,'Delimiter',',')
            
        end
        
        disp(" ")
        
    end
    
end