//
//  UISearchBarWrapper.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/15/24.
//

import Foundation
import SwiftUI
import UIKit

struct UISearchBarWrapper: UIViewRepresentable {
    
    func updateUIView(_ uiView: UIViewType, context: Context) { }
    
    func makeUIView(context: Context) -> some UIView {
        return UISearchBar()
    }
}
