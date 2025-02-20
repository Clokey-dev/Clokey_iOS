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

        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }

        // 🔹 memberProfileUrl 가져오기
        if let memberProfileUrl = request.content.userInfo["memberProfileUrl"] as? String {
            downloadImage(from: memberProfileUrl) { imageUrl in
                if let imageUrl = imageUrl {
                    let attachment = try? UNNotificationAttachment(identifier: "image", url: imageUrl, options: nil)
                    if let attachment = attachment {
                        bestAttemptContent.attachments = [attachment]
                    }
                }
                contentHandler(bestAttemptContent)
            }
        } else {
            contentHandler(bestAttemptContent)
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    // 🔹 이미지 다운로드 후 로컬 URL 반환
    private func downloadImage(from urlString: String, completion: @escaping (URL?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        let task = URLSession.shared.downloadTask(with: url) { location, _, _ in
            guard let location = location else {
                completion(nil)
                return
            }

            let tempDirectory = FileManager.default.temporaryDirectory
            let tempFileURL = tempDirectory.appendingPathComponent(url.lastPathComponent)

            do {
                try FileManager.default.moveItem(at: location, to: tempFileURL)
                completion(tempFileURL)
            } catch {
                completion(nil)
            }
        }
        task.resume()
    }
}
