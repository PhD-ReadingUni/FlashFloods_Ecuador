clear
clc

% INPUT PARAMETERS
Year = 2019;
Region_list = [1,2];
RegionName_list = ["La Costa", "La Sierra"];
RegionPlot_list = ["b-","r-"];
Acc = 12;
Percs = (1:99)';
Perc_list = [75,85,90,95,98,99];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Processed/EcuadorMasks/Emask_ENS.csv";
DirIN_FC = "Data/Processed/FC_Emask_Rainfall_";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Importing Ecuador's mask
FileIN_Emask = strcat(Git_repo, "/", FileIN_Emask);
Emask = import_Emask(FileIN_Emask);

for indRegion = 1 : length(Region_list)
    
    % Selecting the region to consider
    Region = Region_list(indRegion);
    RegionName = RegionName_list(indRegion);
    RegionPlot = RegionPlot_list(indRegion);
    disp(strcat("  - Considering the '", RegionName, "' region"))
    
    % Selecting the grid-boxes belonging to the region considered
    pointer_region = find(Emask(:,3)==Region);
    
    % Initiating the variable that will store the forecasts
    FC = [];
    
    % Defining the time period to consider
    date1 = datenum(strcat(num2str(Year), "-01-01"));
    date2 = datenum(strcat(num2str(Year), "-12-31"));
    cdf_day = [];
    
    for TheDate = date1 : date2
        
        disp(datestr(TheDate))
        
        % Initialize the variable that will store the daily forecast values
        FC_Day = [];
        
        % Selecting forecasts to consider for the accumulation period
        % between 00-12 UTC
        FileIN_FC00 = strcat(Git_repo, "/", DirIN_FC, num2str(Acc), "h/ecPoint/", datestr(TheDate, "yyyymmdd"), "00/tp_", num2str(Acc,'%03d'), "_", datestr(TheDate, "yyyymmdd"), "_00_012.csv");
        if isfile(FileIN_FC00)
            FC00 = import_ecPoint(FileIN_FC00);
            FC = [FC; FC00(pointer_region,3:end)];
        end
        
        FileIN_FC12 = strcat(Git_repo, "/", DirIN_FC, num2str(Acc), "h/ecPoint/", datestr((TheDate-1), "yyyymmdd"), "12/tp_", num2str(Acc,'%03d'), "_", datestr((TheDate-1), "yyyymmdd"), "_12_024.csv");
        if isfile(FileIN_FC12)
            FC12 = import_ecPoint(FileIN_FC12);
            FC = [FC; FC12(pointer_region,3:end)];
        end
        
        % Selecting forecasts to consider for the accumulation period
        % between 12-00 UTC
        FileIN_FC00 = strcat(Git_repo, "/", DirIN_FC, num2str(Acc), "h/ecPoint/", datestr(TheDate, "yyyymmdd"), "00/tp_", num2str(Acc,'%03d'), "_", datestr(TheDate, "yyyymmdd"), "_00_024.csv");
        if isfile(FileIN_FC00)
            FC00 = import_ecPoint(FileIN_FC00);
            FC = [FC; FC00(pointer_region,3:end)];
        end
        
        FileIN_FC12 = strcat(Git_repo, "/", DirIN_FC, num2str(Acc), "h/ecPoint/", datestr((TheDate-1), "yyyymmdd"), "12/tp_", num2str(Acc,'%03d'), "_", datestr((TheDate-1), "yyyymmdd"), "_12_036.csv");
        if isfile(FileIN_FC12)
            FC12 = import_ecPoint(FileIN_FC12);
            FC = [FC; FC12(pointer_region,3:end)];
        end
        
        %Compute the distribution of daily rainfall values considered in
        %the region
        FC_day = FC(:);
        cdf_day = [cdf_day; round(prctile(FC_day,Perc_list),2)];
        
    end
    
%     % Computing the distribution of rainfall values in the considered
%     % region
%     FC = FC(:);
%     cdf = round(prctile(FC,Percs),2);
    
%     % Plot the CDF
%     plot(cdf,Percs, RegionPlot, "LineWidth", 2)
%     title(strcat("Distribution of rainfall values in ", num2str(Year)))
%     xlabel(strcat("Rainfall [mm/", num2str(Acc), "h]"))
%     ylabel("Percentiles [%]")
%     hold on

    [m,n] = size(cdf_day);
    for j = 1 : n
        figure
        temp_vals = cdf_day(:,j);
        temp_cdf = round(prctile(temp_vals,Percs),2);
        plot(temp_cdf, Percs, "LineWidth", 2)
        title(strcat("Distribution of the ", num2str(Perc_list(j)), "th percentiles for '", RegionName, "'"))
        xlabel(strcat("Rainfall [mm/", num2str(Acc), "h]"))
        ylabel("Percentiles [%]")
    end

%     % Plot the CDF of the distribution of daily rainfall values
%     figure
%     plot(cdf,Percs, RegionPlot, "LineWidth", 2)
%     title(strcat("Distribution of rainfall values in ", num2str(Year)))
%     xlabel(strcat("Rainfall [mm/", num2str(Acc), "h]"))
%     ylabel("Percentiles [%]")
%     hold on
    
end





































