import os
import json
import click
from pathlib import Path
import re
import shutil

# Constants
REPETITION_TIME = 1
MAIN_DIR = '/Users/heejungj/Documents/projects_local/visualsnow_source/parv2'
SOURCE_DIR = '/Users/heejungj/Documents/projects_local/visualsnow_source'

@click.command()
@click.option('--sub', default=None, help="Optional subject ID to process")

def process_t2_anatomy(sub):
    """Process T2 Anatomy NIfTI and JSON files for specified or all subjects."""
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
    for session_dir in subject_dir.glob('SESSIONS/*/ACQUISITIONS/T2 Anatomy/FILES'):
        for nii_file in session_dir.glob('*.nii.gz'):
            process_nii_file(nii_file, subject_dir)

def process_nii_file(nii_file, subject_dir):
    """Process a single NIfTI file and its corresponding JSON."""
    try:
        # Extract subject
        sub = subject_dir.name.split('@')[0]

        # Construct new base name
        new_base_name = f"sub-{sub}_T2w"
        parent_dir = Path(SOURCE_DIR) / f"sub-{sub}" / 'anat'
        parent_dir.mkdir(parents=True, exist_ok=True)

        # Copy and rename NIfTI file
        new_nii_file = parent_dir / f"{new_base_name}.nii.gz"
        shutil.copy(str(nii_file), str(new_nii_file))
        print(f"Copied: {nii_file.name} -> {new_nii_file.name}")

        # Process associated JSON file
        json_file = nii_file.with_name(nii_file.name.replace('.nii.gz', '.nii.gz.flywheel.json'))
        if json_file.exists():
            new_json_file = parent_dir / f"{new_base_name}.json"
            shutil.copy(str(json_file), str(new_json_file))
            print(f"Copied: {json_file.name} -> {new_json_file.name}")
        else:
            print(f"JSON file not found for: {nii_file.name}")

    except Exception as e:
        print(f"Error processing {nii_file}: {e}")

if __name__ == "__main__":
    process_t2_anatomy()
