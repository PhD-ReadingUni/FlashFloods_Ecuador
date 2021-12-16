function ENS = import_ENS(filename)

opts = delimitedTextImportOptions("NumVariables", 53);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["lat", "lon", "ENS01", "ENS02", "ENS03", "ENS04", "ENS05", "ENS06", "ENS07", "ENS08", "ENS09", "ENS10", "ENS11", "ENS12", "ENS13", "ENS14", "ENS15", "ENS16", "ENS17", "ENS18", "ENS19", "ENS20", "ENS21", "ENS22", "ENS23", "ENS24", "ENS25", "ENS26", "ENS27", "ENS28", "ENS29", "ENS30", "ENS31", "ENS32", "ENS33", "ENS34", "ENS35", "ENS36", "ENS37", "ENS38", "ENS39", "ENS40", "ENS41", "ENS42", "ENS43", "ENS44", "ENS45", "ENS46", "ENS47", "ENS48", "ENS49", "ENS50", "ENS51"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
ENS = readtable(filename, opts);
ENS = table2array(ENS);

end