%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute_CDF_RainAll_RainFF.m computes the CDF of all rainfall values in 
% "La Costa" and "La Sierra" for 2019, and the rainfall values associated 
% with flash flood events. Day1 ENS and ecPoint forecasts are considered. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
Year = 2019;
Acc = 12;
Percs = (1:99);
PercExt_list = [50,75,85,90,95,98,99];
LZ_Acc = 3;
LZ_Perc = 2;
Region_list = [1,2];
RegionName_list = ["Costa","Sierra"];
SystemFC_list = ["ENS", "ecPoint"];
EFFCI_list = [1,6,10];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Processed/EcuadorMasks/Emask_ENS.csv";
DirIN_FC = "Data/Processed/FC_Emask_Rainfall_";
FileIN_ObsFF = "Data/Raw/ObsFF_Mod/Ecu_FF_Hist_ECMWF_mod.csv";
DirOUT_CDF = "Data/Processed/RainCDF_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: Points that belong to Ecuador's region "Oriente" will not be
% considered in this analysis as there are not many flood reports for that
% region and any analysis might be robust.

% Creating strings from numbers
AccSTR = num2str(Acc, strcat('%0',num2str(LZ_Acc),'.f'));

% Importing Ecuador's mask
FileIN_Emask = strcat(Git_repo, "/", FileIN_Emask);
Emask = import_Emask(FileIN_Emask);

% Creating the directory name of the rainfall forecasts
DirIN_FC = strcat(Git_repo, "/", DirIN_FC, AccSTR);

% Creating the file name of the flood reports
FileIN_FF = strcat(Git_repo, "/", FileIN_ObsFF);

% Creating the output directory
DirOUT = strcat(Git_repo, "/", DirOUT_CDF, AccSTR);
if ~exist(DirOUT, 'dir')
    mkdir(DirOUT)
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating the CDF of the distribution of all rainfall values using day1 
% ENS and ecPoint forecasts
disp("Creating the CDF of the distribution of all rainfall values")

% Setting the dates to consider
date1 = datenum(strcat(num2str(Year),"-01-01"));
date2 = datenum(strcat(num2str(Year),"-12-31"));

