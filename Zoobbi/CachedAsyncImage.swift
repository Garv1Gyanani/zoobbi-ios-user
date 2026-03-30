import SwiftUI
import UIKit

// MARK: - Image Cache (In-Memory + Disk via URLCache)
class ImageCache {
    static let shared = ImageCache()

    private let memoryCache = NSCache<NSString, UIImage>()
    private let session: URLSession

    private init() {
        // 100 MB memory, 500 MB disk cache for images
        let cache = URLCache(
            memoryCapacity: 100 * 1024 * 1024,
            diskCapacity: 500 * 1024 * 1024,
            diskPath: "zoobbi_image_cache"
        )
        let config = URLSessionConfiguration.default
        config.urlCache = cache
        config.requestCachePolicy = .returnCacheDataElseLoad
        self.session = URLSession(configuration: config)

        // Keep up to 200 images in memory
        memoryCache.countLimit = 200
        memoryCache.totalCostLimit = 100 * 1024 * 1024  // 100 MB
    }

    func image(for url: URL) -> UIImage? {
        return memoryCache.object(forKey: url.absoluteString as NSString)
    }

    func setImage(_ image: UIImage, for url: URL) {
        let cost = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        memoryCache.setObject(image, forKey: url.absoluteString as NSString, cost: cost)
    }

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        // Check memory cache first
        if let cached = image(for: url) {
            completion(cached)
            return
        }

        // Load from network (URLCache handles disk caching)
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
        session.dataTask(with: request) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            self.setImage(image, for: url)
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }
}

// MARK: - CachedAsyncImage View
struct CachedAsyncImage<Placeholder: View>: View {
    let url: URL?
    let placeholder: () -> Placeholder

    @State private var image: UIImage?
    @State private var isLoading = true

    init(url: URL?, @ViewBuilder placeholder: @escaping () -> Placeholder) {
        self.url = url
        self.placeholder = placeholder
    }

    var body: some View {
        Group {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
            } else {
                placeholder()
            }
        }
        .onAppear {
            loadImage()
        }
        .onChange(of: url) { newUrl in
            image = nil
            isLoading = true
            loadImage(from: newUrl)
        }
    }

    private func loadImage() {
        loadImage(from: url)
    }

    private func loadImage(from url: URL?) {
        guard let url = url, !url.absoluteString.isEmpty else {
            isLoading = false
            return
        }

        // Instant hit from memory cache
        if let cached = ImageCache.shared.image(for: url) {
            self.image = cached
            self.isLoading = false
            return
        }

        // Load from disk cache / network
        ImageCache.shared.loadImage(from: url) { loadedImage in
            self.image = loadedImage
            self.isLoading = false
        }
    }
}
