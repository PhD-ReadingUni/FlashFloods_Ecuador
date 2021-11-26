%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Importing flash flood reports and creating single files per year %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

% INPUT PARAMETERS
YearS = 2019;
YearF = 2020;
EFFCI2Extract = [1,6,10];
Var2Extract = {'X_DD', 'Y_DD', 'Georegion', 'Hora', 'month', 'day', 'year','FFCI','FFSI','EFFCI'};
Regions2Extract = ["La Costa", "La Sierra", "El Oriente"];
RegionsNames = ["Costa","Sierra","Oriente"];
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN = "Data/Processed/ObsFF_RawMod/Ecu_FF_Hist_ECMWF_mod.csv";
DirOUT = "Data/Processed/ObsFF_Regions";
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Importing the raw flash floods
FileIN = strcat(Git_repo, "/", FileIN);
opts = delimitedTextImportOptions("NumVariables", 47);
opts.DataLines = [3, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["ID", "Source", "ADMN1_ES", "ADM1_PCODE", "ADM2_ES", "ADM2_PCODE", "ADM3_ES", "ADM3_PCODE", "Location", "X_DD", "Y_DD", "Georegion", "Date", "Hora", "month", "day", "year", "FactorInvolved", "FlashFloodIdentifiers", "HeavyPrecipitation", "ShortDurationRain", "ArtificialWaterwayOverflow", "SmallStreamOverflow", "SurfaceRunoff", "Urban", "Slope", "RiverBankFailure", "StrongCurrent", "ShortFlood", "Deaths", "Injured", "Missing", "Houses_Destroyed", "Houses_Damaged", "Household_Affected", "Directly_Affected", "Indirectly_Affected", "Relocated", "Evacuated", "Ha_crops_affected", "Ha_crop_lost", "FFCI", "FFSI", "EFFCI", "Estim_affected", "Estim_household", "Impact_severity"];
opts.VariableTypes = ["double", "categorical", "categorical", "double", "categorical", "double", "categorical", "double", "string", "double", "double", "categorical", "datetime", "datetime", "double", "double", "double", "categorical", "categorical", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "string", "string", "string", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts = setvaropts(opts, ["Location", "Injured", "Missing", "Houses_Destroyed"], "WhitespaceRule", "preserve");
opts = setvaropts(opts, ["Source", "ADMN1_ES", "ADM2_ES", "ADM3_ES", "Location", "Georegion", "FactorInvolved", "FlashFloodIdentifiers", "Injured", "Missing", "Houses_Destroyed"], "EmptyFieldRule", "auto");
opts = setvaropts(opts, "Date", "InputFormat", "MM/dd/yy");
opts = setvaropts(opts, "Hora", "InputFormat", "HH:mm:ss");
opts = setvaropts(opts, ["ADM1_PCODE", "ADM2_PCODE", "ADM3_PCODE"], "TrimNonNumeric", true);
opts = setvaropts(opts, ["ADM1_PCODE", "ADM2_PCODE", "ADM3_PCODE"], "ThousandsSeparator", ",");
FF_temp = readtable(FileIN, opts);

% Cleaning rows with NaN values
FF_temp(isnan(FF_temp.ID),:) = []; 

% Post-processing the raw flash flood reports
for Year = YearS : YearF
    
    disp(strcat("Post-processing flash flood reports for ", num2str(Year)))
    
    FF = FF_temp;
    
    % Extracting the reports for a year
    FF_temp1 = FF(FF.year==Year,:);
    
    % Extracting some attributes of the table
    FF = FF_temp1(:,Var2Extract);
    disp(strcat("N. of flash flood reports: ", num2str(height(FF))))
    
    % Eliminating the flash flood reports with no event time included
    FF(isnat(FF.Hora),:) = [];   
    disp(strcat("N. of flash flood reports with event time: ", num2str(height(FF))))
    
    % Selecting some EFFCI thresholds
    for indEFFCI = 1 : length(EFFCI2Extract)
        
        EFFCI = EFFCI2Extract(indEFFCI);
        FF_EFFCI = FF(FF.EFFCI>=EFFCI,:);
    
        % Saving the table as .csv file
        FileOUT = strcat(Git_repo, "/", DirOUT, "/ObsFF_", num2str(Year), "_EFFCI", num2str(EFFCI,'%02.f'), "_1Region.csv");
        writetable(FF_EFFCI, FileOUT, 'Delimiter',',')
    
        % Selecting some regions
        for indReg = 1 : length(Regions2Extract)
            
            Region = Regions2Extract(indReg);
            RegionName = RegionsNames(indReg);
            FF_reg = FF_EFFCI(FF_EFFCI.Georegion==Region,:);
            
            % Saving the table as .csv file
            FileOUT = strcat(Git_repo, "/", DirOUT, "/ObsFF_", num2str(Year), "_EFFCI", num2str(EFFCI,'%02.f'), "_", RegionName, ".csv");
            writetable(FF_reg, FileOUT, 'Delimiter',',')
            
        end
        
    end
        
end