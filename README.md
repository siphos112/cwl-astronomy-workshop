# CWL for SKA Data Processing Workshop

A 3-hour hands-on workshop introducing Common Workflow Language (CWL) for astronomical data processing, with a focus on Square Kilometre Array (SKA) applications.

## Workshop Overview

This workshop teaches astronomers and data scientists how to create reproducible, portable data processing pipelines using CWL. By the end, participants will be able to build and execute workflows for astronomical data processing.

### Learning Objectives

- Understand CWL fundamentals (YAML syntax, workflow components, CWL philosophy)
- Build basic CWL workflows (CommandLineTool and Workflow definitions)
- Apply CWL to SKA context (astronomical data processing pipelines)
- Execute workflows locally and understand execution environments
- Debug and troubleshoot common issues
- Plan production deployment to SRCNet infrastructure

## Prerequisites

Complete these steps **before the workshop** to ensure a smooth experience.

### Required Software

1. **Docker Desktop** (4GB+ RAM allocation)
   ```bash
   docker run hello-world  # Test installation
   ```

2. **CWL Reference Runner** (cwltool)
   ```bash
   # Create a virtual environment in your workshop directory
   # (run this after cloning the repository)
   cd cwl-astronomy-workshop
   python3 -m venv cwl-workshop-env
   source cwl-workshop-env/bin/activate  # Linux/macOS
   # or: cwl-workshop-env\Scripts\activate  # Windows
   
   # Install cwltool
   pip install cwltool
   
   # Alternatively, use conda
   # conda create -n cwl-workshop python=3.11 cwltool -c conda-forge
   # conda activate cwl-workshop
   
   cwltool --version  # Test installation
   ```

3. **Text Editor with YAML Support**
   - VSCode recommended with [CWL extension](https://marketplace.visualstudio.com/items?itemName=Benten.benten)

4. **Git**
   ```bash
   git --version  # Test installation
   ```

### System Requirements

- 8GB+ RAM (16GB recommended)
- 10GB free disk space
- macOS, Linux, or Windows 10+ with WSL2

## Quick Start

```bash
# Clone the repository
git clone https://github.com/siphos112/cwl-astronomy-workshop.git
cd cwl-astronomy-workshop

# Activate your virtual environment (see Prerequisites if not yet created)
source cwl-workshop-env/bin/activate  # Linux/macOS

# Verify your setup
./setup/workshop-check.sh

# Build the workshop Docker image
docker build -t astronomy-tools:latest docker/astronomy-tools/

# Run your first workflow
cd exercises/01-hello-cwl
cwltool hello.cwl hello-job.yml
```

## Repository Structure

```
cwl-astronomy-workshop/
├── README.md                 # This file
├── setup/                    # Setup scripts and verification
│   └── workshop-check.sh     # Environment verification script
├── data/                     # Sample data files
│   ├── sample-fits/          # FITS files for exercises
│   └── measurement-sets/     # SKA measurement sets
├── exercises/                # Hands-on exercises
│   ├── 01-hello-cwl/         # Basic introduction
│   ├── 02-fits-header/       # FITS metadata extraction
│   ├── 03-imaging-pipeline/  # Multi-step workflow
│   └── 04-ska-calibration/   # Complete SKA example
├── slides/                   # Presentation materials
├── docker/                   # Docker configurations
│   └── astronomy-tools/      # Workshop Docker image
├── cheatsheets/              # Quick reference guides
└── solutions/                # Complete exercise solutions
```

## Exercises

### Exercise 1: Hello CWL
Introduction to CWL syntax and basic concepts. Create your first CommandLineTool.

### Exercise 2: FITS Header Extraction
Build a tool to extract metadata from FITS files using astropy.

### Exercise 3: Imaging Pipeline
Create a multi-step workflow connecting multiple tools.

### Exercise 4: SKA Calibration Pipeline
Complete real-world example using SKA data processing tools.

## Workshop Timeline

| Time | Topic |
|------|-------|
| 0:00-0:15 | Introduction & Setup Verification |
| 0:15-0:45 | CWL Fundamentals |
| 0:45-1:15 | Exercise 1 & 2 |
| 1:15-1:30 | Break |
| 1:30-2:15 | Workflows & Exercise 3 |
| 2:15-2:45 | SKA Use Cases & Exercise 4 |
| 2:45-3:00 | Wrap-up & Next Steps |

## Resources

- [CWL Specification](https://www.commonwl.org/specification/)
- [CWL User Guide](https://www.commonwl.org/user_guide/)
- [SKA Developer Portal](https://developer.skao.int/)
- [RASCIL Documentation](https://ska-telescope.gitlab.io/external/rascil/)

## Support

- **Workshop Slack**: #cwl-workshop
- **Email**: cwl-support@ska.org
- **Office Hours**: Wednesdays 14:00 UTC

## License

This workshop material is licensed under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

## Acknowledgments

Developed by the SKA Observatory in collaboration with the CWL community.
