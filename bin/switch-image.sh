#!/bin/bash

ROLLOUT_NAME="blue-green-app-rollout"

# Get current rollout image
CURRENT_IMAGE=$(kubectl get rollout "$ROLLOUT_NAME" -o jsonpath='{.spec.template.spec.containers[0].image}')

# Blue and green image names
BLUE_IMAGE="blue-demo-image:latest"
GREEN_IMAGE="green-demo-image:latest"

# Determine which image to switch to
if [[ $CURRENT_IMAGE == *"$BLUE_IMAGE"* ]]; then
  NEW_IMAGE="$GREEN_IMAGE"
else
  NEW_IMAGE="$BLUE_IMAGE"
fi

# update the image
PATCH_OUTPUT=$(kubectl patch rollout "$ROLLOUT_NAME" \
  --type='json' \
  -p="[{'op': 'replace', 'path': '/spec/template/spec/containers/0/image', 'value': '$NEW_IMAGE'}]")

# Check the output of the patch command
if [[ $? -ne 0 ]]; then
  echo "Error: Failed to patch rollout."
  exit 1
fi

# Check for errors in the patch output
if [[ $PATCH_OUTPUT == *"error"* || $PATCH_OUTPUT == *"Error"* ]]; then
  echo "Error: Patch operation encountered an error."
  exit 1
fi

echo "Switched rollout to image: $NEW_IMAGE"
