//
//  TodosAPI+Rx.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/30/24.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa

extension TodosApi {
    // MARK: 모든 할 일 목록 가져오기
    static func fetchTodosWithObservableResult(page: Int = 1) -> Observable<Result<BaseListResponse<Todo>, ApiError>> {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [
                "page": "\(page)"
            ]) else {
            return Observable.just(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map ({ (urlResponse: HTTPURLResponse, data: Data) -> Result<BaseListResponse<Todo>, ApiError> in
                
                if !(200...299).contains(urlResponse.statusCode) {
                    switch urlResponse.statusCode {
                    case 401:
                        return .failure(.unAuthorized)
                    default:
                        return .failure(.badStatus(code: urlResponse.statusCode))
                    }
                }
                
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    guard let todos = listResponse.data,
                          !todos.isEmpty else {
                        return .failure(.noContent)
                    }
                    return .success(listResponse)
                } catch {
                    return .failure(.decodingError)
                }
            })
    }
    
    // MARK: 모든 할 일 목록 가져오기
    static func fetchTodosWithObservable(page: Int = 1) -> Observable<BaseListResponse<Todo>> {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [
                "page": "\(page)"
            ]) else {
            return Observable.error(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map ({ (urlResponse: HTTPURLResponse, data: Data) -> BaseListResponse<Todo> in
                
                if !(200...299).contains(urlResponse.statusCode) {
                    switch urlResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: urlResponse.statusCode)
                    }
                }
                
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    guard let todos = listResponse.data,
                          !todos.isEmpty else {
                        throw ApiError.noContent
                    }
                    return listResponse
                } catch {
                    throw ApiError.decodingError
                }
            })
    }
    
    // MARK: 특정 할 일 가져오기
    static func fetchTodoWithObservable(id: Int) -> Observable<BaseResponse<Todo>> {
        guard let url = URL(
            baseUrl: baseURL + "/todos" + "/\(id)",
            queryItems: [:]
        ) else {
            return Observable.error(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                switch urlResponse.statusCode {
                case 204:
                    throw ApiError.noContent
                default: break
                }
                
                if !(200...299).contains(urlResponse.statusCode) {
                    switch urlResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: urlResponse.statusCode)
                    }
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            })
    }
    
    // MARK: 할 일 검색하기
    static func searchTodosWithObservableResult(searchTerm: String, page: Int = 1) -> Observable<Result<BaseListResponse<Todo>, ApiError>> {
        guard let url = URL(
            baseUrl: baseURL + "/todos/search",
            queryItems: [
                "page": "\(page)",
                "query": searchTerm
            ]) else {
            return Observable.just(.failure(ApiError.notAllowedURL))
        }
        
        //        var urlComponents = URLComponents(string: baseURL + "/todos/search")
        //        urlComponents?.queryItems = [
        //            URLQueryItem(name: "page", value: "\(page)"),
        //            URLQueryItem(name: "query", value: searchTerm)
        //        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map ({ (urlResponse: HTTPURLResponse, data: Data) -> Result<BaseListResponse<Todo>, ApiError> in
                switch urlResponse.statusCode {
                case 204:
                    return .failure(ApiError.noContent)
                default: break
                }
                
                if !(200...299).contains(urlResponse.statusCode) {
                    switch urlResponse.statusCode {
                    case 401:
                        return .failure(.unAuthorized)
                    default:
                        return .failure(.badStatus(code: urlResponse.statusCode))
                    }
                }
                
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
                    guard let todos = listResponse.data,
                          !todos.isEmpty else {
                        return .failure(ApiError.noContent)
                    }
                    return .success(listResponse)
                } catch {
                    return .failure(.decodingError)
                }
            })
    }
    
    // MARK: 할 일 추가하기
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addTodoWithObservable(
        title: String,
        isDone: Bool = false
    ) -> Observable<BaseResponse<Todo>> {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [:]
        ) else {
            return Observable.error(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "title", value: title),
            MultipartForm.Part(name: "is_done", value: "\(isDone)")
        ])
        print("form: \(form.contentType)")
        urlRequest.addValue(form.contentType, forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = form.bodyData
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map ({ (urlResponse: HTTPURLResponse, data: Data) -> BaseResponse<Todo> in
                switch urlResponse.statusCode {
                case 204:
                    throw ApiError.noContent
                default: break
                }
                
                if !(200...299).contains(urlResponse.statusCode) {
                    switch urlResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: urlResponse.statusCode)
                    }
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
                
            })
    }
    
    // MARK: 할 일 추가하기 - Json
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addTodoJsonWithObservableResult(
        title: String,
        isDone: Bool = false
    ) -> Observable<Result<BaseResponse<Todo>, ApiError>> {
        guard let url = URL(
            baseUrl: baseURL + "/todos-json",
            queryItems: [:]
        ) else {
            return Observable.just(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: Any] = [
            "title": title,
            "is_done": "\(isDone)"
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return Observable.just(.failure(ApiError.jsonEncodingError))
        }
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map ({ (urlResponse: HTTPURLResponse, data: Data) -> Result<BaseResponse<Todo>, ApiError> in
                switch urlResponse.statusCode {
                case 204:
                    return .failure(ApiError.noContent)
                default: break
                }
                
                if !(200...299).contains(urlResponse.statusCode) {
                    switch urlResponse.statusCode {
                    case 401:
                        return .failure(ApiError.unAuthorized)
                    default:
                        return .failure(ApiError.badStatus(code: urlResponse.statusCode))
                    }
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return .success(baseResponse)
                } catch {
                    return .failure(ApiError.decodingError)
                }
            })
    }
    
    // MARK: 할 일 수정하기 - Json
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func editTodoJsonWithObservable(
        id: Int,
        title: String,
        isDone: Bool = false
    ) ->  Observable<BaseResponse<Todo>> {
        guard let url = URL(
            baseUrl: baseURL + "/todos-json/\(id)",
            queryItems: [:]
        ) else {
            return Observable.error(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: Any] = [
            "title": title,
            "is_done": "\(isDone)"
        ]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestParams, options: [.prettyPrinted])
            urlRequest.httpBody = jsonData
        } catch {
            return Observable.error(ApiError.jsonEncodingError)
        }
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) in
                switch urlResponse.statusCode {
                case 204:
                    throw ApiError.noContent
                default: break
                }
                
                if !(200...299).contains(urlResponse.statusCode) {
                    switch urlResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: urlResponse.statusCode)
                    }
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    // MARK: 할 일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func editTodoWithObservableResult(
        id: Int,
        title: String,
        isDone: Bool = false
    ) -> Observable<Result<BaseResponse<Todo>, ApiError>> {
        guard let url = URL(
            baseUrl: baseURL + "/todos/\(id)",
            queryItems: [:]
        ) else {
            return Observable.just(.failure(ApiError.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PUT"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let requestParams: [String: String] = [
            "title": title,
            "is_done": "\(isDone)"
        ]
        urlRequest.percentEncodeParameters(parameters: requestParams)
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) in
                switch urlResponse.statusCode {
                case 204:
                    return .failure(ApiError.noContent)
                default: break
                }
                
                if !(200...299).contains(urlResponse.statusCode) {
                    switch urlResponse.statusCode {
                    case 401:
                        return .failure(ApiError.unAuthorized)
                    default:
                        return .failure(ApiError.badStatus(code: urlResponse.statusCode))
                    }
                }
                
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return .success(baseResponse)
                } catch {
                    return .failure(ApiError.decodingError)
                }
                
            }
    }
    
    // MARK: 할 일 삭제하기
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - completion: 응답 결과
    static func deleteTodoWithObservable(
        id: Int
    ) -> Observable<BaseResponse<Todo>> {
        print("deleteTodo 호출 됨 / id: \(id)")
        
        guard let url = URL(
            baseUrl: baseURL + "/todos/\(id)",
            queryItems: [:]
        ) else {
            return Observable.error(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.rx
            .response(request: urlRequest)
            .map { (urlResponse: HTTPURLResponse, data: Data) in
                switch urlResponse.statusCode {
                case 204:
                    throw ApiError.noContent
                default: break
                }
                
                if !(200...299).contains(urlResponse.statusCode) {
                    switch urlResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: urlResponse.statusCode)
                    }
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return baseResponse
                } catch {
                    throw ApiError.decodingError
                }
            }
    }
    
    // MARK: 할 일 추가 후 모든 할 일 가져오기
    /// flatMap과 flatMapLatest의 차이: flatMap같은 경우 새로운 데이터 스트림이 생겨 옵저버블을 만들어  방출하지만 flatMapLatest는 최신 옵저버블을 방출
    /// - Parameters:
    ///   - title: 내용
    ///   - completion: 응답 결과
    static func addTodoAndFetchTodosWithObservable(
        title: String,
        isDone: Bool = false
    ) -> Observable<[Todo]> {
        return self.addTodoWithObservable(title: title)
            .flatMapLatest { _ in
                self.fetchTodosWithObservable()
            }
            .compactMap { $0.data }
            .catch({ error in
                print("TodosAPI - catch error / \(error)")
                return Observable.just([])
            })
            .share(replay: 1)
    }
    
    // MARK: 선택된 할 일들 삭제하기 - 클로저 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodosWithObservable(
        selectedTodoIds: [Int]
    ) -> Observable<[Int]> {
        // 매개변수 배열 -> Observable 스트림 배열
        // 배열로 단일 api들 호출
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Int?> in
            return self.deleteTodoWithObservable(id: id)
                .map { $0.data?.id } // Int?
                .catchAndReturn(nil)
//                .catch { error in
//                    return Observable.just(nil)
//                }
        }
        
        // zip은 하나의 배열로 결과가 묶어짐 [A, B, C]
        return Observable.zip(apiCallObservables) // Observable<[Int?]>
            .map { $0.compactMap { $0 } } // Observable<[Int]>
    }
    
    static func deleteSelectedTodosWithObservableMerge(
        selectedTodoIds: [Int]
    ) -> Observable<Int> {
        // 매개변수 배열 -> Observable 스트림 배열
        // 배열로 단일 api들 호출
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Int?> in
            return self.deleteTodoWithObservable(id: id)
                .map { $0.data?.id } // Int?
                .catchAndReturn(nil)
        }
        
        // 여러 옵저버블 스트림의 결과를 하나로 받음, 각각 하나씩 방출
        return Observable.merge(apiCallObservables)
            .compactMap { $0 }
    }
    
    
    // MARK: 선택된 할 일들 가져오기 - 클로저 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithObservable(
        selectedTodoIds: [Int]
    ) -> Observable<[Todo]> {
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Todo?> in
            return self.fetchTodoWithObservable(id: id)
                .map { $0.data }
                .catchAndReturn(nil)
        }
        
        return Observable.zip(apiCallObservables)
            .map { $0.compactMap { $0 } }
    }
    
    // MARK: 선택된 할 일들 가져오기 - 클로저 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithObservableMerge(
        selectedTodoIds: [Int]
    ) -> Observable<Todo> {
        let apiCallObservables = selectedTodoIds.map { id -> Observable<Todo?> in
            return self.fetchTodoWithObservable(id: id)
                .map { $0.data }
                .catchAndReturn(nil)
        }
        
        return Observable.merge(apiCallObservables)
            .compactMap { $0 }
    }
}
