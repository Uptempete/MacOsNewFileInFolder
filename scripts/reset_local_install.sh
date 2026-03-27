#!/bin/zsh

set -euo pipefail

APP_NAME="NewFileCreator"
APP_BUNDLE_ID="com.peter.ownprojects.NewFileCreator"
EXTENSION_BUNDLE_ID="com.peter.ownprojects.NewFileCreator.NewFileCreatorExtension"

APP_PATHS=(
  "/Applications/${APP_NAME}.app"
  "${HOME}/Applications/${APP_NAME}.app"
)

USER_PATHS=(
  "${HOME}/Library/Containers/${APP_BUNDLE_ID}"
  "${HOME}/Library/Containers/${EXTENSION_BUNDLE_ID}"
  "${HOME}/Library/Group Containers/group.${APP_BUNDLE_ID}"
  "${HOME}/Library/Application Scripts/${APP_BUNDLE_ID}"
  "${HOME}/Library/Application Scripts/${EXTENSION_BUNDLE_ID}"
  "${HOME}/Library/Caches/${APP_BUNDLE_ID}"
  "${HOME}/Library/Caches/${EXTENSION_BUNDLE_ID}"
  "${HOME}/Library/Preferences/${APP_BUNDLE_ID}.plist"
  "${HOME}/Library/Preferences/${EXTENSION_BUNDLE_ID}.plist"
  "${HOME}/Library/Saved Application State/${APP_BUNDLE_ID}.savedState"
)

echo "This will remove the installed ${APP_NAME} app, its local sandbox data,"
echo "preferences, and Finder extension registration state from this Mac."
echo "It will not touch the source code in this repository."
echo
read "reply?Continue? [y/N]: "

if [[ ! "${reply}" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo
echo "Stopping running processes..."
killall "${APP_NAME}" 2>/dev/null || true
killall Finder 2>/dev/null || true

echo "Removing installed app bundles..."
for path in "${APP_PATHS[@]}"; do
  if [[ -e "${path}" ]]; then
    rm -rf "${path}"
    echo "  removed ${path}"
  fi
done

echo "Removing local app data..."
for path in "${USER_PATHS[@]}"; do
  if [[ -e "${path}" ]]; then
    rm -rf "${path}"
    echo "  removed ${path}"
  fi
done

echo "Removing PlugInKit registration if present..."
pluginkit -r "${EXTENSION_BUNDLE_ID}" -D -i "${EXTENSION_BUNDLE_ID}" 2>/dev/null || true

echo "Restarting Finder..."
open -a Finder

echo
echo "Reset complete."
echo "Next launch should behave like a fresh install."
