//
//  DirectionViewModel.swift
//  DrivingDirection
//
//  Created by 沈清昊 on 5/15/23.
//

import Foundation
import Combine

class DirectionViewModel: ObservableObject{
    let origin: String
    let dest: String
    
    var searchDriveDirectionString = "https://driving-directions1.p.rapidapi.com/get-directions?origin="
    let headers = [
        "X-RapidAPI-Key": "54217155a0mshc59ae06a0968327p12a4c1jsn682bd9007ac0",
        "X-RapidAPI-Host": "driving-directions1.p.rapidapi.com"
    ]
    
    @Published var drivingDirection: DrivingDirection?
    @Published var hasError = false
    @Published var error: LoadError?
    
    private var bag: Set<AnyCancellable> = []
    
    init(origin: String, dest: String){
        self.origin = origin
        self.dest = dest
    }
    
    func fetchDirection(){
        searchDriveDirectionString += "\(origin.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&destination=\(dest.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
        
        guard let url = URL(string: searchDriveDirectionString) else{
            hasError = true
            error = .failedToUnwrapOptional
            return
        }
        
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = headers
        
        URLSession.shared
            .dataTaskPublisher(for: request)
            .receive(on: DispatchQueue.main)
            .tryMap { result -> DrivingDirection in
                guard let response = result.response as? HTTPURLResponse,
                      response.statusCode >= 200 && response.statusCode <= 300 else{
                          throw LoadError.invalidStatusCode
                      }
                let decoder = JSONDecoder()
                guard let direction = try? decoder.decode(DrivingDirection.self, from: result.data) else{
                    throw LoadError.failedToDecode
                }
                return direction
            }
            .sink { [weak self] result in
                switch result{
                case .finished:
                    break
                case .failure(let error):
                    self?.hasError = true
                    self?.error = .custom(error: error)
                }
            } receiveValue: { [weak self] direction in
                self?.drivingDirection = direction
            }
            .store(in: &bag)
    }
}

extension DirectionViewModel{
    enum LoadError: LocalizedError{
        case custom(error: Error)
        case failedToDecode
        case failedToUnwrapOptional
        case invalidStatusCode
        
        var errorDescription: String?{
            switch self {
            case .custom(let error):
                return error.localizedDescription
            case .failedToDecode:
                return "Falied to decode the data."
            case .failedToUnwrapOptional:
                return "Unable to unwrap the optional value."
            case .invalidStatusCode:
                return "GET request failed due to invalid status code."
            }
        }
    }
}

//extension String{
//    func stringByAddingPercentEncodingForRFC3986() -> String?{
//        let unreversed = "-._~/?"
//        let allowed = NSMutableCharacterSet.alphanumeric()
//        allowed.addCharacters(in: unreversed)
//        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
//    }
//}
