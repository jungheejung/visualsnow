import os
import json
import re

def find_files(bids_dir, subject, session, subfolder, file_extension):
    """Find files in a specific BIDS subfolder for a subject."""
    folder_path = os.path.join(bids_dir, subject, session, subfolder)
    matches = []
    if os.path.exists(folder_path):
        for root, _, files in os.walk(folder_path):
            for file in files:
                if file.endswith(file_extension):
                    matches.append(os.path.join(root, file))
    return matches

def match_fmap_to_func(fmap_file, func_files):
    """Match fmap files to the corresponding func files based on run numbers."""
    matched_func_files = []
    fmap_run = re.search(r'run-(\d+)', fmap_file)
    if fmap_run:
        fmap_run_number = fmap_run.group(1)
        for func_file in func_files:
            if f'run-{fmap_run_number}' in func_file:
                matched_func_files.append(func_file)
    return matched_func_files

def update_intendedfor(fmap_jsons, func_files):
    """Update IntendedFor fields in fieldmap JSON files based on run numbers."""
    for fmap_json in fmap_jsons:
        # Match functional files to this fmap
        matched_func_files = match_fmap_to_func(fmap_json, func_files)
        
        # # BIDS-valid paths for IntendedFor (relative paths prefixed with ./)
        # relative_func_paths = [
        #     os.path.join("./func", os.path.basename(func_file))
        #     for func_file in matched_func_files
        # ]
        # Get relative paths from BIDS root
        relative_func_paths = [
            os.path.relpath(func_file, os.path.dirname(fmap_json))
            for func_file in matched_func_files
        ]
        if relative_func_paths:
            # Update the JSON file
            with open(fmap_json, 'r') as f:
                fmap_metadata = json.load(f)
            
            fmap_metadata['IntendedFor'] = relative_func_paths
            
            with open(fmap_json, 'w') as f:
                json.dump(fmap_metadata, f, indent=4)
            print(f"Updated IntendedFor in: {fmap_json} with {len(relative_func_paths)} matches.")
        else:
            print(f"No matching functional files found for {fmap_json}")

            
def main():
    bids_dir = input("Enter the path to your BIDS dataset: ").strip()
    subject = input("Enter the subject ID (e.g., sub-002): ").strip()
    session = input("Enter session (e.g. ses-02): ").strip()

    # Step 1: Find fmap JSON files and func NIfTI files
    fmap_jsons = sorted(find_files(bids_dir, subject, session, "fmap", ".json"))
    func_files = sorted(find_files(bids_dir, subject, session,  "func", ".nii.gz"))

    print(f"Found {len(fmap_jsons)} fieldmap JSON files in {subject}.")
    print(f"Found {len(func_files)} functional NIfTI files in {subject}.")

    # Step 2: Update IntendedFor fields
    update_intendedfor(fmap_jsons, func_files)
    print("Finished updating IntendedFor fields.")

if __name__ == "__main__":
    main()
