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
    ) async throws -> [Todo] {
        
        // 다른 에러로 변경하고 싶으면 do/catch 블록으로 다른 에러를 던지도록 하면 됨
        let _ = try await addTodoWithAsync(title: title)
        let response = try await fetchTodosWithAsync()
        
        guard let todos = response.data else {
            throw ApiError.noContent
        }
        
        return todos
    }
    
    // MARK: 할 일 추가 후 모든 할 일 가져오기 No Error
    /// - Parameters:
    ///   - title: 내용
    ///   - completion: 응답 결과
    static func addTodoAndFetchTodosWithAsyncNoError(
        title: String,
        isDone: Bool = false
    ) async -> [Todo] {
        
        do {
            let _ = try await addTodoWithAsync(title: title)
            let response = try await fetchTodosWithAsync()
            
            guard let todos = response.data else {
                return []
            }
            
            return todos
        } catch {
            if let _ = error as? ApiError {
                return []
            }
            
            return []
        }
    }
    
    // MARK: 선택된 할 일들 삭제하기 - async 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    static func deleteSelectedTodosWithAsyncNoError(
        selectedTodoIds: [Int]
    ) async -> [Int] {
      
        // 각자 출발
        async let firstResult = self.deleteTodoWithAsync(id: 6754)
        async let secondResult = self.deleteTodoWithAsync(id: 6753)
        async let thirdResult = self.deleteTodoWithAsync(id: 6752)
        
        do {
            let results: [Int?] = try await [
                firstResult.data?.id,
                secondResult.data?.id,
                thirdResult.data?.id
            ]
            return results.compactMap { $0 }
        } catch {
//            if let urlError = error as? URLError {
//                return []
//            }
            
//            if let _ = error as? ApiError {
//                return []
//            }
            return []
        }
    }
    
    static func deleteSelectedTodosWithAsync(
        selectedTodoIds: [Int]
    ) async throws -> [Int] {
      
        // 각자 출발
        async let firstResult = self.deleteTodoWithAsync(id: 6754)
        async let secondResult = self.deleteTodoWithAsync(id: 6750)
        async let thirdResult = self.deleteTodoWithAsync(id: 6749)
        
        let results: [Int?] = try await [
            firstResult.data?.id,
            secondResult.data?.id,
            thirdResult.data?.id
        ]
        return results.compactMap { $0 }
    }
    
    static func deleteSelectedTodosWithAsyncTaskGroup(
        selectedTodoIds: [Int]
    ) async throws -> [Int] {
        
        try await withThrowingTaskGroup(of: Int?.self) { (group: inout ThrowingTaskGroup<Int?, Error>) -> [Int] in
            // 각각 자식 async 테스크를 그룹에 넣기
            for todoId in selectedTodoIds {
                group.addTask (operation: {
                    // 단일 api 쏘기
                    let childTaskResult = try await self.deleteTodoWithAsync(id: todoId)
                    return childTaskResult.data?.id
                })
            }
                
            var deletedTodoIds: [Int] = []
            
            for try await singleValue in group {
                if let value = singleValue {
                    deletedTodoIds.append(value)
                }
            }
            
            return deletedTodoIds
        }
    }
    
    static func deleteSelectedTodosWithAsyncTaskGroupNoError(
        selectedTodoIds: [Int]
    ) async -> [Int] {

        await withTaskGroup(of: Int?.self) { (group: inout TaskGroup<Int?>) -> [Int] in
            for todoId in selectedTodoIds {
                group.addTask (operation: {
                    do {
                        let childTaskResult = try await self.deleteTodoWithAsync(id: todoId)
                        return childTaskResult.data?.id
                    } catch {
                        return nil
                    }
                })
            }
                
            var deletedTodoIds: [Int] = []
            
            for await singleValue in group {
                if let value = singleValue {
                    deletedTodoIds.append(value)
                }
            }
            
            return deletedTodoIds
        }
    }
    
    // MARK: 선택된 할 일들 가져오기 - async 기반 api 동시 처리
    /// - Parameters:
    ///   - selectedTodoIds: 선택된 할 일 아이디들
    ///   - completion: 응답 결과
    static func fetchSelectedTodosWithAsync(
        selectedTodoIds: [Int]
    ) async throws -> [Todo] {
        try await withThrowingTaskGroup(of: Todo?.self) { (group: inout ThrowingTaskGroup<Todo?, Error>) -> [Todo] in
            for todoId in selectedTodoIds {
                group.addTask(operation: {
                    let childTaskResult = try await self.fetchTodoWithAsync(id: todoId)
                    return childTaskResult.data
                })
            }
            
            var fetchedTodos: [Todo] = []
            
            for try await singleValue in group {
                if let value = singleValue {
                    fetchedTodos.append(value)
                }
            }
            
            return fetchedTodos
        }
    }
    
    // TaskGroup
    static func fetchSelectedTodosWithAsyncTaskGroupNoError(
        selectedTodoIds: [Int]
    ) async -> [Todo] {
        await withTaskGroup(of: Todo?.self) { (group: inout TaskGroup<Todo?>) -> [Todo] in
            for todoId in selectedTodoIds {
                group.addTask(operation: {
                    do {
                        let childTaskResult = try await self.fetchTodoWithAsync(id: todoId)
                        return childTaskResult.data
                    } catch {
                        return nil
                    }
                })
            }
            
            var fetchedTodos: [Todo] = []
            
            for await singleValue in group {
                if let value = singleValue {
                    fetchedTodos.append(value)
                }
            }
            
            return fetchedTodos
        }
    }
}


