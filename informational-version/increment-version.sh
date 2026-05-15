#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

CSPROJ_COUNT=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.csproj" | wc -l | tr -d ' ')

if [ "$CSPROJ_COUNT" -ne 1 ]; then
    echo "Nothing done: expected exactly one .csproj file, found ${CSPROJ_COUNT}."
    exit 0
fi

CSPROJ=$(find "$SCRIPT_DIR" -maxdepth 1 -name "*.csproj")

CURRENT=$(awk '
    /<Project[^>]*>/ { in_project=1 }
    /<\/Project>/    { in_project=0 }
    in_project && /<PropertyGroup>/  { in_pg=1 }
    in_project && /<\/PropertyGroup>/ { in_pg=0 }
    in_project && in_pg && /<InformationalVersion>/ {
        val=$0
        sub(/.*<InformationalVersion>/, "", val)
        sub(/<\/InformationalVersion>.*/, "", val)
        print val
        found=1
    }
    END { if (!found) print "__NOT_FOUND__" }
' "$CSPROJ")

if [ "$CURRENT" = "__NOT_FOUND__" ]; then
    echo "Nothing done: <InformationalVersion> not found inside <Project>/<PropertyGroup>."
    exit 0
fi

if [ -z "$CURRENT" ]; then
    NEW=1
elif [[ "$CURRENT" =~ ^[0-9]+$ ]]; then
    NEW=$(( CURRENT + 1 ))
else
    echo "Nothing done: <InformationalVersion> value \"${CURRENT}\" is not an integer."
    exit 0
fi

sed -i '' "s|<InformationalVersion>.*</InformationalVersion>|<InformationalVersion>${NEW}</InformationalVersion>|" "$CSPROJ"
echo "InformationalVersion: ${CURRENT} -> ${NEW}"
