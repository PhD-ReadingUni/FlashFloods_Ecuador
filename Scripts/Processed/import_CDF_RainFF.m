function cdf = import_CDF_RainFF(filename)

opts = delimitedTextImportOptions("NumVariables", 3);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Percentiles", "CDF_LaCosta", "CDF_LaSierra"];
opts.VariableTypes = ["double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
cdf = readtable(filename, opts);
cdf = table2array(cdf);

end