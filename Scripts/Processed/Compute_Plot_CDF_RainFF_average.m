%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Compute_Plot_CDF_RainFF.m computes and plots the CDF of the distribution  
% of rainfall values associated with flash flood events in "La Costa" and 
% "La Sierra". Day 1 ecPoint forecasts are used as proxy rainfall 
% observations.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
Year = 2019;
EFFCI_list = [6];
Region_list = [1,2];
RegionName_list = {'La Costa','La Sierra'};
RegionPlot_list = ["b-", "r-"];
Acc = 12;
Perc_list = [75,85,90,95,98,99];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
DirIN_ecPoint = "Data/Processed/FC_Emask_Rainfall_";
FileIN_ObsFF = "Data/Raw/ObsFF_Mod/Ecu_FF_Hist_ECMWF_mod.csv";
DirOUT_CDF_RainFF_csv = "Data/Processed/CDF_RainFF_";
DirOUT_CDF_RainFF_jpg = "Data/Figures/CDF_RainFF_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: Points that belong to Ecuador's region "Oriente" will not be
% considered in this analysis as there are not many flood reports for that
% region and any analysis might be robust.


% Creating the output directories
DirOUT_csv = strcat(Git_repo, "/", DirOUT_CDF_RainFF_csv, num2str(Acc), "h");
if ~exist(DirOUT_csv, 'dir')
    mkdir(DirOUT_csv)
end

DirOUT_jpg = strcat(Git_repo, "/", DirOUT_CDF_RainFF_jpg, num2str(Acc), "h");
if ~exist(DirOUT_jpg, 'dir')
    mkdir(DirOUT_jpg)
end


% Creating the CDF of the distribution of rainfall values associated with
% flash flood events
disp("Creating the CDF of the distribution of rainfall values associated with flash flood events")

