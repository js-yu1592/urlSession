//
//  TodosAPI+Combine.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 11/11/24.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa
import Combine

extension TodosApi {
    // MARK: 모든 할 일 목록 가져오기
    static func fetchTodosWithPublisherResult(page: Int = 1) -> AnyPublisher<Result<BaseListResponse<Todo>, ApiError>, Never> {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [
                "page": "\(page)"
            ]) else {
            return Just(.failure(ApiError.notAllowedURL)).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared.dataTaskPublisher(for: urlRequest)
            .map({ (data: Data, urlResponse: URLResponse) -> Result<BaseListResponse<Todo>, ApiError> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    return .failure(ApiError.unknown(nil))
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    switch httpResponse.statusCode {
                    case 401:
                        return .failure(.unAuthorized)
                    default:
                        return .failure(.badStatus(code: httpResponse.statusCode))
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
//            .catch({ error in
//                Just(.failure(ApiError.unknown(nil)))
//            })
            .replaceError(with: .failure(ApiError.unknown(nil)))
//            .assertNoFailure()
            .eraseToAnyPublisher()
    }
    
    // MARK: 모든 할 일 목록 가져오기
    static func fetchTodosWithPublisher(page: Int = 1) -> AnyPublisher<BaseListResponse<Todo>, ApiError> {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [
                "page": "\(page)"
            ]) else {
            return Fail(error: ApiError.notAllowedURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    throw ApiError.unknown(nil)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    switch httpResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: httpResponse.statusCode)
                    }
                }
                
                return data
            })
            // JSON -> Struct 로 디코딩 -> 데이터 파싱
            .decode(type: BaseListResponse<Todo>.self, decoder: JSONDecoder())
            .tryMap({ response in
                guard let todos = response.data,
                      !todos.isEmpty else {
                    throw ApiError.noContent
                }
                return response
            })
            .mapError({ error -> ApiError in
                if let error = error as? ApiError { // ApiError라면...
                    return error
                }
                
                if let _ = error as? DecodingError { // 디코딩 에러라면...
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(nil)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: 특정 할 일 가져오기
    static func fetchTodoWithPublisher(id: Int) -> AnyPublisher<BaseResponse<Todo>, ApiError> {
        guard let url = URL(
            baseUrl: baseURL + "/todos" + "/\(id)",
            queryItems: [:]
        ) else {
            return Fail(error: ApiError.notAllowedURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 204:
                    throw ApiError.noContent
                default: break
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    switch httpResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: httpResponse.statusCode)
                    }
                }
                
                return data
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .mapError({ error in
                if let error = error as? ApiError {
                    return error
                }
                
                if let _ = error as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: 할 일 검색하기
    static func searchTodosWithPublisherResult(searchTerm: String, page: Int = 1) -> AnyPublisher<Result<BaseListResponse<Todo>, ApiError>, Never> {
        guard let url = URL(
            baseUrl: baseURL + "/todos/search",
            queryItems: [
                "page": "\(page)",
                "query": searchTerm
            ]) else {
            return Just(.failure(ApiError.notAllowedURL)).eraseToAnyPublisher()
        }
        
        //        var urlComponents = URLComponents(string: baseURL + "/todos/search")
        //        urlComponents?.queryItems = [
        //            URLQueryItem(name: "page", value: "\(page)"),
        //            URLQueryItem(name: "query", value: searchTerm)
        //        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .map { (data: Data, urlResponse: URLResponse) -> Result<BaseListResponse<Todo>, ApiError> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 204:
                    return .failure(ApiError.noContent)
                default: break
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    switch httpResponse.statusCode {
                    case 401:
                        return .failure(ApiError.unAuthorized)
                    default:
                        return .failure(ApiError.badStatus(code: httpResponse.statusCode))
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
            }
            .replaceError(with: .failure(ApiError.unknown(nil)))
            .eraseToAnyPublisher()
    }
    
    // MARK: 할 일 추가하기
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addTodoWithPublisher(
        title: String,
        isDone: Bool = false
    ) -> AnyPublisher<BaseResponse<Todo>, ApiError> {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [:]
        ) else {
            return Fail(error: ApiError.notAllowedURL).eraseToAnyPublisher()
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
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { (data: Data, urlResponse: URLResponse) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 204:
                    throw ApiError.noContent
                default: break
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    switch httpResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: httpResponse.statusCode)
                    }
                }
                
                return data
            }
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .mapError({ error in
                if let error = error as? ApiError {
                    return error
                }
                
                if let _ = error as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: 할 일 추가하기 - Json
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addTodoJsonWithPublisherResult(
        title: String,
        isDone: Bool = false
    ) -> AnyPublisher<Result<BaseResponse<Todo>, ApiError>, Never> {
        guard let url = URL(
            baseUrl: baseURL + "/todos-json",
            queryItems: [:]
        ) else {
            return Just(.failure(ApiError.notAllowedURL)).eraseToAnyPublisher()
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
            return Just(.failure(ApiError.jsonEncodingError)).eraseToAnyPublisher()
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .map({ (data: Data, urlResponse: URLResponse) -> Result<BaseResponse<Todo>, ApiError> in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 204:
                    return .failure(ApiError.noContent)
                default: break
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    switch httpResponse.statusCode {
                    case 401:
                        return .failure(ApiError.unAuthorized)
                    default:
                        return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                    }
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return .success(baseResponse)
                } catch {
                    return .failure(ApiError.decodingError)
                }
            })
            .replaceError(with: .failure(ApiError.unknown(nil)))
            .eraseToAnyPublisher()
    }
    
    // MARK: 할 일 수정하기 - Json
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func editTodoJsonWithPublisher(
        id: Int,
        title: String,
        isDone: Bool = false
    ) ->  AnyPublisher<BaseResponse<Todo>, ApiError> {
        guard let url = URL(
            baseUrl: baseURL + "/todos-json/\(id)",
            queryItems: [:]
        ) else {
            return Fail(error: ApiError.notAllowedURL).eraseToAnyPublisher()
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
            return Fail(error: ApiError.jsonEncodingError).eraseToAnyPublisher()
        }
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap({ (data: Data, urlResponse: URLResponse) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 204:
                    throw ApiError.noContent
                default: break
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    switch httpResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: httpResponse.statusCode)
                    }
                }
                
                return data
            })
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .mapError({ error in
                if let error = error as? ApiError {
                    return error
                }
                
                if let _ = error as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: 할 일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func editTodoWithPublisherResult(
        id: Int,
        title: String,
        isDone: Bool = false
    ) -> AnyPublisher<Result<BaseResponse<Todo>, ApiError>, Never> {
        guard let url = URL(
            baseUrl: baseURL + "/todos/\(id)",
            queryItems: [:]
        ) else {
            return Just(.failure(ApiError.notAllowedURL)).eraseToAnyPublisher()
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
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .map({ (data: Data, urlResponse: URLResponse) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    return .failure(ApiError.unknown(nil))
                }
                
                switch httpResponse.statusCode {
                case 204:
                    return .failure(ApiError.noContent)
                default: break
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    switch httpResponse.statusCode {
                    case 401:
                        return .failure(ApiError.unAuthorized)
                    default:
                        return .failure(ApiError.badStatus(code: httpResponse.statusCode))
                    }
                }
                
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
                    return .success(baseResponse)
                } catch {
                    return .failure(ApiError.decodingError)
                }
            })
            .replaceError(with: .failure(ApiError.unknown(nil)))
            .eraseToAnyPublisher()
    }
    
    // MARK: 할 일 삭제하기
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - completion: 응답 결과
    static func deleteTodoWithPublisher(
        id: Int
    ) -> AnyPublisher<BaseResponse<Todo>, ApiError> {
        print("deleteTodo 호출 됨 / id: \(id)")
        
        guard let url = URL(
            baseUrl: baseURL + "/todos/\(id)",
            queryItems: [:]
        ) else {
            return Fail(error: ApiError.notAllowedURL).eraseToAnyPublisher()
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        return URLSession.shared
            .dataTaskPublisher(for: urlRequest)
            .tryMap { (data: Data, urlResponse: URLResponse) in
                guard let httpResponse = urlResponse as? HTTPURLResponse else {
                    throw ApiError.unknown(nil)
                }
                
                switch httpResponse.statusCode {
                case 204:
                    throw ApiError.noContent
                default: break
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    switch httpResponse.statusCode {
                    case 401:
                        throw ApiError.unAuthorized
                    default:
                        throw ApiError.badStatus(code: httpResponse.statusCode)
                    }
                }
                
                return data
            }
            .decode(type: BaseResponse<Todo>.self, decoder: JSONDecoder())
            .mapError({ error in
                if let error = error as? ApiError {
                    return error
                }
                
                if let _ = error as? DecodingError {
                    return ApiError.decodingError
                }
                
                return ApiError.unknown(error)
            })
            .eraseToAnyPublisher()
    }
    
    // MARK: 할 일 추가 후 모든 할 일 가져오기
    /// - Parameters:
    ///   - title: 내용
    ///   - completion: 응답 결과
    static func addTodoAndFetchTodosWithPublisher(
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
    static func deleteSelectedTodosWithPublisher(
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
    
    static func deleteSelectedTodosWithPublisherMerge(
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
    static func fetchSelectedTodosWithPublisher(
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
    static func fetchSelectedTodosWithPublisherMerge(
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

