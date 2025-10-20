import Foundation

/// Stub for future WeChat SDK integration; keeps authentication surface swappable.
struct WeChatAuthBridge {
    enum AuthResult {
        case success(openID: String, accessToken: String)
        case cancelled
        case failure(Error)
    }

    static func handleLaunchURL(_ url: URL) -> Bool {
        #if canImport(WechatOpenSDK)
        return WXApi.handleOpen(url, delegate: nil)
        #else
        return false
        #endif
    }

    static func startAuthentication(completion: @escaping (AuthResult) -> Void) {
        #if canImport(WechatOpenSDK)
        // Construct and send auth request via WXApi when library is present.
        #else
        completion(.failure(NSError(domain: "WeChatAuth", code: -1, userInfo: [NSLocalizedDescriptionKey: "WeChat SDK not linked"])))
        #endif
    }
}
