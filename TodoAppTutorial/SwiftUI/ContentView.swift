//
//  ContentView.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 9/30/24.
//

import SwiftUI

struct ContentView: View {
    let dummyTodos: [String] = ["asdfdsafdsaf", "asdfsdfewewasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsafasdfdsafdsaf", "vsviadsjkvljl", "asdfdsafdsaf", "asdfsdfewew", "vsviadsjkvljl", "asdfdsafdsaf", "asdfsdfewew", "vsviadsjkvljl"]
    
    var body: some View {
        HeaderView()
        
        Spacer()
        
    }
}

// MARK: - HeaderView
struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("MainVC / page : 0")
            
            Text("선택된 할 일 : []")
            
            HStack(spacing: 10) {
                Button(action: {
                    
                }, label: {
                    Text("클로저")
                        .modifier(CustomButtonModifier(height: 35))
                })
                .background(Color.accentColor)
                .cornerRadius(5)
                
                Button(action: {
                    
                }, label: {
                    Text("Rx")
                        .modifier(CustomButtonModifier(height: 35))
                })
                .background(Color.accentColor)
                .cornerRadius(5)
                
                Button(action: {
                    
                }, label: {
                    Text("콤바인")
                        .modifier(CustomButtonModifier(height: 35))
                })
                .background(Color.accentColor)
                .cornerRadius(5)
                
                Button(action: {
                    
                }, label: {
                    Text("async")
                        .modifier(CustomButtonModifier(height: 35))
                })
                .background(Color.accentColor)
                .cornerRadius(5)
            }
            
            Text("Async 변환 액션들")
            
            HStack(spacing: 10) {
                Button(action: {
                    
                }, label: {
                    Text("클로저 👉🏻 async")
                        .modifier(CustomButtonModifier())
                })
                .background(Color.accentColor)
                .cornerRadius(5)
                
                Button(action: {
                    
                }, label: {
                    Text("Rx 👉🏻 async")
                        .modifier(CustomButtonModifier())
                })
                .background(Color.accentColor)
                .cornerRadius(5)
                
                Button(action: {
                    
                }, label: {
                    Text("콤바인 👉🏻 async")
                        .modifier(CustomButtonModifier())
                })
                .background(Color.accentColor)
                .cornerRadius(5)
            }
            
            HStack(spacing: 10) {
                Button(action: {
                    
                }, label: {
                    Text("초기화")
                        .modifier(CustomButtonModifier())
                })
                .background(Color.purple)
                .cornerRadius(5)
                
                Button(action: {
                    
                }, label: {
                    Text("선택된 할 일들 삭제")
                        .modifier(CustomButtonModifier())
                })
                .background(Color.red)
                .cornerRadius(5)
                
                Button(action: {
                    
                }, label: {
                    Text("할 일 추가")
                        .modifier(CustomButtonModifier())
                })
                .background(Color.green)
                .cornerRadius(5)
            }
            
           
        }
        .padding(.leading, 10)
        .padding(.trailing, 10)
        
    }
}

// MARK: - Custom Button Modifier
struct CustomButtonModifier: ViewModifier {
    var height: CGFloat = 55
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .frame(height: height)
            .frame(maxWidth: .infinity)
    }
}

#Preview {
    ContentView()
}
