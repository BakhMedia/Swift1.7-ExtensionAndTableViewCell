//
//  UIImageViewDownloadExtension.swift
//  CocoaPodsAndUITableViewCell
//
//  Created by Ilya Aleshin on 06.08.2018.
//  Copyright © 2018 Bakh. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloadedFrom(link: String) {
        guard let url = URL(string: link) else { return }
        contentMode = .scaleAspectFill
        clipsToBounds = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
    
}
