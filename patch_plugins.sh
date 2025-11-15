#!/bin/bash

echo "🔧 Patching all Flutter plugins for AGP 8.x compatibility..."

# Function to patch a plugin
patch_plugin() {
  local plugin_name=$1
  local namespace=$2
  
  PLUGIN_PATH=$(find ~/.pub-cache/hosted/pub.dev -name "${plugin_name}-*" -type d | head -n 1)
  
  if [ -z "$PLUGIN_PATH" ]; then
    echo "⚠️  ${plugin_name} not found, skipping..."
    return
  fi
  
  echo "📍 Patching: $PLUGIN_PATH"
  
  BUILD_GRADLE="$PLUGIN_PATH/android/build.gradle"
  
  if [ ! -f "$BUILD_GRADLE" ]; then
    echo "  ⚠️  build.gradle not found, skipping..."
    return
  fi
  
  # Backup
  cp "$BUILD_GRADLE" "${BUILD_GRADLE}.backup" 2>/dev/null
  
  # Add namespace if not exists
  if ! grep -q "namespace" "$BUILD_GRADLE" 2>/dev/null; then
    # Use awk for safer insertion
    awk '/^android \{$/ { print; print "    namespace = \"'"${namespace}"'\""; next }1' "$BUILD_GRADLE" > "${BUILD_GRADLE}.tmp"
    mv "${BUILD_GRADLE}.tmp" "$BUILD_GRADLE"
    echo "  ✅ Added namespace to ${plugin_name}"
  else
    echo "  ⚠️  Namespace already exists in ${plugin_name}"
  fi
  
  # Fix any existing compileSdk issues (remove duplicates/malformed ones)
  sed -i.bak2 's/compileSdk [0-9]*= flutter\.compileSdkVersion/compileSdk = flutter.compileSdkVersion/' "$BUILD_GRADLE" 2>/dev/null
  sed -i.bak3 's/compileSdkVersion flutter\.compileSdkVersion/compileSdk = 35/' "$BUILD_GRADLE" 2>/dev/null
  sed -i.bak4 's/compileSdkVersion [0-9]*/compileSdk = 35/' "$BUILD_GRADLE" 2>/dev/null
  
  # Clean up backup files
  rm -f "${BUILD_GRADLE}.bak" "${BUILD_GRADLE}.bak2" "${BUILD_GRADLE}.bak3" "${BUILD_GRADLE}.bak4" 2>/dev/null
  
  echo "  ✅ ${plugin_name} patched"
}

# Patch all problematic plugins
patch_plugin "webview_flutter_android" "io.flutter.plugins.webviewflutter"
patch_plugin "flutter_keyboard_visibility" "com.jrai.flutter_keyboard_visibility"
patch_plugin "google_maps_flutter_android" "io.flutter.plugins.googlemaps"
patch_plugin "image_picker_android" "io.flutter.plugins.imagepicker"
patch_plugin "url_launcher_android" "io.flutter.plugins.urllauncher"
patch_plugin "shared_preferences_android" "io.flutter.plugins.sharedpreferences"
patch_plugin "path_provider_android" "io.flutter.plugins.pathprovider"
patch_plugin "video_player_android" "io.flutter.plugins.videoplayer"
patch_plugin "geolocator_android" "com.baseflow.geolocator"
patch_plugin "permission_handler_android" "com.baseflow.permissionhandler"
patch_plugin "firebase_messaging" "io.flutter.plugins.firebase.messaging"
patch_plugin "firebase_analytics" "io.flutter.plugins.firebase.analytics"
patch_plugin "device_info_plus" "dev.fluttercommunity.plus.device_info"


