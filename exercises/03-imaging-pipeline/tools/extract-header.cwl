#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: Extract FITS header to JSON

label: FITS Header Extractor

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: extract_header.py
        entry: |
          #!/usr/bin/env python3
          """Extract FITS header to JSON."""
          from astropy.io import fits
          import json
          import sys
          
          def extract_header(fits_file, output_file):
              with fits.open(fits_file) as hdul:
                  header = dict(hdul[0].header)
                  clean_header = {k: str(v) for k, v in header.items() if k}
              
              with open(output_file, 'w') as f:
                  json.dump(clean_header, f, indent=2)
              
              print(f"Extracted {len(clean_header)} keywords")
          
          if __name__ == "__main__":
              extract_header(sys.argv[1], sys.argv[2])

baseCommand: [python3, extract_header.py]

inputs:
  fits_file:
    type: File
    inputBinding:
      position: 1
  
  output_name:
    type: string
    default: "header.json"
    inputBinding:
      position: 2

outputs:
  header_json:
    type: File
    outputBinding:
      glob: "*.json"
