%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create_PointFR_Processed.m creates .csv files containing flood reports
% for a specific year, EFFCI threshold, and geographical region
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

% INPUT PARAMETERS
Year_list = [2019,2020];
EFFCI_list = [1,6,10];
Region_list = [1,2,3];
RegionName_list = ["Costa","Sierra","Oriente"];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Raw/EcuadorMasks/Emask_ENS.csv";
FileIN_PointFR = "Data/Raw_DoNotShare/PointFR_Mod/Ecu_FF_Hist_ECMWF_mod.csv";
DirOUT = "Data/Raw_DoNotShare/PointFR_Processed";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


disp("Creating .csv files containing flood reports for a specific year, EFFCI threshold, and geographical region")

% Reading Ecuador's mask
FileIN = strcat(Git_repo, "/", FileIN_Emask);
Emask = import_Emask(FileIN);

% FileName of the point flood reports
File_FR = strcat(Git_repo, "/", FileIN_PointFR);


% Processing point flood reports
for ind_Year = 1 : length(Year_list)
    
    % Selecting the year to consider
    Year = Year_list(ind_Year);
    disp(" ")
    disp(strcat(" - Considering flood reports for ", num2str(Year)))
    
    for ind_EFFCI = 1 : length(EFFCI_list)
        
        % Selecting the EFFCI threshold to consider
        EFFCI = EFFCI_list(ind_EFFCI);
        disp(strcat("   - Considering flood reports with EFFCI>=",num2str(EFFCI)))
        
        % Reading the point flood reports
        PointFR = import_PointFR(File_FR, Year, EFFCI);
        Region_FR = double(string(PointFR.Georegion));
        Lat_PointFR = PointFR.Y_DD;
        Lon_PointFR = PointFR.X_DD;
        
        for ind_Region = 1 : length(Region_list)
            
            % Selecting the geographical region to consider
            Region = Region_list(ind_Region);
            RegionName = RegionName_list(ind_Region);
            
            % Selecting the coordinates for the point flood reports
            % considered
            Lat_PointFR_temp = Lat_PointFR(Region_FR == Region); 
            Lon_PointFR_temp = Lon_PointFR(Region_FR == Region);
            
            % Saving the coordinates of the point flood reports considered
            FileOUT_temp = strcat(Git_repo, "/", DirOUT, "/PointFR_", num2str(Year), "_EFFCI", num2str(EFFCI,"%02.f"), "_", RegionName, ".csv");
            PointFR_table = array2table([Lat_PointFR_temp,Lon_PointFR_temp], "VariableNames", {'Lat','Lon'});
            writetable(PointFR_table,FileOUT_temp)
        end 
    
    end
    
end