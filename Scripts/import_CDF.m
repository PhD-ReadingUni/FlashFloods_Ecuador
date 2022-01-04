function cdf = import_CDF(FileName)

opts = delimitedTextImportOptions("NumVariables", 2);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Percentiles", "RainfallValues"];
opts.VariableTypes = ["double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
cdf = readtable(FileName, opts);
cdf = table2array(cdf);

end