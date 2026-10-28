#!/bin/bash
conda-smithy rerender
# conda-smithy's output may not end with a newline
printf '\n\n' >> .github/workflows/conda-build.yml
cat extra.yml >> .github/workflows/conda-build.yml
git add .github/workflows/conda-build.yml
