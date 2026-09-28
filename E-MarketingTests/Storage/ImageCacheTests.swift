//
//  ImageCacheTests.swift
//  E-MarketingTests
//

import ImageIO
import UniformTypeIdentifiers
import XCTest
@testable import E_Marketing

final class ImageCacheTests: XCTestCase {

    private final class RequestCounter: @unchecked Sendable {
        var value = 0
    }

    private var cacheDirectory: URL!
    private var requestCounter: RequestCounter!

    override func setUp() {
        super.setUp()
        MockURLProtocol.reset()
        requestCounter = RequestCounter()
        cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("image-cache-tests-\(UUID().uuidString)", isDirectory: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        MockURLProtocol.reset()
        super.tearDown()
    }

    func testMemoryCacheSkipsSecondNetworkRequest() async {
        let url = URL(string: "https://example.com/thumb.png")!
        installImageHandler(url: url)
        let cache = ImageCache(session: makeSession(), directory: cacheDirectory)

        let first = await cache.image(for: url)
        let second = await cache.image(for: url)

        XCTAssertNotNil(first)
        XCTAssertNotNil(second)
        XCTAssertEqual(requestCounter.value, 1)
    }

    func testDiskCacheServesImageWhenServerSendsNoStore() async {
        let url = URL(string: "https://example.com/thumb-disk.png")!
        installImageHandler(url: url)
        let session = makeSession()

        let warmed = await ImageCache(session: session, directory: cacheDirectory).image(for: url)
        XCTAssertNotNil(warmed)
        XCTAssertEqual(requestCounter.value, 1)

        let cached = await ImageCache(session: session, directory: cacheDirectory).image(for: url)

        XCTAssertNotNil(cached)
        XCTAssertEqual(requestCounter.value, 1)
    }

    func testDownsamplesImageToTheCellPixelSize() async {
        let url = URL(string: "https://example.com/large.png")!
        installImageHandler(url: url, png: makePNG(width: 400, height: 200))
        let cache = ImageCache(session: makeSession(), directory: cacheDirectory)

        let image = await cache.image(
            for: url,
            pointSize: CGSize(width: 76, height: 76),
            scale: 2
        )
        let again = await cache.image(
            for: url,
            pointSize: CGSize(width: 76, height: 76),
            scale: 2
        )

        XCTAssertEqual(image?.cgImage?.width, 152)
        XCTAssertEqual(image?.cgImage?.height, 76)
        XCTAssertNotNil(again)
        XCTAssertEqual(requestCounter.value, 1)
    }

    private func installImageHandler(url: URL, png: Data? = nil) {
        let png = png ?? Data(
            base64Encoded: "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg=="
        )!
        let counter = requestCounter!
        MockURLProtocol.handler = { _ in
            counter.value += 1
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: [
                    "Content-Type": "image/png",
                    "Cache-Control": "no-store"
                ]
            )!
            return (response, png)
        }
    }

    private func makePNG(width: Int, height: Int) -> Data {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        guard let context = CGContext(
            data: nil,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ), let image = context.makeImage() else {
            return Data()
        }

        let data = NSMutableData()
        guard let destination = CGImageDestinationCreateWithData(
            data,
            UTType.png.identifier as CFString,
            1,
            nil
        ) else {
            return Data()
        }
        CGImageDestinationAddImage(destination, image, nil)
        guard CGImageDestinationFinalize(destination) else { return Data() }
        return data as Data
    }

    private func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        configuration.urlCache = nil
        return URLSession(configuration: configuration)
    }
}
