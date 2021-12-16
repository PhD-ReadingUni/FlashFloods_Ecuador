%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute_CT.m computes the contingency tables for the flash flood
% verification of ecPoint-Rainfall forecasts in Ecuador
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear 
clc

% INPUT PARAMETERS
BaseDateS = "2020-01-01";
BaseDateF = "2020-12-31";
StepF_S = 12;
StepF_F = 240;
DiscStep = 6;
Acc = 12;
SystemFC = "ecPoint";
EFFCI_list = [6];
Perc_CDF_RainFF_list = [75,85,90,95,98,99];
Region_list = [1,2];
RegionName_list = {'Costa', 'Sierra'};
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Processed/EcuadorMasks/Emask_ENS.csv";
DirIN_CDF = "Data/Processed/CDF_RainFF_";
DirIN_FC = strcat("Data/Processed/",SystemFC, "_Emask_Rainfall_");
DirIN_FF = "Data/Processed/AccFF_";
DirOUT = "Data/Processed/CT_";

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic

% NOTE: Points that belong to Ecuador's region "Oriente" will not be
% considered in this analysis as there are not many flood reports for that
% region and any analysis might be robust.
disp("Computing the contingency tables for the flash flood verification of ecPoint-Rainfall forecasts in Ecuador")


% Setting generic parameters
dS=datenum(BaseDateS,'yyyy-mm-dd');
dF=datenum(BaseDateF,'yyyy-mm-dd');
AccSTR = num2str(Acc,'%03d');
if strcmp(SystemFC,"ecPoint")
    NumCT = 99;
elseif strcmp(SystemFC,"ENS")
    NumCT = 51;
end


% Importing Ecuador's mask
FileIN_Emask = strcat(Git_repo, "/", FileIN_Emask);
Emask = import_Emask(FileIN_Emask);


% Computing the contingency tables 
for indEFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI threshold to consider
    EFFCI = EFFCI_list(indEFFCI);
    
    % Importing the cdf distribution of the rainfall values associated with 
    % flash floods 
    FileIN_CDF = strcat(Git_repo, "/", DirIN_CDF, num2str(Acc), "h/CDF_RainFF_EFFCI", num2str(EFFCI,'%02.f'), ".csv");
    cdf = import_CDF_RainFF(FileIN_CDF);
    
    for indRegion = 1 : length(Region_list)
        
        % Selecting the region to consider
        Region = Region_list(indRegion);
        disp(" ")
        disp(strcat(" - Considering flood reports with EFFCI>=",num2str(EFFCI), " for the region '", RegionName_list(indRegion), "'"))
    
        % Selecting the points that in the Ecuador's mask belong to the
        % considered region
        pointer_region = find(Emask(:,3)==Region);
        
        % Selecting the cdf values that belong to the considered region
        percs = cdf(:,1);
        cdf_region = cdf(:,indRegion+1);
        
        for indPercCDF = 1 : length(Perc_CDF_RainFF_list)
            
            % Selecting the rainfall event to verify based on a cdf
            % percentile
            PercCDF = Perc_CDF_RainFF_list(indPercCDF);
            disp(" ")
            disp(strcat("   - Considering a rainfall event greater than (PercCDF=", num2str(PercCDF), " percentile)"))
            
            % Creating output directory
            DirOUT_temp = strcat(Git_repo, "/", DirOUT, num2str(Acc), "h/", SystemFC, "/EFFCI", num2str(EFFCI,'%02.f'), "/Perc", num2str(PercCDF,'%02.f'));
            if ~exist(DirOUT_temp, "dir")
                mkdir(DirOUT_temp)
            end
            
            % Selecting the rainfall value correspondent to the considered
            % percentile
            RainCDF = cdf_region(percs==PercCDF);
            
            % Selecting the step of end accumulation period to consider for  
            % forecasts from the 00 UTC run
            for StepF00 = StepF_S : DiscStep : StepF_F
                
                disp(strcat("     - StepF (for the 00 UTC run)=", num2str(StepF00)))
                
                % Create template for the contingency tables
                CT = zeros(NumCT,4);
                
                % Selecting the step of end accumulation period to consider  
                % for forecasts from the 12 UTC run
                StepF12 = StepF00 + 12;
                AvStepF = (StepF00 + StepF12) / 2;
                
                % Select the days to consider for the 00 UTC run 
                for d00 = dS : dF
                
                    d12 = d00 - 1;
                    
                    % Select the forecasts to consider
                    FileIN_FC00 = strcat(Git_repo, "/", DirIN_FC, num2str(Acc), "h/", datestr(d00, "yyyymmdd"), "00/tp_", AccSTR, "_", datestr(d00, "yyyymmdd"), "_00_", num2str(StepF00,'%03.f'), ".csv");
                    FileIN_FC12 = strcat(Git_repo, "/", DirIN_FC, num2str(Acc), "h/", datestr(d12, "yyyymmdd"), "12/tp_", AccSTR, "_", datestr(d12, "yyyymmdd"), "_12_", num2str(StepF12,'%03.f'), ".csv");
                    
                    % Select the observations to consider
                    ValidTime = d00 + (0/24) + (StepF00/24);
                    FileIN_FF = strcat(Git_repo, "/", DirIN_FF, num2str(Acc), "h/EFFCI", num2str(EFFCI,'%02.f'), "/AccFF_", datestr(ValidTime, 'yyyymmdd'), "_", datestr(ValidTime, 'HH'), ".csv");
                    
                    % Checking the the files containing the forecasts
                    % and the verifyin gobservations exist
                    if isfile(FileIN_FF)
                        
                        % Reading the verifying observations
                        FF = [];
                        FF_temp = import_AccFF(FileIN_FF);
                        
                        % Reading the forecasts
                        FC = [];
                        if isfile(FileIN_FC00)
                            if strcmp(SystemFC,"ecPoint")
                                FC00 = import_ecPoint(FileIN_FC00);
                            elseif strcmp(SystemFC,"ENS")
                                FC00 = import_ENS(FileIN_FC00);
                            end
                            FC = [FC; FC00(pointer_region,3:end)];
                            FF = [FF; FF_temp(pointer_region,3)];
                        end
                        
                        if isfile(FileIN_FC12)
                            if strcmp(SystemFC,"ecPoint")
                                FC12 = import_ecPoint(FileIN_FC12);
                            elseif strcmp(SystemFC,"ENS")
                                FC12 = import_ENS(FileIN_FC12);
                            end
                            FC = [FC; FC12(pointer_region,3:end)];
                            FF = [FF; FF_temp(pointer_region,3)];
                        end
                        
                        % Defining how many events exceed the rainfall threshold
                        FC_exceed = FC >= RainCDF;
                        FC_exceed_total = sum(FC_exceed,2);
                        
                        % Defining the contingency table
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
                            
                    end
                    
                end
                
                % Saving contingecy table
                CT = array2table(CT,'VariableNames', {'H','FA','M','CN'});
                FileOUT = strcat(DirOUT_temp,"/CT_", RegionName_list(indRegion), "_", num2str(AvStepF,'%03.f'), ".csv");
                writetable(CT,FileOUT,'Delimiter',',')
                
            end
            
        end
        
    end
    
end

toc