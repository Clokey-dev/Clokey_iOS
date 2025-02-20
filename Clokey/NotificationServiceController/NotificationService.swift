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
        print("✅ Push Notification Received in NotificationService")
        
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        guard let bestAttemptContent = bestAttemptContent else {
            print("❌ bestAttemptContent is nil")
            contentHandler(request.content)
            return
        }

        // 🔹 이미지 URL 확인
        if let imageUrlString = request.content.userInfo["image"] as? String {
            print("🔹 Image URL Received: \(imageUrlString)")
            
            downloadImage(from: imageUrlString) { imageUrl in
                if let imageUrl = imageUrl {
                    let attachment = try? UNNotificationAttachment(identifier: "profileImage", url: imageUrl, options: nil)
                    if let attachment = attachment {
                        print("✅ Image Attached Successfully")
                        bestAttemptContent.attachments = [attachment]
                    } else {
                        print("❌ Failed to Create Attachment")
                    }
                } else {
                    print("❌ Image Download Failed")
                }
                contentHandler(bestAttemptContent) // 이미지 없이도 알림 정상 표시
            }
        } else {
            print("❌ No Image URL in Notification Payload")
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
