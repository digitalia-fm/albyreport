//
//  Alby.swift
//
//
//  Created by Franco Solerio on 09/10/23.
//

import Foundation

public class Alby {
    
    let urlSession: URLSession
    
    private let serverAddress: URL = URL(string: "https://api.getalby.com")!
    
    private var baseURL: URL {
        return serverAddress
    }
    
    public init() {
        let urlSessionConfig = URLSessionConfiguration.default
        urlSessionConfig.timeoutIntervalForRequest = 15
        urlSession = URLSession(configuration: urlSessionConfig, delegate: nil, delegateQueue: OperationQueue.main)
    }
    
    private func callAPI<T: Codable>(with request: URLRequest, completionHandler: @escaping (Result<PaginatedResponse<T>, Error>)->Void) {
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                let data = data
            else { completionHandler(.failure(AlbyError.unknown)); return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                if HTTPStatusCode(rawValue: httpResponse.statusCode)?.responseType == .success {
                    let response: T = try decoder.decode(T.self, from: data)
                    var paginatedResponse = PaginatedResponse<T>(response: response)
                    paginatedResponse.currentPage = (httpResponse.allHeaderFields["x-pagination-current-page"] as? String).flatMap({ Int($0) })
                    paginatedResponse.pageCount = (httpResponse.allHeaderFields["x-pagination-page-count"] as? String).flatMap({ Int($0) })
                    completionHandler(.success(paginatedResponse))
                } else if HTTPStatusCode(rawValue: httpResponse.statusCode) == .notFound {
                    completionHandler(.failure(AlbyError.notFound))
                } else {
                    let errorResponse: ErrorResponse = try decoder.decode(ErrorResponse.self, from: data)
                    completionHandler(.failure(AlbyError.alby(response: errorResponse)))    
                }
            }
            catch let error {
                print(error)
                completionHandler(.failure(error))
                return
            }
        }
        
        task.resume()
    }
    
    
    private func callAPI<T: Codable>(with request: URLRequest, completionHandler: @escaping (Result<T, Error>)->Void) {
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard
                let response = response as? HTTPURLResponse,
                let data = data
            else { completionHandler(.failure(error ?? AlbyError.unknown)); return }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .secondsSince1970
            
            do {
                if HTTPStatusCode(rawValue: response.statusCode)?.responseType == .success {
                    let response: T = try decoder.decode(T.self, from: data)
                    completionHandler(.success(response))
                } else if HTTPStatusCode(rawValue: response.statusCode) == .notFound {
                    completionHandler(.failure(AlbyError.notFound))
                } else {
                    if let response: T = try? decoder.decode(T.self, from: data) {
                        completionHandler(.success(response))
                    } else {
                        let errorResponse: ErrorResponse = try decoder.decode(ErrorResponse.self, from: data)
                        completionHandler(.failure(AlbyError.alby(response: errorResponse)))
                    }
                }
            }
            catch let error {
                print(error)
                completionHandler(.failure(error))
                return
            }
        }
        
        task.resume()
    }
    
    public func requestInvoices(with token: String, page: Int? = nil, resultsPerPage: Int? = nil, createdAfter: Date? = nil, completionHandler: @escaping (Result<PaginatedResponse<[RequestInvoiceResponse]>, Error>)->Void) {
        let url = self.baseURL.appendingPathComponent("/invoices/incoming")
        
        var queryItems = [URLQueryItem] ()
        
        if let page {
            queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        }
        
        if let resultsPerPage {
            queryItems.append(URLQueryItem(name: "items", value: "\(resultsPerPage)"))
        }
        
        if let createdAfter {
            queryItems.append(URLQueryItem(name: "q[created_at_gt]", value: "\(Int(createdAfter.timeIntervalSince1970))"))
        }
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        urlComponents.queryItems = queryItems
        let urlWithQuery = urlComponents.url!
        
        var request = URLRequest(url: urlWithQuery)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "GET"
        
        self.callAPI(with: request, completionHandler: completionHandler)
    }
}


public struct PaginatedResponse<T> {
    public var currentPage: Int?
    public var pageCount: Int?
    
    public var response: T
}
