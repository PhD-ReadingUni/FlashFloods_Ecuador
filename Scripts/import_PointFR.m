function PointFR = import_PointFR(filename, Year, Thr_EFFCI)

% Read the raw point flood observations
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
PointFR_temp = readtable(filename, opts);

% Eliminate rows with NaN
PointFR_temp(isnan(PointFR_temp.ID),:) = [];

% Eliminate rows with NaT
PointFR_temp(isnat(PointFR_temp.Hora),:) = [];

% Extract only certain variables
Var2Extract = {'X_DD', 'Y_DD', 'Georegion', 'Hora', 'month', 'day', 'year','EFFCI'};
PointFR_temp = PointFR_temp(:,Var2Extract);

% Convert the local times to UTC
% Ecuador's time zone is UTC-5
PointFR_temp.Hora = PointFR_temp.Hora + hours(5);

% Convert the Georegions to numerical codes
pointer1 = find(PointFR_temp.Georegion == "La Costa");
pointer2 = find(PointFR_temp.Georegion == "La Sierra");
pointer3 = find(PointFR_temp.Georegion == "El Oriente");
PointFR_temp.Georegion(pointer1) = "1"; 
PointFR_temp.Georegion(pointer2) = "2"; 
PointFR_temp.Georegion(pointer3) = "3"; 

% Add a datetime array to the flood reports' dates
[h,m,s] = hms(PointFR_temp.Hora);
PointFR_temp.DateTimeNum = datenum(PointFR_temp.year, PointFR_temp.month, PointFR_temp.day,h,m,s);

% Extract flood reports for a specific year
PointFR_temp = PointFR_temp(PointFR_temp.year==Year,:);

% Extract flood reports for a specific EFFCI threshold
PointFR = PointFR_temp(PointFR_temp.EFFCI>=Thr_EFFCI,:);

end