import Foundation

// Structs that mirror definitions from https://datatracker.ietf.org/doc/rfc9292/

struct KnownLengthRequest {
    static let framingIndicator: UInt8 = 0
    let requestControlData: RequestControlData
    let headerSection: FieldSection
    let content: Data
    let trailerSection: FieldSection
}

struct KnownLengthResponse {
    static let framingIndicator: UInt8 = 1
    let informationalResponses: [KnownLengthInformationalResponse]
    let controlData: ResponseControlData
    let headerSection: FieldSection
    let content: Data
    let trailerSection: FieldSection
}

struct KnownLengthInformationalResponse {
    let controlData: ResponseControlData
    let fieldSection: FieldSection
}

struct ResponseControlData {
    let statusCode: Int
}

struct RequestControlData {
    let method: String
    let scheme: String
    let authority: String
    let path: String
}

struct FieldSection {
    let fieldLines: [FieldLine]

    static let empty = FieldSection(fieldLines: [])
    
    var isEmpty: Bool {
        fieldLines.isEmpty
    }
}

struct FieldLine {
    let name: String
    let value: String
}
