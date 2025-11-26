#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: |
  Solve for time-variable gain calibration.
  Determines amplitude and phase corrections over time.

label: Gain Calibration

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: calibrate_gains.py
        entry: |
          #!/usr/bin/env python3
          """Simulate gain calibration."""
          import json
          import sys
          
          def calibrate_gains(ms_path, source, bandpass_table, output_table, sol_int):
              solutions = {
                  "type": "gains",
                  "source": source,
                  "solution_interval_sec": sol_int,
                  "n_solutions": 120,
                  "reference_antenna": "ea01",
                  "applied_bandpass": bandpass_table,
                  "amplitude_rms": 0.02,
                  "phase_rms_deg": 5.4,
                  "snr_median": 156.2,
                  "failed_solutions": 2,
                  "status": "success"
              }
              
              with open(output_table, "w") as f:
                  json.dump(solutions, f, indent=2)
              
              print(f"Gain calibration complete: {solutions['n_solutions']} solutions")
          
          if __name__ == "__main__":
              calibrate_gains(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], float(sys.argv[5]))

baseCommand: [python3, calibrate_gains.py]

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
  
  bandpass_table:
    type: File
    doc: Bandpass calibration table
    inputBinding:
      position: 3
  
  output_name:
    type: string
    default: "gains.json"
    inputBinding:
      position: 4
  
  solution_interval:
    type: float
    default: 60.0
    doc: Solution interval in seconds
    inputBinding:
      position: 5

outputs:
  gain_table:
    type: File
    outputBinding:
      glob: "gains.json"
