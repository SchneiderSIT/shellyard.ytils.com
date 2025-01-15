#!/bin/bash

dotnet build --configuration Release

TEMPLATE_FILE="nuget.template.config"
OUTPUT_FOLDER="bin/Release"
OUTPUT_FILE="$OUTPUT_FOLDER/nuget.config"
CREDENTIALS_FILE=".nuget.credentials"

mkdir -p "$OUTPUT_FOLDER"

if [ ! -f "$TEMPLATE_FILE" ]; then
  echo "Error: Template file '$TEMPLATE_FILE' not found."
  exit 1
fi
rm "$OUTPUT_FILE"
cp -f "$TEMPLATE_FILE" "$OUTPUT_FILE"

if [ ! -f "$CREDENTIALS_FILE" ]; then
  echo "Error: Credentials file '$CREDENTIALS_FILE' not found."
  exit 1
fi

NAMESPACE=$(jq -r '.namespace' "$CREDENTIALS_FILE")
USERNAME=$(jq -r '.username' "$CREDENTIALS_FILE")
TOKEN=$(jq -r '.token' "$CREDENTIALS_FILE")

if [ -z "$NAMESPACE" ] || [ -z "$USERNAME" ] || [ -z "$TOKEN" ]; then
  echo "Error: Missing field in credentials file. Ensure namespace, username, and token are present."
  exit 1
fi

sed -i "" "s/#namespace#/$NAMESPACE/g" "$OUTPUT_FILE"
sed -i "" "s/#username#/$USERNAME/g" "$OUTPUT_FILE"
sed -i "" "s/#token#/$TOKEN/g" "$OUTPUT_FILE"

echo "nuget.config has been successfully created in the '$OUTPUT_FOLDER' folder."