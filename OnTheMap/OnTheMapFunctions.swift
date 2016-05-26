//
//  UdacityFunctions.swift
//  OnTheMap
//
//  Created by SVYAT on 25.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import Foundation

extension OnTheMapClient {
    
    func udacityAuth(login: String, password: String, completionHandlerForUdacityAuth: (success: Bool, errorString: String?) -> Void) {
        
        loginWithUsernamePassword(login, password: password) { success, sessionID, errorString in
            if let sessionID = sessionID {
                // Save sessionID in the UdacityClient
                self.sessionID = sessionID
                // And in the NSUserDefaults
                NSUserDefaults.standardUserDefaults().setObject(sessionID, forKey: "sessionID")
            }
            completionHandlerForUdacityAuth(success: success, errorString: errorString)
        }
    }
    
    func udacityLogout(completionHandlerForUdacityAuth: (success: Bool, errorString: String?) -> Void) {
        logout { (success, sessionID, errorString) in
            if sessionID != nil {
                // Remove sessionID from the UdacityClient
                self.sessionID = ""
                // And from the NSUserDefaults
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "sessionID")
            }
            completionHandlerForUdacityAuth(success: success, errorString: errorString)
        }
    }
    
    private func loginWithUsernamePassword(login: String, password: String, completionHandlerForLogin: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        let jsonBody = "{\"udacity\": {\"\(OnTheMapClient.JSONBodyKeys.Username)\": \"\(login)\", \"\(OnTheMapClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
        let url = udacityUrlFromParameters(parameters, withPathExtension: Methods.Session)
        
        taskForPOSTMethod(url, parameters: parameters, jsonBody: jsonBody) { results, error in
            if let error = error {
                print(error)
                completionHandlerForLogin(success: false, sessionID: nil, errorString: error.localizedDescription)
            } else {
                if let session = results[OnTheMapClient.JSONResponseKeys.Session] as? [String: AnyObject] {
                    if let sessionID = session[OnTheMapClient.JSONResponseKeys.SessionID] as? String {
                        completionHandlerForLogin(success: true, sessionID: sessionID, errorString: "")
                    } else {
                        completionHandlerForLogin(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.SessionID) in \(session)")
                    }
                } else {
                    completionHandlerForLogin(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
    private func logout(completionHandlerForLogin: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        let url = udacityUrlFromParameters(parameters, withPathExtension: Methods.Session)
        
        taskForDELETEMethod(url, parameters: parameters) { results, error in
            if let error = error {
                completionHandlerForLogin(success: false, sessionID: nil, errorString: error.localizedDescription)
            } else {
                if let session = results[OnTheMapClient.JSONResponseKeys.Session] as? [String: AnyObject] {
                    if let sessionID = session[OnTheMapClient.JSONResponseKeys.SessionID] as? String {
                        completionHandlerForLogin(success: true, sessionID: sessionID, errorString: "")
                    } else {
                        completionHandlerForLogin(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.SessionID) in \(session)")
                    }
                } else {
                    completionHandlerForLogin(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
}
