import Foundation

 enum NetworkError: Error {
    case badRequest
    case forbidden
    case notFound
    case internalServerError
    case serviceUnavailable
}
