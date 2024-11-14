//
//  TodosAPI+Async.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 11/14/24.
//

import Foundation
import MultipartForm
import RxSwift
import RxCocoa
import Combine
import CombineExt

extension TodosApi {
    // MARK: 모든 할 일 목록 가져오기
    static func fetchTodosWithAsyncResult(page: Int = 1) async -> Result<BaseListResponse<Todo>, ApiError> {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [
                "page": "\(page)"
            ]) else {
            return .failure(ApiError.notAllowedURL)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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
            
            let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
            guard let todos = listResponse.data,
                  !todos.isEmpty else {
                return .failure(.noContent)
            }
            return .success(listResponse)
            
        } catch {
            if let _ = error as? DecodingError {
                return .failure(ApiError.decodingError)
            }
            return .failure(ApiError.unknown(error))
        }
    }
    
    // MARK: 모든 할 일 목록 가져오기
    static func fetchTodosWithAsync(page: Int = 1) async throws -> BaseListResponse<Todo> {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [
                "page": "\(page)"
            ]) else {
            throw ApiError.notAllowedURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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
            
            let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
            guard let todos = listResponse.data,
                  !todos.isEmpty else {
                throw ApiError.noContent
            }
            return listResponse
        } catch {
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    // MARK: 특정 할 일 가져오기
    static func fetchTodoWithAsync(id: Int) async throws -> BaseResponse<Todo> {
        guard let url = URL(
            baseUrl: baseURL + "/todos" + "/\(id)",
            queryItems: [:]
        ) else {
            throw ApiError.notAllowedURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse): (Data, URLResponse) = try await URLSession.shared.data(for: urlRequest)
            
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
            
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            guard let _ = baseResponse.data else {
                throw ApiError.noContent
            }
            
            return baseResponse
        } catch {
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    // MARK: 할 일 검색하기
    static func searchTodosWithAsyncResult(searchTerm: String, page: Int = 1) async -> Result<BaseListResponse<Todo>, ApiError> {
        guard let url = URL(
            baseUrl: baseURL + "/todos/search",
            queryItems: [
                "page": "\(page)",
                "query": searchTerm
            ]) else {
            return .failure(ApiError.notAllowedURL)
        }
        
        //        var urlComponents = URLComponents(string: baseURL + "/todos/search")
        //        urlComponents?.queryItems = [
        //            URLQueryItem(name: "page", value: "\(page)"),
        //            URLQueryItem(name: "query", value: searchTerm)
        //        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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
            
            let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: data)
            guard let todos = listResponse.data,
                  !todos.isEmpty else {
                return .failure(ApiError.noContent)
            }
            return .success(listResponse)
        } catch {
            if let apiError = error as? URLError {
                return .failure(ApiError.badStatus(code: apiError.errorCode))
            }
            
            if let _ = error as? DecodingError {
                return .failure(ApiError.decodingError)
            }
            
            return .failure(ApiError.unknown(error))
        }
    }
    
    // MARK: 할 일 추가하기
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addTodoWithAsync(
        title: String,
        isDone: Bool = false
    ) async throws -> BaseResponse<Todo> {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [:]
        ) else {
            throw ApiError.notAllowedURL
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
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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
            
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            guard let _ = baseResponse.data else {
                throw ApiError.noContent
            }
            return baseResponse
        } catch {
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    // MARK: 할 일 추가하기 - Json
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addTodoJsonWithAsyncResult(
        title: String,
        isDone: Bool = false
    ) async -> Result<BaseResponse<Todo>, ApiError> {
        guard let url = URL(
            baseUrl: baseURL + "/todos-json",
            queryItems: [:]
        ) else {
            return .failure(ApiError.notAllowedURL)
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
            return .failure(ApiError.jsonEncodingError)
        }
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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
            
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            return .success(baseResponse)
        } catch {
            if let apiError = error as? URLError {
                return .failure(ApiError.badStatus(code: apiError.errorCode))
            }
            
            if let _ = error as? DecodingError {
                return .failure(ApiError.decodingError)
            }
            
            return .failure(ApiError.unknown(error))
        }
    }
    
    // MARK: 할 일 수정하기 - Json
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func editTodoJsonWithAsync(
        id: Int,
        title: String,
        isDone: Bool = false
    ) async throws -> BaseResponse<Todo> {
        guard let url = URL(
            baseUrl: baseURL + "/todos-json/\(id)",
            queryItems: [:]
        ) else {
            throw ApiError.notAllowedURL
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
            throw ApiError.jsonEncodingError
        }
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
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
            
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            guard let _ = baseResponse.data else {
                throw ApiError.noContent
            }
            return baseResponse
        } catch {
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    // MARK: 할 일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func editTodoWithAsyncResult(
        id: Int,
        title: String,
        isDone: Bool = false
    ) async -> Result<BaseResponse<Todo>, ApiError> {
        guard let url = URL(
            baseUrl: baseURL + "/todos/\(id)",
            queryItems: [:]
        ) else {
            return .failure(ApiError.notAllowedURL)
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
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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
            
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            
            return .success(baseResponse)
        } catch {
            if let apiError = error as? URLError {
                return .failure(ApiError.badStatus(code: apiError.errorCode))
            }
            
            if let _ = error as? DecodingError {
                return .failure(ApiError.decodingError)
            }
            
            return .failure(ApiError.unknown(error))
        }
    }
    
    // MARK: 할 일 삭제하기
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - completion: 응답 결과
    static func deleteTodoWithAsync(
        id: Int
    ) async throws -> BaseResponse<Todo> {
        print("deleteTodo 호출 됨 / id: \(id)")
        
        guard let url = URL(
            baseUrl: baseURL + "/todos/\(id)",
            queryItems: [:]
        ) else {
            throw ApiError.notAllowedURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: urlRequest)
            
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
            
            let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: data)
            guard let _ = baseResponse.data else {
                throw ApiError.noContent
            }
            
            return baseResponse
        } catch {
            if let error = error as? ApiError {
                throw error
            }
            
            if let apiError = error as? URLError {
                throw ApiError.badStatus(code: apiError.errorCode)
            }
            
            if let _ = error as? DecodingError {
                throw ApiError.decodingError
            }
            
            throw ApiError.unknown(error)
        }
    }
    
    // MARK: 할 일 추가 후 모든 할 일 가져오기
    /// - Parameters:
    ///   - title: 내용
    ///   - completion: 응답 결과
    static func addTodoAndFetchTodosWithAsync(
        title: String,
        isDone: Bool = false
    ) -> AnyPublisher<[Todo], ApiError> {
        return self.addTodoWithPublisher(title: title)
            .flatMap { _ in
                self.fetchTodosWithPublisher()
            } // BaseListResponse<Todo>
            .compactMap { $0.data } // [Todo]
            .eraseToAnyPublisher()
    }
    
    // MARK: 할 일 추가 후 모든 할 일 가져오기 No Error
    /// - Parameters:
    ///   - title: 내용
    ///   - completion: 응답 결과
    static func addTodoAndFetchTodosWithAsyncNoError(
        title: String,
        isDone: Bool = false
    ) -> AnyPublisher<[Todo], Never> {
        return self.addTodoWithPublisher(title: title)
            .flatMap { _ in
                self.fetchTodosWithPublisher()
            } // BaseListResponse<Todo>
            .compactMap { $0.data } // [Todo]
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    // MARK: 할 일 추가 후 모든 할 일 가져오기
    /// rx의 flatMapLatest대신 map + switchToLatest 사용
    /// - Parameters:
    ///   - title: 내용
    ///   - completion: 응답 결과
    static func addTodoAndFetchTodosWithAsyncNoErrorSwitchToLatest(
        title: String,
        isDone: Bool = false
    ) -> AnyPublisher<[Todo], Never> {
        return self.addTodoWithPublisher(title: title)
            .map { _ in
                self.fetchTodosWithPublisher()
            } // BaseListResponse<Todo>
            .switchToLatest()
            .compactMap { $0.data } // [Todo]
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    // MARK: 선택된 할 일들 삭제하기 - 클로저 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    static func deleteSelectedTodosWithAsyncMerge(
        selectedTodoIds: [Int]
    ) -> AnyPublisher<Int, ApiError> {
        // 매개변수 배열 -> Publisher 스트림 배열
        // 배열로 단일 api들 호출
        let apiCallPublishers: [AnyPublisher<Int, ApiError>] = selectedTodoIds.map { id -> AnyPublisher<Int, ApiError> in
            return self.deleteTodoWithPublisher(id: id)
                .compactMap { $0.data?.id } // Int
                .eraseToAnyPublisher()
        }
        
        // 여러 퍼블리셔 스트림의 결과를 하나로 받음, 각각 하나씩 방출
        return Publishers
            .MergeMany(apiCallPublishers)
            .eraseToAnyPublisher()
    }
    
    static func deleteSelectedTodosWithAsyncMergeNoError(
        selectedTodoIds: [Int]
    ) -> AnyPublisher<Int, Never> {
        // 매개변수 배열 -> Observable 스트림 배열
        // 배열로 단일 api들 호출
        let apiCallPublishers: [AnyPublisher<Int?, Never>] = selectedTodoIds.map { id -> AnyPublisher<Int?, Never> in
            return self.deleteTodoWithPublisher(id: id)
                .map { $0.data?.id } // Int
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        // 여러 옵저버블 스트림의 결과를 하나로 받음, 각각 하나씩 방출
        return Publishers
            .MergeMany(apiCallPublishers)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    static func deleteSelectedTodosWithAsyncMergeNoErrorZip(
        selectedTodoIds: [Int]
    ) -> AnyPublisher<[Int], Never> {
        // 매개변수 배열 -> Observable 스트림 배열
        // 배열로 단일 api들 호출
        let apiCallPublishers: [AnyPublisher<Int?, Never>] = selectedTodoIds.map { id -> AnyPublisher<Int?, Never> in
            return self.deleteTodoWithPublisher(id: id)
                .map { $0.data?.id } // Int?
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        // 여러 옵저버블 스트림의 결과를 하나로 받음, 각각 하나씩 방출
        return apiCallPublishers
            .zip()
            .map { $0.compactMap { $0 } }
            .eraseToAnyPublisher()
    }
    
    
    // MARK: 선택된 할 일들 가져오기 - 클로저 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithAsyncZip(
        selectedTodoIds: [Int]
    ) -> AnyPublisher<[Todo], Never> {
        let apiCallPublishers = selectedTodoIds.map { id -> AnyPublisher<Todo?, Never> in
            return self.fetchTodoWithPublisher(id: id)
                .compactMap { $0.data }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        return apiCallPublishers
            .zip()
            .map { $0.compactMap { $0 } }
            .eraseToAnyPublisher()
    }
    
    // MARK: 선택된 할 일들 가져오기 - 클로저 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithAsyncMerge(
        selectedTodoIds: [Int]
    ) -> AnyPublisher<Todo, ApiError> {
        let apiCallPublishers = selectedTodoIds.map { id -> AnyPublisher<Todo?, ApiError> in
            return self.fetchTodoWithPublisher(id: id)
                .map { $0.data }
                .eraseToAnyPublisher()
        }
        
        return Publishers
            .MergeMany(apiCallPublishers)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
    
    static func fetchSelectedTodosWithAsyncMergeNoError(
        selectedTodoIds: [Int]
    ) -> AnyPublisher<Todo, Never> {
        let apiCallPublishers = selectedTodoIds.map { id -> AnyPublisher<Todo?, Never> in
            return self.fetchTodoWithPublisher(id: id)
                .map { $0.data }
                .replaceError(with: nil)
                .eraseToAnyPublisher()
        }
        
        return Publishers
            .MergeMany(apiCallPublishers)
            .compactMap { $0 }
            .eraseToAnyPublisher()
    }
}


