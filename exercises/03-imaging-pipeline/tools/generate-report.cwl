#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: CommandLineTool

doc: Generate an HTML report combining header, stats, and thumbnail

label: Report Generator

requirements:
  DockerRequirement:
    dockerPull: astronomy-tools:latest
  InitialWorkDirRequirement:
    listing:
      - entryname: generate_report.py
        entry: |
          #!/usr/bin/env python3
          """Generate HTML report from pipeline outputs."""
          import json
          import base64
          import sys
          from datetime import datetime
          
          def generate_report(header_file, stats_file, thumbnail_file, output_file):
              # Load data
              with open(header_file) as f:
                  header = json.load(f)
              with open(stats_file) as f:
                  stats = json.load(f)
              
              # Encode thumbnail as base64
              with open(thumbnail_file, 'rb') as f:
                  thumb_b64 = base64.b64encode(f.read()).decode()
              
              # Generate HTML
              html = f'''<!DOCTYPE html>
          <html>
          <head>
              <title>FITS Image Report</title>
              <style>
                  body {{ font-family: Arial, sans-serif; margin: 40px; background: #1a1a2e; color: #eee; }}
                  h1 {{ color: #00d4ff; border-bottom: 2px solid #00d4ff; padding-bottom: 10px; }}
                  h2 {{ color: #00d4ff; margin-top: 30px; }}
                  .container {{ max-width: 1000px; margin: 0 auto; }}
                  .stats-grid {{ display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }}
                  .stat-card {{ background: #16213e; padding: 20px; border-radius: 8px; text-align: center; }}
                  .stat-value {{ font-size: 24px; font-weight: bold; color: #00d4ff; }}
                  .stat-label {{ color: #888; margin-top: 5px; }}
                  .thumbnail {{ text-align: center; margin: 30px 0; }}
                  .thumbnail img {{ max-width: 400px; border: 2px solid #00d4ff; border-radius: 8px; }}
                  table {{ width: 100%; border-collapse: collapse; margin-top: 20px; }}
                  th, td {{ padding: 10px; text-align: left; border-bottom: 1px solid #333; }}
                  th {{ background: #16213e; color: #00d4ff; }}
                  .timestamp {{ color: #666; font-size: 12px; margin-top: 40px; }}
              </style>
          </head>
          <body>
              <div class="container">
                  <h1>FITS Image Analysis Report</h1>
                  
                  <div class="thumbnail">
                      <img src="data:image/png;base64,{thumb_b64}" alt="Image Preview">
                  </div>
                  
                  <h2>Image Statistics</h2>
                  <div class="stats-grid">
                      <div class="stat-card">
                          <div class="stat-value">{stats.get('mean', 'N/A'):.4f if isinstance(stats.get('mean'), (int, float)) else 'N/A'}</div>
                          <div class="stat-label">Mean</div>
                      </div>
                      <div class="stat-card">
                          <div class="stat-value">{stats.get('median', 'N/A'):.4f if isinstance(stats.get('median'), (int, float)) else 'N/A'}</div>
                          <div class="stat-label">Median</div>
                      </div>
                      <div class="stat-card">
                          <div class="stat-value">{stats.get('std', 'N/A'):.4f if isinstance(stats.get('std'), (int, float)) else 'N/A'}</div>
                          <div class="stat-label">Std Dev</div>
                      </div>
                      <div class="stat-card">
                          <div class="stat-value">{stats.get('min', 'N/A'):.4f if isinstance(stats.get('min'), (int, float)) else 'N/A'}</div>
                          <div class="stat-label">Minimum</div>
                      </div>
                      <div class="stat-card">
                          <div class="stat-value">{stats.get('max', 'N/A'):.4f if isinstance(stats.get('max'), (int, float)) else 'N/A'}</div>
                          <div class="stat-label">Maximum</div>
                      </div>
                      <div class="stat-card">
                          <div class="stat-value">{stats.get('total_pixels', 'N/A')}</div>
                          <div class="stat-label">Total Pixels</div>
                      </div>
                  </div>
                  
                  <h2>Selected Header Keywords</h2>
                  <table>
                      <tr><th>Keyword</th><th>Value</th></tr>
          '''
              
              # Add selected important header keywords
              important_keys = ['OBJECT', 'TELESCOP', 'INSTRUME', 'DATE-OBS', 'EXPTIME', 
                              'RA', 'DEC', 'NAXIS1', 'NAXIS2', 'BITPIX', 'BUNIT']
              for key in important_keys:
                  if key in header:
                      html += f'            <tr><td>{key}</td><td>{header[key]}</td></tr>\n'
              
              html += f'''        </table>
                  
                  <p class="timestamp">Report generated: {datetime.now().isoformat()}</p>
              </div>
          </body>
          </html>'''
              
              with open(output_file, 'w') as f:
                  f.write(html)
              
              print(f"Report generated: {output_file}")
          
          if __name__ == "__main__":
              generate_report(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])

baseCommand: [python3, generate_report.py]

inputs:
  header:
    type: File
    doc: Header JSON from extract-header
    inputBinding:
      position: 1
  
  stats:
    type: File
    doc: Statistics JSON from image-stats
    inputBinding:
      position: 2
  
  thumbnail:
    type: File
    doc: Thumbnail PNG from make-thumbnail
    inputBinding:
      position: 3
  
  output_name:
    type: string
    default: "report.html"
    inputBinding:
      position: 4

outputs:
  report:
    type: File
    outputBinding:
      glob: "*.html"
