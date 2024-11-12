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
        TodosApi
            .deleteTodoWithPublisher(id: 6731)
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .finished:
                    print("TodoViewModel - deleteTodoWithPublisher finished")
                case .failure(let error):
                    self.handleError(error)
                }
            } receiveValue: { response in
                print("TodosViewModel - deleteTodoWithPublisher : \(response)")
            }
            .store(in: &subscriptions)
        
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
