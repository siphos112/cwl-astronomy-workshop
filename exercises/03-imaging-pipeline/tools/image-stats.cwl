#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: Calculate statistics for a FITS image

label: Image Statistics Calculator

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: image_stats.py
        entry: |
          #!/usr/bin/env python3
          """Calculate basic statistics for a FITS image."""
          from astropy.io import fits
          import numpy as np
          import json
          import sys
          
          def calculate_stats(fits_file, output_file):
              with fits.open(fits_file) as hdul:
                  data = hdul[0].data
                  if data is None:
                      # Try first extension with data
                      for ext in hdul[1:]:
                          if ext.data is not None:
                              data = ext.data
                              break
                  
                  if data is None:
                      stats = {"error": "No image data found"}
                  else:
                      # Handle NaN values
                      valid_data = data[np.isfinite(data)]
                      stats = {
                          "shape": list(data.shape),
                          "dtype": str(data.dtype),
                          "min": float(np.min(valid_data)) if len(valid_data) > 0 else None,
                          "max": float(np.max(valid_data)) if len(valid_data) > 0 else None,
                          "mean": float(np.mean(valid_data)) if len(valid_data) > 0 else None,
                          "median": float(np.median(valid_data)) if len(valid_data) > 0 else None,
                          "std": float(np.std(valid_data)) if len(valid_data) > 0 else None,
                          "total_pixels": int(data.size),
                          "valid_pixels": int(len(valid_data)),
                          "nan_pixels": int(data.size - len(valid_data))
                      }
              
              with open(output_file, 'w') as f:
                  json.dump(stats, f, indent=2)
              
              print(f"Statistics calculated: mean={stats.get('mean', 'N/A'):.4f}")
          
          if __name__ == "__main__":
              calculate_stats(sys.argv[1], sys.argv[2])

baseCommand: [python3, image_stats.py]

inputs:
  fits_file:
    type: File
    doc: Input FITS file
    inputBinding:
      position: 1
  
  output_name:
    type: string
    default: "stats.json"
    inputBinding:
      position: 2

outputs:
  stats_json:
    type: File
    outputBinding:
      glob: "*.json"
