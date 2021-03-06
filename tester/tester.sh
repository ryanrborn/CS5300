#!/bin/bash

on_die()
{
  echo
  exit 0;
}

cd `dirname "$0"`

TESTDIR=TestFiles/ #test files directory (where all test.cpsl files are)
RESULTS=Result/ #results folder (where to store cpsl run results for comparison)
BASE=Base/ #base folder name (contains results to compare against)

CPSLDIR=../../source/ #where cpsl compiler binary lives
BINARY=cpsl #binary name
ASM=asm/ #tmp directory for asm files for mars to run
OUTFILE=output.asm #output file produced by cpsl

MARSDIR=../../mars/
MARSJAR=Mars4_4.jar

if [ -z $1 ]; then
  pushd . >> /dev/null
  cd ${TESTDIR}
  files=`ls *.cpsl`
  popd >>/dev/null
else
  files=$1
fi

#create these directories if they don't exist already
mkdir -p $ASM $RESULTS

trap on_die SIGINT
trap on_die TERM

for file in $files; do

    if [[ ! -f ${TESTDIR}${file} ]]; then
        echo "File '${file}' not found"
        continue
    fi

    ${CPSLDIR}${BINARY} ${TESTDIR}${file}
    mv ${OUTFILE} ${ASM}${file}

    if [ $? -ne 0 ]; then
        echo "Error running: ${CPSLDIR}${BINARY} ${TESTDIR}${file} > ${ASM}${file}"
        continue
    fi

    echo -n "Executing: ${file}"
    java -jar ${MARSDIR}${MARSJAR} ${ASM}${file} > ${RESULTS}${file}

    if [ $? -ne 0 ]; then
        echo "Error running: java -jar ${MARSDIR}${MARSJAR} ${ASM}${file} > ${RESULTS}${file}"
        continue
    fi
    echo "...finished"

    cmp ${RESULTS}${file} ${BASE}${file}
done
