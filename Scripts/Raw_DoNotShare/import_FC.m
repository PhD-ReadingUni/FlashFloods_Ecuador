% import_FC imports in .mat format ENS or ecPoint rainfall forecasts that 
% are stored in .csv format.
%
% Inputs
% FileName (string): name of the file that contains the ENS or ecPoint  
%                    rainfall forecasts in .csv format
% SystemFC (string): name of the forecasting system to consider
%                    Valid values are "ENS" or "ecPoint"
% 
% Outputs
% FC (mat): ENS or ecPoint rainfall forecasts in .mat format
%           FC = matrix(NumGP,2+NumEM)
%           NumGP: number of grid points in the considered domain
%           NumENS: number of ensemble members in ENS(=51) or ecPoint (=99)
%           The first two columns of FC indicate the latitute and the
%           longitude of the grid points in the considered domain.


function FC = import_FC(FileName,SystemFC)

if strcmp(SystemFC,"ENS")
    
    opts = delimitedTextImportOptions("NumVariables", 53);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["lat", "lon", "ENS01", "ENS02", "ENS03", "ENS04", "ENS05", "ENS06", "ENS07", "ENS08", "ENS09", "ENS10", "ENS11", "ENS12", "ENS13", "ENS14", "ENS15", "ENS16", "ENS17", "ENS18", "ENS19", "ENS20", "ENS21", "ENS22", "ENS23", "ENS24", "ENS25", "ENS26", "ENS27", "ENS28", "ENS29", "ENS30", "ENS31", "ENS32", "ENS33", "ENS34", "ENS35", "ENS36", "ENS37", "ENS38", "ENS39", "ENS40", "ENS41", "ENS42", "ENS43", "ENS44", "ENS45", "ENS46", "ENS47", "ENS48", "ENS49", "ENS50", "ENS51"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    FC = readtable(FileName, opts);
    FC = table2array(FC);
    
elseif strcmp(SystemFC,"ecPoint")
    
    opts = delimitedTextImportOptions("NumVariables", 101);
    opts.DataLines = [2, Inf];
    opts.Delimiter = ",";
    opts.VariableNames = ["lat", "lon", "ecPoint_P01", "ecPoint_P02", "ecPoint_P03", "ecPoint_P04", "ecPoint_P05", "ecPoint_P06", "ecPoint_P07", "ecPoint_P08", "ecPoint_P09", "ecPoint_P10", "ecPoint_P11", "ecPoint_P12", "ecPoint_P13", "ecPoint_P14", "ecPoint_P15", "ecPoint_P16", "ecPoint_P17", "ecPoint_P18", "ecPoint_P19", "ecPoint_P20", "ecPoint_P21", "ecPoint_P22", "ecPoint_P23", "ecPoint_P24", "ecPoint_P25", "ecPoint_P26", "ecPoint_P27", "ecPoint_P28", "ecPoint_P29", "ecPoint_P30", "ecPoint_P31", "ecPoint_P32", "ecPoint_P33", "ecPoint_P34", "ecPoint_P35", "ecPoint_P36", "ecPoint_P37", "ecPoint_P38", "ecPoint_P39", "ecPoint_P40", "ecPoint_P41", "ecPoint_P42", "ecPoint_P43", "ecPoint_P44", "ecPoint_P45", "ecPoint_P46", "ecPoint_P47", "ecPoint_P48", "ecPoint_P49", "ecPoint_P50", "ecPoint_P51", "ecPoint_P52", "ecPoint_P53", "ecPoint_P54", "ecPoint_P55", "ecPoint_P56", "ecPoint_P57", "ecPoint_P58", "ecPoint_P59", "ecPoint_P60", "ecPoint_P61", "ecPoint_P62", "ecPoint_P63", "ecPoint_P64", "ecPoint_P65", "ecPoint_P66", "ecPoint_P67", "ecPoint_P68", "ecPoint_P69", "ecPoint_P70", "ecPoint_P71", "ecPoint_P72", "ecPoint_P73", "ecPoint_P74", "ecPoint_P75", "ecPoint_P76", "ecPoint_P77", "ecPoint_P78", "ecPoint_P79", "ecPoint_P80", "ecPoint_P81", "ecPoint_P82", "ecPoint_P83", "ecPoint_P84", "ecPoint_P85", "ecPoint_P86", "ecPoint_P87", "ecPoint_P88", "ecPoint_P89", "ecPoint_P90", "ecPoint_P91", "ecPoint_P92", "ecPoint_P93", "ecPoint_P94", "ecPoint_P95", "ecPoint_P96", "ecPoint_P97", "ecPoint_P98", "ecPoint_P99"];
    opts.VariableTypes = ["double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double", "double"];
    opts.ExtraColumnsRule = "ignore";
    opts.EmptyLineRule = "read";
    FC = readtable(FileName, opts);
    FC = table2array(FC);
    
end