RUN_NUM=3
SUB=sub-001
VISUALSNOW_DIR="/Users/heejungj/Documents/projects_local/visualsnow_source"
FMRIPREPEPI="${VISUALSNOW_DIR}/derivatives/${SUB}/func/${SUB}_task-restclosed_run-0${RUN_NUM}_space-MNI152NLin2009cAsym_desc-preproc_bold.nii.gz"
EPI="${VISUALSNOW_DIR}/${SUB}/func/${SUB}_task-restclosed_run-0${RUN_NUM}_bold.nii.gz"
PEPOLAR="${VISUALSNOW_DIR}/${SUB}/fmap/${SUB}_dir-pa_run-0${RUN_NUM}_epi.nii.gz"
OUTPUT_PEPOLAR="${VISUALSNOW_DIR}/TST/${SUB}/fmap/${SUB}_dir-pa_run-0${RUN_NUM}_fmap.nii.gz"
OUTPUT_TOPUP="${VISUALSNOW_DIR}/TST/${SUB}/fmap/${SUB}_run-0${RUN_NUM}_TOPUP"
CNF="/Users/heejungj/Documents/projects_local/visualsnow/code/diagnosis/b02b0.cnf"
EPI_TOPUP="${VISUALSNOW_DIR}/TST/${SUB}/${SUB}_task-restclosed_run-0${RUN_NUM}_boldcorrected.nii.gz"
ACQPARAMS="${VISUALSNOW_DIR}/acqparams_per_run/${SUB}/${SUB}_run-0${RUN_NUM}_acqparams.txt"

# fslmerge -t ${OUTPUT_PEPOLAR} ${PEPOLAR} ${PEPOLAR}
# Run topup:
topup --imain=${PEPOLAR} \
      --datain=/Users/heejungj/Documents/projects_local/visualsnow/code/diagnosis/acqparams.txt \
      --config=${CNF} \
      --out=${OUTPUT_TOPUP} \
      --iout=corrected_images

applytopup --imain=${EPI} \
           --topup=${OUTPUT_TOPUP} \
           --datain=/Users/heejungj/Documents/projects_local/visualsnow/code/diagnosis/acqparams.txt \
           --inindex=1 \
           --method=jac \
           --out=${EPI_TOPUP}


