#! /usr/bin/env bash
set -e

#
# Publishes the current versions of all Rocket crates to crates.io.
#

# Brings in: ROOT_DIR, EXAMPLES_DIR, LIB_DIR, CODEGEN_DIR, CONTRIB_DIR, DOC_DIR
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${SCRIPT_DIR}/config.sh"

if ! [ -z "$(git status --porcelain)" ]; then
  echo "There are uncommited changes! Aborting."
  exit 1
fi

function strip_dev_dependencies() {
  perl -i.bak -p0e 's/\[dev-dependencies\][^\[]*//smg' "${1}/Cargo.toml"
}

function restore_dev_dependencies() {
  mv "${1}/Cargo.toml.bak" "${1}/Cargo.toml"
}

# Ensure everything passes before trying to publish.
echo ":::: Running test suite..."
cargo clean
bash "${SCRIPT_DIR}/test.sh"
bash "${SCRIPT_DIR}/test.sh --release"

# Temporarily remove dev-dependencies so crates.io verifies.
echo ":::: Stripping [dev-dependencies]..."
for dir in "${LIB_DIR}" "${CODEGEN_DIR}" "${CONTRIB_DIR}"; do
  strip_dev_dependencies "${dir}"
done

# Publish all the things.
for dir in "${LIB_DIR}" "${CODEGEN_DIR}" "${CONTRIB_DIR}"; do
  pushd "${dir}"
  echo ":::: Publishing '${dir}..."
  # We already checked things ourselves. Don't spend time reverifying.
  cargo publish --no-verify --allow-dirty
  popd
done

# Restore dev-dependencies.
echo ":::: Restoring [dev-dependencies]..."
for dir in "${LIB_DIR}" "${CODEGEN_DIR}" "${CONTRIB_DIR}"; do
  restore_dev_dependencies "${dir}"
done
