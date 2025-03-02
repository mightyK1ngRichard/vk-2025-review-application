import UIKit
import CommonCrypto

protocol FileManagerImageHashProtocol {

    func getImage(key: String) -> UIImage?
    func saveImage(uiImage: UIImage, for key: String, completion: ((Error?) -> Void)?)
    func deleteImage(by key: String)

}

// MARK: - FileManagerImageHash

final class FileManagerImageHash {

    static let shared = FileManagerImageHash()
    private let fileManager = FileManager.default
    private let saveQueue = DispatchQueue(label: "com.vk.FileManagerImageHash.saveImages", qos: .utility, attributes: [.concurrent])

    private init() {}

}

// MARK: - FileManagerImageHashProtocol

extension FileManagerImageHash: FileManagerImageHashProtocol {

    func getImage(key: String) -> UIImage? {
        guard let url = path else {
            return nil
        }

        let imageURL = url.appendingPathComponent(imageHash(with: key))

        let imagePath: String
        if #available(iOS 16.0, *) {
            imagePath = imageURL.path(percentEncoded: true)
        } else {
            imagePath = imageURL.path
        }

        guard
            fileManager.fileExists(atPath: imagePath),
            let data = try? Data(contentsOf: imageURL)
        else {
            return nil
        }

        return UIImage(data: data)
    }

    func saveImage(uiImage: UIImage, for key: String, completion: ((Error?) -> Void)? = nil) {
        guard let url = path else {
            return
        }

        let imageURL = url.appendingPathComponent(imageHash(with: key))
        saveQueue.async {
            let data = uiImage.pngData()
            do {
                try data?.write(to: imageURL, options: [.atomic])
                completion?(nil)
            } catch {
                #if DEBUG
                print("[DEBUG]: \(error)")
                #endif
                completion?(error)
            }
        }
    }

    func deleteImage(by key: String) {
        guard let url = path else {
            return
        }

        let imageURL = url.appendingPathComponent(imageHash(with: key))

        do {
            if #available(iOS 16.0, *) {
                try fileManager.removeItem(atPath: imageURL.path(percentEncoded: true))
            } else {
                try fileManager.removeItem(atPath: imageURL.path)
            }
        } catch {
            #if DEBUG
            print("[DEBUG]: failed deletion of the file by key: \(key)")
            #endif
        }
    }

}

// MARK: - Helpers

private extension FileManagerImageHash {

    var path: URL? {
        try? fileManager.url(for: .documentDirectory,
                             in: .userDomainMask,
                             appropriateFor: nil,
                             create: true)
    }

    func imageHash(with key: String) -> String {
        let data = Data(key.utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        _ = data.withUnsafeBytes {
            CC_SHA256($0.baseAddress, CC_LONG(data.count), &digest)
        }

        let hash = digest.map { String(format: "%02x", $0) }.joined()
        return hash
    }

}
