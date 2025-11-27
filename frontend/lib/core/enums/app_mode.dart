enum AppMode {
  /// User is authenticated and online - full access
  online,

  /// User is offline but was previously authenticated
  offline,

  /// User's auth expired or logged out - requires re-authentication
  localMode,
}
