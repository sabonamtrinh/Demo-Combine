//
//  ImageCache.swift
//  Demo-Combine
//
//  Created by namtrinh on 09/11/2021.
//

import UIKit

class ImageCache {
    
    static let shared = ImageCache()
    
    private let cache = NSCache<NSString, UIImage>()
    
    private weak var task: URLSessionTask?
    
    func image(for url: URL, completionHandler: @escaping (Result<UIImage, Error>) -> Void) {
        if let imageInCache = self.cache.object(forKey: url.absoluteString as NSString) {
            completionHandler(.success(imageInCache))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            guard let data = data else { return }
            guard let image = UIImage(data: data) else { return }
            self.cache.setObject(image, forKey: url.absoluteString as NSString)
            completionHandler(.success(image))
        }
        task.resume()
    }
}
