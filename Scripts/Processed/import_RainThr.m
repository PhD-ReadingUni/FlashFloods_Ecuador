function [Percentile,Value] = import_RainThr(filename)

opts = delimitedTextImportOptions("NumVariables", 2);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["Percentile", "Value"];
opts.VariableTypes = ["double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
tbl = readtable(filename, opts);

Percentile = tbl.Percentile;
Value = tbl.Value;

end