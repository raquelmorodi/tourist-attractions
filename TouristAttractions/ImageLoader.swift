//
//  ImageLoader.swift
//  TouristAttractions
//
//  Created by Raquel Morodi on 2026/03/10.
//

import UIKit

class ImageLoader {

    static let shared = ImageLoader()
    private init() {}

    private let cache = NSCache<NSURL, UIImage>()

    
    @discardableResult
    func load(url: URL, into imageView: UIImageView, placeholder: UIImage? = UIImage(systemName: "photo")) -> URLSessionDataTask? {

        //Set placeholder immediately (prevents stale images on reuse)
        imageView.image = placeholder

        //Check cache first
        if let cached = cache.object(forKey: url as NSURL) {
            imageView.image = cached
            return nil
        }

        //Download
        let task = URLSession.shared.dataTask(with: url) { [weak self, weak imageView] data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            self?.cache.setObject(image, forKey: url as NSURL)
            DispatchQueue.main.async {
                // Fade in for a polished feel
                UIView.transition(with: imageView ?? UIImageView(),
                                  duration: 0.25,
                                  options: .transitionCrossDissolve) {
                    imageView?.image = image
                }
            }
        }
        task.resume()
        return task
    }

  //Cancel
    func cancelLoad(for imageView: UIImageView) {
        imageView.image = nil
    }
}

