//
//  ImageCache.swift
//  E-Marketing
//

import ImageIO
import UIKit

actor ImageCache {

    static let shared = ImageCache()

    private static let indexFileName = "index.json"

    private let memory = NSCache<NSURL, UIImage>()
    private let session: URLSession
    private let directory: URL
    private let maxDiskBytes: Int
    private let fileManager = FileManager.default
    private var index: [String: String]

    init(
        session: URLSession = ImageCache.makeSession(),
        directory: URL = ImageCache.defaultDirectory,
        maxDiskBytes: Int = 100 * 1024 * 1024
    ) {
        self.session = session
        self.directory = directory
        self.maxDiskBytes = maxDiskBytes
        memory.countLimit = 200
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        index = Self.readIndex(in: directory)
    }

    func image(for url: URL?, pointSize: CGSize? = nil, scale: CGFloat = 1) async -> UIImage? {
        guard let url else { return nil }
        let key = url as NSURL
        if let cached = memory.object(forKey: key) {
            return cached
        }

        if let stored = readDisk(url, pointSize: pointSize, scale: scale) {
            memory.setObject(stored, forKey: key)
            return stored
        }

        do {
            let (data, _) = try await session.data(from: url)
            guard let image = decode(data, pointSize: pointSize, scale: scale) else { return nil }
            memory.setObject(image, forKey: key)
            writeDisk(data, for: url)
            return image
        } catch {
            return nil
        }
    }

    private func readDisk(_ url: URL, pointSize: CGSize?, scale: CGFloat) -> UIImage? {
        guard let name = index[url.absoluteString] else { return nil }
        let fileURL = directory.appendingPathComponent(name)
        guard let data = try? Data(contentsOf: fileURL),
              let image = decode(data, pointSize: pointSize, scale: scale) else {
            index.removeValue(forKey: url.absoluteString)
            saveIndex()
            return nil
        }
        return image
    }

    private func decode(_ data: Data, pointSize: CGSize?, scale: CGFloat) -> UIImage? {
        guard let pointSize, pointSize.width > 0, pointSize.height > 0 else {
            return UIImage(data: data)
        }
        let pixels = Int((max(pointSize.width, pointSize.height) * max(scale, 1)).rounded(.up))
        return Self.downsample(data, maxPixelSize: pixels)
    }

    private static func downsample(_ data: Data, maxPixelSize: Int) -> UIImage? {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithData(data as CFData, sourceOptions) else {
            return nil
        }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary

        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            return nil
        }
        return UIImage(cgImage: image)
    }

    private func writeDisk(_ data: Data, for url: URL) {
        let name = index[url.absoluteString] ?? UUID().uuidString
        let fileURL = directory.appendingPathComponent(name)
        do {
            try data.write(to: fileURL, options: .atomic)
        } catch {
            return
        }
        index[url.absoluteString] = name
        saveIndex()
        evictIfNeeded()
    }

    private func evictIfNeeded() {
        let keys: Set<URLResourceKey> = [.contentModificationDateKey, .fileSizeKey]
        guard let files = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: Array(keys)
        ) else {
            return
        }

        var entries: [(url: URL, size: Int, date: Date)] = files.compactMap { file in
            guard file.lastPathComponent != Self.indexFileName else { return nil }
            let values = try? file.resourceValues(forKeys: keys)
            guard let size = values?.fileSize else { return nil }
            return (file, size, values?.contentModificationDate ?? .distantPast)
        }

        var total = entries.reduce(0) { $0 + $1.size }
        entries.sort { $0.date < $1.date }

        var removedFile = false
        for entry in entries where total > maxDiskBytes {
            try? fileManager.removeItem(at: entry.url)
            let name = entry.url.lastPathComponent
            index = index.filter { $0.value != name }
            total -= entry.size
            removedFile = true
        }
        if removedFile {
            saveIndex()
        }
    }

    private func saveIndex() {
        let fileURL = directory.appendingPathComponent(Self.indexFileName)
        guard let data = try? JSONEncoder().encode(index) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    private static func readIndex(in directory: URL) -> [String: String] {
        let fileURL = directory.appendingPathComponent(indexFileName)
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([String: String].self, from: data) else {
            return [:]
        }
        return decoded
    }

    private static var defaultDirectory: URL {
        let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("image-cache", isDirectory: true)
    }

    private static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = nil
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }
}
