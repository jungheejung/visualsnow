import os
import re

def rename_per_run_fieldmaps(fmap_dir):
    """
    Rename fieldmaps from *_task-xxx_run-XX_fieldmap.ext → *_run-XX_fieldmap.ext
    """
    for file in os.listdir(fmap_dir):
        if file.endswith('_fieldmap.nii.gz') or file.endswith('_fieldmap.json'):
            match = re.match(r'(sub-\d+)_ses-(\d+)_.*?run-(\d+)_fieldmap\.(nii\.gz|json)', file)
            if match:
                sub, ses, run, ext = match.groups()
                new_name = f"{sub}_ses-{ses}_run-{run}_fieldmap.{ext}"
                old_path = os.path.join(fmap_dir, file)
                new_path = os.path.join(fmap_dir, new_name)
                print(f"Renaming: {file} -> {new_name}")
                os.rename(old_path, new_path)

# Example usage
fmap_path = "/Users/heejungj/Documents/projects_local/visualsnow_BIDS/sub-002/ses-03/fmap"
rename_per_run_fieldmaps(fmap_path)
