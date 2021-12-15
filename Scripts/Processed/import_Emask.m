function mask = import_Emask(filename)

opts = delimitedTextImportOptions("NumVariables", 3);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["lat", "lon", "region_code"];
opts.VariableTypes = ["double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
mask = readtable(filename, opts);
mask = table2array(mask);

end