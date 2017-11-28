
#if DEBUG
let SERVER_BASE_URL = "https://api.flickr.com/services/rest/"
#else
let SERVER_BASE_URL = "https://api.flickr.com/services/rest/"
#endif

let apiKey = "f2ddfcba0e5f88c2568d96dcccd09602"

import UIKit

enum eHTTPMethod
{
    case eHTTPMethodGET
    case eHTTPMethodPOST
    case eHTTPMethodPUT
    case eHTTPMethodDELETE
}

enum eWebRequestName
{
    case eRequestTypeSearch
}

/*
 'http_code' is '200' & 'success' is 'true' in case of success
 'http_code' is '422' & 'success' is 'false' in case of failre (ex: validation errors)
 'http_code' is '500'(series) & 'success' is 'false' in case of server side error (ex: exceptions)
 'http_code' is '401' (Unauthorized: Access is denied )
 'http_code' is '400' (Unauthorized: Access is denied )
 */

enum eStatusCode: Int
{
    case eRequestSuccess = 200
    case eRequestFailure = 422
    case eServerNotRespond = 500
    case eServerNotResponding = 599
    case eInvalidToken = 400
    case eInvalidTokenLimit = 499
}

let kNoInternetMessage  = "No Internet Connectivity"

class NetworkCall: NSObject
{
    static let sharedNetworkManager = NetworkCall()
    private var reachability: Reachability = Reachability(hostname: "https://api.flickr.com")!
    
    //MARK:- Method to get specifically Internet Status
    func giveInternetStatus() -> Bool
    {
        if reachability.isReachable
        {
            return true
        }
        else
        {
            self.noInternetSatusBar(msg: kNoInternetMessage)
            return false
        }
    }
    
    //MARK:- Display Message for internet connectivity.
    func noInternetSatusBar(msg : String)
    {
        DispatchQueue.main.async {
            let internetStatusview = InternetStatusView.init()
            internetStatusview.showInternetStatusMessage(status: msg)
        }
    }
    
    
    //MARK:-  Server GET Call
    func getServerCall(getApi: eWebRequestName,params:String? = nil,completion: @escaping (_ result: NSDictionary) -> Void)
    {
        if self.giveInternetStatus()
        {
            var urlString = String(format: "%@%@", SERVER_BASE_URL,self.apiURLForRequestType(type: getApi))
            
            if let parameters : String = params
            {
                let para : NSString = parameters as NSString
                let escapedParameters = para.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)

                urlString = urlString.appending(escapedParameters!)
            }
            
            let url: NSURL = NSURL(string: urlString)!
            
            let request: NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
            
            request.httpMethod = "GET"
            request.timeoutInterval = 30
    
            let task = URLSession.shared.dataTask(with: request as URLRequest) {
                data, response, error in
                
                DispatchQueue.main.async(execute: {
                    
                    if let httpResponse = response as? HTTPURLResponse
                    {
                        //print(httpResponse)
                        
                        switch httpResponse.statusCode
                        {
                        case eStatusCode.eRequestSuccess.rawValue:
                            
                            do {
                                
                                let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
                                
                                print( jsonResult)
                                
                                guard (jsonResult.isEqual(nil)) else
                                {
                                    let resultDict : NSDictionary = jsonResult.value(forKey: "photos") as! NSDictionary
                                    let sucessStatus : NSString = jsonResult.value(forKey:"stat") as! NSString
                                    
                                    if (sucessStatus == "ok")
                                    {
                                        completion(resultDict)
                                    }
                                    return
                                }
                            }catch let error as NSError {
                                print(error.localizedDescription)
                            }
                            break
                            
                        case eStatusCode.eRequestFailure.rawValue:
                            
                            self.displayErrorMessage(data: data!)
                            break
                            
                        case (eStatusCode.eServerNotRespond.rawValue...eStatusCode.eServerNotResponding.rawValue):
                            self.displayErrorMessage(data: data!)
                            break
                            
                        case (eStatusCode.eInvalidToken.rawValue...eStatusCode.eInvalidTokenLimit.rawValue):
                            self.displayErrorMessage(data: data!)
                            break
                            
                        default:
                            
                            break
                        }
                    }
                })
            }
            task.resume()
        }
    }
    
    
    //MARK:- Display Error Message
    func displayErrorMessage(data : Data)
    {
        do {
            let jsonResult: NSDictionary = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments) as! NSDictionary
            
            if let resultDict : NSDictionary = jsonResult.value(forKey: "status") as? NSDictionary
            {
                if let message = resultDict["message"] as? String{
                    let alert = UIAlertController(title: "Error", message: "\(message)", preferredStyle: UIAlertControllerStyle.alert)
                    
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    
                    DispatchQueue.main.async() {
                        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }catch let error as NSError {
            NSLog("%@", error.localizedDescription)
        }
    }
    
    //MARK:-  EndPoint Method
    func apiURLForRequestType(type : eWebRequestName) -> String
    {
        var apiURL : String
        
        switch (type)
        {
            case .eRequestTypeSearch:
                apiURL = "?method=flickr.photos.search&api_key=\(apiKey)&format=json&nojsoncallback=1&safe_search=1&text="
        }
        return apiURL
    }
    
    //MARK:-  String Conversion to JsonString
    func convertDictToJsonString (postInfo : Dictionary<String,AnyObject>) -> NSString
    {
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: postInfo, options: [.prettyPrinted])
            
            guard NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) == nil else {
                return NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue)!
            }
        }
        catch
        {
            print("\(error)")
        }
        
        return NSString(string: "error")
    }
}
