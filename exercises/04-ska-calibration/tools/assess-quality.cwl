#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: Assess image quality and generate metrics report

label: Quality Assessment

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: assess_quality.py
        entry: |
          #!/usr/bin/env python3
          """Assess image quality metrics."""
          from astropy.io import fits
          import numpy as np
          import json
          import sys
          from datetime import datetime
          
          def assess_quality(image_file, output_file):
              with fits.open(image_file) as hdul:
                  data = hdul[0].data
                  header = hdul[0].header
                  
                  # Handle multi-dimensional data
                  while data.ndim > 2:
                      data = data[0]
                  
                  # Calculate quality metrics
                  rms = np.std(data)
                  peak = np.max(data)
                  dynamic_range = peak / rms if rms > 0 else 0
                  
                  # Simple source detection (peaks above 5 sigma)
                  threshold = 5 * rms
                  sources = np.sum(data > threshold)
                  
                  metrics = {
                      "timestamp": datetime.now().isoformat(),
                      "image_file": image_file,
                      "image_shape": list(data.shape),
                      "rms_noise_jy": float(rms),
                      "peak_flux_jy": float(peak),
                      "dynamic_range": float(dynamic_range),
                      "sources_detected_5sigma": int(sources),
                      "beam_major_arcsec": header.get('BMAJ', 0) * 3600,
                      "beam_minor_arcsec": header.get('BMIN', 0) * 3600,
                      "beam_pa_deg": header.get('BPA', 0),
                      "quality_grade": "A" if dynamic_range > 1000 else "B" if dynamic_range > 100 else "C",
                      "status": "success"
                  }
              
              with open(output_file, "w") as f:
                  json.dump(metrics, f, indent=2)
              
              print(f"Quality assessment: DR={metrics['dynamic_range']:.1f}, Grade={metrics['quality_grade']}")
          
          if __name__ == "__main__":
              assess_quality(sys.argv[1], sys.argv[2])

baseCommand: [python3, assess_quality.py]

inputs:
  image:
    type: File
    doc: FITS image to assess
    inputBinding:
      position: 1
  
  output_name:
    type: string
    default: "quality_report.json"
    inputBinding:
      position: 2

outputs:
  report:
    type: File
    outputBinding:
      glob: "*.json"
