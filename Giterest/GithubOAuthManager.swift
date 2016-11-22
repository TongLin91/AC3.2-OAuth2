//
//  GithubOAuthManager.swift
//  Giterest
//
//  Created by Tong Lin on 11/17/16.
//  Copyright © 2016 C4Q. All rights reserved.
//

import Foundation
import UIKit

enum GithubAuthScope: String{
    case user, public_repo
}

internal class GithubOAuthManager{
    private static let authorizationURL: URL = URL(string: "https://github.com/login/oauth/authorize")!
    private static let accessTokenURL: URL = URL(string: "https://github.com/login/oauth/access_token")!
    internal static let redirectURI: URL = URL(string: "giterest://auth.url")!
    
    private var clientID: String?
    private var clientSecret: String?
    
    private var requestToken: String?
    private var accessToken: String?
    
    internal static let shared: GithubOAuthManager = GithubOAuthManager()
    private init() {}
    
    internal class func configure(clientID: String, clientSecret: String) {
        shared.clientID = clientID
        shared.clientSecret = clientSecret
    }
    
    internal func requestAuthentication(scopes: [GithubAuthScope]) throws {
        guard
            clientID != nil,
            clientSecret != nil
            else {
                throw NSError(domain: "No Client", code: 01, userInfo: nil)
        }
        
        var urlComponents = URLComponents(url: GithubOAuthManager.authorizationURL, resolvingAgainstBaseURL: true)
        
        let clientIDQuery = URLQueryItem(name: "client_id", value: self.clientID!)
        let redirectURIQuery = URLQueryItem(name: "redirect_uri", value: GithubOAuthManager.redirectURI.absoluteString)
        let scopeQuery = URLQueryItem(name: "scope", value: scopes.flatMap { $0.rawValue }.joined(separator: " ".addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!) )
        
        urlComponents?.queryItems = [clientIDQuery, redirectURIQuery, scopeQuery]
        
        UIApplication.shared.open(urlComponents!.url!, options: [:], completionHandler: nil)
    }
    
    internal func requestAuthToken(from responseURL: URL) {
        guard
            let urlQuery = responseURL.query,
            let accessCode = urlQuery.components(separatedBy: "=").last
            else {
                return
        }
        
        let clientIDQuery = URLQueryItem(name: "client_id", value: self.clientID!)
        let clientSecretQuery = URLQueryItem(name: "client_secret", value: self.clientSecret!)
        let codeQuery = URLQueryItem(name: "code", value: accessCode)
        let redirectURIQuery = URLQueryItem(name: "redirect_uri", value: GithubOAuthManager.redirectURI.absoluteString)
          
        var urlComponents = URLComponents(url: GithubOAuthManager.accessTokenURL, resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = [clientIDQuery, clientSecretQuery, codeQuery, redirectURIQuery]
        
        var request = URLRequest(url: urlComponents!.url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession(configuration: .default)
        session.dataTask(with: request, completionHandler: { (data: Data?, _, error: Error?) in
            
            if error != nil {
                print("Error encountered on token request: \(error!)")
            }
            
            if data != nil{
                
                
            }
            
        }).resume()
        
    }
    
}



