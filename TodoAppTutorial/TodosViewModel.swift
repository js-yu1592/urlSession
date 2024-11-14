//
//  TodosViewModel.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/24/24.
//

import Foundation
import Combine
import RxSwift
import RxCocoa
import RxRelay

class TodosViewModel: ObservableObject {
    
    var disposeBag = DisposeBag()
    
    var subscriptions = Set<AnyCancellable>()
    
    init() {
        
        Task {
            do {
                let response = try await TodosApi.deleteTodoWithAsync(id: 6747)
                print("TodosViewModel response: \(response)")
            } catch {
                self.handleError(error)
            }
        }
        
    }
    
    fileprivate func handleError(_ error: Error) {
        if error is TodosApi.ApiError {
            let apiError = error as! TodosApi.ApiError
            
            print("handleError: \(apiError.info)")
            
//            switch apiError {
//            case .noContent:
//                print("컨텐츠 없음")
//            case .unAuthorized:
//                print("인증 안됨")
//            default:
//                print("알 수 없는 에러")
//            }
        }
    }
}
