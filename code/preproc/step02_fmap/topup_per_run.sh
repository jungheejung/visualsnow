#!/bin/bash

# Base directory
VISUALSNOW_DIR="/Users/heejungj/Documents/projects_local/visualsnow_source"

# Configuration file path
#CNF="/Users/heejungj/Documents/projects_local/visualsnow/code/diagnosis/b02b0.cnf"
CNF="${FSLDIR}/etc/flirtsch/b02b0.cnf"
# Loop through subjects
for SUB in sub-001 sub-002 sub-003; do #sub-001
    echo "Processing subject: ${SUB}"

    # Find all runs for the subject
    RUN_FILES=$(find "${VISUALSNOW_DIR}/${SUB}/func" -type f -name "${SUB}_task-*_run-*_bold.json")

    # Loop through each run file
    for RUN_FILE in $RUN_FILES; do
        # Extract task and run information
        TASK=$(basename "${RUN_FILE}" | sed -E "s/.*task-([a-zA-Z0-9]+)_run-.*/\1/")
        RUN_NUM=$(basename "${RUN_FILE}" | sed -E "s/.*run-([0-9]+)_bold.*/\1/")

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
        # Extract 10 slices from the EPI to capture bi-polar directions in the fieldmap. 
        # NOTE: the PEpolar maps only include uni-directional phase encoding, which is opposite to the phase encoding direction used in the EPI maps
        fslroi ${EPI} ${EPI10} 20 10
        fslmerge -t ${SYNTH_PEPOLAR} ${PEPOLAR} ${EPI10}

        # Run topup
        topup --imain=${SYNTH_PEPOLAR} \
              --datain=${ACQPARAMS} \
              --config=${CNF} \
              --out=${OUTPUT_TOPUP} \
              --fout=${VISUALSNOW_DIR}/TST/${SUB}/offresonance_task-${TASK}_run-${RUN_NUM}.nii.gz \
              --iout=${VISUALSNOW_DIR}/TST/${SUB}/unwarped_images_task-${TASK}_run-${RUN_NUM}.nii.gz

        # Apply topup
        # applytopup --imain=${EPI} \
        #            --topup=${OUTPUT_TOPUP} \
        #            --datain=${ACQPARAMS} \
        #            --inindex=1 \
        #            --method=jac \
        #            --out=${EPI_TOPUP}
        # index 12 points to the to the EPI direction
        # I manually created 20 scans with 10 in the topup direction P >> A; 10 in the EPI direction A >> P
        applytopup --imain=${EPI} \
                --topup=${OUTPUT_TOPUP} \
                --datain=${ACQPARAMS} \
                --inindex=12 --method=jac \
                --out=${EPI_TOPUP}

        echo "  Finished processing task-${TASK}, run-${RUN_NUM} for ${SUB}"
    done
done

echo "All subjects, tasks, and runs processed!"
