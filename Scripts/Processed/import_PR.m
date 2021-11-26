function PR = import_PR(filename)

opts = delimitedTextImportOptions("NumVariables", 101);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["lat", "lon", "ecPR_P01", "ecPR_P02", "ecPR_P03", "ecPR_P04", "ecPR_P05", "ecPR_P06", "ecPR_P07", "ecPR_P08", "ecPR_P09", "ecPR_P10", "ecPR_P11", "ecPR_P12", "ecPR_P13", "ecPR_P14", "ecPR_P15", "ecPR_P16", "ecPR_P17", "ecPR_P18", "ecPR_P19", "ecPR_P20", "ecPR_P21", "ecPR_P22", "ecPR_P23", "ecPR_P24", "ecPR_P25", "ecPR_P26", "ecPR_P27", "ecPR_P28", "ecPR_P29", "ecPR_P30", "ecPR_P31", "ecPR_P32", "ecPR_P33", "ecPR_P34", "ecPR_P35", "ecPR_P36", "ecPR_P37", "ecPR_P38", "ecPR_P39", "ecPR_P40", "ecPR_P41", "ecPR_P42", "ecPR_P43", "ecPR_P44", "ecPR_P45", "ecPR_P46", "ecPR_P47", "ecPR_P48", "ecPR_P49", "ecPR_P50", "ecPR_P51", "ecPR_P52", "ecPR_P53", "ecPR_P54", "ecPR_P55", "ecPR_P56", "ecPR_P57", "ecPR_P58", "ecPR_P59", "ecPR_P60", "ecPR_P61", "ecPR_P62", "ecPR_P63", "ecPR_P64", "ecPR_P65", "ecPR_P66", "ecPR_P67", "ecPR_P68", "ecPR_P69", "ecPR_P70", "ecPR_P71", "ecPR_P72", "ecPR_P73", "ecPR_P74", "ecPR_P75", "ecPR_P76", "ecPR_P77", "ecPR_P78", "ecPR_P79", "ecPR_P80", "ecPR_P81", "ecPR_P82", "ecPR_P83", "ecPR_P84", "ecPR_P85", "ecPR_P86", "ecPR_P87", "ecPR_P88", "ecPR_P89", "ecPR_P90", "ecPR_P91", "ecPR_P92", "ecPR_P93", "ecPR_P94", "ecPR_P95", "ecPR_P96", "ecPR_P97", "ecPR_P98", "ecPR_P99"];
opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
PR = readtable(filename, opts);

%% Convert to output type
PR = table2array(PR);
end