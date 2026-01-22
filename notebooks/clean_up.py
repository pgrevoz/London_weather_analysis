from pathlib import Path
import pandas as pd

path = Path("data/raw/heathrow_monthly_weather.txt")
output_path = Path("data/processed/heathrow_monthly_weather.csv")

# Read file as text
lines = path.read_text().splitlines()

# Find the header row (the one starting with 'yyyy')
header_idx = next(
    i for i, line in enumerate(lines)
    if line.strip().lower().startswith("yyyy")
)

# Read the data from the real header
df = pd.read_fwf(path, skiprows=header_idx)

# Clean column names
df.columns = [c.strip().lower() for c in df.columns]

# Replace Met Office missing values and strip quality flags
df = df.replace({"---": pd.NA, "--": pd.NA})
df = df.replace(r"[*#]$", "", regex=True)

# Convert numeric columns
# Convert numeric columns (coerce non-finite or flagged values)
for c in df.columns:
    df[c] = pd.to_numeric(df[c], errors="coerce")

# Build a proper date column
df["date"] = pd.to_datetime(
    {"year": df["yyyy"], "month": df["mm"], "day": 1},
    errors="coerce",
)

df.to_csv(output_path, index=False)

print(f"Wrote cleaned data to {output_path}")
