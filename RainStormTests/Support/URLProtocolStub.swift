//
//  URLProtocolStub.swift
//  RainStormTests
//
//  Intercepta as requisições de uma URLSession de teste: nenhuma chamada sai para a rede.
//  O estado é estático, então as suítes que o usam precisam do trait `.serialized`.
//

import Foundation

nonisolated final class URLProtocolStub: URLProtocol {

    private struct Stub {
        let data: Data
        let statusCode: Int
        let error: URLError?
    }

    private static let lock = NSLock()
    nonisolated(unsafe) private static var stub: Stub?
    nonisolated(unsafe) private static var recordedRequest: URLRequest?

    static var lastRequest: URLRequest? {
        lock.withLock { recordedRequest }
    }

    static func session(returning data: Data?, status: Int) -> URLSession {
        install(Stub(data: data ?? Data(), statusCode: status, error: nil))
    }

    static func session(failingWith code: URLError.Code) -> URLSession {
        install(Stub(data: Data(), statusCode: 0, error: URLError(code)))
    }

    private static func install(_ newStub: Stub) -> URLSession {
        lock.withLock {
            stub = newStub
            recordedRequest = nil
        }
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return URLSession(configuration: configuration)
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let current = Self.lock.withLock {
            Self.recordedRequest = request
            return Self.stub
        }

        guard let current, let url = request.url else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        if let error = current.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        let response = HTTPURLResponse(url: url, statusCode: current.statusCode, httpVersion: nil, headerFields: nil)!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: current.data)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
