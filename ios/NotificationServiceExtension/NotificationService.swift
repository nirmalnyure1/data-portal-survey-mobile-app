import UserNotifications

class NotificationService: UNNotificationServiceExtension {
  override func didReceive(
    _ request: UNNotificationRequest,
    withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void
  ) {
    guard let content = request.content.mutableCopy() as? UNMutableNotificationContent else {
      contentHandler(request.content)
      return
    }

    let userInfo = content.userInfo
    let imageUrlString = (userInfo["image_url"] as? String)
      ?? ((userInfo["fcm_options"] as? [String: Any])?["image"] as? String)

    guard let imageUrlString, let url = URL(string: imageUrlString) else {
      contentHandler(content)
      return
    }

    URLSession.shared.downloadTask(with: url) { location, _, _ in
      defer { contentHandler(content) }
      guard let location else { return }

      let tmp = URL(fileURLWithPath: NSTemporaryDirectory())
        .appendingPathComponent(url.lastPathComponent)

      do {
        try FileManager.default.moveItem(at: location, to: tmp)
        if let attachment = try? UNNotificationAttachment(
          identifier: "image",
          url: tmp,
          options: nil
        ) {
          content.attachments = [attachment]
        }
      } catch {
        // Keep text-only notification when attachment creation fails.
      }
    }.resume()
  }

  override func serviceExtensionTimeWillExpire() {
    // Called just before the extension is terminated by the system.
  }
}
