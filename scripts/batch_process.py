import os
import sys
import logging
from pathlib import Path
from magic_pdf.data.batch_build_dataset import batch_build_dataset
from magic_pdf.tools.common import batch_do_parse

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/app/MinerU/data/logs/mineru.log'),
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

def process_pdfs(
    input_dir: str = "/app/MinerU/data/input",
    output_dir: str = "/app/MinerU/data/output",
    method: str = "auto",
    lang: str = "",
    num_workers: int = 4,
    batch_size: int = 200
):
    """
    Process PDFs in batch from input directory.
    
    Args:
        input_dir: Directory containing PDF files
        output_dir: Directory to save processed results
        method: Processing method ('auto', 'layout', or 'vision')
        lang: Language code (empty for auto-detection)
        num_workers: Number of worker processes
        batch_size: Number of pages to process in one batch
    """
    try:
        logger.info(f"Starting batch processing from {input_dir}")
        os.makedirs(output_dir, exist_ok=True)
        
        # Collect PDF paths
        doc_paths = list(Path(input_dir).glob('*.pdf'))
        if not doc_paths:
            logger.warning(f"No PDF files found in {input_dir}")
            return
            
        logger.info(f"Found {len(doc_paths)} PDF files to process")
        
        # Set batch size for inference
        os.environ["MINERU_MIN_BATCH_INFERENCE_SIZE"] = str(batch_size)
        
        # Build dataset
        logger.info(f"Building dataset with {num_workers} workers")
        datasets = batch_build_dataset(doc_paths, num_workers, lang)
        
        # Process documents
        logger.info("Starting document processing")
        batch_do_parse(
            output_dir,
            [str(doc_path.stem) for doc_path in doc_paths],
            datasets,
            method
        )
        
        logger.info("Batch processing completed successfully")
        
    except Exception as e:
        logger.error(f"Error during batch processing: {str(e)}", exc_info=True)
        raise

if __name__ == '__main__':
    process_pdfs() 