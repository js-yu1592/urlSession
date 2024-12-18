//
//  TodosAPI+Closure.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/30/24.
//

import Foundation
import MultipartForm

extension TodosApi {
    // MARK: 모든 할 일 목록 가져오기
    static func fetchTodos(page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [
                "page": "\(page)"
            ]) else {
            return completion(.failure(.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                return completion(.failure(.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 401:
                    return completion(.failure(.unAuthorized))
                default:
                    return completion(.failure(.badStatus(code: httpResponse.statusCode)))
                }
            }
            
            if let jsonData = data {
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                    guard let todos = listResponse.data,
                          !todos.isEmpty else {
                        return completion(.failure(.noContent))
                    }
                    completion(.success(listResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    /// 에러 처리 X - result
    /// Closure -> Async
    static func fetchTodosClosureToAsync(page: Int = 1) async -> Result<BaseListResponse<Todo>, ApiError> {
        return await withCheckedContinuation { (continuation: CheckedContinuation<Result<BaseListResponse<Todo>, ApiError>, Never>) in
            fetchTodos(page: page) { (result: Result<BaseListResponse<Todo>, ApiError>) in
                continuation.resume(returning: result)
            }
        }
    }
    
    /// 에러 처리 X - [Todo]
    /// Closure -> Async
    static func fetchTodosClosureToAsyncReturnArray(page: Int = 1) async -> [Todo] {
        return await withCheckedContinuation { (continuation: CheckedContinuation<[Todo], Never>) in
            fetchTodos(page: page) { (result: Result<BaseListResponse<Todo>, ApiError>) in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.data ?? [])
                case .failure(_):
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    /// 에러 처리 O
    /// Closure -> Async
    static func fetchTodosClosureToAsyncWithError(page: Int = 1) async throws -> BaseListResponse<Todo> {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<BaseListResponse<Todo>, Error>) in
            fetchTodos(page: page) { (result: Result<BaseListResponse<Todo>, ApiError>) in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    /// 에러 처리 O - 에러 형태 변경
    /// Closure -> Async
    static func fetchTodosClosureToAsyncWithMapError(page: Int = 1) async throws -> BaseListResponse<Todo> {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<BaseListResponse<Todo>, Error>) in
            fetchTodos(page: page) { (result: Result<BaseListResponse<Todo>, ApiError>) in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    // 에러를 변경해서 throwing
//                    if let _ = error as? DecodingError {
//                        continuation.resume(throwing: ApiError.decodingError)
//                    }
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: 특정 할 일 가져오기
    static func fetchTodo(id: Int, completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void) {
        guard let url = URL(
            baseUrl: baseURL + "/todos" + "/\(id)",
            queryItems: [:]
        ) else {
            return completion(.failure(.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                return completion(.failure(.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 204:
                return completion(.failure(.noContent))
            default: break
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 401:
                    return completion(.failure(.unAuthorized))
                default:
                    return completion(.failure(.badStatus(code: httpResponse.statusCode)))
                }
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    static func fetchTodoClosureToAsync(id: Int) async -> Result<BaseResponse<Todo>, ApiError> {
        return await withCheckedContinuation { continuation in
            fetchTodo(id: id) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    static func fetchTodoClosureToAsyncWithError(id: Int) async throws -> BaseResponse<Todo> {
        return try await withCheckedThrowingContinuation { continuation in
            fetchTodo(id: id) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: 할 일 검색하기
    static func searchTodos(searchTerm: String, page: Int = 1, completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void) {
        guard let url = URL(
            baseUrl: baseURL + "/todos/search",
            queryItems: [
                "page": "\(page)",
                "query": searchTerm
            ]) else {
            return completion(.failure(.notAllowedURL))
        }
        
        //        var urlComponents = URLComponents(string: baseURL + "/todos/search")
        //        urlComponents?.queryItems = [
        //            URLQueryItem(name: "page", value: "\(page)"),
        //            URLQueryItem(name: "query", value: searchTerm)
        //        ]
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                return completion(.failure(.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 204:
                return completion(.failure(.noContent))
            default: break
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 401:
                    return completion(.failure(.unAuthorized))
                default:
                    return completion(.failure(.badStatus(code: httpResponse.statusCode)))
                }
            }
            
            if let jsonData = data {
                do {
                    let listResponse = try JSONDecoder().decode(BaseListResponse<Todo>.self, from: jsonData)
                    guard let todos = listResponse.data,
                          !todos.isEmpty else {
                        return completion(.failure(.noContent))
                    }
                    completion(.success(listResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    static func searchTodosClosureToAsync(searchTerm: String, page: Int = 1) async -> Result<BaseListResponse<Todo>, ApiError> {
        return await withCheckedContinuation { continuation in
            searchTodos(searchTerm: searchTerm, page: page) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    static func searchTodosClosureToAsyncReturningArray(searchTerm: String, page: Int = 1) async -> [Todo] {
        return await withCheckedContinuation { continuation in
            searchTodos(searchTerm: searchTerm) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.data ?? [])
                case .failure(_):
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    static func searchTodosClosureToAsyncWithError(searchTerm: String, page: Int = 1) async throws -> BaseListResponse<Todo> {
        return try await withCheckedThrowingContinuation { continuation in
            searchTodos(searchTerm: searchTerm) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: 할 일 추가하기
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addTodo(
        title: String,
        isDone: Bool = false,
        completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void
    ) {
        guard let url = URL(
            baseUrl: baseURL + "/todos",
            queryItems: [:]
        ) else {
            return completion(.failure(.notAllowedURL))
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
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                return completion(.failure(.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 204:
                return completion(.failure(.noContent))
            default: break
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 401:
                    return completion(.failure(.unAuthorized))
                default:
                    return completion(.failure(.badStatus(code: httpResponse.statusCode)))
                }
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    static func addTodoClosureToAsync(title: String, isDone: Bool = false) async -> Result<BaseResponse<Todo>, ApiError> {
        return await withCheckedContinuation { continuation in
            addTodo(title: title, isDone: isDone) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    static func addTodoClosureToAsyncWithError(title: String, isDone: Bool = false) async throws -> BaseResponse<Todo> {
        return try await withCheckedThrowingContinuation { continuation in
            addTodo(title: title) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    // MARK: 할 일 추가하기 - Json
    /// - Parameters:
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func addTodoJson(
        title: String,
        isDone: Bool = false,
        completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void
    ) {
        guard let url = URL(
            baseUrl: baseURL + "/todos-json",
            queryItems: [:]
        ) else {
            return completion(.failure(.notAllowedURL))
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
            return completion(.failure(.jsonEncodingError))
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                return completion(.failure(.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 204:
                return completion(.failure(.noContent))
            default: break
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 401:
                    return completion(.failure(.unAuthorized))
                default:
                    return completion(.failure(.badStatus(code: httpResponse.statusCode)))
                }
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: 할 일 수정하기 - Json
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func editTodoJson(
        id: Int,
        title: String,
        isDone: Bool = false,
        completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void
    ) {
        guard let url = URL(
            baseUrl: baseURL + "/todos-json/\(id)",
            queryItems: [:]
        ) else {
            return completion(.failure(.notAllowedURL))
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
            return completion(.failure(.jsonEncodingError))
        }
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                return completion(.failure(.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 204:
                return completion(.failure(.noContent))
            default: break
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 401:
                    return completion(.failure(.unAuthorized))
                default:
                    return completion(.failure(.badStatus(code: httpResponse.statusCode)))
                }
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    static func editTodoJsonClosureToAsync(id: Int, title: String, isDone: Bool = false) async -> Result<BaseResponse<Todo>, ApiError> {
        return await withCheckedContinuation { continuation in
            editTodoJson(id: id, title: title) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    static func editTodoJsonClosureToAsyncWithError(id: Int, title: String, isDone: Bool = false) async throws -> BaseResponse<Todo> {
        return try await withCheckedThrowingContinuation { continuation in
            editTodoJson(id: id, title: title) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: 할 일 수정하기 - PUT urlEncoded
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - title: 할 일 타이틀
    ///   - isDone: 할 일 완료 여부
    ///   - completion: 응답 결과
    static func editTodo(
        id: Int,
        title: String,
        isDone: Bool = false,
        completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void
    ) {
        guard let url = URL(
            baseUrl: baseURL + "/todos/\(id)",
            queryItems: [:]
        ) else {
            return completion(.failure(.notAllowedURL))
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
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                return completion(.failure(.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 204:
                return completion(.failure(.noContent))
            default: break
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 401:
                    return completion(.failure(.unAuthorized))
                default:
                    return completion(.failure(.badStatus(code: httpResponse.statusCode)))
                }
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    // MARK: 할 일 삭제하기
    /// - Parameters:
    ///   - id:수정할 할 일 아이디
    ///   - completion: 응답 결과
    static func deleteTodo(
        id: Int,
        completion: @escaping (Result<BaseResponse<Todo>, ApiError>) -> Void
    ) {
        
        print("deleteTodo 호출 됨 / id: \(id)")
        
        guard let url = URL(
            baseUrl: baseURL + "/todos/\(id)",
            queryItems: [:]
        ) else {
            return completion(.failure(.notAllowedURL))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        urlRequest.addValue("application/json", forHTTPHeaderField: "accept")
        
        URLSession.shared.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                return completion(.failure(.unknown(error)))
            }
            
            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                return completion(.failure(.unknown(nil)))
            }
            
            switch httpResponse.statusCode {
            case 204:
                return completion(.failure(.noContent))
            default: break
            }
            
            if !(200...299).contains(httpResponse.statusCode) {
                switch httpResponse.statusCode {
                case 401:
                    return completion(.failure(.unAuthorized))
                default:
                    return completion(.failure(.badStatus(code: httpResponse.statusCode)))
                }
            }
            
            if let jsonData = data {
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<Todo>.self, from: jsonData)
                    completion(.success(baseResponse))
                } catch {
                    completion(.failure(.decodingError))
                }
            }
        }.resume()
    }
    
    static func deleteTodoClosureToAsync(id: Int) async -> Result<BaseResponse<Todo>, ApiError> {
        return await withCheckedContinuation { continuation in
            deleteTodo(id: id) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    static func deleteTodoClosureToAsyncWithError(id: Int) async throws -> BaseResponse<Todo> {
        return try await withCheckedThrowingContinuation { continuation in
            deleteTodo(id: id) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: 할 일 추가 후 모든 할 일 가져오기
    /// - Parameters:
    ///   - title: 내용
    ///   - completion: 응답 결과
    static func addTodoAndFetchTodos(
        title: String,
        isDone: Bool = false,
        completion: @escaping (Result<BaseListResponse<Todo>, ApiError>) -> Void
    ) {
        self.addTodo(title: title) { result in
            switch result {
            case .success(_):
                self.fetchTodos {
                    switch $0 {
                    case .success(let data):
                        completion(.success(data))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func addTodoAndFetchTodosClosureToAsync(title: String, isDone: Bool = false) async -> Result<BaseListResponse<Todo>, ApiError> {
        return await withCheckedContinuation { continuation in
            addTodoAndFetchTodos(title: title) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    static func addTodoAndFetchTodosClosureToAsyncWithError(title: String, isDone: Bool = false) async throws -> BaseListResponse<Todo> {
        return try await withCheckedThrowingContinuation { continuation in
            addTodoAndFetchTodos(title: title) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    static func addTodoAndFetchTodosClosureToAsyncReturningArray(title: String, isDone: Bool = false) async -> [Todo] {
        return await withCheckedContinuation { continuation in
            addTodoAndFetchTodos(title: title) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response.data ?? [])
                case .failure(_):
                    continuation.resume(returning: [])
                }
            }
        }
    }
    
    // MARK: 선택된 할 일들 삭제하기 - 클로저 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 실제 삭제가 완료된 아이디들
    static func deleteSelectedTodos(
        selectedTodoIds: [Int],
        completion: @escaping ([Int]) -> Void
    ) {
        let group = DispatchGroup()
        // 성공적으로 삭제가 이뤄진 할 일 아이디
        var deletedTodoIds: [Int] = []
        
        selectedTodoIds.forEach { todoId in
            group.enter()
            
            self.deleteTodo(id: todoId) { result in
                switch result {
                case .success(let response):
                    // 삭제된 아이디를 배열에 넣음
                    if let todoId = response.data?.id {
                        deletedTodoIds.append(todoId)
                    }
                case .failure(let error):
                    print("inner deleteTodo - fail: \(error)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("모든 삭제 api 완료")
            completion(deletedTodoIds)
        }
    }
    
    static func deleteSelectedTodosClosureToAsync(selectedIds: [Int]) async -> [Int] {
        return await withCheckedContinuation { continuation in
            deleteSelectedTodos(selectedTodoIds: selectedIds) { deletedTodoIds in
                continuation.resume(returning: deletedTodoIds)
            }
        }
    }
    
    static func deleteSelectedTodosClosureToAsyncWithError(selectedIds: [Int]) async throws -> [Int] {
        return try await withCheckedThrowingContinuation { continuation in
            deleteSelectedTodos(selectedTodoIds: selectedIds) { deletedTodoIds in
                if deletedTodoIds.isEmpty {
                    continuation.resume(throwing: ApiError.noContent)
                } else {
                    continuation.resume(returning: deletedTodoIds)
                }
            }
        }
    }
 
    
    // MARK: 선택된 할 일들 가져오기 - 클로저 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 응답 결과
    static func fetchSelectedTodos(
        selectedTodoIds: [Int],
        completion: @escaping (Result<[Todo], ApiError>) -> Void
    ) {
        let group = DispatchGroup()
        
        // 1. 가져온 할 일들과 에러를 따로 보관하는 방법
        var fetchedTodos: [Todo] = []
        
        var apiErrors: [ApiError] = []
        
        // 2. 응답 결과를 한번에 보관하는 방법
//        var apiResult: [Int: Result<BaseResponse<Todo>, APIError>] = [:]
        
        selectedTodoIds.forEach { todoId in
            group.enter()
            
            self.fetchTodo(id: todoId) { result in
                switch result {
                case .success(let response):
                    // 가져온 할 일을 가져온 할 일 배열에 넣음
                    if let todo = response.data {
                        fetchedTodos.append(todo)
                    }
                case .failure(let error):
                    apiErrors.append(error)
                    print("inner fetchTodo - fail: \(error),\(todoId)")
                }
                group.leave()
            }
        }
        
        group.notify(queue: .main) {
            print("모든 삭제 api 완료")
            // 만약 에러가 있다면 에러 올려주기
            if  !apiErrors.isEmpty {
                if let firstError = apiErrors.first {
                    completion(.failure(firstError))
                    return
                }
            }
            
            completion(.success(fetchedTodos))
        }
    }
    
    static func fetchSelectedTodosClosureToAsync(selectedIds: [Int]) async -> Result<[Todo], ApiError> {
        return await withCheckedContinuation { continuation in
            fetchSelectedTodos(selectedTodoIds: selectedIds) { result in
                continuation.resume(returning: result)
            }
        }
    }
    
    static func fetchSelectedTodosClosureToAsyncWithError(selectedIds: [Int]) async throws -> [Todo] {
        return try await withCheckedThrowingContinuation { continuation in
            fetchSelectedTodos(selectedTodoIds: selectedIds) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    static func fetchSelectedTodosClosureToAsyncReturningArray(selectedIds: [Int]) async -> [Todo] {
        return await withCheckedContinuation { continuation in
            fetchSelectedTodos(selectedTodoIds: selectedIds) { result in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(_):
                    continuation.resume(returning: [])
                }
            }
        }
    }
 }
