%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute_HR_FAR_CI.m computes HRs and FARs for flood verification using 
% forecast runs from 00 and 12 UTC. 
% NOTE: This script is hard-coded to use forecasts for the 00 and 12 UTC
% runs.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear 
clc

% INPUT PARAMETERS
Year = 2020;
StepF_S = 12;
StepF_F = 246;
DiscStep = 6;
Acc = 12;

EFFCI_list = [1,6,10];

PercCDF_list = [85,90,95,98,99];
PercRetentionFR = 25;

SystemFC_list = ["ENS","ecPoint"];
NumEM_list = [51,99];

Region_list = [1,2];
RegionName_list = ["Costa","Sierra"];

NumBS = 1000;
PercCI = 95;

Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Raw/EcuadorMasks/Emask_ENS.csv";
DirIN_FC = "Data/Raw/FC_Emask_Rainfall_";
DirIN_FR = "Data/Raw/GridAccFR_";
DirIN_CDF = "Data/Processed/RainCDF_";
DirOUT = "Data/Processed/HR_FAR_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% NOTE: Points that belong to Ecuador's region "Oriente" will not be
% considered in this analysis as there are not many flood reports for that
% region and any analysis might be robust.
disp("Computing the contingency tables for flood verification")

% Importing Ecuador's mask
FileIN_Emask = strcat(Git_repo, "/", FileIN_Emask);
Emask = import_Emask(FileIN_Emask);

% Defining verification period
BaseDateS = strcat(num2str(Year), "-01-01");
BaseDateF = strcat(num2str(Year), "-12-31");
dS=datenum(BaseDateS,'yyyy-mm-dd');
dF=datenum(BaseDateF,'yyyy-mm-dd');

% Creating strings from numbers
AccSTR = num2str(Acc, strcat('%03.f'));


