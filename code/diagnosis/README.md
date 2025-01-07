## 1. How to export data from flywheel to local or remote server
### A. download flywheel from flywheel.io
- Here's instructions on where to download flywheel: https://docs.flywheel.io/CLI/start/install/
- Download flywheel
- You'll se a `fw` program
- We need to move this `fw` program so that the program is accessed everytime in the future, not just in your Download's folder.
- Based on Flywheel's documentation: https://docs.flywheel.io/CLI/start/install/#mac-and-linux</br>
`sudo mv ./fw /usr/local/bin`

- Confirm status via 
`fw status`

- If it doesn't work, check the permission settings. Update permission of usr/local/bin folder </br>
`sudo chmod +x /usr/local/bin/fw`

### B. Generate API key
`Flywheel` > `Profile` > `Flywheel Access` > `+ Generate API Key`

### C. Login to flywheel on your path
`fw login [ API key]` 

### D. Transfer over data`fw sync` data
Example: 
```
fw sync --include nifti \
--metadata fw://parvizi/parv2 \
/Users/h/Documents/projects_local/visualsnow_source
```

```
fw sync --include nifti \
--metadata fw://parvizi/parv2/VOL \
/Users/heejungj/Documents/projects_local/visualsnow_source/volunteer
```

## 2. Running fmriprep on BIDS validated data
- A. install fmriprep-docker
- B. get Freesurefer license
- C. run the following line of code
```
INPUT_DIRECTORY=/Users/heejungj/Documents/projects_local/visualsnow_source
OUTPUT_DIRECTORY=/Users/heejungj/Documents/projects_local/visualsnow_source/derivatives
LICENSE_DIR=/Users/heejungj/freesurfer_license.txt

  docker run --rm -it \
  --platform linux/amd64 \
  -v ${INPUT_DIRECTORY}:/data:ro \
  -v ${OUTPUT_DIRECTORY}:/out \
  -v ${LICENSE_DIR}:/opt/freesurfer/license.txt:ro \
  nipreps/fmriprep:24.1.1 --verbose \
  --fs-no-reconall --low-mem --mem 8 \
  /data /out participant --participant-label sub-002

```
