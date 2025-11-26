#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: Create a thumbnail preview of a FITS image

label: Thumbnail Generator

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: make_thumbnail.py
        entry: |
          #!/usr/bin/env python3
          """Generate a thumbnail PNG from a FITS image."""
          from astropy.io import fits
          from astropy.visualization import ZScaleInterval, ImageNormalize
          import matplotlib
          matplotlib.use('Agg')
          import matplotlib.pyplot as plt
          import numpy as np
          import sys
          
          def make_thumbnail(fits_file, output_file, size=256):
              with fits.open(fits_file) as hdul:
                  data = hdul[0].data
                  if data is None:
                      for ext in hdul[1:]:
                          if ext.data is not None:
                              data = ext.data
                              break
                  
                  if data is None:
                      print("No image data found")
                      # Create placeholder
                      fig, ax = plt.subplots(figsize=(4, 4))
                      ax.text(0.5, 0.5, 'No Data', ha='center', va='center', fontsize=20)
                      ax.set_xlim(0, 1)
                      ax.set_ylim(0, 1)
                      ax.axis('off')
                  else:
                      # Handle multi-dimensional data
                      while data.ndim > 2:
                          data = data[0]
                      
                      # Apply zscale normalization
                      norm = ImageNormalize(data, interval=ZScaleInterval())
                      
                      fig, ax = plt.subplots(figsize=(4, 4))
                      ax.imshow(data, origin='lower', cmap='viridis', norm=norm)
                      ax.axis('off')
                  
                  plt.tight_layout()
                  plt.savefig(output_file, dpi=64, bbox_inches='tight', 
                              facecolor='black', edgecolor='none')
                  plt.close()
                  
                  print(f"Thumbnail saved to {output_file}")
          
          if __name__ == "__main__":
              fits_file = sys.argv[1]
              output_file = sys.argv[2] if len(sys.argv) > 2 else "thumbnail.png"
              make_thumbnail(fits_file, output_file)

baseCommand: [python3, make_thumbnail.py]

inputs:
  fits_file:
    type: File
    doc: Input FITS file
    inputBinding:
      position: 1
  
  output_name:
    type: string
    default: "thumbnail.png"
    inputBinding:
      position: 2

outputs:
  thumbnail:
    type: File
    outputBinding:
      glob: "*.png"
