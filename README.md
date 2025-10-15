# Pip Download Script

A bash script to download Python packages for multiple Python versions.

## Description

This script downloads the `mrx_link` (v2.4.1) and `mrx-runway` (v1.13.1) packages and their dependencies for multiple Python versions (3.8, 3.9, 3.10, 3.11) using separate virtual environments.
`mrx_link_git` (v2.2.0) is resolved automatically as a dependency of `mrx_link`.

## Features

- Downloads packages for multiple Python versions
- Uses isolated virtual environments for each Python version
- Installs PostgreSQL development tools as prerequisites
- Downloads packages with dependencies to a specified output directory

## Prerequisites

- Ubuntu/Debian-based system with `sudo` privileges
- Python 3.8, 3.9, 3.10, and 3.11 installed
- Internet connection

## Usage

1. Make the script executable:
   ```bash
   chmod +x pip_download.sh
   ```

2. Run the script:
   ```bash
   ./pip_download.sh
   ```

## Configuration

You can modify the following variables in the script:

- `PYTHON_VERSIONS`: Array of Python versions to use
- `MRX_LINK_VERSION`: Version of `mrx_link` to download
- `MRX_RUNWAY_VERSION`: Version of `mrx-runway` to download
- `OUTPUT_ROOT`: Root directory for downloaded packages
- `PIP_INDEX_URL`: PyPI index URL to use for downloads

## Output

Downloaded packages will be stored in a directory combining the target versions, for example:
```
/root/pip_runway_download/mrx_link_2.4.1__mrx-runway_1.13.1/
```

## Dependencies

The script automatically installs:
- `libpq-dev` (PostgreSQL development headers)
- Updates pip in each virtual environment

## Notes

- Virtual environments are created in `/tmp/venv_runway/`
- The script includes `psycopg2<3.0.0,>=2.9.5` as an additional dependency
- Each Python version uses its own isolated virtual environment
