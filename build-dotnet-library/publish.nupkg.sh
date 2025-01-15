#!/bin/bash

TARGET_DIR="bin/Release"

if [ ! -d "$TARGET_DIR" ]; then
  echo "The folder '$TARGET_DIR' does not exist."
  exit 1
fi

nupkg_files=($(find "$TARGET_DIR" -maxdepth 1 -name "*.nupkg" 2>/dev/null))

if [ ${#nupkg_files[@]} -eq 0 ]; then
  echo "No .nupkg files found in '$TARGET_DIR'."
  exit 1
fi

get_version() {
  echo "$1" | sed -E 's/^.*\.([0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9\.]+)?)\.nupkg$/\1/'
}

highest_version=""
latest_file=""

for file in "${nupkg_files[@]}"; do
  version=$(get_version "$(basename "$file")")
  if [[ -z "$highest_version" || "$(echo -e "$highest_version\n$version" | sort -V | tail -n1)" == "$version" ]]; then
    highest_version="$version"
    latest_file="$file"
  fi
done

if [ -n "$latest_file" ]; then
  file_name=$(basename "$latest_file")
  cd "$TARGET_DIR" || exit 1
  echo "Stepped into directory: $(pwd)"
  echo "The .nupkg file with the highest version is: $file_name (Version: $highest_version)"
  echo "Pushing $file_name to the GitHub nuget repository..."
  dotnet nuget push "$file_name" --source "github" --skip-duplicate
  
  if [ $? -eq 0 ]; then
    echo "NuGet package successfully pushed."
  else
    echo "Failed to push the NuGet package."
    exit 1
  fi

  cd - > /dev/null
else
  echo "Error: Could not determine the file with the highest version."
  exit 1
fi