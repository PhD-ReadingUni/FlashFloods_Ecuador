% import_GridAccFR imports in .mat format the flood reports accumulated over a
% considered accumulation period
%
% Inputs
% FileName (string): name of the file that contains the accumulated flood
%                    reports in .csv format
% 
% Outputs
% FR (mat): accumulated flood reports in .mat format
%           FR = matrix(NumGP,2+1)
%           NumGP: number of grid points in the considered domain
%           The first two columns of FR indicate the latitute and the
%           longitude of the grid points in the considered domain. The
%           third column contains 1s and 0s depending on whether, 
%           respectively, at least one flood report was recorded or not in 
%           the grid-box for the considered accumulation period.

function FR = import_AccFR(FileName)

opts = delimitedTextImportOptions("NumVariables", 3);
opts.DataLines = [2, Inf];
opts.Delimiter = ",";
opts.VariableNames = ["lat", "lon", "AccFR_code"];
opts.VariableTypes = ["double", "double", "double"];
opts.ExtraColumnsRule = "ignore";
opts.EmptyLineRule = "read";
FR = readtable(FileName, opts);
FR = table2array(FR);