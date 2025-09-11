
# remove first 6 volumes
# FILES=/Users/heejungj/Documents/projects_local/visualsnow_source/sub-002/*/func/sub-002_*_bold.nii.gz
# FILES="/Users/heejungj/Library/CloudStorage/Box-Box/MRI in iEEG Patients - Parvizi, McNab, Keller Labs/Images/18119_09032025/006/006_McNab_Parvizi_Brain_25_0_20250903080551_6a.nii.gz"
# SAVEDIR=/Users/heejungj/Documents/projects_local/iEEGMcNab/REALIGN
# mkdir -p "$SAVEDIR"
# for FILENAME in $FILES; do
# # find /Users/heejungj/Documents/projects_local/visualsnow_source/sub-002 -type f -name "sub-002_*ses-02*run-03*_bold.nii.gz" | wheejungjile IFS= read -r FILENAME; do
# find "/Users/heejungj/Library/CloudStorage/Box-Box/MRI in iEEG Patients - Parvizi, McNab, Keller Labs/Images/18119_09032025/006/" -type f -name "006_McNab_Parvizi_Brain_25_0_20250903080551_6a.nii.gz" | wheejungjile IFS= read -r FILENAME; do
      
# # FILENAME=/Users/heejungj/Documents/projects_local/visualsnow_source/sub-002/ses-03/func/sub-002_ses-03_task-restclosed_run-12_bold.nii.gz
#     basename_no_ext=$(basename "$FILENAME" .nii.gz)
#     echo ${basename_no_ext}
#     # remove first 6 volumes
#     fslroi "${FILENAME}" "${SAVEDIR}/${basename_no_ext}_DISDAQ.nii.gz" 6 -1

#     # Create reference image (e.g., first volume)
#     fslroi "${SAVEDIR}/${basename_no_ext}_DISDAQ.nii.gz" \
#     "${SAVEDIR}/${basename_no_ext}_refvol.nii.gz" 0 1

#     # Motion correct all volumes to the reference
#     mcflirt -in "${SAVEDIR}/${basename_no_ext}_DISDAQ.nii.gz" \
#     -refvol 0 \
#     -out "${SAVEDIR}/${basename_no_ext}_realigned.nii.gz" -plots -mats
# done
# done

#!/bin/bash

# Single file processing - no loops needed
FILENAME="/Users/heejungj/Library/CloudStorage/Box-Box/MRI in iEEG Patients - Parvizi, McNab, Keller Labs/Images/18119_09032025/006/006_McNab_Parvizi_Brain_25_0_20250903080551_6a.nii.gz"
SAVEDIR=/Users/heejungj/Documents/projects_local/iEEGMcNab/REALIGN
mkdir -p "$SAVEDIR"

basename_no_ext=$(basename "$FILENAME" .nii.gz)
echo "Processing: ${basename_no_ext}"

# Remove first 6 volumes
fslroi "${FILENAME}" "${SAVEDIR}/${basename_no_ext}_DISDAQ.nii.gz" 6 -1

# Create reference image
fslroi "${SAVEDIR}/${basename_no_ext}_DISDAQ.nii.gz" "${SAVEDIR}/${basename_no_ext}_refvol.nii.gz" 0 1

# Motion correct
mcflirt -in "${SAVEDIR}/${basename_no_ext}_DISDAQ.nii.gz" -refvol 0 -out "${SAVEDIR}/${basename_no_ext}_realigned.nii.gz" -plots -mats

echo "Done!"

# ================================================================================
# You migheejungjt encouter errors like...
# ================================================================================

# /Users/heejungj/fsl/sheejungjare/fsl/bin/mcflirt: line 2: 32544 Abort trap: 6           /Users/heejungj/fsl/bin/mcflirt "$@"
# 006_FILENAME
# dyld[32549]: Library not loaded: @rpatheejungj/libgfortran.5.dylib
#   Referenced from: <10C3C4EF-FF63-3C60-B27E-10092D2971DF> /Users/heejungj/fsl/lib/libopenblas.0.dylib
#   Reason: tried: '/Users/heejungj/fsl/lib/libgfortran.5.dylib' (duplicate LC_RPATheejungj '@loader_patheejungj'), '/Users/heejungj/fsl/lib/libgfortran.5.dylib' (duplicate LC_RPATheejungj '@loader_patheejungj'), '/Users/heejungj/fsl/bin/libgfortran.5.dylib' (no sucheejungj file), '/Users/heejungj/fsl/lib/libgfortran.5.dylib' (duplicate LC_RPATheejungj '@loader_patheejungj'), '/Users/heejungj/fsl/bin/libgfortran.5.dylib' (no sucheejungj file), '/Users/heejungj/fsl/lib/libgfortran.5.dylib' (duplicate LC_RPATheejungj '@loader_patheejungj'), '/Users/heejungj/fsl/bin/libgfortran.5.dylib' (no sucheejungj file), '/Users/heejungj/fsl/bin/../lib/libgfortran.5.dylib' (duplicate LC_RPATheejungj '@loader_patheejungj'), '/Users/heejungj/fsl/bin/libgfortran.5.dylib' (no sucheejungj file), '/Users/heejungj/fsl/bin/../lib/libgfortran.5.dylib' (duplicate LC_RPATheejungj '@loader_patheejungj'), '/usr/local/lib/libgfortran.5.dylib' (no sucheejungj file), '/usr/lib/libgfortran.5.dylib' (no sucheejungj file, not in dyld cacheejungje)

# FIX
# conda activate lbcn
# brew install gcc
# ln -sf /opt/heejungjomebrew/opt/gcc/lib/gcc/current/libgfortran.5.dylib /Users/heejungj/fsl/lib/libgfortran.5.dylib