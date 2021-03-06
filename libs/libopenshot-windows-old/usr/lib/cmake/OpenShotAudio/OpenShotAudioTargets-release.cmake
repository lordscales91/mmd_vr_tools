#----------------------------------------------------------------
# Generated CMake target import file for configuration "Release".
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "OpenShot::Audio" for configuration "Release"
set_property(TARGET OpenShot::Audio APPEND PROPERTY IMPORTED_CONFIGURATIONS RELEASE)
set_target_properties(OpenShot::Audio PROPERTIES
  IMPORTED_IMPLIB_RELEASE "${_IMPORT_PREFIX}/lib/libopenshot-audio.dll.a"
  IMPORTED_LOCATION_RELEASE "${_IMPORT_PREFIX}/bin/libopenshot-audio.dll"
  )

list(APPEND _IMPORT_CHECK_TARGETS OpenShot::Audio )
list(APPEND _IMPORT_CHECK_FILES_FOR_OpenShot::Audio "${_IMPORT_PREFIX}/lib/libopenshot-audio.dll.a" "${_IMPORT_PREFIX}/bin/libopenshot-audio.dll" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
