#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: Apply calibration solutions to target data

label: Apply Calibration

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.ms)
        writable: true
      - entryname: apply_calibration.py
        entry: |
          #!/usr/bin/env python3
          """Simulate applying calibration."""
          import json
          import sys
          import os
          import shutil
          
          def apply_calibration(ms_path, bandpass, gains, target, output_dir):
              output_ms = os.path.join(output_dir, "calibrated_" + os.path.basename(ms_path))
              if os.path.exists(output_ms):
                  shutil.rmtree(output_ms)
              shutil.copytree(ms_path, output_ms)
              
              result = {
                  "target_source": target,
                  "applied_bandpass": bandpass,
                  "applied_gains": gains,
                  "n_visibilities_calibrated": 850000,
                  "status": "success"
              }
              
              with open("apply_summary.json", "w") as f:
                  json.dump(result, f, indent=2)
              
              print(f"Calibration applied to {result['n_visibilities_calibrated']} visibilities")
          
          if __name__ == "__main__":
              apply_calibration(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], ".")

baseCommand: [python3, apply_calibration.py]

inputs:
  ms:
    type: Directory
    inputBinding:
      position: 1
  
  bandpass_table:
    type: File
    inputBinding:
      position: 2
  
  gain_table:
    type: File
    inputBinding:
      position: 3
  
  target_source:
    type: string
    inputBinding:
      position: 4

outputs:
  calibrated_ms:
    type: Directory
    outputBinding:
      glob: "calibrated_*.ms"
  
  apply_summary:
    type: File
    outputBinding:
      glob: "apply_summary.json"
