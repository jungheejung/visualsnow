import os, json
from pathlib import Path
import re
import shutil
"""
Bidsify fmap - direct download from flywheel. Renaming files to align with BIDS convention
"""
# Base directory
main_dir = '/Users/heejungj/Documents/projects_local/visualsnow_source/parv2'
source_dir = '/Users/heejungj/Documents/projects_local/visualsnow_source'
PHASE_ENCODING = 'j'

def calculate_total_readout_time(effective_echo_spacing, acquisition_matrix_pe):
    return (acquisition_matrix_pe - 1) * effective_echo_spacing

# Define the specific logic to locate .nii.gz files in a controlled way
for subject_dir in Path(main_dir).glob('SUBJECTS/*@Parvizi'):  # Loop through subjects
    for session_dir in subject_dir.glob('SESSIONS/*/ACQUISITIONS/*epi-pepolar*/FILES'):  # Navigate to FILES directories
        for nii_file in session_dir.glob('*.nii.gz'):  # Only look for .nii.gz files in these directories
            # Extract subject
            sub = subject_dir.name.split('@')[0]

            # Extract run number
            run_match = re.search(r'run-(\d+)', str(nii_file))
            run_number = f"run-{run_match.group(1)}" if run_match else "unknown_run"

            # Extract task type
            # task_match = re.search(r'task-([a-zA-Z0-9]+)', str(nii_file))
            # task_type = f"task-{task_match.group(1)}" if task_match else "unknown_task"

            # Construct new base name
            new_base_name = f"sub-{sub}_dir-pa_{run_number}_epi"

            # Rename .nii.gz file
            parent_dir = Path(source_dir) / f"sub-{sub}" / 'fmap'
            parent_dir.mkdir(parents=True, exist_ok=True)
            new_nii_file = parent_dir / f"{new_base_name}.nii.gz"
            # os.rename(nii_file, new_nii_file)
            shutil.copy(str(nii_file), str(new_nii_file))
            print(f"Renamed: {nii_file.name} -> {new_nii_file.name}")

            # Find corresponding .json file
            json_file = nii_file.with_name(nii_file.name.replace('.nii.gz', '.nii.gz.flywheel.json'))
            if json_file.exists():
                new_json_file = parent_dir / f"{new_base_name}.json"
                # os.rename(json_file, new_json_file)
                shutil.copy(str(json_file), str(new_json_file))
                print(f"Renamed: {json_file.name} -> {new_json_file.name}")

                try:
                    with open(new_json_file, 'r+') as jf:
                        data = json.load(jf)
                        data['PhaseEncodingDirection'] = PHASE_ENCODING

                        effective_echo_spacing = data.get('EffectiveEchoSpacing')
                        acquisition_matrix_pe = data.get('AcquisitionMatrixPE')

                        if effective_echo_spacing is not None and acquisition_matrix_pe is not None:
                            # Calculate TotalReadoutTime
                            total_readout_time = calculate_total_readout_time(effective_echo_spacing, acquisition_matrix_pe)
                            data['TotalReadoutTime'] = total_readout_time

                            jf.seek(0)
                            json.dump(data, jf, indent=4)
                            jf.truncate()
                            print(f"Updated PhaseEncodingDirection in: {new_json_file}")
                except json.JSONDecodeError as e:
                    print(f"Error reading JSON file {new_json_file}: {e}")
            else:
                print(f"JSON file not found for: {nii_file.name}")

