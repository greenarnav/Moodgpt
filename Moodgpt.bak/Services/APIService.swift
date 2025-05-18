import Foundation
import Combine

// Generic API errors
enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case networkError(Error)
    case decodingError(Error)
    case serverError(Int)
    case unauthorized
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let code):
            return "Server error with code: \(code)"
        case .unauthorized:
            return "Unauthorized access"
        case .unknown:
            return "Unknown error occurred"
        }
    }
}

// Main API Service that handles all network requests
class APIService {
    static let shared = APIService()
    
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private var cache = NSCache<NSString, NSData>()
    
    private init() {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.waitsForConnectivity = true
        self.session = URLSession(configuration: configuration)
        
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder.dateEncodingStrategy = .iso8601
        
        // Configure cache
        cache.countLimit = 100 // Number of items
        cache.totalCostLimit = 10 * 1024 * 1024 // 10MB
    }
    
    // MARK: - Generic API Request Methods
    
    func request<T: Decodable>(
        endpoint: String,
        baseURL: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        useCache: Bool = false,
        retryCount: Int = 3
    ) -> AnyPublisher<T, APIError> {
        guard let url = URL(string: baseURL + endpoint) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        // Check cache if enabled
        if useCache, method == .get, let cachedData = checkCache(for: url.absoluteString) {
            do {
                let decodedObject = try decoder.decode(T.self, from: cachedData as Data)
                return Just(decodedObject)
                    .setFailureType(to: APIError.self)
                    .eraseToAnyPublisher()
            } catch {
                // Fall through to network request if decoding fails
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        // Add parameters
        if let parameters = parameters {
            switch method {
            case .get:
                if var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                    components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    request.url = components.url
                }
            case .post, .put, .patch:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch {
                    return Fail(error: APIError.networkError(error)).eraseToAnyPublisher()
                }
            case .delete:
                // DELETE requests usually don't have a body, but can have query parameters
                if var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                    components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    request.url = components.url
                }
            }
        }
        
        return session.dataTaskPublisher(for: request)
            .retry(retryCount)
            .tryMap { [weak self] data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw APIError.invalidResponse
                }
                
                switch httpResponse.statusCode {
                case 200...299:
                    // Success, cache the response if needed
                    if useCache {
                        self?.cacheResponse(data, for: url.absoluteString)
                    }
                    return data
                case 401:
                    throw APIError.unauthorized
                case 400...499:
                    throw APIError.serverError(httpResponse.statusCode)
                case 500...599:
                    throw APIError.serverError(httpResponse.statusCode)
                default:
                    throw APIError.unknown
                }
            }
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.networkError(error)
            }
            .decode(type: T.self, decoder: decoder)
            .mapError { error -> APIError in
                if let apiError = error as? APIError {
                    return apiError
                }
                return APIError.decodingError(error)
            }
            .eraseToAnyPublisher()
    }
    
    // Non-Combine version for simpler use cases
    func fetch<T: Decodable>(
        endpoint: String,
        baseURL: String,
        method: HTTPMethod = .get,
        parameters: [String: Any]? = nil,
        headers: [String: String]? = nil,
        useCache: Bool = false,
        completion: @escaping (Result<T, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Check cache if enabled
        if useCache, method == .get, let cachedData = checkCache(for: url.absoluteString) {
            do {
                let decodedObject = try decoder.decode(T.self, from: cachedData as Data)
                completion(.success(decodedObject))
                return
            } catch {
                // Fall through to network request if decoding fails
            }
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        // Add headers
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        headers?.forEach { request.addValue($1, forHTTPHeaderField: $0) }
        
        // Add parameters
        if let parameters = parameters {
            switch method {
            case .get:
                if var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                    components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    request.url = components.url
                }
            case .post, .put, .patch:
                do {
                    request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                } catch {
                    completion(.failure(.networkError(error)))
                    return
                }
            case .delete:
                // DELETE requests usually don't have a body, but can have query parameters
                if var components = URLComponents(url: url, resolvingAgainstBaseURL: true) {
                    components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
                    request.url = components.url
                }
            }
        }
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                
                // Cache the response if needed
                if useCache {
                    self?.cacheResponse(data, for: url.absoluteString)
                }
                
                do {
                    let decodedData = try self?.decoder.decode(T.self, from: data)
                    if let decodedData = decodedData {
                        completion(.success(decodedData))
                    } else {
                        completion(.failure(.decodingError(NSError(domain: "Decoding failed", code: -1, userInfo: nil))))
                    }
                } catch {
                    completion(.failure(.decodingError(error)))
                }
            case 401:
                completion(.failure(.unauthorized))
            case 400...499:
                completion(.failure(.serverError(httpResponse.statusCode)))
            case 500...599:
                completion(.failure(.serverError(httpResponse.statusCode)))
            default:
                completion(.failure(.unknown))
            }
        }
        
        task.resume()
    }
    
    // MARK: - Helper Methods
    
    private func checkCache(for key: String) -> NSData? {
        return cache.object(forKey: key as NSString)
    }
    
    private func cacheResponse(_ data: Data, for key: String) {
        cache.setObject(data as NSData, forKey: key as NSString)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
    
    // Upload data (like images)
    func uploadData(
        endpoint: String,
        baseURL: String,
        data: Data,
        mimeType: String,
        parameters: [String: String]? = nil,
        completion: @escaping (Result<Data, APIError>) -> Void
    ) {
        guard let url = URL(string: baseURL + endpoint) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let boundary = "Boundary-\(UUID().uuidString)"
        
        var request = URLRequest(url: url)
        request.httpMethod = HTTPMethod.post.rawValue
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // Add parameters if any
        if let parameters = parameters {
            for (key, value) in parameters {
                body.append("--\(boundary)\r\n".data(using: .utf8)!)
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                body.append("\(value)\r\n".data(using: .utf8)!)
            }
        }
        
        // Add file data
        let filename = "file-\(Date().timeIntervalSince1970)"
        
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n".data(using: .utf8)!)
        
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(.networkError(error)))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(.failure(.invalidResponse))
                return
            }
            
            switch httpResponse.statusCode {
            case 200...299:
                guard let data = data else {
                    completion(.failure(.invalidResponse))
                    return
                }
                completion(.success(data))
            case 401:
                completion(.failure(.unauthorized))
            case 400...499:
                completion(.failure(.serverError(httpResponse.statusCode)))
            case 500...599:
                completion(.failure(.serverError(httpResponse.statusCode)))
            default:
                completion(.failure(.unknown))
            }
        }
        
        task.resume()
    }
}

// HTTP Methods
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
} 