for indFC = 1 : length(SystemFC_list)
     
    % Selecting the forecasting system to consider
    SystemFC = SystemFC_list(indFC);
    disp(strcat(" - Considering '", SystemFC, "'"))
    
    DirIN_FC_temp = strcat(DirIN_FC, "/", SystemFC);
    
    for indRegion = 1 : length(Region_list)
    
        % Selecting the region to consider
        Region = Region_list(indRegion);
        RegionName = RegionName_list(indRegion);
        disp(strcat("   - Considering the region '", RegionName, "'"))
        
        pointer_region = find(Emask(:,3)==Region);
        FC = [];
        RainExt = [];
        
        for TheDate = date1 : date2
            
            % Selecting the forecast dates to consider
            
            % NOTE: the following accumulation periods are going to be considered
            % for Day(x):
            %  - Period n.1 (P1): from 00 to 12 UTC
            %  - Period n.2 (P2): from 12 to 24 UTC
            % The day1 forecasts to consider are:
            %  - P1: Day(x), 00 UTC (t+0,t+12)
            %  - P2: Day(x), 00 UTC (t+12,t+24)
            %  - P1: Day(x-1), 12 UTC (t+12,t+24)
            %  - P2: Day(x), 12 UTC (t+0,t+12)
            
            TheDateSTR_x = datestr(TheDate, "yyyymmdd");
            TheDateSTR_x1 = datestr(TheDate-1, "yyyymmdd");
            FC_day = [];
            
            FileIN_P1_00 = strcat(DirIN_FC_temp, "/", TheDateSTR_x, "00/tp_", AccSTR, "_", TheDateSTR_x, "_00_012.csv");
            if isfile(FileIN_P1_00) && strcmp(SystemFC,"ENS")
                FC_temp = import_ENS(FileIN_P1_00);
                FC_day = [FC_day; FC_temp(pointer_region,3:end)];
            elseif isfile(FileIN_P1_00) && strcmp(SystemFC,"ecPoint")
                FC_temp = import_ecPoint(FileIN_P1_00);
                FC_day = [FC_day; FC_temp(pointer_region,3:end)];
            end
            
            FileIN_P2_00 = strcat(DirIN_FC_temp, "/", TheDateSTR_x, "00/tp_", AccSTR, "_", TheDateSTR_x, "_00_024.csv");
            if isfile(FileIN_P2_00) && strcmp(SystemFC,"ENS")
                FC_temp = import_ENS(FileIN_P2_00);
                FC_day = [FC_day; FC_temp(pointer_region,3:end)];
            elseif isfile(FileIN_P2_00) && strcmp(SystemFC,"ecPoint")
                FC_temp = import_ecPoint(FileIN_P2_00);
                FC_day = [FC_day; FC_temp(pointer_region,3:end)];
            end
            
            FileIN_P1_12 = strcat(DirIN_FC_temp, "/", TheDateSTR_x1, "12/tp_", AccSTR, "_", TheDateSTR_x1, "_12_024.csv");
            if isfile(FileIN_P1_12) && strcmp(SystemFC,"ENS")
                FC_temp = import_ENS(FileIN_P1_12);
                FC_day = [FC_day; FC_temp(pointer_region,3:end)];
            elseif isfile(FileIN_P1_12) && strcmp(SystemFC,"ecPoint")
                FC_temp = import_ecPoint(FileIN_P1_12);
                FC_day = [FC_day; FC_temp(pointer_region,3:end)];
            end
            
            FileIN_P2_12 = strcat(DirIN_FC_temp, "/", TheDateSTR_x, "12/tp_", AccSTR, "_", TheDateSTR_x, "_12_012.csv");
            if isfile(FileIN_P2_12) && strcmp(SystemFC,"ENS")
                FC_temp = import_ENS(FileIN_P2_12);
                FC_day = [FC_day; FC_temp(pointer_region,3:end)];
            elseif isfile(FileIN_P2_12) && strcmp(SystemFC,"ecPoint")
                FC_temp = import_ecPoint(FileIN_P2_12);
                FC_day = [FC_day; FC_temp(pointer_region,3:end)];
            end
            
            FC_day = FC_day(:);
            
            % Computing the distribution of extreme rainfall values (given 
            % by user percentiles), for all points, for each day
            RainExt = [RainExt; prctile(FC_day,PercExt_list)];
            
            % Assembling the forecasts for the whole period
            FC = [FC; FC_day];
            
        end
        
        % Computing and saving the percentiles for all points, for the 
        % whole period 
        FileOUT = strcat(DirOUT, strcat("/RainCDF_All_", SystemFC, "_", RegionName, ".csv"));
        CDF_All = array2table([Percs', prctile(FC,Percs)'],'VariableNames', {'Percentiles','Rainfall Values'});
        writetable(CDF_All,FileOUT,'Delimiter',',')
        
        % Computing the percentiles for the extreme rainfall values, for
        % all points, for the whole period
        for i = 1 : length(PercExt_list)
            
            PercExt = PercExt_list(i);
            PercExtSTR = num2str(PercExt, strcat('%0',num2str(LZ_Perc),'.f'));
            
            FileOUT = strcat(DirOUT, strcat("/RainCDF_All_RainExt", PercExtSTR, "_", SystemFC, "_", RegionName, ".csv"));
            CDF_RainExt = array2table([Percs', prctile(RainExt(:,i),Percs)'],'VariableNames', {'Percentiles','Rainfall Values'});
            writetable(CDF_RainExt,FileOUT,'Delimiter',',')
            
        end
            
    end
    
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Creating the CDF of the distribution of the rainfall values associated 
% with flood reports using day1 ENS and ecPoint forecasts
disp(" ")
disp("Creating the CDF of the distribution of rainfall values associated with flood reports using day1 ENS and ecPoint forecasts")

