//
//  UIRefreshControl+Helpers.swift
//  EssentialFeediOS
//
//  Created by Viral on 18/07/22.
//

import UIKit

extension UIRefreshControl {
    func update(isRefreshing: Bool) {
        isRefreshing ? beginRefreshing() : endRefreshing()
    }
}
