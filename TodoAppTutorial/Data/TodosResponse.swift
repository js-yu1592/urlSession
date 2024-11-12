//
//  TodosResponse.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/26/24.
//

// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let todosResponse = try? JSONDecoder().decode(TodosResponse.self, from: jsonData)

import Foundation

// MARK: - TodosResponse
//struct TodosResponse: Codable {
//    let data: [Todo]?
//    let meta: Meta?
//    let message: String?
//}

struct BaseListResponse<T: Codable>: Codable {
    let data: [T]?
    let meta: Meta?
    let message: String?
//    let error: String
}

struct BaseResponse<T: Codable>: Codable {
    let data: T?
    let message: String?
//    let error: String
}

// MARK: - Todo
struct Todo: Codable {
    let id: Int?
    let title: String?
    let isDone: Bool?
    let createdAt, updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case isDone = "is_done"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Meta
struct Meta: Codable {
    let currentPage, from, lastPage, perPage: Int?
    let to, total: Int?

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case perPage = "per_page"
        case to, total
    }
}
