//
//  UIImageView+.swift
//  Demo-Combine
//
//  Created by namtrinh on 09/11/2021.
//

import UIKit

public extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self.image = image
                    }
                }
            }
        }
    }
    
    func setImage(from url: URL, placeholder: UIImage? = nil) {
        image = placeholder
        ImageCache.shared.image(for: url) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.image = image
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
