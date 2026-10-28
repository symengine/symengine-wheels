# Notes for agents

This repo is a conda-smithy feedstock that builds PyPI wheels for symengine.py
(recipe in `recipe/`, default branch `conda`).

## Rerendering

Always rerender with `./rerender.sh`, not `conda-smithy rerender` directly.
After rerendering, `extra.yml` must be appended to
`.github/workflows/conda-build.yml`. It adds the steps that upload the built
wheels as workflow artifacts and to the GitHub release on tag builds, and
conda-smithy drops them on every rerender. `rerender.sh` does the append.
Check that the end of `conda-build.yml` still parses as YAML afterwards.
