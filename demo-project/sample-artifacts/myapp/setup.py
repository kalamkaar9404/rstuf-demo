from setuptools import setup, find_packages

setup(
    name="rstuf-demo-app",
    version="1.0.0",
    description="Sample application for RSTUF tutorial",
    author="Your Name",
    author_email="your.email@example.com",
    packages=find_packages(),
    py_modules=["app"],
    entry_points={
        "console_scripts": [
            "rstuf-demo=app:main",
        ],
    },
    python_requires=">=3.8",
    classifiers=[
        "Development Status :: 4 - Beta",
        "Intended Audience :: Developers",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.8",
        "Programming Language :: Python :: 3.9",
        "Programming Language :: Python :: 3.10",
        "Programming Language :: Python :: 3.11",
    ],
)
