# %% 
import json
import glob

# %%
json_files = glob.glob("/Users/heejungj/Documents/projects_local/visualsnow_BIDS/sub-002/ses-*/anat/*.json")

# %%
# json_file = [json_files[0]]
for f in json_files:
    with open(f, 'r') as infile:
        data = json.load(infile)

    # Flatten if wrapped in "info"
    if "info" in data:
        data = data["info"]

    with open(f, 'w') as outfile:
        json.dump(data, outfile, indent=4)

    print(f"✔ Flattened: {f}")

# %%
