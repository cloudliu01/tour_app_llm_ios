import Foundation

/// Lightweight abstraction so the app compiles without Firebase during early scaffolding.
struct CrashlyticsBridge {
    static func configureIfAvailable() {
        #if canImport(FirebaseCrashlytics)
        // FirebaseApp.configure() is expected to be called in AppDelegate when integrated.
        #endif
    }

    static func record(error: Error, userInfo: [String: Any]? = nil) {
        #if canImport(FirebaseCrashlytics)
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
        #else
        #if DEBUG
        print("Crashlytics stub captured error: \(error)")
        #endif
        #endif
    }
}
