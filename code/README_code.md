# Folder structure

* `experiment_utils` module focuses on all aspects of displaying stimuli "during" scanning sessions. 
* the  `preproc` module handles all tasks related to the processing and organization of files generated "after" scanning, including formatting to BIDS, generating fieldmaps and preprocessing for analysis.
    * Under preproc, there are two folders: `bidsify` and `fmap`
    * 1) `bidsify` converts flywheel source files into BIDS compatible files.
    * 2) `fmap` implements TOPUP for distortion correction. 