//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <auto_lock_windows/auto_lock_windows_plugin_c_api.h>
#include <camera_windows/camera_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AutoLockWindowsPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AutoLockWindowsPluginCApi"));
  CameraWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("CameraWindows"));
}
