//
//  UdacityFunctions.swift
//  OnTheMap
//
//  Created by SVYAT on 25.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    func udacityAuth(login: String, password: String, completionHandlerForUdacityAuth: (success: Bool, errorString: String?) -> Void) {
        
        loginWithUsernamePassword(login, password: password) { success, sessionID, errorString in
            if let sessionID = sessionID {
                self.sessionID = sessionID
            }
            completionHandlerForUdacityAuth(success: success, errorString: errorString)
        }
    }
    
    private func loginWithUsernamePassword(login: String, password: String, completionHandlerForLogin: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        let parameters = [String:AnyObject]()
        let jsonBody = "{\"udacity\": {\"\(UdacityClient.JSONBodyKeys.Username)\": \"\(login)\", \"\(UdacityClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
        taskForPOSTMethod(Methods.Session, parameters: parameters, jsonBody: jsonBody) { results, error in
            if let error = error {
                print(error)
                completionHandlerForLogin(success: false, sessionID: nil, errorString: error.localizedDescription)
            } else {
                if let session = results[UdacityClient.JSONResponseKeys.Session] as? [String: AnyObject] {
                    if let sessionID = session[UdacityClient.JSONResponseKeys.SessionID] as? String {
                        completionHandlerForLogin(success: true, sessionID: sessionID, errorString: "")
                    } else {
                        completionHandlerForLogin(success: false, sessionID: nil, errorString: "Could not find \(UdacityClient.JSONResponseKeys.SessionID) in \(session)")
                    }
                } else {
                    //print("Could not find \(UdacityClient.JSONResponseKeys.Session) in \(results)")
                    completionHandlerForLogin(success: false, sessionID: nil, errorString: "Could not find \(UdacityClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
}
