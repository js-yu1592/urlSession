//
//  TodoAppTutorialApp.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 9/30/24.
//

import SwiftUI

@main
struct TodoAppTutorialApp: App {
    
    @StateObject var todosViewModel: TodosViewModel = .init()
    
    var body: some Scene {
        WindowGroup {
            TabView {
                TodosView()
                    .tabItem {
                        Image(systemName: "1.square.fill")
                        Text("SwiftUI")
                    }
                
                MainVC.instantiate()
                    .getRepresentable()
                    .tabItem {
                        Image(systemName: "2.square.fill")
                        Text("UIKit")
                    }
            }
        }
    }
}
