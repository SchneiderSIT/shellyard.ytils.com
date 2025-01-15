#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CS_PROJ_FILE=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.csproj")

if [ -z "$CS_PROJ_FILE" ]; then
  echo "Error: No .csproj file found in the same directory as the script."
  exit 1
fi

echo "Found .csproj file: $CS_PROJ_FILE"

INCREMENT_MAJOR=false
INCREMENT_MINOR=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --major)
      INCREMENT_MAJOR=true
      ;;
    --minor)
      INCREMENT_MINOR=true
      ;;
    *)
      echo "Unknown argument: $1"
      echo "Usage: $0 [--minor] [--major]"
      exit 1
      ;;
  esac
  shift
done

if [ "$INCREMENT_MAJOR" = true ] && [ "$INCREMENT_MINOR" = true ]; then
  echo "Error: Cannot set both --major and --minor at the same time."
  exit 1
fi

increment_version() {
  local version=$1
  local major=$(echo "$version" | cut -d. -f1)
  local minor=$(echo "$version" | cut -d. -f2)
  local patch=$(echo "$version" | cut -d. -f3)

  if [ "$INCREMENT_MAJOR" = true ]; then
    major=$((major + 1))
    minor=0
    patch=0
  elif [ "$INCREMENT_MINOR" = true ]; then
    minor=$((minor + 1))
    patch=0
  else
    patch=$((patch + 1))
  fi

  echo "$major.$minor.$patch"
}

update_version_tag() {
  local tag=$1
  current_version=$(grep -o "<$tag>[0-9]\+\.[0-9]\+\.[0-9]\+</$tag>" "$CS_PROJ_FILE" | sed -E "s|<$tag>(.*)</$tag>|\1|")

  if [ -n "$current_version" ]; then
    new_version=$(increment_version "$current_version")
    sed -i '' -E "s|<$tag>$current_version</$tag>|<$tag>$new_version</$tag>|" "$CS_PROJ_FILE"
    echo "$tag updated: $current_version -> $new_version"
  else
    echo "No <$tag> found in the file. Skipping..."
  fi
}

update_version_tag "Version"
update_version_tag "AssemblyVersion"
update_version_tag "FileVersion"

echo "Version update complete."