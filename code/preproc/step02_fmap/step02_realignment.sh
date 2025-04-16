
# remove first 6 volumes
FILES=/Users/heejungj/Documents/projects_local/visualsnow_source/sub-002/*/func/sub-002_*_bold.nii.gz
SAVEDIR=/Users/heejungj/Documents/projects_local/REALIGN
mkdir -p "$SAVEDIR"
# for FILENAME in $FILES; do
find /Users/heejungj/Documents/projects_local/visualsnow_source/sub-002 -type f -name "sub-002_*_bold.nii.gz" | while IFS= read -r FILENAME; do
    
# FILENAME=/Users/heejungj/Documents/projects_local/visualsnow_source/sub-002/ses-03/func/sub-002_ses-03_task-restclosed_run-12_bold.nii.gz
    basename_no_ext=$(basename "$FILENAME" .nii.gz)
    echo ${basename_no_ext}
    # remove first 6 volumes
    fslroi "${FILENAME}" "${SAVEDIR}/${basename_no_ext}_DISDAQ.nii.gz" 6 -1

    # Create reference image (e.g., first volume)
    fslroi "${SAVEDIR}/${basename_no_ext}_DISDAQ.nii.gz" \
    "${SAVEDIR}/${basename_no_ext}_refvol.nii.gz" 0 1

    # Motion correct all volumes to the reference
    mcflirt -in "${SAVEDIR}/${basename_no_ext}_DISDAQ.nii.gz" \
    -refvol 0 \
    -out "${SAVEDIR}/${basename_no_ext}_realigned.nii.gz" -plots -mats
done
