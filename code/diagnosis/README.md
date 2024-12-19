## How to export data from flywheel to local or remote server
1. Generate API key
Flywheel > Profile > Flywheel Access > `+ Generate API Key`
2. Install flywheel CLI
3. `fw login [ API key]` from step 1
4. `fw sync` data
Example: 
```
fw sync --include nifti \
--metadata fw://parvizi/parv2 \
/Users/h/Documents/projects_local/visualsnow_source
```


fw sync --include nifti --metadata fw://parvizi/parv2 /Users/heejungj/Documents/projects_local/visualsnow_source


## Running fmriprep on BIDS validated data
1. install fmriprep-docker
2. get Freesurefer license
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