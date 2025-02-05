import UIKit

public struct API {
    public static let baseURL = "https://clokey.shop"
    
    static let membersURL = "\(baseURL)/users"
    static let clothesURL = "\(baseURL)/clothes"
    static let categoriesURL = "\(baseURL)/categories"
    static let folderURL = "\(baseURL)/folders"
    static let searchURL = "\(baseURL)/search"
    static let recommendURL = "\(baseURL)/recommend"
    static let homeURL = "\(baseURL)/home"
    static let historyURL = "\(baseURL)/histories"
    static let notificationURL = "\(baseURL)/notifications"
}
