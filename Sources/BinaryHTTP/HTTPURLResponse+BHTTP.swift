import Foundation

extension HTTPURLResponse {
    
    public static func from(
        url: URL,
        binaryHTTPData data: Data
    ) throws -> (response: HTTPURLResponse, body: Data) {
        let decoder = BinaryHTTPDecoder(data)
        
        guard let framingIndicator: UInt8 = [UInt8](try decoder.readData(1)).first else {
            throw BinaryHTTPDecodingError.framingIndicatorUnknown
        }
        switch framingIndicator {
        // only known-length response type is supported currently
        case KnownLengthResponse.framingIndicator:
            let response: KnownLengthResponse = try decoder.read()
            return try fromKnownLengthResponse(url: url, response: response)
        default:
            throw BinaryHTTPDecodingError.framingIndicatorUnknown
        }
    }
    
    private static func fromKnownLengthResponse(
        url: URL,
        response: KnownLengthResponse
    ) throws -> (response: HTTPURLResponse, body: Data) {
        
        guard let httpResponse = HTTPURLResponse(
            url: url,
            statusCode: response.controlData.statusCode,
            httpVersion: nil,
            headerFields: response.headerSection.fieldLines.reduce(into: [String: String]()) { result, fieldLine in
                let values: [String] = [result[fieldLine.name], fieldLine.value].compactMap { $0 }
                result[fieldLine.name] = values.joined(separator: ", ")
            }
        ) else {
            throw ResponseCreationError()
        }
        
        return (httpResponse, response.content)
    }
}

struct ResponseCreationError: Error {}
