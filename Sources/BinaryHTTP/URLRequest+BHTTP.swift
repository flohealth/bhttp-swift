import Foundation

extension URLRequest {
    public func asBinaryHTTP() throws -> Data {
        try asBinaryHTTP(sortFields: false)
    }
   
    // Non-public option with determinate header sorting for tests
    func asBinaryHTTP(sortFields: Bool) throws -> Data {
        try knownLengthRequest(sortFields: sortFields).binaryEncoded()
    }
    
    func knownLengthRequest(sortFields: Bool) throws -> KnownLengthRequest {
        guard let url = self.url else {
            throw RequestCreationError(description: "URL can't be empty")
        }
        guard let method = self.httpMethod else {
            throw RequestCreationError(description: "HTTP method is missing: \(self.httpMethod ?? "nil")")
        }
        guard let scheme = self.url?.scheme?.lowercased() else {
            throw RequestCreationError(description: "Scheme can't be empty, url: \(url)")
        }
        guard let host = self.url?.host else {
            throw RequestCreationError(description: "Host can't be empty, url: \(url)")
        }
        
        // URLRequest will have either an HTTP body or an HTTP body stream,
        // only one may be set for a request
        var content = Data()
        if let body = self.httpBody {
            content = body
        } else if let stream = self.httpBodyStream {
            content = try Data(reading: stream)
        }
        
        let fieldLines: [FieldLine]
        if sortFields {
            let sortedKeys = allHTTPHeaderFields?.keys.sorted() ?? []
            fieldLines = sortedKeys.map { FieldLine(name: $0, value: allHTTPHeaderFields?[$0] ?? "") }
        } else {
            fieldLines = allHTTPHeaderFields?.map { key, value in FieldLine(name: key, value: value) } ?? []
        }
        
        return KnownLengthRequest(
            requestControlData: .init(
                method: method,
                scheme: scheme,
                authority: host,
                path: url.pathWithQuery),
            headerSection: FieldSection(fieldLines: fieldLines),
            content: content,
            trailerSection: .empty
        )
    }
}

extension Data {
    init(reading input: InputStream) throws {
        self.init()
        
        input.open()
        let chunkSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: chunkSize)
        defer {
            input.close()
            buffer.deallocate()
        }
        while input.hasBytesAvailable {
            let read = input.read(buffer, maxLength: chunkSize)
            if read < 0 {
                throw ReadingStreamError(underlyingError: input.streamError)
            } else if read == 0 {
                break
            }
            append(buffer, count: read)
        }
    }
    
    struct ReadingStreamError: Error {
        var underlyingError: Error?
    }
}

extension URL {
    var pathWithQuery: String {
        query.map { "\(path)?\($0)" } ?? path
    }
}

struct RequestCreationError: Error {
    var description: String
}
