# Exercise 2: FITS Header Extraction

In this exercise, you'll create a CWL tool that extracts metadata from FITS files using Python and astropy.

## Learning Objectives

- Use Docker containers in CWL
- Work with File inputs and outputs
- Understand requirements and hints
- Handle real astronomical data formats

## Background

FITS (Flexible Image Transport System) is the standard data format in astronomy. Every FITS file contains headers with metadata about the observation.

### Key Concepts

1. **DockerRequirement**: Specifies a container to run the tool
2. **File type**: For file inputs/outputs
3. **InitialWorkDirRequirement**: Set up the working directory
4. **InlineJavascriptRequirement**: Enable JavaScript expressions

## Exercise

### Step 1: Examine the Python Script

Look at `fits_header.py`:

```python
#!/usr/bin/env python3
from astropy.io import fits
import json
import sys

def extract_header(fits_file, output_file):
    with fits.open(fits_file) as hdul:
        header = dict(hdul[0].header)
        # Convert to JSON-serializable format
        clean_header = {k: str(v) for k, v in header.items() if k}
        
    with open(output_file, 'w') as f:
        json.dump(clean_header, f, indent=2)

if __name__ == "__main__":
    extract_header(sys.argv[1], sys.argv[2])
```

### Step 2: Complete the CWL Tool

Fill in the missing parts of `fits-header.cwl`:

```yaml
cwlVersion: v1.2
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: fits_header.py
        entry: |
          #!/usr/bin/env python3
          # Your script here...

baseCommand: [python3, fits_header.py]

inputs:
  fits_file:
    type: File
    doc: Input FITS file
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
```

### Step 3: Create the Job File

Create `fits-header-job.yml`:

```yaml
fits_file:
  class: File
  path: ../../data/sample-fits/observation.fits

output_name: observation-header.json
```

### Step 4: Run the Tool

```bash
cwltool fits-header.cwl fits-header-job.yml
```

### Step 5: Examine the Output

```bash
cat observation-header.json | python -m json.tool
```

## Challenge

Extend the tool to:

1. Accept an optional list of specific header keywords to extract
2. Output both JSON and a human-readable text summary
3. Handle multi-extension FITS files

## Key Takeaways

- Docker containers provide reproducible environments
- File inputs/outputs handle data files
- InitialWorkDirRequirement can embed scripts
- CWL separates tool definition from inputs

## Next Steps

Continue to [Exercise 3: Imaging Pipeline](../03-imaging-pipeline/).
