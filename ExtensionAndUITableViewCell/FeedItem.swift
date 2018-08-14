//
//  FeedItem.swift
//  UITableViewAndDelegate
//
//  Created by Ilya Aleshin on 10.07.2018.
//  Copyright © 2018 Bakh. All rights reserved.
//

import UIKit

class FeedItem: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var feedImage: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    
    public func setTitle(title: String) {
        titleLabel.text = title
    }
    
    public func setFeed(feed: Feed) {
        titleLabel.text = feed.title
        feedImage.downloadedFrom(link: feed.cover)
        dateLabel.text = "TEYE GROUP • " + feed.creationTime
    }
    
}
