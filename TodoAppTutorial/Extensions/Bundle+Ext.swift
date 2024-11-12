//
//  Bundle+Ext.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 11/12/24.
//

import Foundation

extension Bundle {
    
    var baseUrl: String {
        guard let urlPath = Bundle.main.url(forResource: "Info", withExtension: "plist"),
              let dictionary = try? NSDictionary(contentsOf: urlPath, error: ()),
              let baseUrl = dictionary["Base url"] as? String  else {
            fatalError("Info plist의 데이터를 불러오는데 실패했습니다.")
        }
        
        return baseUrl
    }
}
