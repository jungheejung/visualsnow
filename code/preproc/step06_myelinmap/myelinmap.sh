# 1. Input Data Requirements
# You need:
# A T1-weighted (T1w) image (bias-corrected, high-res, ~0.7 mm isotropic)
# A T2-weighted (T2w) image (bias-corrected, same resolution and space as T1w)
# Surface reconstructions from FreeSurfer (e.g., fsaverage or fs_LR if following HCP)
# Optionally, you can use the HCP pipelines to project the map to surface space (fs_LR_32k)

# 2. preproc
# Make sure both T1w and T2w are:
# Skull-stripped
# Bias field corrected (this is crucial — you want to remove intensity inhomogeneities)
# Rigidly aligned to the same space (often AC-PC aligned)
antsRegistrationSyN.sh -d 3 -f T1w.nii.gz -m T2w.nii.gz -o T2w_to_T1w_

# 3. Calculate the Ratio Image
# Compute the T1w/T2w ratio, voxelwise:
fslmaths T1w.nii.gz -div T2w.nii.gz T1w_div_T2w.nii.gz


# 4. surface projection
wb_command -volume-to-surface-mapping \
  T1w_div_T2w.nii.gz \
  midthickness.surf.gii \
  myelin_map.func.gii \
  -trilinear

# Tools & References
# HCP Pipelines: https://github.com/Washington-University/Pipelines

# Relevant Workbench tools: wb_command

# Key papers:

# Glasser & Van Essen (2011): Mapping Human Cortical Areas In Vivo Based on Myelin Content as Revealed by T1- and T2-Weighted MRI

# Glasser et al. (2016): A multi-modal parcellation of human cerebral cortex