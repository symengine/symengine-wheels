#!/bin/bash
conda-smithy rerender
cat extra.yml >> .github/workflows/conda-build.yml
