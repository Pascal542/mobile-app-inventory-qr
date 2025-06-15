#
# Generated file, do not edit.
#

list(APPEND FLUTTER_PLUGIN_LIST
  cloud_firestore
  file_selector_windows
  firebase_auth
  firebase_core
<<<<<<< HEAD
<<<<<<< HEAD
=======
  firebase_storage
>>>>>>> 3bf7aa8 (actualizacion de QR)
=======
  firebase_storage
>>>>>>> 4f84740f03c71dba7c3a05df1af7ab6a1073de7a
  flutter_secure_storage_windows
  printing
  url_launcher_windows
)

list(APPEND FLUTTER_FFI_PLUGIN_LIST
)

set(PLUGIN_BUNDLED_LIBRARIES)

foreach(plugin ${FLUTTER_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${plugin}/windows plugins/${plugin})
  target_link_libraries(${BINARY_NAME} PRIVATE ${plugin}_plugin)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES $<TARGET_FILE:${plugin}_plugin>)
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${plugin}_bundled_libraries})
endforeach(plugin)

foreach(ffi_plugin ${FLUTTER_FFI_PLUGIN_LIST})
  add_subdirectory(flutter/ephemeral/.plugin_symlinks/${ffi_plugin}/windows plugins/${ffi_plugin})
  list(APPEND PLUGIN_BUNDLED_LIBRARIES ${${ffi_plugin}_bundled_libraries})
endforeach(ffi_plugin)
