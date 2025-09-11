#!/bin/bash

# INPUT: 
# * PEPOLAR
# * EPI

# OUTPUT: EPI10

# Base directory
VISUALSNOW_DIR="/Users/heejungj/Library/CloudStorage/Box-Box/MRI in iEEG Patients - Parvizi, McNab, Keller Labs/Images" #"/Users/heejungj/Documents/projects_local/visualsnow_source"
REALIGN_DIR="/Users/heejungj/Documents/projects_local/iEEGMcNab/REALIGN"
SDC_DIR="/Users/heejungj/Documents/projects_local/iEEGMcNab/SDC"
# Configuration file path
CNF="${FSLDIR}/etc/flirtsch/b02b0.cnf"

# Loop through subjects
for SUB in 18119_09032025; do 
    echo "Processing subject: ${SUB}"

    # Find all run files for the subject and process them one by one
    #find "${VISUALSNOW_DIR}/${SUB}" -type f -name "/006/006_McNab_Parvizi_Brain_25_0_20250903080551_6a.json" | while IFS= read -r RUN_FILE; do
        # Extract task and run information
        #TASK=$(basename "${RUN_FILE}" | sed -E "s/.*task-([a-zA-Z0-9]+)_run-.*/\1/")
        #RUN_NUM=$(basename "${RUN_FILE}" | sed -E "s/.*run-([0-9]+)_bold.*/\1/")
        
        # echo "  Processing ${SUB}, task-${TASK}, run-${RUN_NUM}..."

        # FMRIPREPEP="${VISUALSNOW_DIR}/${SUB}/006/006_McNab_Parvizi_Brain_25_0_20250903080551_6a.nii.gz"
        # #EPI="${VISUALSNOW_DIR}/${SUB}/${SESSION}/func/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_bold.nii.gz"
        # EPI="${REALIGN_DIR}/006_McNab_Parvizi_Brain_25_0_20250903080551_6a_realigned.nii.gz" #"${REALIGN_DIR}/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_bold_realigned.nii.gz"
        # EPI10="${REALIGN_DIR}/006_McNab_Parvizi_Brain_25_0_20250903080551_6a_10.nii.gz" #"${REALIGN_DIR}/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_bold10.nii.gz"
        # SYNTH_PEPOLAR="${SDC_DIR}/${SUB}/${SESSION}/func/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_synthfmap.nii.gz"
        # PEPOLAR="${VISUALSNOW_DIR}/${SUB}/${SESSION}/fmap/${SUB}_${SESSION}_dir-pa_run-${RUN_NUM}_epi.nii.gz"
        # OUTPUT_PEPOLAR="${SDC_DIR}/${SUB}/${SESSION}/fmap/${SUB}_${SESSION}_dir-pa_run-${RUN_NUM}_fmap.nii.gz"
        # OUTPUT_TOPUP="${SDC_DIR}/${SUB}/${SESSION}/fmap/${SUB}_${SESSION}_run-${RUN_NUM}_TOPUP"
        # EPI_TOPUP="${SDC_DIR}/${SUB}/${SESSION}/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_boldcorrected.nii.gz"
        # ACQPARAMS="${VISUALSNOW_DIR}/acqparams_per_run/${SUB}/${SESSION}/${SUB}_run-${RUN_NUM}_acqparams.txt"
        # FUNC_DIR="${SDC_DIR}/${SUB}/${SESSION}/func"
        # FMAP_DIR="${SDC_DIR}/${SUB}/${SESSION}/fmap"
        # mkdir -p "$FUNC_DIR" "$FMAP_DIR"

        # Define file paths
        FMRIPREPEP="${VISUALSNOW_DIR}/${SUB}/006/006_McNab_Parvizi_Brain_25_0_20250903080551_6a.nii.gz"
        #EPI="${VISUALSNOW_DIR}/${SUB}/${SESSION}/func/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_bold.nii.gz"
        EPI="${REALIGN_DIR}/006_McNab_Parvizi_Brain_25_0_20250903080551_6a_realigned.nii.gz" #"${REALIGN_DIR}/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_bold_realigned.nii.gz"
        EPI10="${REALIGN_DIR}/006_McNab_Parvizi_Brain_25_0_20250903080551_6a_10.nii.gz" #"${REALIGN_DIR}/${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}_bold10.nii.gz"
        SYNTH_PEPOLAR="${SDC_DIR}/006_McNab_Parvizi_Brain_25_0_20250903080551_6a_synthfmap.nii.gz"
        PEPOLAR="${VISUALSNOW_DIR}/${SUB}/007/007_McNab_Parvizi_Brain_25_0_20250903080551_7.nii.gz"  # "${VISUALSNOW_DIR}/${SUB}/${SESSION}/fmap/${SUB}_${SESSION}_dir-pa_run-${RUN_NUM}_epi.nii.gz"
        OUTPUT_PEPOLAR="${SDC_DIR}/fmap/run01_fmap.nii.gz"
        OUTPUT_TOPUP="${SDC_DIR}/fmap/run01_TOPUP"
        EPI_TOPUP="${SDC_DIR}/run01_boldcorrected.nii.gz"
        ACQPARAMS="/Users/heejungj/Documents/projects_local/iEEGMcNab/acqparams_per_run/18119_09032025/18119_09032025_Parvizi_acqparams.txt"
        FUNC_DIR="${SDC_DIR}/func"
        FMAP_DIR="${SDC_DIR}/fmap"
        mkdir -p "$FUNC_DIR" "$FMAP_DIR"
        # Ensure output directories exist
        mkdir -p "$(dirname "${OUTPUT_PEPOLAR}")"
        mkdir -p "$(dirname "${OUTPUT_TOPUP}")"
        mkdir -p "$(dirname "${EPI_TOPUP}")"
        mkdir -p "$(dirname "${SYNTH_PEPOLAR}")"
        mkdir -p "${SDC_DIR}/${SUB}/${SESSION}/func"
        #mkdir -p "$(dirname "${EPI10}")"
        echo ${FMRIPREP}

        # Extract 10 slices from the EPI to capture bi-polar directions in the fieldmap
        fslroi "${EPI}" "${EPI10}" 20 10
        fslmerge -t "${SYNTH_PEPOLAR}" "${PEPOLAR}" "${EPI10}"

        # Run topup
        topup --imain="${SYNTH_PEPOLAR}" \
              --datain="${ACQPARAMS}" \
              --config="${CNF}" \
              --out="${OUTPUT_TOPUP}" \
              --fout="${SDC_DIR}/${SUB}/${SESSION}/offresonance_${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}.nii.gz" \
              --iout="${SDC_DIR}/${SUB}/${SESSION}/unwarped_images_${SUB}_${SESSION}_task-${TASK}_run-${RUN_NUM}.nii.gz" \
              -v

        # Apply topup
        applytopup --imain="${EPI}" \
                   --topup="${OUTPUT_TOPUP}" \
                   --datain="${ACQPARAMS}" \
                   --inindex=12 --method=jac \
                   --out="${EPI_TOPUP}" -v

        echo "Finished processing task-${TASK}, run-${RUN_NUM} for ${SUB}"
    done
# done

# echo "All subjects, tasks, and runs processed"
