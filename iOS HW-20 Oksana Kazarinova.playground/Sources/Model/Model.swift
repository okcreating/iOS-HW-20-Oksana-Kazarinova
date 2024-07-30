import Foundation

public struct CardModel: Decodable {
    let name: String
    let cmc: Int
    let setName: String
    let number: String
    let power: String
}
