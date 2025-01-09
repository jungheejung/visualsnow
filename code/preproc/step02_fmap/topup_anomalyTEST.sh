#!/bin/bash

# Base directory
VISUALSNOW_DIR="/Users/heejungj/Documents/projects_local/visualsnow_source"

# Configuration file path
CNF="${FSLDIR}/etc/flirtsch/b02b0.cnf"

# Define mappings for each subject using indexed variables
FMAP_MAPPING_SUB002_run01="run-08"
FMAP_MAPPING_SUB002_run02="run-08"
FMAP_MAPPING_SUB002_run08="run-07"

FMAP_MAPPING_SUB003_run01="run-06"
FMAP_MAPPING_SUB003_run06="run-07"

# Loop through subjects
for SUB in sub-002 sub-003; do
    echo "Processing subject: ${SUB}"

    # Specify the runs you want to process for each subject
    if [ "$SUB" == "sub-002" ]; then
        RUNS=("run-01" "run-02" "run-08")
    elif [ "$SUB" == "sub-003" ]; then
        RUNS=("run-01" "run-06")
    else
        echo "No mapping defined for ${SUB}, skipping..."
        continue
    fi

    # Loop through specified runs
    for RUN_KEY in "${RUNS[@]}"; do
        echo "Processing ${SUB}, ${RUN_KEY}..."

        # Set the appropriate mapping for the current run using a case statement
        case "$SUB" in
            sub-002)
                case "$RUN_KEY" in
                    run-01) FMAP_RUN=${FMAP_MAPPING_SUB002_run01} ;;
                    run-02) FMAP_RUN=${FMAP_MAPPING_SUB002_run02} ;;
                    run-08) FMAP_RUN=${FMAP_MAPPING_SUB002_run08} ;;
                    *) echo "No mapping found for ${RUN_KEY} in ${SUB}. Skipping..."; continue ;;
                esac
                ;;
            sub-003)
                case "$RUN_KEY" in
                    run-01) FMAP_RUN=${FMAP_MAPPING_SUB003_run01} ;;
                    run-06) FMAP_RUN=${FMAP_MAPPING_SUB003_run06} ;;
                    *) echo "No mapping found for ${RUN_KEY} in ${SUB}. Skipping..."; continue ;;
                esac
                ;;
            *)
                echo "No mapping defined for ${SUB}. Skipping..."
                continue
                ;;
        esac

        echo "For ${SUB}, mapping ${RUN_KEY} to ${FMAP_RUN}"

        # Find the specific run file
        RUN_FILE=$(find "${VISUALSNOW_DIR}/${SUB}/func" -type f -name "${SUB}_task-*_${RUN_KEY}_bold.json")
        if [ -z "$RUN_FILE" ]; then
            echo "No file found for ${SUB}, ${RUN_KEY}. Skipping..."
            continue
        fi

        # Extract task and run number
        TASK=$(basename "${RUN_FILE}" | sed -E "s/.*task-([a-zA-Z0-9]+)_run-.*/\1/")
        RUN_NUM=$(basename "${RUN_FILE}" | sed -E "s/.*run-([0-9]+)_bold.*/\1/")
        
        # Define file paths
        FMRIPREPEPI="${VISUALSNOW_DIR}/derivatives/${SUB}/func/${SUB}_task-${TASK}_run-${RUN_NUM}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"
        EPI="${VISUALSNOW_DIR}/${SUB}/func/${SUB}_task-${TASK}_run-${RUN_NUM}_bold.nii.gz"
        EPI10="${VISUALSNOW_DIR}/TST/${SUB}/func/${SUB}_task-${TASK}_run-${RUN_NUM}_bold10.nii.gz"
        SYNTH_PEPOLAR="${VISUALSNOW_DIR}/TST/${SUB}/func/${SUB}_task-${TASK}_run-${RUN_NUM}_synthfmap.nii.gz"
        PEPOLAR="${VISUALSNOW_DIR}/${SUB}/fmap/${SUB}_dir-pa_${FMAP_RUN}_epi.nii.gz"
        OUTPUT_PEPOLAR="${VISUALSNOW_DIR}/TST/${SUB}/fmap/${SUB}_dir-pa_run-${RUN_NUM}_fmap.nii.gz"
        OUTPUT_TOPUP="${VISUALSNOW_DIR}/TST/${SUB}/fmap/${SUB}_run-${RUN_NUM}_TOPUP"
        EPI_TOPUP="${VISUALSNOW_DIR}/TST/${SUB}/${SUB}_task-${TASK}_run-${RUN_NUM}_boldcorrected.nii.gz"
        ACQPARAMS="${VISUALSNOW_DIR}/acqparams_per_run/${SUB}/${SUB}_run-${RUN_NUM}_acqparams.txt"

        echo "EPI: ${EPI}\nEPI10: ${EPI10}\nPEPOLAR ${PEPOLAR}\nSYNTH_PEPOLAR: ${SYNTH_PEPOLAR}\nOUTPUT_PEPOLAR:${OUTPUT_PEPOLAR}\nOUTPUT_TOPUP: ${OUTPUT_TOPUP}"

        # Ensure output directories exist
        mkdir -p "$(dirname ${OUTPUT_PEPOLAR})"
        mkdir -p "$(dirname ${OUTPUT_TOPUP})"
        mkdir -p "$(dirname ${EPI_TOPUP})"
        mkdir -p "$(dirname ${SYNTH_PEPOLAR})"
        mkdir -p "$(dirname ${EPI10})"
        
        # Preprocessing
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
        applytopup --imain=${EPI} \
                --topup=${OUTPUT_TOPUP} \
                --datain=${ACQPARAMS} \
                --inindex=12 --method=jac \
                --out=${EPI_TOPUP}

        echo "  Finished processing task-${TASK}, run-${RUN_NUM} for ${SUB}"
    done
done

echo "Selected runs for all subjects processed!"
