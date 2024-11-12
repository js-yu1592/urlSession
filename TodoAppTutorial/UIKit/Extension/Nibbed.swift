//
//  Nibbed.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/7/24.
//

import UIKit

protocol Nibbed {
    static var uinib: UINib { get }
}

extension Nibbed {
    static var uinib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}

extension UITableViewCell: Nibbed { }
