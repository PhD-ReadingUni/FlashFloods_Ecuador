function REV = import_REV(FileName)

opts = delimitedTextImportOptions("NumVariables", 2);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Percentiles", "Rainfall Values"];
opts.VariableTypes = ["double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
REV = readtable(FileName, opts);
REV = table2array(REV);

end