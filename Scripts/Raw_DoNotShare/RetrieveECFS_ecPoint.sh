# RetrieveECFS_ecPoint.sh retrieves ecPoint-Rainfall forecasts and 
# its WTs from ECFS.
# NOTE: at a later stage, include also the download of the rainfall 
# forecasts. 

# INPUT PARAMETERS
DateS=2020-01-01
DateF=2020-12-31
Git_repo="/vol/ecpoint/mofp/PhD/Papers2Write/FlashFloods_Ecuador"
DirOUT_WT="Data/Raw_DoNotShare/FC/ecPoint_WT"
DirECFS="ec:/emos/ecpoint/Oper/ecPoint_Rainfall/012/Vers1.2"
#################################################################


# Retriving forecasts from ECFS
echo "Retrieving the WTs for..."

DateS=$(date -d $DateS +%Y%m%d)
DateF=$(date -d $DateF +%Y%m%d)
TheDate=${DateS}

while [[ ${TheDate} -le ${DateF} ]]; do
    
    for Time in 0 12; do
    
        if [[ ${Time} -eq 0 ]]; then
            TheTime=0
            TheTimeSTR=0${Time}
        else
            TheTime=1200
            TheTimeSTR=${Time}
        fi
        
        echo " "
        echo " - ${TheDate}${TheTimeSTR}..."
        
        DirIN_temp="${DirECFS}/${TheDate}${TheTimeSTR}"
        DirOUT_WT_temp="${Git_repo}/${DirOUT_WT}/${TheDate}${TheTimeSTR}"
        
        mkdir -p ${DirOUT_WT_temp}
        ecp ${DirIN_temp}/WT.tar ${DirOUT_WT_temp}    
        tar -xvf "${DirOUT_WT_temp}/WT.tar"
        #mv "sc2/tcwork/emos/emos_data/log/ecpoint_oper/emos/Forecasts/Oper/ecPoint_Rainfall/012/Vers1.2/${TheDate}${TheTimeSTR}/WT/*" ${DirOUT_WT_temp}
        #rm -rf "${DirOUT_WT_temp}/WT.tar" "${DirOUT_WT_temp}/sc2"
        
    done
    
    TheDate=$(date -d"${TheDate} + 1 day" +"%Y%m%d")

done 


