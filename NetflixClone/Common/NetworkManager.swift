//
//  NetworkManager.swift
//  NetflixClone
//
//  Created by 백시훈 on 8/2/24.
//

import Foundation
import RxSwift

enum NetworkError: Error{
    case invailedUrl
    case dataFetchFail
    case decodingFail
}


// 싱글톤 네트워크 매니저
class NetworkManager{
    static let shared = NetworkManager()
    private init(){}
    
    func fetch<T: Decodable>(url: URL) -> Single<T>{
        return Single.create{ observer in
            let session = URLSession(configuration: .default)
            session.dataTask(with: URLRequest(url: url)){ data, response, error in
                
                if let error = error {
                    observer(.failure(error))
                    return
                }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode) else {
                    observer(.failure(NetworkError.dataFetchFail))
                    return
                }
                
                do{
                    let decodedData = try JSONDecoder().decode(T.self, from: data)
                    observer(.success(decodedData))
                }catch{
                    observer(.failure(NetworkError.decodingFail))
                }
                
            }.resume()
            return Disposables.create()
        }
    }
}
