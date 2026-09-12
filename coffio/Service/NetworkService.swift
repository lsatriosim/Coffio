//
//  NetworkService.swift
//  coffio
//
//  Created by Liefran Satrio Sim on 10/09/26.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case unauthorized
    case serverError(statusCode: Int, message: String)
    case decodingError(Error)
    case unknown
}

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: String,
        body: Encodable?
    ) async throws -> T
}

// Extension to make method parameter optional for GET requests
extension NetworkServiceProtocol {
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        return try await request(endpoint: endpoint, method: method, body: body)
    }
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL = "http://localhost:8080/api"
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil
    ) async throws -> T {
        guard let url = URL(string: baseURL + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Automatically inject the Supabase access token
        do {
            let session = try await supabaseClient.auth.session
            if !session.isExpired {
                urlRequest.setValue("Bearer \(session.accessToken)", forHTTPHeaderField: "Authorization")
            } else {
                throw NetworkError.unauthorized
            }
        } catch {
            throw NetworkError.unauthorized
        }
        
        if let body = body {
            urlRequest.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown server error"
            throw NetworkError.serverError(statusCode: httpResponse.statusCode, message: errorMessage)
        }
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let result: T = try decoder.decode(T.self, from: data)
        return result
    }
}
