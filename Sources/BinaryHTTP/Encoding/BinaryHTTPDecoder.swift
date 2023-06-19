import Foundation

protocol BinaryHTTPDecodable {
    static func decode(_ decoder: BinaryHTTPDecoder) throws -> Self
}

protocol LengthPrefixedBinaryHTTPDecodable {
    static func fromData(_ data: Data) throws -> Self
}

final class BinaryHTTPDecoder {
    
    private let bytes: [UInt8]
    private var offset: Int = 0
    
    init(_ data: Data) {
        bytes = [UInt8](data)
    }
    
    func readData(_ count: Int) throws -> Data {
        let newOffset = offset + count
        guard newOffset <= bytes.count else {
            throw BinaryHTTPDecodingError.eof
        }
        var slice = Array(bytes[offset ..< newOffset])
        offset = newOffset
        return Data(bytes: &slice, count: count)
    }
    
    var firstByte: UInt8? {
        hasMoreData() ? bytes[offset] : nil
    }
    
    func hasMoreData() -> Bool {
        bytes.indices.contains(offset)
    }
    
    func read<T: BinaryHTTPDecodable>() throws -> T {
        try T.decode(self)
    }
    
    func read<T: LengthPrefixedBinaryHTTPDecodable>() throws -> T {
        let length: Int = try read()
        return try T.fromData(try readData(length))
    }
}

enum BinaryHTTPDecodingError: Error {
    // unexpected end of data
    case eof
    // could not decode string from data where ASCII is expected
    case asciiDecodingError
    // status code is not of 100-599 or couldn't be read
    case invalidStatusCode
    // framing indicator is invalid or unsupported
    case framingIndicatorUnknown
}
