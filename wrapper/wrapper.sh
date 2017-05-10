#!/bin/bash

function debug {
  echo "creating debugging directory"
mkdir .debug
for word in ${rmthis}
  do
    if [[ "${word}" == *.sh ]] || [[ "${word}" == lib ]]
      then
        mv "${word}" .debug;
      fi
  done
}

rmthis=`ls`
echo ${rmthis}

ARGSU=" ${quality_trimming} ${3only} ${pass} ${always_quality} ${max5error} ${max3error} ${minimal_length} ${5range} ${3range} ${window_size} ${average_quality} ${5trim} ${case_sensitive} ${check_fastq} ${phred_offset} ${barcode} ${failed_reads} ${3first} "
SEQUENCEFILEU="${sequence_file}"
PATTERNFILEU="${pattern_file}"
INPUTSU="${SEQUENCEFILEU}, ${PATTERNFILEU} "
echo "Sequence file is " "${SEQUENCEFILEU}"
echo "Pattern file, if provided, is " "${PATTERNFILEU}"
echo "Input files are " "${INPUTSU}"
echo "Arguments are " "${ARGSU}"

CMDLINEARG="btrim64 ${quality_trimming} ${3only} ${pass} ${always_quality} ${max5error} ${max3error} ${minimal_length} ${5range} ${3range} ${window_size} ${average_quality} ${5trim} ${case_sensitive} ${check_fastq} ${phred_offset} ${barcode} ${failed_reads} ${3first} "

if [ -z "${quality_trimming}" -a -z "${pattern_file}" ]
  then
    >&2 echo "Pattern file is required to remove adaptors."
    debug
    exit 1;
fi
if [ -n "${PATTERNFILEU}" ]
  then
    if [ -n "${quality_trimming}" -a -z "${always_quality}" ]
      then
        >&2 echo "WARNING: pattern file will be ignored in quality trimming mode"
      else
        CMDLINEARG+="-p ${PATTERNFILEU} "
    fi
fi

CMDLINEARG+="-t ${SEQUENCEFILEU} -o output"
OUTPUTSU="output, "
if [ -n "${failed_reads}" ]
  then
    OUTPUTSU+="failed_output"
fi
echo ${CMDLINEARG};

chmod +x launch.sh

echo  universe                = docker >> lib/condorSubmitEdit.htc
echo docker_image            =  cyverseuk/btrim:v0.0.0 >> lib/condorSubmitEdit.htc ######
echo executable               =  ./launch.sh >> lib/condorSubmitEdit.htc #####
echo arguments                          = ${CMDLINEARG} >> lib/condorSubmitEdit.htc
echo transfer_input_files = ${INPUTSU}, launch.sh >> lib/condorSubmitEdit.htc
echo transfer_output_files = ${OUTPUTSU} >> lib/condorSubmitEdit.htc
cat /mnt/data/apps/btrim/lib/condorSubmit.htc >> lib/condorSubmitEdit.htc

less lib/condorSubmitEdit.htc

jobid=`condor_submit -batch-name ${PWD##*/} lib/condorSubmitEdit.htc`
jobid=`echo $jobid | sed -e 's/Sub.*uster //'`
jobid=`echo $jobid | sed -e 's/\.//'`

#echo $jobid

#echo going to monitor job $jobid
condor_tail -f $jobid

debug

exit 0
