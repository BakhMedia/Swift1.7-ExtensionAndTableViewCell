//
//  Feed.swift
//  URLSessionAndJSON
//
//  Created by Ilya Aleshin on 26.07.2018.
//  Copyright © 2018 Bakh. All rights reserved.
//

import Foundation
import UIKit

class Feed {
    
    public var cover: String
    public var link: String
    public var title: String
    public var creationTime: String
    
    init(data d: [String:Any]) {
        self.cover = d["cover"] as! String
        self.link = d["link"] as! String
        self.title = d["title"] as! String
        
        let secondsSince1970: Int = Int(d["creation_time"] as! String)!
        let creationDate = Date(timeIntervalSince1970: TimeInterval(secondsSince1970))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.creationTime = formatter.string(from: creationDate)
    }
    
    func openLink() {
        guard let url = URL(string: self.link) else {
            return
        }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
}
