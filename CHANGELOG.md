## 0.4.0
 * Add ReadonlyMessageMixin. The generated message classes use this to
   for the default values of message fields.

## 0.3.11
 * Add meta.dart which declares reserved names for the plugin.

## 0.3.10
 * Add GeneratedService and ProtobufClient interfaces.

## 0.3.9
 * Add experimental mixins_meta library
 * Add experimental PbMapMixin class (in a separate library).
 * Fix bug where ExtensionRegistry would not be used for nested messages.

## 0.3.7
 * More docs.

## 0.3.6
 * Added mergeFromMap() and writeToJsonMap()
 * Fixed an analyzer warning.

## 0.3.5+3
 * Bugfix for `setRange()`: Do not assume Iterable has a `sublist()` method.

## 0.3.5+2
 * Simplify some types used in is checks and correct PbList to match the
 * signature of the List setRange method.

## 0.3.5+1

 * Bugfix for incorrect decoding of protobuf messages: Uint8List views with
   non-zero offsets were handled incorrectly.

## 0.3.5

 * Allow constants as field initial values as well as creation thunks to reduce
   generated code size.

 * Improve the performance of reading a protobuf buffer.

 * Fixed truncation error in least significant bits with large Int64 constants.