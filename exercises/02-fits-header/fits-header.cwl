#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: |
  Extract metadata from FITS file headers using astropy.
  Outputs header information as JSON.

label: FITS Header Extractor

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: fits_header.py
        entry: |
          #!/usr/bin/env python3
          """Extract FITS header to JSON format."""
          from astropy.io import fits
          import json
          import sys
          
          def extract_header(fits_file, output_file):
              """Extract header from FITS file and save as JSON."""
              with fits.open(fits_file) as hdul:
                  header = dict(hdul[0].header)
                  # Convert to JSON-serializable format
                  clean_header = {}
                  for k, v in header.items():
                      if k:  # Skip empty keys
                          try:
                              clean_header[k] = str(v)
                          except:
                              clean_header[k] = "UNPARSEABLE"
                  
                  # Add some metadata
                  clean_header['_num_extensions'] = len(hdul)
                  clean_header['_primary_shape'] = str(hdul[0].data.shape) if hdul[0].data is not None else "None"
              
              with open(output_file, 'w') as f:
                  json.dump(clean_header, f, indent=2)
              
              print(f"Extracted {len(clean_header)} header keywords to {output_file}")
          
          if __name__ == "__main__":
              if len(sys.argv) != 3:
                  print("Usage: fits_header.py <input.fits> <output.json>")
                  sys.exit(1)
              extract_header(sys.argv[1], sys.argv[2])

baseCommand: [python3, fits_header.py]

inputs:
  fits_file:
    type: File
    doc: Input FITS file to extract headers from
    inputBinding:
      position: 1
  
  output_name:
    type: string
    default: "header.json"
    doc: Name for the output JSON file
    inputBinding:
      position: 2

outputs:
  header_json:
    type: File
    doc: JSON file containing the extracted header
    outputBinding:
      glob: "*.json"

stdout: fits-header-log.txt
