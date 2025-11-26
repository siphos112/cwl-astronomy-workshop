#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: |
  Flag radio frequency interference (RFI) and bad data in a measurement set.
  Uses aoflagger or similar flagging strategy.

label: RFI Flagging

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.ms)
        writable: true
      - entryname: flag_data.py
        entry: |
          #!/usr/bin/env python3
          """Simulate RFI flagging on measurement set."""
          import json
          import sys
          import os
          import shutil
          
          def flag_data(ms_path, output_dir, strategy):
              # In a real implementation, this would call aoflagger
              # For the workshop, we simulate the operation
              
              # Copy MS to output (simulating in-place flagging)
              output_ms = os.path.join(output_dir, os.path.basename(ms_path))
              if os.path.exists(output_ms):
                  shutil.rmtree(output_ms)
              shutil.copytree(ms_path, output_ms)
              
              # Generate flag summary
              summary = {
                  "total_visibilities": 1000000,
                  "flagged_visibilities": 45000,
                  "flag_percentage": 4.5,
                  "strategy_used": strategy,
                  "rfi_detected_channels": [120, 121, 122, 380, 381],
                  "bad_antennas": [],
                  "status": "success"
              }
              
              with open("flag_summary.json", "w") as f:
                  json.dump(summary, f, indent=2)
              
              print(f"Flagged {summary['flag_percentage']}% of data")
              return output_ms
          
          if __name__ == "__main__":
              ms = sys.argv[1]
              strategy = sys.argv[2] if len(sys.argv) > 2 else "default"
              flag_data(ms, ".", strategy)

baseCommand: [python3, flag_data.py]

inputs:
  ms:
    type: Directory
    doc: Input measurement set
    inputBinding:
      position: 1
  
  strategy:
    type: string
    default: "ska-default"
    doc: Flagging strategy name
    inputBinding:
      position: 2

outputs:
  flagged_ms:
    type: Directory
    outputBinding:
      glob: "*.ms"
  
  flag_summary:
    type: File
    outputBinding:
      glob: "flag_summary.json"
