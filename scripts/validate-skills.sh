#!/usr/bin/env bash
# Validate that every skill in skills/ has a SKILL.md with the required
# frontmatter fields. Exits non-zero on the first failure batch.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="${REPO_ROOT}/skills"

REQUIRED_FIELDS=(id name category description tags agents)

red()   { printf '\033[31m%s\033[0m\n' "$*"; }
green() { printf '\033[32m%s\033[0m\n' "$*"; }
bold()  { printf '\033[1m%s\033[0m\n' "$*"; }

if [[ ! -d "${SKILLS_DIR}" ]]; then
  red "skills/ directory not found at ${SKILLS_DIR}"
  exit 1
fi

errors=0
checked=0

bold "Validating skills in ${SKILLS_DIR}"
printf '\n'

for skill_dir in "${SKILLS_DIR}"/*/; do
  [[ -d "${skill_dir}" ]] || continue
  skill_id="$(basename "${skill_dir}")"
  skill_file="${skill_dir}SKILL.md"
  checked=$((checked + 1))

  if [[ ! -f "${skill_file}" ]]; then
    red "✗ ${skill_id}: missing SKILL.md"
    errors=$((errors + 1))
    continue
  fi

  # Frontmatter must be the first non-empty content and delimited by --- markers.
  first_line="$(awk 'NF{print; exit}' "${skill_file}")"
  if [[ "${first_line}" != "---" ]]; then
    red "✗ ${skill_id}: SKILL.md does not start with a '---' frontmatter delimiter"
    errors=$((errors + 1))
    continue
  fi

  # Confirm there's a closing '---' after line 1.
  if ! awk 'NR>1 && /^---[[:space:]]*$/{found=1; exit} END{exit !found}' "${skill_file}"; then
    red "✗ ${skill_id}: SKILL.md frontmatter is not closed with '---'"
    errors=$((errors + 1))
    continue
  fi

  # Extract frontmatter block (between the first two '---' lines).
  frontmatter="$(awk '/^---[[:space:]]*$/{c++; if(c==2) exit; next} c==1' "${skill_file}")"

  missing=()
  for field in "${REQUIRED_FIELDS[@]}"; do
    if ! grep -Eq "^${field}:[[:space:]]" <<<"${frontmatter}"; then
      missing+=("${field}")
    fi
  done

  if (( ${#missing[@]} > 0 )); then
    red "✗ ${skill_id}: missing required field(s): ${missing[*]}"
    errors=$((errors + 1))
    continue
  fi

  # Confirm directory name matches the id field.
  declared_id="$(grep -E '^id:[[:space:]]' <<<"${frontmatter}" | head -1 | sed -E 's/^id:[[:space:]]*//')"
  if [[ "${declared_id}" != "${skill_id}" ]]; then
    red "✗ ${skill_id}: frontmatter id '${declared_id}' does not match directory name"
    errors=$((errors + 1))
    continue
  fi

  green "✓ ${skill_id}"
done

printf '\n'
if (( errors > 0 )); then
  red "${errors} skill(s) failed validation out of ${checked} checked"
  exit 1
fi

green "All ${checked} skills passed validation"
