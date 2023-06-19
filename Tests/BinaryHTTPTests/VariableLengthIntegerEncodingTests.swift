import XCTest

@testable import BinaryHTTP

// Examples taken from https://datatracker.ietf.org/doc/html/draft-ietf-quic-transport-16#section-16

class VariableLengthIntegerEncodingTests: XCTestCase {
    
    func testOneByteLengthNumbersEncoding() {
        XCTAssertEqual(0.variableLengthEncoded().hexEncodedString(), "00")
        XCTAssertEqual(9.variableLengthEncoded().hexEncodedString(), "09")
        XCTAssertEqual(29.variableLengthEncoded().hexEncodedString(), "1d")
        XCTAssertEqual(63.variableLengthEncoded().hexEncodedString(), "3f")
    }
    
    func testTwoByteLengthNumbersEncoding() {
        XCTAssertEqual(64.variableLengthEncoded().hexEncodedString(), "4040")
        XCTAssertEqual(15293.variableLengthEncoded().hexEncodedString(), "7bbd")
        XCTAssertEqual(16383.variableLengthEncoded().hexEncodedString(), "7fff")
    }
    
    func testFourByteLengthNumbersEncoding() {
        XCTAssertEqual(16384.variableLengthEncoded().hexEncodedString(), "80004000")
        XCTAssertEqual(494878333.variableLengthEncoded().hexEncodedString(), "9d7f3e7d")
        XCTAssertEqual(1073741823.variableLengthEncoded().hexEncodedString(), "bfffffff")
    }
    
    func testEightByteLengthNumbersEncoding() {
        XCTAssertEqual(1073741824.variableLengthEncoded().hexEncodedString(), "c000000040000000")
        XCTAssertEqual(151288809941952652.variableLengthEncoded().hexEncodedString(), "c2197c5eff14e88c")
        XCTAssertEqual(4611686018427387903.variableLengthEncoded().hexEncodedString(), "ffffffffffffffff")
    }
    
    func testOneByteLengthNumbersDecoding() {
        let hexNumbers = [
            "00",
            "09",
            "1d",
            "3f"
        ]
        let decoder = BinaryHTTPDecoder(hexNumbers.joined().hexadecimal!)
        
        var number: Int = try! decoder.read()
        XCTAssertEqual(number, 0)
        number = try! decoder.read()
        XCTAssertEqual(number, 9)
        number = try! decoder.read()
        XCTAssertEqual(number, 29)
        number = try! decoder.read()
        XCTAssertEqual(number, 63)
    }
    
    func testTwoByteLengthNumbersDecoding() {
        let hexNumbers = [
            "4040",
            "7bbd",
            "7fff"
        ]
        let decoder = BinaryHTTPDecoder(hexNumbers.joined().hexadecimal!)
        
        var number: Int = try! decoder.read()
        XCTAssertEqual(number, 64)
        number = try! decoder.read()
        XCTAssertEqual(number, 15293)
        number = try! decoder.read()
        XCTAssertEqual(number, 16383)
    }

    func testFourByteLengthNumbersDecoding() {
        let hexNumbers = [
            "80004000",
            "9d7f3e7d",
            "bfffffff"
        ]
        let decoder = BinaryHTTPDecoder(hexNumbers.joined().hexadecimal!)
        
        var number: Int = try! decoder.read()
        XCTAssertEqual(number, 16384)
        number = try! decoder.read()
        XCTAssertEqual(number, 494878333)
        number = try! decoder.read()
        XCTAssertEqual(number, 1073741823)
    }

    func testEightByteLengthNumbersDecoding() {
        let hexNumbers = [
            "c000000040000000",
            "c2197c5eff14e88c",
            "ffffffffffffffff"
        ]
        let decoder = BinaryHTTPDecoder(hexNumbers.joined().hexadecimal!)
        
        var number: Int = try! decoder.read()
        XCTAssertEqual(number, 1073741824)
        number = try! decoder.read()
        XCTAssertEqual(number, 151288809941952652)
        number = try! decoder.read()
        XCTAssertEqual(number, 4611686018427387903)
    }
}

extension String {
    
    var hexadecimal: Data? {
        guard let regex = try? NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive) else {
            return nil
        }
        var data = Data(capacity: count / 2)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            guard let match = match else { return }
            let byteString = (self as NSString).substring(with: match.range)
            if let num = UInt8(byteString, radix: 16) {
                data.append(num)
            }
        }
        guard data.count > 0 else { return nil }
        return data
    }
}
