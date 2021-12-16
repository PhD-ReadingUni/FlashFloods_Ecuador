function [ObsFF] = import_ObsFF(filename, Year, Thr_EFFCI)

% Read the raw flash flood observations
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
ObsFF_temp = readtable(filename, opts);

% Eliminate rows with NaN
ObsFF_temp(isnan(ObsFF_temp.ID),:) = [];

% Eliminate rows with NaT
ObsFF_temp(isnat(ObsFF_temp.Hora),:) = [];

% Extract only certain variables
Var2Extract = {'X_DD', 'Y_DD', 'Georegion', 'Hora', 'month', 'day', 'year','EFFCI'};
ObsFF_temp = ObsFF_temp(:,Var2Extract);

% Convert the local times to UTC
% Ecuador's time zone is UTC-5
ObsFF_temp.Hora = ObsFF_temp.Hora + hours(5);

% Convert the Georegions to numerical codes
pointer1 = find(ObsFF_temp.Georegion == "La Costa");
pointer2 = find(ObsFF_temp.Georegion == "La Sierra");
pointer3 = find(ObsFF_temp.Georegion == "El Oriente");
ObsFF_temp.Georegion(pointer1) = "1"; 
ObsFF_temp.Georegion(pointer2) = "2"; 
ObsFF_temp.Georegion(pointer3) = "3"; 

% Add a datetime array for the flash flood reports' dates
[h,m,s] = hms(ObsFF_temp.Hora);
ObsFF_temp.DateTimeNum = datenum(ObsFF_temp.year, ObsFF_temp.month, ObsFF_temp.day,h,m,s);

% Extract observations for a specific year
ObsFF_temp = ObsFF_temp(ObsFF_temp.year==Year,:);

% Extract flash flood observations for a specific EFFCI threshold
ObsFF = ObsFF_temp(ObsFF_temp.EFFCI>=Thr_EFFCI,:);

end