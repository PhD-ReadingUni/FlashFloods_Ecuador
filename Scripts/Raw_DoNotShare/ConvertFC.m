% clear
% clc
% 
% SystemFC_list = ["ENS", "ecPoint"];
% DirIN = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador/Data/Raw/FC_Emask_Rainfall_012";
% 
% for TheDate = datenum("2019-01-01") : datenum("2019-12-31")
%     
%     disp(datestr(TheDate))
%     
%     for TheTime = 0 : 12 : 12
%         
%         for TheStepF = 12 : 6: 30
%             
%             for indFC = 1 : length(SystemFC_list)
%                 
%                 SystemFC = SystemFC_list(indFC);
%             
%                 FileIN = strcat(DirIN, "/", SystemFC, "/", datestr(TheDate, "yyyymmdd"), num2str(TheTime,"%02.f"), "/tp_012_", datestr(TheDate, "yyyymmdd"), "_", num2str(TheTime,"%02.f"), "_", num2str(TheStepF,"%03.f"), ".csv");
%                 
%                 if isfile(FileIN)
%                     FC = import_FC(FileIN,SystemFC);
%                     FileOUT = strcat(DirIN, "/", SystemFC, "/", datestr(TheDate, "yyyymmdd"), num2str(TheTime,"%02.f"), "/tp_012_", datestr(TheDate, "yyyymmdd"), "_", num2str(TheTime,"%02.f"), "_", num2str(TheStepF,"%03.f"), ".mat");
%                     save(FileOUT, "FC", "-v6")
%                 end
%             
%             end
%             
%         end
%         
%     end
%     
% end
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear 
% clc
% 
% SystemFC_list = ["ENS", "ecPoint"];
% DirIN = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador/Data/Raw/FC_Emask_Rainfall_012";
% 
% for TheDate = datenum("2020-01-01") : datenum("2020-12-31")
%     
%     disp(datestr(TheDate))
%     
%     for TheTime = 0 : 12 : 12
%         
%         for TheStepF = 12 : 6: 246
%             
%             for indFC = 1 : length(SystemFC_list)
%                 
%                 SystemFC = SystemFC_list(indFC);
%             
%                 FileIN = strcat(DirIN, "/", SystemFC, "/", datestr(TheDate, "yyyymmdd"), num2str(TheTime,"%02.f"), "/tp_012_", datestr(TheDate, "yyyymmdd"), "_", num2str(TheTime,"%02.f"), "_", num2str(TheStepF,"%03.f"), ".csv");
%                 
%                 if isfile(FileIN)
%                     FC = import_FC(FileIN,SystemFC);
%                     FileOUT = strcat(DirIN, "/", SystemFC, "/", datestr(TheDate, "yyyymmdd"), num2str(TheTime,"%02.f"), "/tp_012_", datestr(TheDate, "yyyymmdd"), "_", num2str(TheTime,"%02.f"), "_", num2str(TheStepF,"%03.f"), ".mat");
%                     save(FileOUT, "FC", "-v6")
%                 end
%                 
%             end
%             
%         end
%         
%     end
%     
% end
% 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear
clc

EFFCI_list = [1,6,10];
DirIN = "/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador/Data/Raw/GridAccFR_012";

for TheDate = datenum("2020-01-01") : datenum("2020-12-31")
    
    disp(datestr(TheDate))
    
    for indEFFCI = 1 : length(EFFCI_list)
        
        EFFCI = EFFCI_list(indEFFCI);
        
        for EndPer = 0 : 6 : 18
        
            FileIN = strcat(DirIN, "/EFFCI", num2str(EFFCI,"%02.f"),"/GridAccFR_", datestr(TheDate, "yyyymmdd"), "_", num2str(EndPer,"%02.f"), ".csv");
            
            if isfile(FileIN)
                FR = import_GridAccFR(FileIN);
                FileOUT = strcat(DirIN, "/EFFCI", num2str(EFFCI,"%02.f"),"/GridAccFR_", datestr(TheDate, "yyyymmdd"), "_", num2str(EndPer,"%02.f"), ".mat");
                save(FileOUT, "FR", "-v6")
            end
            
        end
        
    end
    
end