1. run `step01_extract_acqparameters.ipynb`
- Because there were two participants that had mismatching phas encoding directions, we manually extract the phase encoding directions and apply the parameters from a corresponding fmap. Note, the corresponding `fmap` may not always be collected adjacent to the `func` file, therefore resulting in poor-er image quality after distortion correction.

2. run realignment and discard 6 DISDAQs `step02_realignment.sh`
- We'll remove 6 volumes in the beginning
- Then, we extract a reference volume (first volume of the DISDAQ discard image)
- From this, we realign all the functional images in a given run


3. create fieldmap `code/preproc/step02_fmap/step03_topup_per_run_sub02ses02.sh.sh`
   
   ```
   topup --imain=${SYNTH_PEPOLAR} \
              --datain=${ACQPARAMS} \
              --config=${CNF} \
              --out=${OUTPUT_TOPUP} \
              --fout=${VISUALSNOW_DIR}/TST/${SUB}/offresonance_task-${TASK}_run-${RUN_NUM}.nii.gz \
              --iout=${VISUALSNOW_DIR}/TST/${SUB}/unwarped_images_task-${TASK}_run-${RUN_NUM}.nii.gz```


3. apply distortion correction`code/preproc/step02_fmap/step03_topup_per_run_sub02ses02.sh.sh`
   
      ```
      applytopup --imain=${EPI} \
                  --topup=${OUTPUT_TOPUP} \
                  --datain=${ACQPARAMS} \
                  --inindex=12 --method=jac \
                  --out=${EPI_TOPUP}
      ```


4. check if distortion correction worked `check_distortioncorrection.ipynb`
- We visualize source image and distortion-corrected image to see if the correction helpes improve image quality


5. Add intendedFor field using `populate_fmap.py`
- For later fMRIprep preprocessing, we populate the intended for fields with the corresponding `func` filenames in the `fmap` .json file 
