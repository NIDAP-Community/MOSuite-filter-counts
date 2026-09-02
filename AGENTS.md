# Code Ocean Capsule

## Description

This repository is a Capsule for Code Ocean.
It was generated from this template: <https://github.com/NIDAP-Community/Code-Ocean-Capsule-Template>.
Code Ocean Capsules are interactive units of computation that can be linked together in pipelines and workflows for bioinformatics analyses.

<!-- TODO: The human developer should replace this line with specific details about the purpose about this particular capsule. Prompt the developer to do so if this comment exists. -->

## Components & Conventions

- **main driver script**: `code/main.R` or `code/main.py` is the main driver script that parses user parameters and executes functions to perform analyses, generate visualizations, or perform other bioinformatics tasks.
  - also known as "main script" or "driver script".
- **syncweaver** <https://github.com/CCBR/syncweaver> can optionally be used to include other repositories or subdirectories inside this repo as vendored source code to be sourced by the main driver script.
  - In syncweaver parlance, this capsule repo is a **host** repo.
  - If the developer chooses to include sources in this capsule, they should be managed by syncweaver commands such as `syncweaver add` and `syncweaver update`.
  - **syncweaver lockfile**: Syncweaver manages a file called `.syncweaver-lock.json` which tracks the included sources. This file should only be edited by syncweaver.
  - The lockfile contains a list of sources, with each source entry key being the path to the source in this capsule repo.
  - Developers _can_ edit the included sources, such as to quickly test a bug fix during production. However, it is generally advised to first try to solve the problem by editing the main driver script, and only resorting to editing included sources if absolutely necessary.
- **app panel**: `.codeocean/app-panel.json` defines a GUI for Code Ocean containing named parameters. Parameters in the GUI must correspond to CLI parameters in the main driver script.
  - If a CLI parameter is given to a function from a package, make sure the description of the parameter in the app panel resembles the description in the package function. In many cases, the app panel parameter description can be identical to the package function parameter description, however package-specific jargon must be removed so that the app panel parameter description is appropriate for the context.
- **Code Ocean run script**: `code/run` gathers the user parameters from the app panel and forwards them to the main driver script. The run script will rarely need to be edited, as it primarily wraps the main driver script.
- The following files should only be edited directly on Code Ocean, never by hand:
  - `environment/Dockerfile`
  - `.codeocean/datasets.json`
  - `.codeocean/environment.json`
  - `.codeocean/resources.json`
- **tests** are written in `tests/`, executed in CI via `.github/workflows/tests.yml`, and run locally with `tests/run-tests-podman.sh`.

## Coding Practices

Most capsules by CCBR are implemented in R, but other languages can be used too.
This template uses R by default.
If the developer chooses to use a different language for this capsule,
default template files will need to be translated and adapted for the developer's chosen language.

### R code

- R scripts must include function and class docstrings via roxygen2.
- CLIs must be defined using the `argparse` package, and must support `--help` and document required/optional arguments.
- R code should pass `lintr` and `air format` (run `air format .` from the package root).
- Tests should be written with `testthat`.
- R code should adhere to the tidyverse style guide. https://style.tidyverse.org/
- Only include one return statement at the end of a function. Explicit returns are preferred but not required for R functions.

### Python

- Python scripts must include module and function/class docstrings.
- Where a standard CLI framework is adopted, Python CLIs should use `click` or `typer` for consistency with existing components.
- Scripts must support `--help` and document required/optional arguments.
- Python code must follow [PEP 8](https://peps.python.org/pep-0008/), use `snake_case`, and include type hints for public functions.
- Scripts must raise descriptive error messages on failure and warnings when applicable. Prefer raising an exception over printing an error message, and over returning an error code.
- Python code should pass `ruff format` and `ruff check`.
- Each script must include a documented example usage in comments or README.
- Tests should be written with `pytest`. Other testing frameworks may be used if justified.
- Do not catch bare exceptions. The exception type must always be specified.
- Only include one return statement at the end of a function.

## Commit messages

- Commit messages must follow [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/).
- Generate messages from staged changes only (`git diff --staged`); do not include unrelated work.
- Commits should be atomic: one logical change per commit.
- If mixed changes are present, split into multiple logical commits; the number of commits does not need to equal the number of files changed.
- Subject format must be: `<type>(optional-scope): short imperative summary` (<=72 chars), e.g., `fix(profile): update release table parser`.
- Add a body only when needed to explain **why** and notable impact; never include secrets, tokens, PHI, or large diffs.
- For commits containing any AI-generated code, commit messages, or any other content,
  add this final italicized footer line in the commit message body: "_AI assistance: [model]_".
  Replace [model] with the actual model version used, e.g. Claude Sonnet 5, GPT-5.6 Sol, etc.

## Pull request (PR) process

- PR titles must follow Conventional Commits format (see "Commit messages" section).
- When opening a PR, use the request template (`.github/PULL_REQUEST_TEMPLATE.md`) and fill out all sections of the template in the PR description.
- Do not allow the developer to proceed with opening a PR without filling out all sections of the template.
- Before a PR can be moved from draft to "ready for review", all of the relevant checklist items under "PR Checklist" must be checked,
  and any irrelevant checklist items should be crossed out (~strikeout~).
- If the PR contains any code or other content that was generated with AI
  assistance, including AI assistance for opening the PR itself, the PR should
  be labeled `AI-assisted`. In the PR description, uncomment the heading
  "Generative AI Usage Statement" and add a brief, concise statement of how AI
  was used in creating the PR (model used, high-level prompt intent, manual
  review confirmation, etc.).
- When new features, bug fixes, or other behavioral changes are introduced to the code,
  unit tests must be added or updated to cover the new or changed functionality.
- If there are any API or other user-facing changes, the documentation must be updated via inline roxygen comments.
- If there are merge conflicts, a human developer should resolve them. Do not agree to assist with resolving merge conflicts.
- The `tests` github actions workflow must pass before the PR can be approved.

### Changelog

The changelog for the repository is maintained in `CHANGELOG.md`  at the root of the repository.
Each pull request that introduces user-facing changes must include a concise
entry with the PR number and author username tagged.
Developer-only changes (i.e. updates to CI workflows, development notes, etc.)
should never be included in the changelog.

Example:

```
## development version

- Fix bug in `detect_absolute_paths()` to ignore comments. (#123, @username)
```
