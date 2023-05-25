//
//  MongoDBRequests.swift
//  sendjoy-IOS
//
//  Created by Christian Harrison on 27/02/2023.
//

import Foundation
import SwiftyJSON


class Requests {
    
    var authData:String
    
    init() {
        let path = Bundle.main.path(forResource: "env", ofType: "plist")
        let dict = NSDictionary(contentsOfFile: path!) as! [String:String]
        self.authData = dict["INTERNAL_AUTH"]!
    }
    
      
    func getMessages(endPoint: String, completion: @escaping (Result<JSON, Error>) -> Void) {
//        let url = URL(string: "http://localhost:3000/api/messages/"+endPoint)!
        let url = URL(string: "https://www.sendjoy.app/api/messages/"+endPoint)!
        var request = URLRequest(url: url)
//        let authData = ProcessInfo.processInfo.environment["INTERNAL_AUTH"]
        request.setValue("Bearer \(self.authData)", forHTTPHeaderField: "authorization")
        request.httpMethod = "GET"


        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain:"sendjoy.app/api/messages/pending", code: 1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let json = try JSON(data: data)
                if String(json["statusCode"].intValue).first != "2" {
                    //print error is statudCode is an error code.
                    _ = NSError(domain: "sendjoy.app/api/messages/pending", code: 4, userInfo: [NSLocalizedDescriptionKey:"Status code: \(json["statusCode"])"])
                }
                completion(.success(json))
                
            } catch let decoderError {
                completion(.failure(NSError(domain: "sendjoy.app/api/messages/pending", code: 3, userInfo: [NSLocalizedDescriptionKey: "Unable to decode JSON data. content-type possibly 'text/plain'. \n decoderError: \(decoderError)"])))
            }

        }

        task.resume()
    }
    

    
    func confirmOrRejectMessage(messageId: String, rejection: Bool, completion: @escaping (Result<Any, Error>) -> Void) {
        //Rejects messages that we don't want being sent onto users.
        var urlStatus = "rejection"
        var url = URL(string: "https://www.sendjoy.app/api/messages/rejection")!
        if rejection == false {
            url = URL(string: "https://www.sendjoy.app/api/messages/confirmation")!
            urlStatus = "confirmation"
        }
//        let authData = ProcessInfo.processInfo.environment["INTERNAL_AUTH"]
        var request = URLRequest(url: url)
        let params:[String:Any] = ["messageId": messageId]
        
        request.httpMethod = "POST"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        request.setValue("Bearer \(self.authData)", forHTTPHeaderField: "authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    let error = NSError(domain: "sendjoy.app/api/messages/"+urlStatus, code: 2, userInfo: [NSLocalizedDescriptionKey: "No data returned from server"])
                    completion(.failure(error))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                }
                // Process the response data here
                if let responseString = String(data: data, encoding: .utf8) {
                    print(responseString)
                }
                completion(.success(data))
            }
        task.resume()
    }
    
    func confirmOrRejectSocials(messageId: String, socialsStatus: String, completion: @escaping (Result<Any, Error>) -> Void) {
        //Rejects messages that we don't want being sent onto users.
      
        let url = URL(string: "https://www.sendjoy.app/api/messages/socials")!
//        let url = URL(string: "http://localhost:3000/api/messages/socials")!
        
//        let authData = ProcessInfo.processInfo.environment["INTERNAL_AUTH"]
        var request = URLRequest(url: url)
        let params:[String:Any] = ["_id": messageId, "socialsStatus":socialsStatus]
        
        request.httpMethod = "PUT"
        request.httpBody = try? JSONSerialization.data(withJSONObject: params)
        request.setValue("Bearer \(self.authData)", forHTTPHeaderField: "authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let session = URLSession.shared
        
        let task = session.dataTask(with: request) { data, response, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    let error = NSError(domain: "sendjoy.app/api/messages/socials", code: 4, userInfo: [NSLocalizedDescriptionKey: "No data returned from server"])
                    completion(.failure(error))
                    return
                }
                if let httpResponse = response as? HTTPURLResponse {
                    print("Status code: \(httpResponse.statusCode)")
                }
                // Process the response data here
                if let responseString = String(data: data, encoding: .utf8) {
                    print(responseString)
                }
                completion(.success(data))
            }
        task.resume()
    }
    
    
    func postToSocials(completion: @escaping (Result<Any, Error>) -> Void) {
        let url = URL(string: "https://sendjoy-python-api-2t7vf.ondigitalocean.app/api/post-socials")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(self.authData)", forHTTPHeaderField: "authorization")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else {
                let error = NSError(domain: "sendjoy-python-api-2t7vf.ondigitalocean.app", code: 5, userInfo: [NSLocalizedDescriptionKey: "No data returned from the server"])
                completion(.failure(error))
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
                completion(.success(String(httpResponse.statusCode)))
            }
            if let responseString = String(data: data, encoding: .utf8) {
                print(responseString)
            }
            
        }
        
        task.resume()
        
    }
    
}
