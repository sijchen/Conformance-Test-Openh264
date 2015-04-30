#!/bin/bash
#***************************************************************************************
# brief:
#      --generate SGE job file based on SGE template
#      --usage: run_GenerateSGEJobFile.sh  $TestSequenceDir  $TestYUVName $YUVIndex "
#
#
#date:  04/30/2015 Created
#***************************************************************************************


runPrepareSGEJobFile()
{
	if [ ! $# -eq 2 ]
	then
        echo "usage: runPrepareSGEJobFile \$SubCaseIndex     \$SubCaseFile"
		return 1
	fi

    SubCaseIndex=$1
    SubCaseFile=$2


    let "SGEQueueIndex = SGEJobNum % 3"

	SGEQueue="Openh264SGE_${SGEQueueIndex}"
	SGEName="${TestYUVName}_SGE_Test_SubCaseIndex_${SubCaseIndex}"
	SGEModelFile="${CurrentDir}/${ScriptFolder}/SGEModel.sge"
	SGEJobFile="${TestSequenceDir}/${TestYUVName}_SubCaseIndex_${SubCaseIndex}.sge"
	SGEJobScript="run_TestOneYUVWithAssignedCases.sh"
	
	echo ""
	echo -e "\033[32m creating SGE job file : ${SGEJobFile} ......\033[0m"
	echo ""
	
	echo "">${SGEJobFile}
	while read line
	do
		
		if [[ $line =~ ^"#$ -q"  ]]
		then
			echo "#$ -q ${SGEQueue}  # Select the queue">>${SGEJobFile}
		elif [[ $line =~ ^"#$ -N"  ]]
		then
			echo "#$ -N ${SGEName} # The name of job">>${SGEJobFile}
		elif [[ $line =~ ^"#$ -wd"  ]]
		then
			echo "#$ -wd ${TestSequenceDir}">>${SGEJobFile}
		else
			echo $line >>${SGEJobFile}
		fi
	
	done <${SGEModelFile}
	
	echo "${TestSequenceDir}/${SGEJobScript}  SGETest  ${TestYUVName}  ${FinalResultDir}  ${ConfigureFile} ${SubCaseIndex} ${SubCaseFile} ">>${SGEJobFile}

	return 0
}

runGenerateSGEJobFileForOneYUV()
{

    for vSubCaseFile in ${TestSequenceDir}/${TestYUVName}_SubCases_*.csv
    do
        let "SubCaseIndex ++"
        let "SGEJobNum ++"
        runPrepareSGEJobFile ${SubCaseIndex} ${vSubCaseFile}
    done

    return 0
}


runMain()
{
    if [ ! $# -eq 3 ]
    then
        echo "usage: run_GenerateSGEJobFile.sh  \$TestSequenceDir  \$TestYUVName \$YUVIndex "
        return 1
    fi

    TestSequenceDir=$1
    TestYUVName=$2
    YUVIndex=$3

    ScriptFolder="Scripts"

    let "SubCaseIndex = 0"
    CurrentDir=`pwd`

    if [ -d ${TestSequenceDir} ]
    then
        cd ${TestSequenceDir}
        TestSequenceDir=`pwd`
        cd ${CurrentDir}
    else
        echo -e "\033[31m Job folder does not exist! Please double check! \033[0m"
        exit 1
    fi

    runGenerateSGEJobFileForOneYUV

    return $?

}
TestSequenceDir=$1
TestYUVName=$2
YUVIndex=$3
runMain ${TestSequenceDir} ${TestYUVName} ${YUVIndex}
