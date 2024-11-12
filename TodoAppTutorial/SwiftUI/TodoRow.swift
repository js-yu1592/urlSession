//
//  TodoRow.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/15/24.
//

import Foundation
import SwiftUI

struct TodoRow: View {
    
    @State var isSelected: Bool = false
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                Text("id : 123 / 완료 여부 : 미완료")
                
                Text("오늘도 빡코디이이이잉")
            }
            .frame(maxWidth: .infinity)
            
            VStack(alignment: .trailing) {
                actionButtons
                
                Toggle(isOn: $isSelected, label: {
                    EmptyView()
                })
                .frame(width: 80)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    fileprivate var actionButtons: some View {
        HStack {
            Button(action: { }, label: {
                Text("수정")
            })
            .buttonStyle(MyDefaultButtonStyle())
            .frame(width: 80)
            
            Button(action: { }, label: {
                Text("삭제")
            })
            .buttonStyle(MyDefaultButtonStyle(bgColor: .purple))
            .frame(width: 80)
        }
    }
}

struct TodoRow_Previews: PreviewProvider {
    static var previews: some View {
        TodoRow()
    }
}
