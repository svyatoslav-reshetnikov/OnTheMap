//
//  UdacityFunctions.swift
//  OnTheMap
//
//  Created by SVYAT on 25.05.16.
//  Copyright © 2016 HiT2B. All rights reserved.
//

import Foundation

extension OnTheMapClient {
    
    func udacityAuth(login: String, password: String, completionHandler: (success: Bool, errorString: String?) -> Void) {
        
        loginWithUsernamePassword(login, password: password) { success, sessionID, errorString in
            if let sessionID = sessionID {
                // Save sessionID in the UdacityClient
                self.sessionID = sessionID
                // And in the NSUserDefaults
                NSUserDefaults.standardUserDefaults().setObject(sessionID, forKey: "sessionID")
            }
            completionHandler(success: success, errorString: errorString)
        }
    }
    
    func udacityLogout(completionHandler: (success: Bool, errorString: String?) -> Void) {
        logout { (success, sessionID, errorString) in
            if sessionID != nil {
                // Remove sessionID from the UdacityClient
                self.sessionID = ""
                // And from the NSUserDefaults
                NSUserDefaults.standardUserDefaults().setObject("", forKey: "sessionID")
            }
            completionHandler(success: success, errorString: errorString)
        }
    }
    
    func getStudents(limit: Int, completionHandler: (success: Bool, errorString: String?) -> Void) {
        getStudentsFromParse(limit) { success, students, errorString in
            if students != nil {
                self.students = students!
            }
            completionHandler(success: success, errorString: errorString)
        }
    }
    
    private func loginWithUsernamePassword(login: String, password: String, completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        let jsonBody = "{\"udacity\": {\"\(OnTheMapClient.JSONBodyKeys.Username)\": \"\(login)\", \"\(OnTheMapClient.JSONBodyKeys.Password)\": \"\(password)\"}}"
        let url = udacityUrlFromParameters(parameters, withPathExtension: Methods.Session)
        
        let request = createRequest(url)
        
        taskForPOSTMethod(request, jsonBody: jsonBody) { results, error in
            if let error = error {
                print(error)
                completionHandler(success: false, sessionID: nil, errorString: error.localizedDescription)
            } else {
                if let session = results[OnTheMapClient.JSONResponseKeys.Session] as? [String: AnyObject] {
                    if let sessionID = session[OnTheMapClient.JSONResponseKeys.SessionID] as? String {
                        completionHandler(success: true, sessionID: sessionID, errorString: "")
                    } else {
                        completionHandler(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.SessionID) in \(session)")
                    }
                } else {
                    completionHandler(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
    private func logout(completionHandler: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        let url = udacityUrlFromParameters(parameters, withPathExtension: Methods.Session)
        
        let request = createRequest(url)
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        taskForDELETEMethod(request) { results, error in
            if let error = error {
                completionHandler(success: false, sessionID: nil, errorString: error.localizedDescription)
            } else {
                if let session = results[OnTheMapClient.JSONResponseKeys.Session] as? [String: AnyObject] {
                    if let sessionID = session[OnTheMapClient.JSONResponseKeys.SessionID] as? String {
                        completionHandler(success: true, sessionID: sessionID, errorString: "")
                    } else {
                        completionHandler(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.SessionID) in \(session)")
                    }
                } else {
                    completionHandler(success: false, sessionID: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
    private func getStudentsFromParse(limit: Int, completionHandler: (success: Bool, students: [StudentIndormation]?, errorString: String?) -> Void) {
        
        var parameters = [String:AnyObject]()
        parameters["limit"] = limit
        
        let url = parseUrlFromParameters(parameters, withPathExtension: Methods.StudentLocation)
        
        let request = createParseRequest(url)
        
        taskForGETMethod(request) { results, error in
            if let error = error {
                completionHandler(success: false, students: nil, errorString: error.localizedDescription)
            } else {
                if let resultsArray = results[OnTheMapClient.JSONResponseKeys.Results] as? NSArray {
                    var students = [StudentIndormation]()
                    for result in resultsArray {
                        let student = StudentIndormation(dictionary: result as! NSDictionary)
                        students.append(student)
                    }
                    
                    if students.count == 0 {
                        completionHandler(success: false, students: nil, errorString: "No students")
                    } else {
                        self.students = students
                        completionHandler(success: true, students: students, errorString: nil)
                    }
                } else {
                    completionHandler(success: false, students: nil, errorString: "Could not find \(OnTheMapClient.JSONResponseKeys.Session) in \(results)")
                }
            }
        }
    }
    
}