% Computing the contingency tables 
for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI threshold to consider
    EFFCI = EFFCI_list(indEFFCI);
    disp(" ")
    disp(strcat(" - Considering the flood reports with EFFCI>=",num2str(EFFCI)))
    
    for indPercCDF = 1 : length(PercCDF_list)
        
        % Selecting the rainfall event to verify
        PercCDF = PercCDF_list(indPercCDF);
        disp(" ")
        disp(strcat("  - Considering rainfall events >= (PercCDF=", num2str(PercCDF), "th percentile)"))

        for indSystemFC = 1 : length(SystemFC_list)
    
            % Selecting the forecasting system to consider
            SystemFC = SystemFC_list(indSystemFC);
            NumEM = NumEM_list(indSystemFC);
            
            % Creating output directory
            DirOUT_temp = strcat(Git_repo, "/", DirOUT, AccSTR, "/", SystemFC, "/EFFCI", num2str(EFFCI,'%02.f'), "/Perc", num2str(PercCDF,'%02.f'));
            if ~exist(DirOUT_temp, "dir")
                mkdir(DirOUT_temp)
            end
                
            for indRegion = 1 : length(Region_list)
        
                % Selecting the region to consider
                Region = Region_list(indRegion);
                RegionName = RegionName_list(indRegion);
                disp(strcat("    - Considering the '", RegionName, "' region for ", SystemFC))
                
                % Selecting the points that belong to the considered region 
                % in the Ecuador's domain
                pointer_region = find(Emask(:,3)==Region);
                
                % Reading the rainfall values that define the verification
                % events
                FileIN_CDF = strcat(Git_repo, "/", DirIN_CDF, AccSTR, "/RainFR/", SystemFC, "/EFFCI", num2str(EFFCI,'%02.f'), "/", RegionName, "/RainCDF_RainExt", num2str(PercCDF,"%02.f"), ".csv");
                cdf = import_CDF(FileIN_CDF);
            
                % Selecting the rainfall value that corresponds to a
                % certain percentage of flood report retention
                rev = cdf(cdf(:,1)==PercRetentionFR,2);
                
                % Initialize the variables that will store the HRs and
                % FARs, and the their correspondent confidence intervals
                NumSteps = length(StepF_S : DiscStep : StepF_F);
                HR_AllSteps = zeros(NumEM,NumSteps);
                FAR_AllSteps = zeros(NumEM,NumSteps);
                HR_upCI_AllSteps = zeros(NumEM,NumSteps);
                HR_lowCI_AllSteps = zeros(NumEM,NumSteps);
                FAR_upCI_AllSteps = zeros(NumEM,NumSteps);
                FAR_lowCI_AllSteps = zeros(NumEM,NumSteps);
                
                % Selecting the step of end accumulation period to consider
                % for forecasts from the 00 UTC run
                indStep = 1; 
                
                for StepF00 = StepF_S : DiscStep : StepF_F
                    
                    disp(strcat("       - StepF=", num2str(StepF00)))
                    
                    % Initializing the variables that will store the daily
                    % CTs 
                    H = zeros(NumEM,366);
                    FA = zeros(NumEM,366);
                    M = zeros(NumEM,366);
                    CN = zeros(NumEM,366);
                    
                    % Selecting the step of end accumulation period to 
                    % consider for forecasts from the 12 UTC run
                    StepS00 = StepF00 - Acc;
                    CountDay = 1;
                    
                    for d00 = dS : dF
                        
                        if StepS00 < 12
                            d12 = d00 - 1;
                            StepS12 = StepS00 + 12;
                        else
                            d12 = d00;
                            StepS12 = StepS00 - 12;
                        end
                        StepF12 = StepS12 + Acc;
                        
                        % Select the forecasts to consider
                        FileIN_FC00 = strcat(Git_repo, "/", DirIN_FC, AccSTR, "/", SystemFC, "/", datestr(d00, "yyyymmdd"), "00/tp_", num2str(Acc,'%03d'), "_", datestr(d00, "yyyymmdd"), "_00_", num2str(StepF00,'%03.f'), ".mat");
                        FileIN_FC12 = strcat(Git_repo, "/", DirIN_FC, AccSTR, "/", SystemFC, "/", datestr(d12, "yyyymmdd"), "12/tp_", num2str(Acc,'%03d'), "_", datestr(d12, "yyyymmdd"), "_12_", num2str(StepF12,'%03.f'), ".mat");
                        
                        % Select the observations to consider
                        ValidTime = d00 + (0/24) + (StepF00/24);
                        FileIN_FR = strcat(Git_repo, "/", DirIN_FR, AccSTR, "/EFFCI", num2str(EFFCI,'%02.f'), "/GridAccFR_", datestr(ValidTime, 'yyyymmdd'), "_", datestr(ValidTime, 'HH'), ".mat");
                        
                        % Reading the forecasts and the verifying 
                        % observations if they exist 
                        if isfile(FileIN_FC00) && isfile(FileIN_FC12) && isfile(FileIN_FR)
                            
                            load(FileIN_FC00)
                            FC00 = FC;
                            load(FileIN_FC12)
                            FC12 = FC;
                            FC = [FC00(pointer_region,3:end); FC12(pointer_region,3:end)];
                            
                            load(FileIN_FR)
                            FR_temp = FR;
                            FR = [FR_temp(pointer_region,3); FR_temp(pointer_region,3)];
                                
                            % Defining how many events exceed the rainfall 
                            % threshold
                            EMs_exceedFC = (FC >= rev);
                            NumEMs_exceedFC = sum(EMs_exceedFC,2);
                                
                            % Defining the contingency table
                            for ind_NumEM = 1 : NumEM
                                
                                indCT = NumEM - ind_NumEM + 1;
                                
                                pointer_NumEMs_exceedFC_YES = find(NumEMs_exceedFC>=ind_NumEM);
                                pointer_NumEMs_exceedFC_NO = find(NumEMs_exceedFC<ind_NumEM);
                                
                                FR_YES = FR(pointer_NumEMs_exceedFC_YES);
                                FR_NO = FR(pointer_NumEMs_exceedFC_NO);
                                
                                H(indCT,CountDay) = sum(FR_YES==1);
                                FA(indCT,CountDay) = sum(FR_YES==0);
                                M(indCT,CountDay) = sum(FR_NO==1);
                                CN(indCT,CountDay) = sum(FR_NO==0);
                                
                            end
                            
                            CountDay = CountDay + 1;
                            
                        end
                        
                    end
                    
                    % Removing days for which forecasts and/or verifying
                    % observations were not available
                    H(:,CountDay:end) = [];
                    FA(:,CountDay:end) = [];
                    M(:,CountDay:end) = [];
                    CN(:,CountDay:end) = [];
                    [m,n] = size(H);
                    
                    % Compute HRs and FARs for the original data 
                    H_year = sum(H,2);
                    FA_year = sum(FA,2);
                    M_year = sum(M,2);
                    CN_year = sum(CN,2);
                    
                    HR_AllSteps(:,indStep) = H_year ./ (H_year + M_year);
                    FAR_AllSteps(:,indStep) = FA_year ./ (FA_year + CN_year);
                    
                    % Compute HRs and FARs for the BS samples
                    HR_BS = zeros(m,NumBS);
                    FAR_BS = zeros(m,NumBS);
                    
                    for indBS = 1 : NumBS
                        
                        indCols = randi(n,1,n);
                        
                        H_BS = H(:,indCols);
                        FA_BS = FA(:,indCols);
                        M_BS = M(:,indCols);
                        CN_BS = CN(:,indCols);
                        
                        H_year = sum(H_BS,2);
                        FA_year = sum(FA_BS,2);
                        M_year = sum(M_BS,2);
                        CN_year = sum(CN_BS,2);
                        
                        HR_BS(:,indBS) = H_year ./ (H_year + M_year);
                        FAR_BS(:,indBS) = FA_year ./ (FA_year + CN_year);
                        
                    end
                    
                    % Compute the confidence intervals for HRs and FARs
                    HR_upCI_AllSteps(:,indStep) = prctile(HR_BS,PercCI,2);
                    HR_lowCI_AllSteps(:,indStep) = prctile(HR_BS,(100-PercCI),2);
                    
                    FAR_upCI_AllSteps(:,indStep) = prctile(FAR_BS,PercCI,2);
                    FAR_lowCI_AllSteps(:,indStep) = prctile(FAR_BS,(100-PercCI),2);
                    
                    indStep = indStep + 1;
                    
                end
                
                FileOut = strcat(DirOUT_temp, "/HR_FAR_CI_", RegionName, ".mat");
                save(FileOut, "HR_AllSteps", "FAR_AllSteps", "HR_upCI_AllSteps", "HR_lowCI_AllSteps", "FAR_upCI_AllSteps", "FAR_lowCI_AllSteps")
                
            end
            
        end
        
    end
    
end