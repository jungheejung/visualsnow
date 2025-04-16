#!/bin/bash

# Base directory
VISUALSNOW_DIR="/Users/heejungj/Documents/projects_local/visualsnow_source"
REALIGN_DIR="/Users/heejungj/Documents/projects_local/REALIGN"
SDC_DIR="/Users/heejungj/Documents/projects_local/SDC"
# Configuration file path
CNF="${FSLDIR}/etc/flirtsch/b02b0.cnf"
SESSION="ses-03"
# Loop through subjects
for SUB in sub-002; do 
    echo "Processing subject: ${SUB}"

    # Find all run files for the subject and process them one by one
    find "${VISUALSNOW_DIR}/${SUB}/${SESSION}/func" -type f -name "${SUB}_${SESSION}_task-*_run-*_bold.json" | while IFS= read -r RUN_FILE; do
        # Extract task and run information
        TASK=$(basename "${RUN_FILE}" | sed -E "s/.*task-([a-zA-Z0-9]+)_run-.*/\1/")
        RUN_NUM=$(basename "${RUN_FILE}" | sed -E "s/.*run-([0-9]+)_bold.*/\1/")
        
        echo "  Processing ${SUB}, task-${TASK}, run-${RUN_NUM}..."

        # Define file paths
        FMRIPREPEP="${VISUALSNOW_DIR}/derivatives/${SUB}/func/${SUB}_task-${TASK}_run-${RUN_NUM}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"
        #EPI="${VISUALSNOW_DIR}/${SUB}/${SESSION}/func/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_bold.nii.gz"
        EPI="${REALIGN_DIR}/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_bold_realigned.nii.gz"
        EPI10="${REALIGN_DIR}/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_bold10.nii.gz"
        SYNTH_PEPOLAR="${SDC_DIR}/${SUB}/${SESSION}/func/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_synthfmap.nii.gz"
        PEPOLAR="${VISUALSNOW_DIR}/${SUB}/${SESSION}/fmap/${SUB}_${SESSION}_dir-pa_run-${RUN_NUM}_epi.nii.gz"
        OUTPUT_PEPOLAR="${SDC_DIR}/${SUB}/${SESSION}/fmap/${SUB}_${SESSION}_dir-pa_run-${RUN_NUM}_fmap.nii.gz"
        OUTPUT_TOPUP="${SDC_DIR}/${SUB}/${SESSION}/fmap/${SUB}_${SESSION}_run-${RUN_NUM}_TOPUP"
        EPI_TOPUP="${SDC_DIR}/${SUB}/${SESSION}/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_boldcorrected.nii.gz"
        ACQPARAMS="${VISUALSNOW_DIR}/acqparams_per_run/${SUB}/${SESSION}/${SUB}_run-${RUN_NUM}_acqparams.txt"
        FUNC_DIR="${SDC_DIR}/${SUB}/${SESSION}/func"
        FMAP_DIR="${SDC_DIR}/${SUB}/${SESSION}/fmap"
        mkdir -p "$FUNC_DIR" "$FMAP_DIR"
        # Ensure output directories exist
        mkdir -p "$(dirname "${OUTPUT_PEPOLAR}")"
        mkdir -p "$(dirname "${OUTPUT_TOPUP}")"
        mkdir -p "$(dirname "${EPI_TOPUP}")"
        mkdir -p "$(dirname "${SYNTH_PEPOLAR}")"
        mkdir -p "${SDC_DIR}/${SUB}/${SESSION}/func"
        #mkdir -p "$(dirname "${EPI10}")"


        # Extract 10 slices from the EPI to capture bi-polar directions in the fieldmap
        fslroi "${EPI}" "${EPI10}" 20 10
        fslmerge -t "${SYNTH_PEPOLAR}" "${PEPOLAR}" "${EPI10}"

        # Run topup
        topup --imain="${SYNTH_PEPOLAR}" \
              --datain="${ACQPARAMS}" \
              --config="${CNF}" \
              --out="${OUTPUT_TOPUP}" \
              --fout="${SDC_DIR}/${SUB}/${SESSION}/offresonance_${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}.nii.gz" \
              --iout="${SDC_DIR}/${SUB}/${SESSION}/unwarped_images_${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}.nii.gz"

        # Apply topup
        applytopup --imain="${EPI}" \
                   --topup="${OUTPUT_TOPUP}" \
                   --datain="${ACQPARAMS}" \
                   --inindex=12 --method=jac \
                   --out="${EPI_TOPUP}"

        echo "Finished processing task-${TASK}, run-${RUN_NUM} for ${SUB}"
    done
done

echo "All subjects, tasks, and runs processed"
