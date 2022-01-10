function CT_BS = import_CT_BS(filename,NameVar,BS)

opts = delimitedTextImportOptions("NumVariables", 1001);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";

VariableNames = [];
VariableTypes = [];
for i = 1 : (BS+1)
    temp = strcat(NameVar,num2str(i));
    VariableNames = [VariableNames,temp];
    VariableTypes = [VariableTypes, "double"];
end
opts.VariableNames = VariableNames;
opts.VariableTypes = VariableTypes;

opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
CT_BS = readtable(filename, opts);
CT_BS = table2array(CT_BS);

end