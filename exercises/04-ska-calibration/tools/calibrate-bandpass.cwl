#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: |
  Solve for bandpass calibration using a calibrator source.
  Determines frequency-dependent gain corrections.

label: Bandpass Calibration

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: calibrate_bandpass.py
        entry: |
          #!/usr/bin/env python3
          """Simulate bandpass calibration."""
          import json
          import sys
          import numpy as np
          
          def calibrate_bandpass(ms_path, source, output_table):
              # Simulate bandpass solution
              n_channels = 512
              n_antennas = 64
              
              # Generate mock bandpass solutions
              solutions = {
                  "type": "bandpass",
                  "source": source,
                  "n_channels": n_channels,
                  "n_antennas": n_antennas,
                  "reference_antenna": "ea01",
                  "solution_interval": "inf",
                  "snr_min": 15.2,
                  "snr_max": 245.8,
                  "snr_median": 89.4,
                  "failed_solutions": 0,
                  "status": "success"
              }
              
              with open(output_table, "w") as f:
                  json.dump(solutions, f, indent=2)
              
              print(f"Bandpass calibration complete: median SNR = {solutions['snr_median']}")
          
          if __name__ == "__main__":
              calibrate_bandpass(sys.argv[1], sys.argv[2], sys.argv[3])

baseCommand: [python3, calibrate_bandpass.py]

inputs:
  ms:
    type: Directory
    doc: Input measurement set
    inputBinding:
      position: 1
  
  source:
    type: string
    doc: Calibrator source name
    inputBinding:
      position: 2
  
  output_name:
    type: string
    default: "bandpass.json"
    inputBinding:
      position: 3

outputs:
  bandpass_table:
    type: File
    outputBinding:
      glob: "bandpass.json"
