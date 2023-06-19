import Foundation

extension KnownLengthRequest {

    func binaryEncoded() throws -> Data {
        var result = Data()
        [
            withUnsafeBytes(of: Self.framingIndicator) { Data($0) },
            try requestControlData.binaryEncoded(),
            try headerSection.binaryEncoded(),
            content.withLengthPrefix(),
            try trailerSection.binaryEncoded()
        ].forEach { result.append($0) }
        
        return result
    }
}

extension RequestControlData {

    func binaryEncoded() throws -> Data {
        guard let methodData = method.asciiDataWithLengthPrefix() else {
            throw RequestCreationError(description: "Non-ASCII characters in method: \(method)")
        }
        guard let schemeData = scheme.asciiDataWithLengthPrefix() else {
            throw RequestCreationError(description: "Non-ASCII characters in scheme: \(scheme)")
        }
        guard let authorityData = authority.asciiDataWithLengthPrefix() else {
            throw RequestCreationError(description: "Non-ASCII characters in authority: \(authority)")
        }
        guard let pathData = path.asciiDataWithLengthPrefix() else {
            throw RequestCreationError(description: "Non-ASCII characters in path: \(path)")
        }
        var result = Data()
        [
            methodData,
            schemeData,
            authorityData,
            pathData
        ].forEach { result.append($0) }
        return result
    }
}

extension FieldSection {
    
    func binaryEncoded() throws -> Data {
        var linesData = Data()
        try fieldLines.forEach {
            linesData.append(try $0.binaryEncoded())
        }
        return linesData.count.variableLengthEncoded() + linesData
    }
}

extension FieldLine {

    func binaryEncoded() throws -> Data {
        guard let nameData = name.asciiDataWithLengthPrefix() else {
            throw RequestCreationError(description: "Non-ASCII characters in field name: \(name)")
        }
        guard let valueData = value.asciiDataWithLengthPrefix() else {
            throw RequestCreationError(description: "Non-ASCII characters in field value. Field name: \(name), value: \(value)")
        }
        return nameData + valueData
    }
}

extension String {
    func asciiDataWithLengthPrefix() -> Data? {
        guard let encoded = self.data(using: .ascii, allowLossyConversion: false) else { return nil }
        return encoded.withLengthPrefix()
    }
}

extension Data {
    func withLengthPrefix() -> Self {
        count.variableLengthEncoded() + self
    }
}
