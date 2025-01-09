import os
import json
import click
from pathlib import Path
import re
import shutil

# Constants
MAIN_DIR = '/Users/heejungj/Documents/projects_local/visualsnow_source/parv2'
SOURCE_DIR = '/Users/heejungj/Documents/projects_local/visualsnow_source'

# Phase encoding direction mappings
DIRECTION_MAP = {
    'i': 'LR', 'i-': 'RL',
    'j': 'PA', 'j-': 'AP',
    'k': 'IS', 'k-': 'SI'
}

def calculate_total_readout_time(effective_echo_spacing, acquisition_matrix_pe):
    return (acquisition_matrix_pe - 1) * effective_echo_spacing

@click.command()
@click.option('--sub', default=None, help="Optional subject ID to process")
def process_fmap(sub):
    """Process fmap NIfTI and JSON files for specified or all subjects."""
    # Handle subject filtering
    if sub:
        subject_dirs = [Path(MAIN_DIR) / f"SUBJECTS/{sub}"]
    else:
        subject_dirs = list(Path(MAIN_DIR).glob('SUBJECTS/*@Parvizi'))

    if not subject_dirs:
        print("No matching subjects found.")
        return

    # Process each subject directory
    for subject_dir in subject_dirs:
        process_subject(subject_dir)

def process_subject(subject_dir):
    """Process a single subject directory."""
    print(f"Processing subject: {subject_dir}")

    # Iterate through sessions and acquisitions
    for session_dir in subject_dir.glob('SESSIONS/*/ACQUISITIONS/*epi-pepolar*/FILES'):
        for nii_file in session_dir.glob('*.nii.gz'):
            process_nii_file(nii_file, subject_dir)

def process_nii_file(nii_file, subject_dir):
    """Process a single NIfTI file and its corresponding JSON."""
    try:
        # Extract subject
        sub = subject_dir.name.split('@')[0]

        # Extract run number
        run_match = re.search(r'run-(\d+)', str(nii_file))
        run_number = f"run-{run_match.group(1)}" if run_match else "unknown_run"

        # Process associated JSON file
        json_file = nii_file.with_name(nii_file.name.replace('.nii.gz', '.nii.gz.flywheel.json'))
        if json_file.exists():
            # Extract phase encoding direction from JSON
            phase_encoding_dir = extract_phase_encoding_direction(json_file)

            # Construct new base name
            new_base_name = f"sub-{sub}_dir-{phase_encoding_dir}_{run_number}_epi"
            parent_dir = Path(SOURCE_DIR) / f"sub-{sub}" / 'fmap'
            parent_dir.mkdir(parents=True, exist_ok=True)

            # Copy and rename NIfTI file
            new_nii_file = parent_dir / f"{new_base_name}.nii.gz"
            shutil.copy(str(nii_file), str(new_nii_file))
            print(f"Copied: {nii_file.name} -> {new_nii_file.name}")

            # Copy and update JSON file
            new_json_file = parent_dir / f"{new_base_name}.json"
            shutil.copy(str(json_file), str(new_json_file))
            print(f"Copied: {json_file.name} -> {new_json_file.name}")

            # Update JSON metadata
            update_json(new_json_file)
        else:
            print(f"JSON file not found for: {nii_file.name}")

    except Exception as e:
        print(f"Error processing {nii_file}: {e}")

def extract_phase_encoding_direction(json_file):
    """Extract and map phase encoding direction from JSON file."""
    try:
        with open(json_file, 'r') as jf:
            data = json.load(jf)
            direction = data.get('info', {}).get('PhaseEncodingDirection')
            return DIRECTION_MAP.get(direction, 'unknown')
    except Exception as e:
        print(f"Error extracting phase encoding direction from {json_file}: {e}")
        return 'unknown'

def update_json(json_file):
    """Update JSON file with TotalReadoutTime."""
    try:
        with open(json_file, 'r+') as jf:
            data = json.load(jf)

            effective_echo_spacing = data.get('EffectiveEchoSpacing')
            acquisition_matrix_pe = data.get('AcquisitionMatrixPE')

            if effective_echo_spacing is not None and acquisition_matrix_pe is not None:
                # Calculate TotalReadoutTime
                total_readout_time = calculate_total_readout_time(effective_echo_spacing, acquisition_matrix_pe)
                data['TotalReadoutTime'] = total_readout_time

            jf.seek(0)
            json.dump(data, jf, indent=4)
            jf.truncate()
            print(f"Updated JSON metadata in: {json_file}")
    except json.JSONDecodeError as e:
        print(f"Error reading JSON file {json_file}: {e}")

if __name__ == "__main__":
    process_fmap()
