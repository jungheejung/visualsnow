#!/bin/bash

# Base directory
VISUALSNOW_DIR="/Users/heejungj/Documents/projects_local/visualsnow_source"

# Configuration file path
#CNF="/Users/heejungj/Documents/projects_local/visualsnow/code/diagnosis/b02b0.cnf"
CNF="${FSLDIR}/etc/flirtsch/b02b0.cnf"
# Loop through subjects
# for SUB in  sub-002 sub-003; do #sub-001
SUB="sub-002"
    # echo "Processing subject: ${SUB}"

    # # Find all runs for the subject
    # RUN_FILES=$(find "${VISUALSNOW_DIR}/${SUB}/func" -type f -name "${SUB}_task-*_run-*_bold.json")

    # # Loop through each run file
    # for RUN_FILE in $RUN_FILES; do
    #     # Extract task and run information
    #     TASK=$(basename "${RUN_FILE}" | sed -E "s/.*task-([a-zA-Z0-9]+)_run-.*/\1/")
    #     RUN_NUM=$(basename "${RUN_FILE}" | sed -E "s/.*run-([0-9]+)_bold.*/\1/")
TASK="restopen"
RUN_NUM="05"
        echo "  Processing ${SUB}, task-${TASK}, run-${RUN_NUM}..."

        # Define file paths
        FMRIPREPEPI="${VISUALSNOW_DIR}/derivatives/${SUB}/func/${SUB}_task-${TASK}_run-${RUN_NUM}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"
        EPI="${VISUALSNOW_DIR}/${SUB}/func/${SUB}_task-${TASK}_run-${RUN_NUM}_bold.nii.gz"
        EPI10="${VISUALSNOW_DIR}/TST/${SUB}/func/${SUB}_task-${TASK}_run-${RUN_NUM}_bold10.nii.gz"
        SYNTH_PEPOLAR="${VISUALSNOW_DIR}/TST/${SUB}/func/${SUB}_task-${TASK}_run-${RUN_NUM}_synthfmap.nii.gz"
        PEPOLAR="${VISUALSNOW_DIR}/${SUB}/fmap/${SUB}_dir-pa_run-${RUN_NUM}_epi.nii.gz"
        OUTPUT_PEPOLAR="${VISUALSNOW_DIR}/TST/${SUB}/fmap/${SUB}_dir-pa_run-${RUN_NUM}_fmap.nii.gz"
        OUTPUT_TOPUP="${VISUALSNOW_DIR}/TST/${SUB}/fmap/${SUB}_run-${RUN_NUM}_TOPUP"
        EPI_TOPUP="${VISUALSNOW_DIR}/TST/${SUB}/${SUB}_task-${TASK}_run-${RUN_NUM}_boldcorrected.nii.gz"
        ACQPARAMS="${VISUALSNOW_DIR}/acqparams_per_run/${SUB}/${SUB}_run-${RUN_NUM}_acqparams.txt"

        # Ensure output directories exist
        mkdir -p "$(dirname ${OUTPUT_PEPOLAR})"
        mkdir -p "$(dirname ${OUTPUT_TOPUP})"
        mkdir -p "$(dirname ${EPI_TOPUP})"
        mkdir -p "$(dirname ${SYNTH_PEPOLAR})"
        mkdir -p "$(dirname ${EPI10})"
        fslroi ${EPI} ${EPI10} 20 10
        fslmerge -t ${SYNTH_PEPOLAR} ${PEPOLAR} ${EPI10}
# means that data will be subsampled by a factor of 4
#  and the transform will be calculated at that level. 
# It will the be subsampled by a factor of 2 (i.e. an upsampling compared to the previous step) 
# and the warps will be estimated at that scale, with the warps from the first scale as a starting estimate. 
# And finally this will be repeated at the full resolution (i.e. subsampling 1).

              
        # Run topup
        topup --imain=${SYNTH_PEPOLAR} \
              --datain=${ACQPARAMS} \
              --config=${CNF} \
              --out=${OUTPUT_TOPUP} \
              --fout=${VISUALSNOW_DIR}/TST/${SUB}/offresonance_task-${TASK}_run-${RUN_NUM}.nii.gz \
              --iout=${VISUALSNOW_DIR}/TST/${SUB}/unwarped_images_task-${TASK}_run-${RUN_NUM}.nii.gz 
            #   --subsamp=2,1
        # Apply topup
        # applytopup --imain=${EPI} \
        #            --topup=${OUTPUT_TOPUP} \
        #            --datain=${ACQPARAMS} \
        #            --method=jac \
        #            --out=${EPI_TOPUP} \
        #            --inindex=1 #,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
                #    --regmod=membrane_energy
applytopup --imain=${EPI} \
           --topup=${OUTPUT_TOPUP} \
           --datain=${ACQPARAMS} \
           --inindex=12 --method=jac \
           --out=${EPI_TOPUP}
# (fill in dynamically generated indices)

# applytopup --imain=${EPI} \
#            --topup=${OUTPUT_TOPUP} \
#            --datain=${ACQPARAMS} \
#            --inindex=1,11 \
#            --method=jac \
#            --out=${EPI_TOPUP}
        echo "  Finished processing task-${TASK}, run-${RUN_NUM} for ${SUB}"
#     done
# done

echo "All subjects, tasks, and runs processed!"
