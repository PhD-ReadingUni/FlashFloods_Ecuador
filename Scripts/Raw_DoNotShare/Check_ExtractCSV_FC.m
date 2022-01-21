clear
clc

DateS = "2020-01-01";
DateF = "2020-12-31";
TimeS = 0;
TimeF = 12;
DiscTime =12;
StepS = 12;
StepF = 246;
DiscStep = 6;
DirIN = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador/Data/Raw/FC_Emask_Rainfall_012";
SystemFC_list = ["ENS","ecPoint"];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DateS = datenum(DateS);
DateF = datenum(DateF);

count = 1;
for indFC = 1 : length(SystemFC_list)
    
    SystemFC = SystemFC_list(indFC);
    if strcmp(SystemFC,"ENS")
        NumEM = 51;
    elseif strcmp(SystemFC,"ecPoint")
        NumEM = 99;
    end

    for TheDate = DateS : DateF
        
        TheDateSTR = datestr(TheDate, "yyyymmdd");
        
        for TheTime = TimeS : DiscTime : TimeF
            
            TheTimeSTR = num2str(TheTime, "%02.f");
            DirIN_temp = strcat(DirIN, "/", SystemFC, "/", TheDateSTR, TheTimeSTR);
            
            for TheStep = StepS : DiscStep : StepF
                
                TheStepSTR = num2str(TheStep, "%03.f");
                FileIN = strcat(DirIN_temp, "/tp_012_", TheDateSTR, "_", TheTimeSTR, "_", TheStepSTR, ".csv");
                
                if isfile(FileIN)
                    
                    FC = import_FC(FileIN,SystemFC);
                    [m,n] = size(FC);
                    if m~=1090 || n~=(NumEM+2)
                        disp(strcat("  - File not extracted correctly: ", FileIN))
                        count = count + 1;
                    end
                    
                else
                    
                    disp(strcat("File not available: ", FileIN))
                    
                end
                
            end
            
        end
        
    end
    
end

if count == 1
    disp("All file extracted correctly!")
end