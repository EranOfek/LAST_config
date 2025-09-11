#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Sep 11 16:43:52 2025

@author: Ron
"""

import pandas as pd
import os

# Path for YAML files
yaml_dir = os.path.expanduser("~/matlab/LAST/LAST_config/config/obs.focuser")

# Read slope values
df = pd.read_excel("~/matlab/LAST/LAST_config/config/obs.focuser/slopes_BestPos_Temp_10_09_2025.xlsx")

for _, row in df.iterrows():
    mount = int(row["mount"])
    scope = int(row["scope"])
    slope = row["slope_avg"]

    # Build full file path
    filename = f"obs.focuser.{mount:02d}_1_{scope}.create.yml"
    filepath = os.path.join(yaml_dir, filename)

    # Read existing YAML content
    with open(filepath, "r") as f:
        lines = f.readlines()

    # Replace the FocusTempDeriv line
    new_lines = []
    for line in lines:
        if line.strip().startswith("FocusTempDeriv"):
            new_lines.append(f"FocusTempDeriv : {slope}\n")
        else:
            new_lines.append(line)

    # Write back
    with open(filepath, "w") as f:
        f.writelines(new_lines)

    print(f"Updated {filepath}")
