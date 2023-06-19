import Foundation

// According to BHTTP spec
// (https://datatracker.ietf.org/doc/rfc9292/)
// Variable-Length Integer Encoding from QUIC should be used
// (https://datatracker.ietf.org/doc/html/draft-ietf-quic-transport-16#section-16)

extension FixedWidthInteger {
    
    private func byteArray() -> [UInt8] {
        withUnsafeBytes(of: self.bigEndian, Array.init)
    }
    
    func variableLengthEncoded() -> Data {
        switch self {
        // 0-63, 1 byte: 2 bits for length id (00) + 6 usable bits
        case 0...63:
            var value = UInt8(self).bigEndian
            return Data(bytes: &value, count: 1)
            
        // 0-16383, 2 bytes: 2 bits for length id (01) + 14 usable bits
        case 64...16383:
            var byteArray = UInt16(self).byteArray()
            // first two bits are 00, set them to 01
            byteArray[0] = byteArray[0] | (1 << 6)
            return Data(bytes: &byteArray, count: 2)
            
        // 0-1073741823, 4 bytes: 2 bits for length id (10) + 30 usable bits
        case 16384...1073741823:
            var byteArray = UInt32(self).byteArray()
            // first two bits are 00, set them to 10
            byteArray[0] = byteArray[0] | (1 << 7)
            return Data(bytes: &byteArray, count: 4)
            
        // 0-4611686018427387903, 8 bytes: 2 bits for length id (11) + 62 usable bits
        case 1073741824...4611686018427387903:
            var byteArray = UInt64(self).byteArray()
            // first two bits are 00, set them to 11
            byteArray[0] = byteArray[0] | (1 << 7) | (1 << 6)
            return Data(bytes: &byteArray, count: 8)
            
        default:
            return Data()
        }
    }
}

extension Int: BinaryHTTPDecodable {
    
    static func decode(_ decoder: BinaryHTTPDecoder) throws -> Self {
        guard let firstByte = decoder.firstByte else {
            throw BinaryHTTPDecodingError.eof
        }
        /*
         The QUIC variable-length integer encoding reserves the two most
         significant bits of the first octet to encode the base 2 logarithm of
         the integer encoding length in octets.
        */
        let firstByteLengthBits = firstByte / (1 << 6)
        let firstByteValuableBits = firstByte % (1 << 6)
        let length = 1 << firstByteLengthBits
        
        var bytes = [UInt8](try decoder.readData(length))
        bytes[0] = firstByteValuableBits
        
        var value: UInt64 = 0
        for byte in bytes {
            value = value << 8
            value = value | UInt64(byte)
        }
        return Int(value)
    }
}
