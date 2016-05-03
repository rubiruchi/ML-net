#!/bin/bash

set -e

if [ ! -z "$EXP_DIR" ]
then
    echo Running automatic analysis with $EXP_DIR
else
    echo Experiment directory \(EXP_DIR env var\) is not set
    exit 1
fi

ANALYSIS_DIR=$EXP_DIR/auto_analysis
mkdir -p $ANALYSIS_DIR
~/ML-net/decode.py -i $EXP_DIR -o $ANALYSIS_DIR &> $ANALYSIS_DIR/decode.log
for csv in `ls $ANALYSIS_DIR/*.csv` ; do
    echo Running SVM analysis for $csv 
    CHECK=`~/ML-net/check_result.sh $csv`
    echo $CHECK
    if [[  $(echo $CHECK | grep -c "Overload=0") -gt 0 ]]
    then
      echo Skipping this file\'s ML analysis - no overloaded samples
    else
      python ~/ML-net/auto_switch_svm.py -i $csv --write-each-class-results &> $csv.result 
    fi
done

echo The analysis files can be found in $ANALYSIS_DIR
