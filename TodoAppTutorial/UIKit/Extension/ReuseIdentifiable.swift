//
//  ReuseIdentifiable.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/7/24.
//

import UIKit

protocol ReuseIdentifiable {
    static var identifier: String { get }
}

extension ReuseIdentifiable {
    static var identifier: String {
        return String(describing: Self.self)
    }
}

extension UITableViewCell: ReuseIdentifiable { }
