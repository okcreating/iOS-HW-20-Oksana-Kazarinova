import Foundation

// MARK: Model

public struct Cards: Decodable {
    let cards: [Card]
}

public struct Card: Decodable {
    var name: String
    var cmc: Int?
    var setName: String
    var number: String?
    var power: String?
    var artist: String?
}

final class NetworkManager: ObservableObject {

    // MARK: URL Creation

    enum Path: String {
        case v1Cards = "/v1/cards"
        case wrongURL = "/v0/neverfindable"
    }

    func createURL(path: Path, queryItems: [URLQueryItem]) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.magicthegathering.io"
        components.path = path.rawValue
        components.queryItems = queryItems
        return components.url
    }

    // MARK: Errors

    enum NetworkError: Error {
        case noAccess
        case badRequest
        case forbidden
        case notFound
        case internalServerError
        case serviceUnavailable
    }

    // MARK: URL Request

    func createRequest(url: URL?) -> URLRequest? {
        guard let url else { return nil }
        let request = URLRequest(url: url)
        return request
    }

    // MARK: Fetching Data

    func getData(path: Path, queryItems: [URLQueryItem], completion: @escaping(Result<Cards, NetworkError>) -> Void) {
        guard let url = createURL(path: path, queryItems: queryItems),
              let urlRequest = createRequest(url: url) else { return }

        URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                print("Error occurred")
                completion(.failure(.noAccess))
                } else {
                guard let httpresponse = response as? HTTPURLResponse,
                      let data else { return }

                switch httpresponse.statusCode {
                case 200:
                    print("You've got the data!")
                    do {
                        let result = try JSONDecoder().decode(Cards.self, from: data)
                        completion(.success(result))
                    } catch {
                            completion(.failure(.noAccess))
                    }
                case 400:
                    print("\(httpresponse.statusCode). We could not process that action")
                    completion(.failure(.badRequest))
                case 403:
                    print("\(httpresponse.statusCode). You exceeded the rate limit")
                    completion(.failure(.forbidden))
                case 404:
                    print("\(httpresponse.statusCode). The requested resource could not be found")
                    completion(.failure(.notFound))
                case 500:
                    print(" \(httpresponse.statusCode). We had a problem with our server. Please try again later")
                    completion(.failure(.internalServerError))
                case 503:
                    print("\(httpresponse.statusCode). We are temporarily offline for maintenance. Please try again later")
                    completion(.failure(.serviceUnavailable))
                default:
                    print("Sorry, you faced with unknown error.")
                    completion(.failure(.noAccess))
                    }
               }
            }.resume()
        }
    }

var cardsInformation = NetworkManager()

cardsInformation.getData(path:.v1Cards, queryItems: [URLQueryItem(name: "name", value: "Opt|Black Lotus")]) { result in
    switch result {
    case .success(let cards):
        print(cards.cards.forEach({ card in
            print("\(card.name.uppercased()) card:\ncmc: \(card.cmc ?? 0)\nset name: \(card.setName)\nnumber: \(card.number ?? "")\npower: \(card.power ?? "Doesn't matter")\nartist: \(card.artist ?? "unknowm")\n")
        }))
    case .failure(let failure):
        print(failure.localizedDescription)
    }
}


