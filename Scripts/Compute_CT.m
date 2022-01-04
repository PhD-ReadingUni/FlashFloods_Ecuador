%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute_CT.m computes the contingency tables for flood verification
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear 
clc

% INPUT PARAMETERS
Year = 2020;
StepF_S = 12;
StepF_F = 24;
DiscStep = 6;
Acc = 12;
SystemFC_list = ["ENS","ecPoint"];
NumEM_list = [51,99];
Region_list = [1,2];
RegionName_list = ["Costa","Sierra"];
EFFCI_list = [1,6,10];
PercREV_list = [85,90,95,98,99];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Raw/EcuadorMasks/Emask_ENS.csv";
DirIN_FC = "Data/Raw/FC_Emask_Rainfall_";
DirIN_FR = "Data/Raw/GridAccFR_";
DirIN_REV = "Data/Processed/RainEventVerif_";
DirOUT = "Data/Processed/CT_";
LZ_Acc = 3;
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
AccSTR = num2str(Acc, strcat('%0',num2str(LZ_Acc),'.f'));


% Computing the contingency tables 
for indSystemFC = 1: length(SystemFC_list)
    
    % Selecting the forecasting system to consider
    SystemFC = SystemFC_list(indSystemFC);
    NumEM = NumEM_list(indSystemFC);
    disp(strcat(" - Considering the ", SystemFC, " forecasting system"))
    
    for indRegion = 1 : length(Region_list)
        
        % Selecting the region to consider
        Region = Region_list(indRegion);
        RegionName = RegionName_list(indRegion);
        disp(strcat("  - Considering the '", RegionName, "' region"))
        
        % Selecting the points that belong to the considered region in the
        % Ecuador's domain
        pointer_region = find(Emask(:,3)==Region);
        
        for indEFFCI = 1 : length(EFFCI_list)
            
            % Selecting the EFFCI threshold to consider
            EFFCI = EFFCI_list(indEFFCI);
            disp(" ")
            disp(strcat("   - Considering the flood reports with EFFCI>=",num2str(EFFCI)))
            
            % Reading the rainfall values that define the verification
            % events
            FileIN_REV = strcat(Git_repo, "/", DirIN_REV, AccSTR, "/RainEventVerif_EFFCI", num2str(EFFCI,'%02.f'), "_", RegionName, ".csv");
            rev = import_REV(FileIN_REV);
            
            for indPercREV = 1 : length(PercREV_list)
                
                % Selecting the percentile that defines how extreme is the
                % rainfall event to verify 
                PercREV = PercREV_list(indPercREV);
                disp(" ")
                disp(strcat(" - Considering rainfall events >= (PercREV=", num2str(PercREV), "th percentile)"))
                
                % Selecting the rainfall value that corresponds to the
                % percentile that defines how extreme is the rainfall event
                % to verify
                rev_perc = rev(rev(:,1)==PercREV,2);
                
                % Selecting the step of end accumulation period to consider
                % for forecasts from the 00 UTC run
                for StepF00 = StepF_S : DiscStep : StepF_F
                    
                    disp(strcat("   - StepF=", num2str(StepF00)))
                    
                    NumDay = 1;
                    for d00 = dS : dF
                        
                        % Creating template for the contingency tables
                        CT = zeros(NumEM,4);
                    
                        % Selecting the step of end accumulation period to consider
                        % for forecasts from the 12 UTC run, and determining the
                        % average step of end accumulation period
                        if StepF00 < 24
                            d12 = d00 - 1;
                            StepF12 = StepF00 + Acc;
                        else
                            d12 = d00;
                            StepF12 = StepF00 - Acc;
                        end
                        AvStepF = (StepF00 + StepF12) / 2;
                        
                        % Creating output directory
                        DirOUT_temp = strcat(Git_repo, "/", DirOUT, AccSTR, "/", SystemFC, "/EFFCI", num2str(EFFCI,'%02.f'), "/Perc", num2str(PercREV,'%02.f'), "/", RegionName, "/", num2str(AvStepF,'%03.f'));
                        if ~exist(DirOUT_temp, "dir")
                            mkdir(DirOUT_temp)
                        end
                        
                        % Select the forecasts to consider
                        FileIN_FC00 = strcat(Git_repo, "/", DirIN_FC, AccSTR, "/", SystemFC, "/", datestr(d00, "yyyymmdd"), "00/tp_", num2str(Acc,'%03d'), "_", datestr(d00, "yyyymmdd"), "_00_", num2str(StepF00,'%03.f'), ".csv");
                        FileIN_FC12 = strcat(Git_repo, "/", DirIN_FC, AccSTR, "/", SystemFC, "/", datestr(d12, "yyyymmdd"), "12/tp_", num2str(Acc,'%03d'), "_", datestr(d12, "yyyymmdd"), "_12_", num2str(StepF12,'%03.f'), ".csv");
                        
                        % Select the observations to consider
                        ValidTime = d00 + (0/24) + (StepF00/24);
                        FileIN_FR = strcat(Git_repo, "/", DirIN_FR, AccSTR, "/EFFCI", num2str(EFFCI,'%02.f'), "/GridAccFR_", datestr(ValidTime, 'yyyymmdd'), "_", datestr(ValidTime, 'HH'), ".csv");
                        
                        % Reading the forecasts and the verifying observations
                        FC = [];
                        FR = [];
                        
                        if isfile(FileIN_FC00) && isfile(FileIN_FC12)
                            
                            FC00 = import_FC(FileIN_FC00,SystemFC);
                            FC12 = import_FC(FileIN_FC12,SystemFC);
                            FC = [FC; FC00(pointer_region,3:end); FC12(pointer_region,3:end)];
                            
                            FR_temp = import_GridAccFR(FileIN_FR);
                            FR = [FR; FR_temp(pointer_region,3); FR_temp(pointer_region,3)];
                            
                        end
                            
                        % Defining how many events exceed the rainfall threshold
                        FC_exceed = (FC >= rev_perc);
                        FC_exceed_total = sum(FC_exceed,2);
                        
                        % Defining the contingency table
                        for indEM = 1 : NumEM
                            
                            pointer_FC_YES = find(FC_exceed_total>=indEM);
                            pointer_FC_NO = find(FC_exceed_total<indEM);
                            
                            FR_FC_YES = FR(pointer_FC_YES);
                            FR_FC_NO = FR(pointer_FC_NO);
                            
                            CT(indEM,1) = sum(FR_FC_YES==1); % hits (H)
                            CT(indEM,2) = sum(FR_FC_YES==0); % false alarms (FA)
                            CT(indEM,3) = sum(FR_FC_NO==1); % misses (M)
                            CT(indEM,4) = sum(FR_FC_NO==0); % correct negatives (CN)
                        
                        end
                        
                        % Saving contingecy table
                        CT = array2table(CT,'VariableNames', {'H','FA','M','CN'});
                        FileOUT = strcat(DirOUT_temp,"/CT_Day", num2str(NumDay,'%03.f'), ".csv");
                        writetable(CT,FileOUT,'Delimiter',',')
                        
                        NumDay = NumDay + 1;
                        
                    end
                    
                end
                
            end
            
        end
        
    end
    
end