for indRegion = 1 : length(Region_list)
        
    % Selecting the region to consider
    Region = Region_list(indRegion);
    RegionName = RegionName_list(indRegion);
    disp(strcat(" - Considering the region '", RegionName, "'"))
    
    for ind_EFFCI = 1 : length(EFFCI_list)
        
        % Selecting the EFFCI threshold to consider
        EFFCI = EFFCI_list(ind_EFFCI);
        disp(strcat("   - Considering flood reports with EFFCI>=",num2str(EFFCI)))
        
        % Reading the flood reports for the correspondent year and EFFCI
        ObsFF = import_ObsFF(FileIN_FF,Year,EFFCI);
        
        % Selecting the flood reports for the correspondent region
        pointer_region = find(double(string(ObsFF.Georegion)) == Region);
        lats = ObsFF.Y_DD(pointer_region);
        lons = ObsFF.X_DD(pointer_region);
        DateTimes = ObsFF.DateTimeNum(pointer_region);
        m = length(DateTimes);
        
        for indFC = 1 : length(SystemFC_list)
     
            % Selecting the forecasting system to consider
            SystemFC = SystemFC_list(indFC);
            disp(strcat("    - Considering '", SystemFC, "'"))
            
            DirIN_FC_temp = strcat(DirIN_FC, "/", SystemFC);
            
            % Initializing the variable that will contain all the day1 
            % rainfall forecasts and rainfall extremes associated with all 
            % flood reports
            FC = [];
            RainExt = [];
            
            for indFF = 1 : m
                
                % Selecting the coordinates and the time for the flood 
                % report to consider
                coord_FF = [lats(indFF),lons(indFF)];
                DateTime = DateTimes(indFF);
                
                % Initializing the variable that will contain the rainfall
                % forecasts associated with the considered flood report
                FC_Day = [];
                
                % Selecting the 12-hourly day1 rainfall forecasts to consider
                Date_x = datenum(datestr(DateTime, "yyyy-mm-dd"));
                DateSTR_x = datestr(Date_x, "yyyymmdd");
                
                Date_1x = Date_x - hours(24);
                DateSTR_1x = datestr(Date_1x, "yyyymmdd");
                
                Date_x1 = Date_x + hours(24);
                DateSTR_x1 = datestr(Date_x1, "yyyymmdd");
                
                % NOTE: the day1 rainfall forecasts to consider are 
                % determined depending on the reporting time of the flood
                % event. Since there is no information to locate the
                % rainfall event that caused the flood event, all rainfall
                % accumulation periods which include the flood reporting  
                % time are considered in the analysis.
                
                % Flood event reported on Day(x) between 0 and 6 UTC.
                % The 12-hourly valid rainfall periods and the
                % correspondent day1 rainfall forecasts to consider are:
                %  - Period n.1_1: from Day(x-1) at 18 UTC to Day(x) at 6 UTC
                %     - FC_00 -> Day(x-1), 00 UTC (t+18,t+30)
                %     - FC_12 -> Day(x-1), 12 UTC (t+6,t+18)
                %  - Period n.1_2: from Day(x) at 0 UTC to Day(x) at 12 UTC
                %     - FC_00 -> Day(x), 00 UTC (t+0,t+12)
                %     - FC_12 -> Day(x-1), 12 UTC (t+12,t+24)
                
                if DateTime >= (Date_x + hours(0)) && DateTime <= (Date_x + hours(6))
                    
                    FileIN_FC_list = [strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_1x, "00/tp_", AccSTR, "_", DateSTR_1x, "_00_030.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "00/tp_", AccSTR, "_", DateSTR_x, "_00_012.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_1x, "12/tp_", AccSTR, "_", DateSTR_1x, "_12_018.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_1x, "12/tp_", AccSTR, "_", DateSTR_1x, "_12_024.csv");];
                    
                    for i = 1 : length(FileIN_FC_list)
                        FileIN_FC = FileIN_FC_list(i);
                        if isfile(FileIN_FC)
                            FC_temp = import_ecPoint(FileIN_FC);
                            pointer_FC = dsearchn(FC_temp(:,1:2), coord_FF);
                            FC_Day = [FC_Day; FC_temp(pointer_FC,3:end)'];
                        end
                    end
                    
                end
                
                % Flood event reported on Day(x) between 6 and 12 UTC.
                % The 12-hourly valid rainfall periods and the
                % correspondent day1 rainfall forecasts to consider are:
                %  - Period n.2_1: from Day(x) at 0 UTC to Day(x) at 12 UTC
                %     - FC_00 -> Day(x), 00 UTC (t+0,t+12)
                %     - FC_12 -> Day(x-1), 12 UTC (t+12,t+24)
                %  - Period n.2_2: from Day(x) at 6 UTC to Day(x) at 18 UTC
                %     - FC_00 -> Day(x), 00 UTC (t+6,t+18)
                %     - FC_12 -> Day(x-1), 12 UTC (t+18,t+30)
                
                if DateTime >= (Date_x + hours(6)) && DateTime <= (Date_x + hours(12))
                    
                    FileIN_FC_list = [strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "00/tp_", AccSTR, "_", DateSTR_x, "_00_012.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "00/tp_", AccSTR, "_", DateSTR_x, "_00_018.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_1x, "12/tp_", AccSTR, "_", DateSTR_1x, "_12_024.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_1x, "12/tp_", AccSTR, "_", DateSTR_1x, "_12_030.csv");];
                    
                    for i = 1 : length(FileIN_FC_list)
                        FileIN_FC = FileIN_FC_list(i);
                        if isfile(FileIN_FC)
                            FC_temp = import_ecPoint(FileIN_FC);
                            pointer_FC = dsearchn(FC_temp(:,1:2), coord_FF);
                            FC_Day = [FC_Day; FC_temp(pointer_FC,3:end)'];
                        end
                    end
                    
                end
                
                % Flood event reported on Day(x) between 12 and 18 UTC.
                % The 12-hourly valid rainfall periods and the
                % correspondent day1 rainfall forecasts to consider are:
                %  - Period n.3_1: from Day(x) at 6 UTC to Day(x) at 18 UTC
                %     - FC_00 -> Day(x), 00 UTC (t+6,t+18)
                %     - FC_12 -> Day(x-1), 12 UTC (t+18,t+30)
                %  - Period n.3_2: from Day(x) at 12 UTC to Day(x+1) at 0 UTC
                %     - FC_00 -> Day(x), 00 UTC (t+12,t+24)
                %     - FC_12 -> Day(x), 12 UTC (t+0,t+12)
                
                if DateTime >= (Date_x + hours(12)) && DateTime <= (Date_x + hours(18))
                    
                    FileIN_FC_list = [strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "00/tp_", AccSTR, "_", DateSTR_x, "_00_018.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "00/tp_", AccSTR, "_", DateSTR_x, "_00_024.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_1x, "12/tp_", AccSTR, "_", DateSTR_1x, "_12_030.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "12/tp_", AccSTR, "_", DateSTR_x, "_12_012.csv");];
                    
                    for i = 1 : length(FileIN_FC_list)
                        FileIN_FC = FileIN_FC_list(i);
                        if isfile(FileIN_FC)
                            FC_temp = import_ecPoint(FileIN_FC);
                            pointer_FC = dsearchn(FC_temp(:,1:2), coord_FF);
                            FC_Day = [FC_Day; FC_temp(pointer_FC,3:end)'];
                        end
                    end
                    
                end
                
                % Flood event reported on Day(x) between 18 and 24 UTC.
                % The 12-hourly valid rainfall periods and the
                % correspondent day1 rainfall forecasts to consider are:
                %  - Period n.4_1: from Day(x) at 12 UTC to Day(x+1) at 0 UTC
                %     - FC_00 -> Day(x), 00 UTC (t+12,t+24)
                %     - FC_12 -> Day(x), 12 UTC (t+0,t+12)
                %  - Period n.4_2: from Day(x) at 18 UTC to Day(x+1) at 6 UTC
                %     - FC_00 -> Day(x), 00 UTC (t+18,t+30)
                %     - FC_12 -> Day(x), 12 UTC (t+6,t+18)
                
                if DateTime >= (Date_x + hours(18)) && DateTime <= (Date_x1 + hours(0))
                    
                    FileIN_FC_list = [strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "00/tp_", AccSTR, "_", DateSTR_x, "_00_024.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "00/tp_", AccSTR, "_", DateSTR_x, "_00_030.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "12/tp_", AccSTR, "_", DateSTR_1x, "_12_012.csv");
                                      strcat(DirIN_FC, "/", SystemFC, "/", DateSTR_x, "12/tp_", AccSTR, "_", DateSTR_x, "_12_018.csv");];
                    
                    for i = 1 : length(FileIN_FC_list)
                        FileIN_FC = FileIN_FC_list(i);
                        if isfile(FileIN_FC)
                            FC_temp = import_ecPoint(FileIN_FC);
                            pointer_FC = dsearchn(FC_temp(:,1:2), coord_FF);
                            FC_Day = [FC_Day; FC_temp(pointer_FC,3:end)'];
                        end
                    end
                    
                end
                
                FC_Day = FC_Day(:);
            
                % Computing the distribution of extreme rainfall values 
                % (given by user percentiles) for the considered flood 
                % report
                RainExt = [RainExt; prctile(FC_Day,PercExt_list)];
                
                % Assembling the forecasts for the whole period
                FC = [FC; FC_Day];
                
            end
            
            % Computing and saving the percentiles for all rainfall values
            % associated with flood reports
            FileOUT = strcat(DirOUT, strcat("/RainCDF_FF_", SystemFC, "_", RegionName, ".csv"));
            CDF_All = array2table([Percs', prctile(FC,Percs)'],'VariableNames', {'Percentiles','Rainfall Values'});
            writetable(CDF_All,FileOUT,'Delimiter',',')
            
            % Computing and saving the percentiles for the extreme rainfall 
            % values associated with flood reports
            for i = 1 : length(PercExt_list)
                
                PercExt = PercExt_list(i);
                PercExtSTR = num2str(PercExt, strcat('%0',num2str(LZ_Perc),'.f'));
                
                FileOUT = strcat(DirOUT, strcat("/RainCDF_FF_RainExt", PercExtSTR, "_", SystemFC, "_", RegionName, ".csv"));
                CDF_RainExt = array2table([Percs', prctile(RainExt(:,i),Percs)'],'VariableNames', {'Percentiles','Rainfall Values'});
                writetable(CDF_RainExt,FileOUT,'Delimiter',',')
                
            end
            
        end
            
    end
    
end
