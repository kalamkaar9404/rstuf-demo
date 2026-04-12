#!/usr/bin/env python3
"""
Sample Python application for RSTUF demo.
This is a simple app that will be secured using RSTUF.
"""

__version__ = "1.0.0"

def greet(name: str = "World") -> str:
    """Return a greeting message."""
    return f"Hello, {name}! This is a secure app protected by RSTUF."

def main():
    """Main entry point."""
    print(greet())
    print(f"Version: {__version__}")
    print("✅ This artifact was verified by TUF!")

if __name__ == "__main__":
    main()
