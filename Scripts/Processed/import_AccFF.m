function FF = import_AccFF(filename)

opts = delimitedTextImportOptions("NumVariables", 3);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["lat", "lon", "AccFF_code"];
opts.VariableTypes = ["double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
FF = readtable(filename, opts);
FF = table2array(FF);
end