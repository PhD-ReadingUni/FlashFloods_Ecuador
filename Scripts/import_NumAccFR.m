function NumAccFR = import_NumAccFR(FileName)

dataLines = [2, Inf];
opts = delimitedTextImportOptions("NumVariables", 2);
opts.DataLines = dataLines;
opts.Delimiter = ",";
opts.VariableNames = ["UTC", "VarName2"];
opts.VariableTypes = ["char", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
opts.ConsecutiveDelimitersRule = "join";
opts = setvaropts(opts, "UTC", "WhitespaceRule", "preserve");
opts = setvaropts(opts, "UTC", "EmptyFieldRule", "auto");
opts = setvaropts(opts, "VarName2", "ThousandsSeparator", ",");
NumAccFR = readtable(FileName, opts);

NumAccFR = table2cell(NumAccFR);
numIdx = cellfun(@(x) ~isnan(str2double(x)), NumAccFR);
NumAccFR(numIdx) = cellfun(@(x) {str2double(x)}, NumAccFR(numIdx));

