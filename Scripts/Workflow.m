%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                         %
%       FLASH FLOOD VERIFICATION FOR ECUADOR USING ECPOINT-RAINFALL       %
%                                                                         %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% DESCRIPTION INPUT PARAMETERS 

% FORECASTING SYSTEMS FEATURES
% SystemFC_list: list of forecasting systems considered for verification
% NumEM_list: number of ensemble members in each forecasting system
%             considered for verification
% Acc: verified rainfall accumulation period

% FLOOD REPORTS FEATURES
% EFFCI_list: list of EFFCI indexes considered for verification

% FEATURES OF FORECASTS USED TO CREATE POINT-BASED RAINFALL THRESHOLDS TO
% DEFINE VERIFICATION EVENTS
% Year_RT: year considered for the development of 







% Forecasting systems to verify
SystemFC_list = ["ENS","ecPoint"];
NumEM_list = [51,99];
Acc = 12;

% EFFCI index for flood reports
EFFCI_list = [1,6,10];





% Analysis period for the creation of point-based rainfall thresholds for
% verification
Year_RT = 2019;
StepF_Start_RT = 12;
StepF_End_RT = 30;

% Verification period
Year_V = 2020;
StepF_Start_V = 12;
StepF_End_V = 234;
DiscStep = 6;


% Main directory and file system
Git_repo = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador";
FileIN_Emask = "Data/Processed/EcuadorMasks/Emask_ENS.csv";
DirIN_CDF = "Data/Processed/RainCDF_";
DirIN_FC = "Data/Processed/FC_Emask_Rainfall_";
DirIN_FF = "Data/Processed/AccFF_";
DirOUT = "Data/Processed/CT_";


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking forecasts used in the analysis %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Forecasts used for the development of point-based rainfall thresholds


