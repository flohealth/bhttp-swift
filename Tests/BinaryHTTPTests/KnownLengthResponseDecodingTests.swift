import XCTest

@testable import BinaryHTTP

class KnownLengthResponseDecodingTests: XCTestCase {
    
    func testSimpleKnownLengthResponseDecoding() {
        let url = URL(string: "https://www.example.com/hello.txt")!
        do {
            let result = try HTTPURLResponse.from(
                url: url,
                binaryHTTPData: knownLengthResponseDataHex.hexadecimal!
            )
            XCTAssertEqual(result.response.url, url)
            XCTAssertEqual(result.response.statusCode, 200)
            XCTAssertTrue(result.response.allHeaderFields.isEmpty)
            XCTAssertEqual(String(data: result.body, encoding: .ascii), "This content contains CRLF.\r\n")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testEarlyTrimmedKnownLengthResponseDecoding() {
        let url = URL(string: "https://www.example.com/hello.txt")!
        do {
            let result = try HTTPURLResponse.from(
                url: url,
                binaryHTTPData: earlyTrimmedKnownLengthResponseDataHex.hexadecimal!
            )
            XCTAssertEqual(result.response.url, url)
            XCTAssertEqual(result.response.statusCode, 200)
            XCTAssertEqual(result.response.allHeaderFields["header"] as? String, "text")
            XCTAssertTrue(result.body.isEmpty)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
}

fileprivate let knownLengthResponseDataHex = [
    // Framing indicator:
    "01",
    
    // Response control data:
    "40c8", // Status code(200)
    
    // Header section:
    "00", // Header section length (0)
    
    // Content:
    "1d", // Content length (29)
    "5468697320636f6e74656e7420636f6e7461696e732043524c462e0d0a", // Content (This content contains CRLF.)
    
    // Trailer section:
    "0d", // Trailer section length (13)
    
    //Field line:
    "07", // Name length(7)
    "747261696c6572", // Name(trailer)
    "04", // Value length (4)
    "74657874", // Value(text)
].joined()

fileprivate let earlyTrimmedKnownLengthResponseDataHex = [
    // Framing indicator:
    "01",
    
    // Response control data:
    "40c8", // Status code(200)
    
    // Header section:
    "0c", // Header section length (12)
    
    //Field line:
    "06", // Name length(6)
    "686561646572", // Name(header)
    "04", // Value length (4)
    "74657874", // Value(text)
    
    // Content (truncated - only 00 length is present)
    "00",
    
    // Trailer section (truncated - only 00 length is present)
    "00"
].joined()
