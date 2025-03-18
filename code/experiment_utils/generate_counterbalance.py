import numpy as np
import pandas as pd
from pathlib import Path
# Set random seed for reproducibility
random_seed = 42
np.random.seed(random_seed)

code_dir = Path.cwd()
main_dir = code_dir.parent.parent
design_dir = Path(main_dir, "design")

# Generate a 100x4 sequence of 0s and 1s with two 0s and two 1s per row
rows, cols = 99, 8
sequences = []

for _ in range(rows):
    seq = np.array([0, 0, 0, 0, 1, 1, 1, 1])
    np.random.shuffle(seq)
    sequences.append(seq)

# Convert to DataFrame
df = pd.DataFrame(sequences, columns=[f"run-0{i+1}" for i in range(cols)])
row_indices = [f"sub-{i:02d}" for i in range(1, 100)]
df.insert(0, "subject", row_indices)
# Save to TSV file
output_file = Path(design_dir, "counterbalance_sequences.tsv") 
df.to_csv(output_file, sep="\t", index=False)

# Save random seed for reference
seed_file = Path(design_dir, "random_seed.txt")
with open(seed_file, "w") as f:
    f.write(str(random_seed))

output_file, seed_file
