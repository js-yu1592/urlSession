//
//  TodosApi.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/24/24.
//

import Foundation

enum TodosApi {
    static let version: String = "/v2"

    static let baseURL: String = Bundle.main.baseUrl + version
    
    enum ApiError: Error {
        case notAllowedURL
        case noContent
        case decodingError
        case jsonEncodingError
        case badStatus(code: Int)
        case unknown(_ error: Error?)
        case unAuthorized
        
        var info: String {
            switch self {
            case .noContent:
                return "데이터가 없습니다."
            case .decodingError:
                return "디코딩에 실패했습니다"
            case .jsonEncodingError:
                return "유효한 json 형식이 아닙니다."
            case .badStatus(let code):
                return "잘못된 에러 상태 코드입니다. \(code)"
            case .unknown(let error):
                return "알 수 없는 에러입니다. \(error.debugDescription)"
            case .unAuthorized:
                return "인증되지 않은 사용자입니다."
            case .notAllowedURL:
                return "올바른 URL 형식이 아닙니다."
            }
        }
    }
    
  
}
