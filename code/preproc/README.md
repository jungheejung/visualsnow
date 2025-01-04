1. create fieldmap `topup_per_run.sh`
   
   ```
   topup --imain=${SYNTH_PEPOLAR} \
              --datain=${ACQPARAMS} \
              --config=${CNF} \
              --out=${OUTPUT_TOPUP} \
              --fout=${VISUALSNOW_DIR}/TST/${SUB}/offresonance_task-${TASK}_run-${RUN_NUM}.nii.gz \
              --iout=${VISUALSNOW_DIR}/TST/${SUB}/unwarped_images_task-${TASK}_run-${RUN_NUM}.nii.gz```
2. apply distortion correction`topup_per_run.sh`
   
      ```
      applytopup --imain=${EPI} \
                  --topup=${OUTPUT_TOPUP} \
                  --datain=${ACQPARAMS} \
                  --inindex=12 --method=jac \
                  --out=${EPI_TOPUP}
      ```

3. run `extract_acqparameters.ipynb`
- Because there were two participants that had mismatching phas encoding directions, we manually extract the phase encoding directions and apply the parameters from a corresponding fmap. Note, the corresponding `fmap` may not always be collected adjacent to the `func` file, therefore resulting in poor-er image quality after distortion correction.

4. check if distortion correction worked `check_distortioncorrection.ipynb`
- We visualize source image and distortion-corrected image to see if the correction helpes improve image quality

5. Add intendedFor field using `populate_fmap.py`
- For later fMRIprep preprocessing, we populate the intended for fields with the corresponding `func` filenames in the `fmap` .json file 
