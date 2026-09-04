/// A self-contained Firebase product setup step.
///
/// New Firebase products implement this interface and are registered in the
/// bootstrapper; they do not need to alter any existing product module.
abstract interface class FirebaseModule {
  Future<void> initialize();
}
