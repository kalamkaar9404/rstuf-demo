#!/usr/bin/env python3
"""
TUF client verification example for RSTUF demo.
Downloads and verifies an artifact using TUF metadata.
"""

import sys
import os
from pathlib import Path

try:
    from tuf.ngclient import Updater
except ImportError:
    print("❌ Error: python-tuf not installed")
    print("Install with: pip install tuf")
    sys.exit(1)


def verify_and_download(target_path: str, 
                        metadata_url: str = "http://localstack.local/tuf-metadata/",
                        target_url: str = "http://localstack.local/artifacts/",
                        download_dir: str = "downloads"):
    """
    Download and verify an artifact using TUF.
    
    Args:
        target_path: Path to the artifact (e.g., "releases/myapp-1.0.0.whl")
        metadata_url: URL to TUF metadata
        target_url: URL to artifacts
        download_dir: Local directory to download to
    """
    
    print(f"🔍 Verifying artifact: {target_path}")
    print(f"   Metadata URL: {metadata_url}")
    print(f"   Target URL: {target_url}")
    print()
    
    # Create directories
    metadata_dir = Path("tuf-metadata")
    download_path = Path(download_dir)
    metadata_dir.mkdir(exist_ok=True)
    download_path.mkdir(exist_ok=True)
    
    try:
        # Initialize TUF updater
        print("📥 Initializing TUF client...")
        updater = Updater(
            metadata_dir=str(metadata_dir),
            metadata_base_url=metadata_url,
            target_base_url=target_url,
            target_dir=str(download_path)
        )
        
        # Refresh metadata
        print("🔄 Refreshing TUF metadata...")
        updater.refresh()
        print("✅ Metadata refreshed and verified")
        print()
        
        # Get target info
        print(f"🔍 Looking up target: {target_path}")
        target_info = updater.get_targetinfo(target_path)
        
        if target_info is None:
            print(f"❌ Error: Target not found in metadata: {target_path}")
            return False
        
        print("✅ Target found in metadata")
        print(f"   Length: {target_info.length} bytes")
        print(f"   SHA256: {target_info.hashes.get('sha256', 'N/A')}")
        print()
        
        # Download and verify
        print("📥 Downloading and verifying artifact...")
        path = updater.download_target(target_info)
        
        print()
        print("=" * 60)
        print("✅ SUCCESS! Artifact verified and downloaded")
        print("=" * 60)
        print(f"📁 Downloaded to: {path}")
        print(f"📊 Size: {target_info.length} bytes")
        print(f"🔐 SHA256: {target_info.hashes.get('sha256', 'N/A')}")
        print()
        print("🎉 The artifact is authentic and has not been tampered with!")
        
        return True
        
    except Exception as e:
        print()
        print("=" * 60)
        print("❌ VERIFICATION FAILED!")
        print("=" * 60)
        print(f"Error: {e}")
        print()
        print("⚠️  This could mean:")
        print("   - The artifact was tampered with")
        print("   - The metadata is invalid or expired")
        print("   - The artifact doesn't exist")
        print("   - Network issues")
        print()
        print("🛡️  DO NOT use this artifact!")
        
        return False


def main():
    """Main entry point."""
    
    if len(sys.argv) < 2:
        print("Usage: python verify-download.py <target-path>")
        print()
        print("Example:")
        print("  python verify-download.py releases/myapp-1.0.0.whl")
        print()
        print("Environment variables:")
        print("  METADATA_URL: TUF metadata URL (default: http://localstack.local/tuf-metadata/)")
        print("  TARGET_URL: Artifacts URL (default: http://localstack.local/artifacts/)")
        print("  DOWNLOAD_DIR: Download directory (default: downloads)")
        sys.exit(1)
    
    target_path = sys.argv[1]
    metadata_url = os.getenv("METADATA_URL", "http://localstack.local/tuf-metadata/")
    target_url = os.getenv("TARGET_URL", "http://localstack.local/artifacts/")
    download_dir = os.getenv("DOWNLOAD_DIR", "downloads")
    
    success = verify_and_download(target_path, metadata_url, target_url, download_dir)
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
