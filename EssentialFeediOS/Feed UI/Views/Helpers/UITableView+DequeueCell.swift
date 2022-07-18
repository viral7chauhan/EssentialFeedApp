//
//  UITableView+DequeueCell.swift
//  EssentialFeediOS
//
//  Created by Viral on 26/05/22.
//

import UIKit

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>() -> T {
        let identifier = String(describing: T.self)
        return dequeueReusableCell(withIdentifier: identifier) as! T
    }
}
