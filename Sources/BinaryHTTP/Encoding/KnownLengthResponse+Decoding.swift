import Foundation

extension KnownLengthResponse: BinaryHTTPDecodable {

    static func decode(_ decoder: BinaryHTTPDecoder) throws -> Self {
        var informationalResponses: [KnownLengthInformationalResponse] = []
        var controlData: ResponseControlData = try decoder.read()
        while controlData.isInformational() {
            let informationalResponse = KnownLengthInformationalResponse(
                controlData: controlData,
                fieldSection: try decoder.read()
            )
            informationalResponses.append(informationalResponse)
            controlData = try decoder.read()
        }
        
        return KnownLengthResponse(
            informationalResponses: informationalResponses,
            controlData: controlData,
            headerSection: try decoder.read(),
            content: try decoder.read(),
            trailerSection: try decoder.read()
        )
    }
}

extension ResponseControlData: BinaryHTTPDecodable {
    
    func isInformational() -> Bool {
        100...199 ~= statusCode
    }
    
    static func decode(_ decoder: BinaryHTTPDecoder) throws -> Self {
        let statusCode: Int = try decoder.read()
        guard 100...599 ~= statusCode else {
            throw BinaryHTTPDecodingError.invalidStatusCode
        }
        return ResponseControlData(statusCode: statusCode)
    }
}

extension FieldSection: LengthPrefixedBinaryHTTPDecodable {
    
    static func fromData(_ data: Data) throws -> FieldSection {
        let internalDecoder = BinaryHTTPDecoder(data)
        var lines: [FieldLine] = []
        while internalDecoder.hasMoreData() {
            lines.append(try internalDecoder.read())
        }
        return FieldSection(fieldLines: lines)
    }
}

extension FieldLine: BinaryHTTPDecodable {

    static func decode(_ decoder: BinaryHTTPDecoder) throws -> Self {
        FieldLine(
            name: try decoder.read(),
            value: try decoder.read()
        )
    }
}

extension String: LengthPrefixedBinaryHTTPDecodable {
    
    static func fromData(_ data: Data) throws -> String {
        if let asciiString = String(data: data, encoding: .ascii) {
           return asciiString
        } else {
            throw BinaryHTTPDecodingError.asciiDecodingError
        }
    }
}

extension Data: LengthPrefixedBinaryHTTPDecodable {
    static func fromData(_ data: Data) throws -> Data { data }
}
