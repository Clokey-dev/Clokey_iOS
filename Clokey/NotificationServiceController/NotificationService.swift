//
//  NotificationService.swift
//  Clokey
//
//  Created by 소민준 on 2/20/25.
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent,
              let imageUrlString = bestAttemptContent.userInfo["image"] as? String,
              let imageUrl = URL(string: imageUrlString) else {
            contentHandler(bestAttemptContent ?? request.content)
            return
        }

        // 🔥 이미지 다운로드 및 설정
        downloadImage(from: imageUrl) { localUrl in
            if let localUrl = localUrl, let attachment = try? UNNotificationAttachment(identifier: "image", url: localUrl, options: nil) {
                bestAttemptContent.attachments = [attachment]
            }
            contentHandler(bestAttemptContent)
        }
    }

    private func downloadImage(from url: URL, completion: @escaping (URL?) -> Void) {
        let task = URLSession.shared.downloadTask(with: url) { (downloadedUrl, _, _) in
            completion(downloadedUrl)
        }
        task.resume()
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}