for ind_EFFCI = 1 : length(EFFCI_list)
    
    % Selecting the EFFCI threshold to consider
    EFFCI = EFFCI_list(ind_EFFCI);
    disp(strcat(" - Considering flood reports with EFFCI>=",num2str(EFFCI)))
    
    % Reading the flash flood reports for the correspondent year and EFFCI
    FileIN = strcat(Git_repo, "/", FileIN_ObsFF);
    ObsFF = import_ObsFF(FileIN,Year,EFFCI);
    
    for ind_Region = 1 : length(Region_list)
        
        % Selecting the region to consider
        Region = Region_list(ind_Region);
        pointer_reg = find(double(string(ObsFF.Georegion)) == Region);
    
        % Selecting coordinates and times for the flood reports in the
        % considered region
        lats = ObsFF.Y_DD(pointer_reg);
        lons = ObsFF.X_DD(pointer_reg);
        DateTimes = ObsFF.DateTimeNum(pointer_reg);
        m = length(DateTimes);
        
        % Initiating the variable that will store the distribution of
        % percentiles for day1 ecPoint-Rainfall forecasts, for each flash
        % flood report
        n = length(Perc_list);
        percCDF = zeros(m,n);
        
        for i = 1 : m
            
            disp(i)
            % Initiating the variable that will contain the day1
            % ecPoint-Rainfall forecasts
            fc = [];
            
            % Selecting the coordinates and the time for the flood report to
            % consider
            lat = lats(i);
            lon = lons(i);
            DateTime = DateTimes(i);
            
            % Determining which acumulation periods for day1 ecPoint forecasts
            % are going to be considered, and reading the forecats
            DateNUM = datenum(datestr(DateTime, "yyyy-mm-dd"));
            
            % - Forecasts from the 00 UTC run for the same day
            if DateTime >= (DateNUM + hours(0) + hours(0)) && DateTime < (DateNUM + hours(0) + hours(12))
                DateSTR = datestr(DateNUM, "yyyymmdd");
                FileIN_ecPoint = strcat(Git_repo, "/", DirIN_ecPoint, num2str(Acc), "h/ecPoint/", DateSTR, "00/tp_", num2str(Acc,'%03.f'), "_", DateSTR, "_00_012.csv");
                if isfile(FileIN_ecPoint)
                    fc_temp = import_ecPoint(FileIN_ecPoint);
                    pointer_fc = dsearchn(fc_temp(:,1:2), [lat,lon]);
                    fc = [fc; fc_temp(pointer_fc,3:end)'];
                end
            end
            
            if DateTime >= (DateNUM + hours(0) + hours(6)) && DateTime < (DateNUM + hours(0) + hours(18))
                DateSTR = datestr(DateNUM, "yyyymmdd");
                FileIN_ecPoint = strcat(Git_repo, "/", DirIN_ecPoint, num2str(Acc), "h/ecPoint/", DateSTR, "00/tp_", num2str(Acc,'%03.f'), "_", DateSTR, "_00_018.csv");
                if isfile(FileIN_ecPoint)
                    fc_temp = import_ecPoint(FileIN_ecPoint);
                    pointer_fc = dsearchn(fc_temp(:,1:2), [lat,lon]);
                    fc = [fc; fc_temp(pointer_fc,3:end)'];
                end
            end
            
            if DateTime >= (DateNUM + hours(0) + hours(12)) && DateTime < (DateNUM + hours(0) + hours(24))
                DateSTR = datestr(DateNUM, "yyyymmdd");
                FileIN_ecPoint = strcat(Git_repo, "/", DirIN_ecPoint, num2str(Acc), "h/ecPoint/", DateSTR, "00/tp_", num2str(Acc,'%03.f'), "_", DateSTR, "_00_024.csv");
                if isfile(FileIN_ecPoint)
                    fc_temp = import_ecPoint(FileIN_ecPoint);
                    pointer_fc = dsearchn(fc_temp(:,1:2), [lat,lon]);
                    fc = [fc; fc_temp(pointer_fc,3:end)'];
                end
            end
            
            if DateTime >= (DateNUM + hours(0) + hours(18)) && DateTime < (DateNUM + hours(0) + hours(30))
                DateSTR = datestr(DateNUM, "yyyymmdd");
                FileIN_ecPoint = strcat(Git_repo, "/", DirIN_ecPoint, num2str(Acc), "h/ecPoint/", DateSTR, "00/tp_", num2str(Acc,'%03.f'), "_", DateSTR, "_00_030.csv");
                if isfile(FileIN_ecPoint)
                    fc_temp = import_ecPoint(FileIN_ecPoint);
                    pointer_fc = dsearchn(fc_temp(:,1:2), [lat,lon]);
                    fc = [fc; fc_temp(pointer_fc,3:end)'];
                end
            end
            
            % - Forecasts from the 12 UTC run for the previous day
            if DateTime >= ((DateNUM-1) + hours(12) + hours(0)) && DateTime < ((DateNUM-1) + hours(12) + hours(12))
                DateSTR = datestr(DateNUM, "yyyymmdd");
                FileIN_ecPoint = strcat(Git_repo, "/", DirIN_ecPoint, num2str(Acc), "h/ecPoint/", DateSTR, "12/tp_", num2str(Acc,'%03.f'), "_", DateSTR, "_12_012.csv");
                if isfile(FileIN_ecPoint)
                    fc_temp = import_ecPoint(FileIN_ecPoint);
                    pointer_fc = dsearchn(fc_temp(:,1:2), [lat,lon]);
                    fc = [fc; fc_temp(pointer_fc,3:end)'];
                end
            end
            
            if DateTime >= ((DateNUM-1) + hours(12) + hours(6)) && DateTime < ((DateNUM-1) + hours(12) + hours(18))
                DateSTR = datestr(DateNUM, "yyyymmdd");
                FileIN_ecPoint = strcat(Git_repo, "/", DirIN_ecPoint, num2str(Acc), "h/ecPoint/", DateSTR, "12/tp_", num2str(Acc,'%03.f'), "_", DateSTR, "_12_018.csv");
                if isfile(FileIN_ecPoint)
                    fc_temp = import_ecPoint(FileIN_ecPoint);
                    pointer_fc = dsearchn(fc_temp(:,1:2), [lat,lon]);
                    fc = [fc; fc_temp(pointer_fc,3:end)'];
                end
            end
            
            if DateTime >= ((DateNUM-1) + hours(12) + hours(12)) && DateTime < ((DateNUM-1) + hours(12) + hours(24))
                DateSTR = datestr(DateNUM, "yyyymmdd");
                FileIN_ecPoint = strcat(Git_repo, "/", DirIN_ecPoint, num2str(Acc), "h/ecPoint/", DateSTR, "12/tp_", num2str(Acc,'%03.f'), "_", DateSTR, "_12_024.csv");
                if isfile(FileIN_ecPoint)
                    fc_temp = import_ecPoint(FileIN_ecPoint);
                    pointer_fc = dsearchn(fc_temp(:,1:2), [lat,lon]);
                    fc = [fc; fc_temp(pointer_fc,3:end)'];
                end
            end
            
            if DateTime >= ((DateNUM-1) + hours(12) + hours(18)) && DateTime < ((DateNUM-1) + hours(12) + hours(30))
                DateSTR = datestr(DateNUM, "yyyymmdd");
                FileIN_ecPoint = strcat(Git_repo, "/", DirIN_ecPoint, num2str(Acc), "h/ecPoint/", DateSTR, "12/tp_", num2str(Acc,'%03.f'), "_", DateSTR, "_12_030.csv");
                if isfile(FileIN_ecPoint)
                    fc_temp = import_ecPoint(FileIN_ecPoint);
                    pointer_fc = dsearchn(fc_temp(:,1:2), [lat,lon]);
                    fc = [fc; fc_temp(pointer_fc,3:end)'];
                end
            end
            
            % Computing some percentiles for the distribution of rainfall
            % values associated with flash flood events
            percCDF(i,:) = round(prctile(fc,Perc_list),2);    
            
        end
%         
%         % Plot the CDF
%         for j = 1 : n
%             figure
%             temp = percCDF(:,j);
%             perc_temp = round(prctile(temp,(1:99)),2); 
%             plot(perc_temp,(1:99), RegionPlot_list(ind_Region), "LineWidth", 2)
%             title(strcat("Distribution of the ", num2str(Perc_list(j)), "th percentiles"))
%             xlabel(strcat("Rainfall [mm/", num2str(Acc), "h]"))
%             ylabel("Percentiles [%]")
%             xlim([0 250])
%         end
%         
%     end
   
    % Saving the plot 
    FileOUT_eps = strcat(DirOUT_jpg, "/CDF_RainFF_EFFCI", num2str(EFFCI,'%02.f'), ".eps");
    saveas(gcf,FileOUT_eps, "epsc")
    
    % Converting the matrix to table to store the CDFs in a .csv file with
    % headings
    cdf_table = array2table([Perc',cdf], 'VariableNames', ["Percentiles",RegionName_list]);
    
    % Saving the CDF of the distribution of rainfall values associated with 
    % flash flood events as a .csv file
    FileOUT_csv = strcat(DirOUT_csv, "/CDF_RainFF_EFFCI", num2str(EFFCI,'%02.f'), ".csv");
    writetable(cdf_table, FileOUT_csv, 'Delimiter',',')
    
end