function [H,FA,M,CN] = import_CT(filename)

opts = delimitedTextImportOptions("NumVariables", 4);
opts.DataLines = [1, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["H", "FA", "M", "CN"];
opts.VariableTypes = ["double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
tbl = readtable(filename, opts);

H = tbl.H;
FA = tbl.FA;
M = tbl.M;
CN = tbl.CN;

end