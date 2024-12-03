# visualsnow

This repository hosts code and images for fMRI data collection with Visual Snow patients. 
The MRI protocol involves 1) T1-weighted, 2) T2-weighted, and 3) four EPI resting-state scans. 
The protocol sequence can be found here: [Protocol PDF](https://github.com/jungheejung/visualsnow/blob/main/mriprotocol.pdf)

The functional resting-state scan displays no other stimulus other than a fixation cross for the whole duration of 8 min. We provide instructions prior to the scan whether to a) open or b) close eyes. The sequence of eyes open and closed are counterbalanced across participants. 

<p align="center">
  <img src="https://github.com/jungheejung/visualsnow/blob/main/stimuli/eyes_closed.png" alt="Image 1" width="25%">
  <img src="https://github.com/jungheejung/visualsnow/blob/main/stimuli/eyes_open.png" alt="Image 2" width="25%">
</p>
<p align="center">
    <img src="https://github.com/jungheejung/visualsnow/blob/main/stimuli/fixation.png" alt="Image 1" width="25%">
  <img src="https://github.com/jungheejung/visualsnow/blob/main/stimuli/end.png" alt="Image 2" width="25%">
</p>


## Running code
1. git clone this repo
2. navigate to `/code` subfolder
3. run `RUN_visualsnow_v2.m` [ link ](https://github.com/jungheejung/visualsnow/blob/main/code/RUN_visualsnow_v2.m)
4. The code will prompt user for subject ID and run number.
   * subject ID: insert integer (the code will zero pad for you)
   * run number: 1-8 runs in total. If for some reason, scanner aborted in the middle of run 3, you can start from 3 with this code.
     
## Regenerating counterbalancing scheme
If user needs to generate another counterbalancing scheme for longer or shorter runs, 
1. please navigate to `/code/utils`
2. make edits in `generate_counterbalance.py`
3. run `python generate_counterbalance.py`, which creates a `counterbalance_sequences.tsv`. [ link ](https://github.com/jungheejung/visualsnow/blob/main/design/counterbalance_sequences.tsv)
4. This sequeqnce file `.tsv` is essential for providing the correct instruction image for each run. 
