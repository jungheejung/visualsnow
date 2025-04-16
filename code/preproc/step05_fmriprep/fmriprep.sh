fmriprep-docker \
    --env OMP_NUM_THREADS=4 \
    /Users/heejungj/Documents/projects_local/visualsnow_BIDS \
    /Users/heejungj/Documents/projects_local/visualsnow_BIDS/derivatives \
    participant \
    --participant-label 002 \
    --dvars-spike-threshold 0.9 \
    --fs-no-reconall --fs-license-file ~/license.txt

mriqc \
    /Users/heejungj/Documents/projects_local/visualsnow_BIDS \
    /Users/heejungj/Documents/projects_local/visualsnow_BIDS/MRIQC \
    participant --participant-label 002 \
    --session-id ses-02

docker run -it --rm \
  -v /Users/heejungj/Documents/projects_local/visualsnow_BIDS:/data:ro \
  -v /Users/heejungj/Documents/projects_local/visualsnow_BIDS/MRIQC:/out \
  nipreps/mriqc:24.0.2 \
  /data /out participant --participant-label 002 --nprocs 1 --omp-nthreads 1 --mem_gb 20 --no-sub -m bold