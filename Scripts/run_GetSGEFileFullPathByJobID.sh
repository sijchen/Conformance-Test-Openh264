#!/bin/bash



runUsage()
{
    echo ""
    echo -e "\033[32m Usage: run_GetSGEFileFullPathByJobID.sh \${SGEJobID} \033[0m"
    echo ""
    echo -e "\033[33m e.g.: run_GetSGEFileFullPathByJobID.sh 937           \033[0m"
    echo ""
}

runInit()
{
    CurrentDir=`pwd`
    TestSpace=${CurrentDir}/AllTestData
    SGEFileFullPath=""

    SGEJobSubmittedLog="${CurrentDir}/SGEJobsSubmittedInfo.log"
    SGEJobName=""
    YUVName=""
    let "JobExistFlag=0"
}

runCheck()
{
    if [ ! -d ${TestSpace} ]
    then
        echo ""
        echo -e "\033[31m Test space does not exist, please double check \033[0m"
        echo -e "\033[31m Test space dir is ${TestSpace} \033[0m"
        echo ""
        exit 1
    fi

    if [ ! -e ${SGEJobSubmittedLog} ]
    then
        echo ""
        echo -e "\033[31m job submitted log ${SGEJobSubmittedLog} does not exist, please double check \033[0m"
        echo ""
        exit 1
    fi

}

runParseJobInfo()
{
    while read line
    do
        # Your job 898 ("ScreenCaptureDocEditing_320X180_noDuplicate.yuv_SGE_Test_SubCaseIndex_0")
        if [[ "$line" =~ "${SGEJobID}"  ]]
        then
            SGEJobName=`echo $line | awk 'BEGIN {FS="[()]"} {print $2}'`
            let "JobExistFlag=1"
            break
        fi
    done<${SGEJobSubmittedLog}

}

runGenerateSGEFileFullPath()
{
    if [  ${JobExistFlag} -eq 1 ]
    then
        YUVName=`echo ${SGEJobName}  awk 'BEGINE {FS=".yuv"} {print $1}' `
        YUVName=${YUVName}.yuv
        SGEFileFullPath=${TestSpace}/${YUVName}/${SGEJobName}.sge
    else
        SGEFileFullPath=""
    fi

}

runOutputSGEJobFileInfo()
{
    if [ ${JobExistFlag} -eq 1 ]
    then
        if [ -e ${SGEFileFullPath} ]
        then
            echo ${SGEFileFullPath}
        else
            echo ""
            echo -e "\033[31m SGE job file ${SGEFileFullPath} does not exist, please double check \033[0m"
            echo ""
        fi
    else
        echo ""
        echo -e "\033[31m job ID ${SGEJobID} does not in the submitted log file, please double check \033[0m"
        echo -e "\033[31m The submitted log file is ${SGEJobSubmittedLog} \033[0m"
        echo ""
    fi
}


runMai()
{
    runInit
    runCheck
    runParseJobInfo
    runGenerateSGEFileFullPath
    runOutputSGEJobFileInfo

}


if [ ! $# -eq 1 ]
then
    runUsage
    exit 1
fi
SGEJobID=$1
runMain

