set -euxo pipefail

# Test
pytest  --exitfirst --verbose --failed-first

# Lint
flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics

# mypy
# @TODO run mypy
# mypy opennem


poetry version ${1-prerelease}

git add pyproject.toml
VERSION=$(poetry version | sed 's/opennem\ //g')
git commit -m "$VERSION"


# Make docs
make github

echo "Building version $VERSION"

poetry export --format requirements.txt > requirements.txt
poetry export --format requirements.txt --dev > requirements-dev.txt

git add pyproject.toml requirements.txt
git diff-index --quiet HEAD || git commit -m "v$VERSION"

git tag v$VERSION
git push -u origin master v$VERSION


poetry build
poetry publish

rm -rf build
