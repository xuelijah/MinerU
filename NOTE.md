# MinerU Docker Deployment Guide for Apple Silicon

This guide provides detailed instructions for deploying MinerU using Docker, specifically optimized for Apple Silicon (ARM) architecture. The setup includes automatic configuration of MPS acceleration, volume mounting for real-time processing, and a structured batch processing system.

## Project Structure

```
.
├── data/
│   ├── input/      # Place PDF files here for processing
│   ├── output/     # Processed results will be saved here
│   └── logs/       # Application logs
├── docker/
│   └── global/     # Docker configuration files, the original file for the reference only
├── scripts/
│   └── batch_process.py  # Custom batch processing script
├── docker-compose.yml    # Docker Compose configuration
├── Dockerfile            # Docker configuration file, the one in use
└── NOTE.md              # This documentation
```

## Prerequisites

- Docker Desktop for Mac (Apple Silicon)
- Git
- At least 16GB RAM recommended (32GB preferred for optimal performance)
- At least 10GB free disk space (SSD recommended)
- macOS 11 or later

## Repository Setup

1. Clone the MinerU repository:
   ```bash
   git clone git@github.com:xuelijah/MinerU.git
   cd MinerU
   ```

2. Configure upstream repository:
   ```bash
   git remote add upstream https://github.com/opendatalab/MinerU.git
   ```

3. Keep your repository updated:
   ```bash
   # Using rebase strategy (recommended)
   git fetch upstream
   git rebase upstream/master

   # Or using merge strategy
   git fetch upstream
   git merge upstream/master
   ```

## Docker Configuration

The deployment uses a custom Docker configuration optimized for Apple Silicon:

- ARM64 platform support
- MPS (Metal Performance Shaders) acceleration enabled
- Volume mounts for real-time code synchronization
- Dedicated directories for input/output/logs
- Persistent container state

### Directory Structure

The Docker configuration uses a specific directory structure:
```
/app/MinerU/
├── magic_pdf/     # Core library files
├── scripts/       # Processing scripts
├── data/
│   ├── input/    # Input PDF files
│   ├── output/   # Processed results
│   └── logs/     # Application logs
└── requirements.txt  # Python dependencies
```

### Dependencies

The container includes all necessary dependencies for full functionality:
- Core ML libraries: PyTorch, torchvision, transformers
- Document processing: PyMuPDF, pdfminer.six
- Layout analysis: doclayout_yolo, ultralytics
- OCR and table extraction: rapid_table
- Utility packages: tqdm, loguru, PyYAML

### Key Features

1. **ARM Optimization**:
   - Native ARM64 image base
   - MPS acceleration for PyTorch operations
   - Optimized memory management

2. **Volume Mounting**:
   - Selective code mounting for better performance
   - Persistent data storage with read-write access
   - Separate mounts for source code and data

3. **Resource Management**:
   - Configurable worker count
   - Adjustable batch processing size
   - Memory-optimized container settings

## Deployment Steps

1. Build and start the container:
   ```bash
   docker-compose build mineru
   docker-compose up -d
   ```

2. Verify deployment:
   ```bash
   docker-compose ps
   ```

## Usage Guide

### Processing PDF Files

1. **Input Preparation**:
   - Place PDF files in the `data/input` directory
   - Files are automatically mounted in the container

2. **Basic Processing**:
   ```bash
   docker-compose exec mineru python3 /app/MinerU/scripts/batch_process.py
   ```

3. **Expected Output**:
   ```
   2025-04-21 02:17:11,869 - __main__ - INFO - Starting batch processing from /app/MinerU/data/input
   2025-04-21 02:17:11,870 - __main__ - INFO - Found X PDF files to process
   2025-04-21 02:17:11,870 - __main__ - INFO - Building dataset with 4 workers
   2025-04-21 02:17:11,872 - __main__ - INFO - Starting document processing
   ...
   2025-04-21 02:17:XX,XXX - __main__ - INFO - Batch processing completed successfully
   ```

4. **Advanced Processing Options**:
   ```bash
   docker-compose exec mineru python3 /app/MinerU/scripts/batch_process.py \
     --input_dir /app/MinerU/data/input \
     --output_dir /app/MinerU/data/output \
     --method auto \
     --lang "" \
     --num_workers 4 \
     --batch_size 200
   ```

### Output Files

After processing, you'll find in `data/output/`:
- `{filename}.md`: Markdown version of the PDF
- `{filename}.json`: Structured data extraction
- `{filename}/`: Directory containing:
  - Extracted images
  - Table data
  - Layout analysis results

### Monitoring and Logs

1. **Real-time Log Monitoring**:
   ```bash
   docker-compose logs -f mineru
   ```

2. **Access Log Files**:
   - Check `data/logs/mineru.log` for detailed processing logs
   - Monitor system resources using Docker Desktop

## Performance Optimization

### MPS Acceleration

The setup automatically enables MPS acceleration through environment variables:
```yaml
environment:
  - PYTORCH_ENABLE_MPS_FALLBACK=1
  - PYTORCH_MPS_ENABLE_IF_AVAILABLE=1
  - PYTHONPATH=/app/MinerU
```

### Batch Processing

Optimize performance by adjusting:
- `num_workers`: CPU thread count (default: 4)
- `batch_size`: Pages per batch (default: 200)
- Container memory limits in docker-compose.yml

## Troubleshooting

1. **Container Issues**:
   ```bash
   # Check container logs
   docker-compose logs mineru

   # Restart container
   docker-compose restart mineru

   # Complete rebuild
   docker-compose down
   docker-compose up -d --build --force-recreate
   ```

2. **Processing Issues**:
   - Check `data/logs/mineru.log` for errors
   - Verify file permissions in mounted directories
   - Ensure sufficient system resources

## Maintenance

### Regular Updates

1. Update from upstream:
   ```bash
   git fetch upstream
   git rebase upstream/master
   docker-compose up -d --build
   ```

2. Clean up resources:
   ```bash
   # Remove unused containers/images
   docker-compose down
   docker system prune

   # Clean output directory
   rm -rf data/output/*
   ```

### Best Practices

- Regularly pull updates from upstream
- Monitor log files for issues
- Back up important output data
- Clean up processed files periodically

## Support and Resources

- [MinerU GitHub Repository](https://github.com/opendatalab/MinerU)
- [MinerU Documentation](https://github.com/opendatalab/MinerU/tree/master/docs)
- [Issue Tracker](https://github.com/opendatalab/MinerU/issues)
- Log files: `data/logs/mineru.log` 