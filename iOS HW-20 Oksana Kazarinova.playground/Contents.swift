import Foundation

// MARK: URL Creation

final class NetworkManager {

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

    // MARK: URL Request
    
    func createRequest(url: URL?) -> URLRequest? {
        guard let url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        return request
    }

    //// MARK: Session Configuration
    //
    //func sessionConfiguration() -> URLSession {
    //    let configuration = URLSessionConfiguration.default
    //    configuration.allowsCellularAccess = false
    //    configuration.waitsForConnectivity = true
    //    return URLSession(configuration: configuration)
    //}

    // MARK: Fetching Data

    func getData(completion: @escaping(Result<CardModel, NetworkError>) -> Void, path: Path, queryItems: [URLQueryItem]) {
        guard let url = createURL(path: path, queryItems: queryItems),
              // guard let url = createURL(path: .wrongURL),
            let urlRequest = createRequest(url: url) else { return }
            let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if error != nil {
                print("Error occurred")
                completion(.failure())
                let response = response as? HTTPURLResponse
                switch response?.statusCode {
                case 200:
                    do {
                        let result = try JSONDecoder().decode(CardModel.self, from: data)
                        completion(.success())
                    }
                case 400:
                    print(response.statusCode + ". We could not process that action")
                case 403:
                    print(response.statusCode + ". You exceeded the rate limit")
                case 404:
                    print(response.statusCode + ". The requested resource could not be found")
                case 500:
                    print(response.statusCode + ". We had a problem with our server. Please try again later")
                case 503:
                    print(response.statusCode + ". We are temporarily offline for maintenance. Please try again later")
                default:
                    print("Sorry, you faced with unknown error.")
                }
                guard let data = data else { return }
                let dataAsString = String(data: data, encoding: .utf8)
                print("\(String(describing: dataAsString))")
            }
        }
    } task.resume()
    }


let cardInformation = NetworkManager()
cardInformation.getData { result in
    switch result {
    case .success(let cardInfo):
        print("Card Info:/n name: \(cardInfo.name)")
    }


}
