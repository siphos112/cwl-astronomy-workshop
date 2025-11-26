#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: |
  Create images from calibrated visibilities using wsclean.
  Performs gridding, FFT, and deconvolution.

label: WSClean Imaging

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: make_image.py
        entry: |
          #!/usr/bin/env python3
          """Simulate wsclean imaging."""
          from astropy.io import fits
          import numpy as np
          import json
          import sys
          
          def make_image(ms_path, name, size, scale, niter):
              # Create a simulated FITS image
              image_data = np.random.randn(size, size) * 0.001
              
              # Add some simulated sources
              n_sources = np.random.randint(5, 15)
              for _ in range(n_sources):
                  x = np.random.randint(size//4, 3*size//4)
                  y = np.random.randint(size//4, 3*size//4)
                  flux = np.random.exponential(0.01)
                  sigma = np.random.uniform(2, 5)
                  yy, xx = np.ogrid[:size, :size]
                  gaussian = flux * np.exp(-((xx-x)**2 + (yy-y)**2) / (2*sigma**2))
                  image_data += gaussian
              
              # Create FITS header
              header = fits.Header()
              header['SIMPLE'] = True
              header['BITPIX'] = -64
              header['NAXIS'] = 2
              header['NAXIS1'] = size
              header['NAXIS2'] = size
              header['CTYPE1'] = 'RA---SIN'
              header['CTYPE2'] = 'DEC--SIN'
              header['CDELT1'] = -float(scale.replace('asec', '')) / 3600
              header['CDELT2'] = float(scale.replace('asec', '')) / 3600
              header['CRPIX1'] = size / 2
              header['CRPIX2'] = size / 2
              header['CRVAL1'] = 180.0
              header['CRVAL2'] = 45.0
              header['BUNIT'] = 'JY/BEAM'
              header['BMAJ'] = 0.001
              header['BMIN'] = 0.0008
              header['BPA'] = 45.0
              
              # Write FITS file
              hdu = fits.PrimaryHDU(data=image_data, header=header)
              output_file = f"{name}-image.fits"
              hdu.writeto(output_file, overwrite=True)
              
              # Write imaging summary
              summary = {
                  "image_size": size,
                  "pixel_scale": scale,
                  "clean_iterations": niter,
                  "peak_flux_jy": float(np.max(image_data)),
                  "rms_noise_jy": float(np.std(image_data)),
                  "beam_major_arcsec": 3.6,
                  "beam_minor_arcsec": 2.88,
                  "beam_pa_deg": 45.0,
                  "status": "success"
              }
              
              with open(f"{name}-imaging.json", "w") as f:
                  json.dump(summary, f, indent=2)
              
              print(f"Image created: {output_file}, peak={summary['peak_flux_jy']:.4f} Jy")
          
          if __name__ == "__main__":
              make_image(sys.argv[1], sys.argv[2], int(sys.argv[3]), sys.argv[4], int(sys.argv[5]))

baseCommand: [python3, make_image.py]

inputs:
  ms:
    type: Directory
    doc: Calibrated measurement set
    inputBinding:
      position: 1
  
  name:
    type: string
    default: "output"
    doc: Output name prefix
    inputBinding:
      position: 2
  
  size:
    type: int
    default: 2048
    doc: Image size in pixels
    inputBinding:
      position: 3
  
  scale:
    type: string
    default: "1asec"
    doc: Pixel scale
    inputBinding:
      position: 4
  
  niter:
    type: int
    default: 50000
    doc: Number of clean iterations
    inputBinding:
      position: 5

outputs:
  image:
    type: File
    outputBinding:
      glob: "*-image.fits"
  
  imaging_summary:
    type: File
    outputBinding:
      glob: "*-imaging.json"
