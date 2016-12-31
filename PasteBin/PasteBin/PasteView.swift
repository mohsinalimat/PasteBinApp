//
//  PasteView.swift
//  PasteBin
//
//  Created by JonLuca De Caro on 12/28/16.
//  Copyright © 2016 JonLuca De Caro. All rights reserved.
//

import UIKit
import AFNetworking

class PasteView: UIViewController, UITextViewDelegate, UIGestureRecognizerDelegate {
    var isCurrentlyEditing = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Don't judge for the following code - fairly redudant but works
        let tapOutTextField: UITapGestureRecognizer = UITapGestureRecognizer(target: textView, action: #selector(edit));
        textView.delegate = self;
        textView.addGestureRecognizer(tapOutTextField);
        view.addGestureRecognizer(tapOutTextField)
    }
    
    @IBOutlet weak var titleText: UITextField!
    
    @IBAction func editAction(_ sender: Any) {
        titleText.text = "";
    }
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    @IBAction func done(_ sender: Any) {
        if(!isCurrentlyEditing){
            if(textView.text?.isEmpty)!{
                let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
                let vC : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "mainView") as! ViewController;
                self.present(vC, animated: false, completion: nil);
            }else{
                let alertController = UIAlertController(title: "Are you sure?", message: "You'll lose all text currently in the editor", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                    let mainStoryboard = UIStoryboard(name: "Main", bundle: nil);
                    let vC : ViewController = mainStoryboard.instantiateViewController(withIdentifier: "mainView") as! ViewController;
                    self.present(vC, animated: false, completion: nil);                }
                alertController.addAction(OKAction)
                let NoActions = UIAlertAction(title: "Cancel", style: .default) { (action) in
                    
                }
                alertController.addAction(NoActions)
                
                self.present(alertController, animated: true){
                    
                }
            }
            
        }else{
            isCurrentlyEditing = false;
            doneButton.title = "Back";
            view.endEditing(true);
            submitButton.isEnabled = true;
            submitButton.title = "Submit";
        }
    }
    func edit(){
        isCurrentlyEditing = true;
        submitButton.isEnabled = false;
        submitButton.title = nil;
        
        doneButton.title = "Done";
    }
    
    @IBOutlet weak var textView: UITextView!
    
    @IBAction func submit(_ sender: Any) {
        let text = textView.text;
        if(text?.isEmpty)!{
            let alertController = UIAlertController(title: "Error!", message: "Text cannot be empty!", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // handle response here.
            }
            alertController.addAction(OKAction)
            self.present(alertController, animated: true){
                
            }
        }else{
            if(isInternetAvailable()){
                
                let defaults = UserDefaults.standard
                
                let api_dev_key = "&api_dev_key=" + "71788ef035e5bf63bbbd11945bd8441c";
                var api_paste_private = "&api_paste_private=";
                
                if(defaults.bool(forKey: "SwitchState")){
                    api_paste_private += "1"; // 0=public 1=unlisted 2=private
                }else{
                    api_paste_private += "0";
                }
                
                var api_paste_name = "&api_paste_name=";
                // name or title of your paste
                if(titleText.text?.isEmpty)!{
                    api_paste_name += "Created with Pastebin App";
                }else{
                    api_paste_name += titleText.text!;
                }
                
                let api_paste_expire_date = "&api_paste_expire_date=" + "N";
                
                let api_paste_format = "&api_paste_format=" + "text";
                
                let api_user_key = "&api_user_key=" + ""; // if an invalid api_user_key or no key is used, the paste will be create as a guest
                let encoded_text = "&api_paste_code=" + (text?.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed))!;
                
                let encoded_title = api_paste_name.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed);
                
                
                var request = URLRequest(url: URL(string: "http://pastebin.com/api/api_post.php")!)
                request.httpMethod = "POST"
                
                //convoluted but necessary for their post api
                var postString = "api_option=paste";
                postString +=  api_user_key;
                postString += api_paste_private;
                postString += encoded_title!;
                postString += api_paste_expire_date;
                postString += api_paste_format;
                postString += api_dev_key + encoded_text;
                
                request.httpBody = postString.data(using: .utf8)
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        //if not connected to internet
                        print("error=\(error)")
                        return
                    }
                    
                    if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                        print("statusCode should be 200, but is \(httpStatus.statusCode)")
                        print("response = \(response)")
                        let alertController = UIAlertController(title: "Error!", message: "Unknown error - HTTP Code" + String(httpStatus.statusCode), preferredStyle: .alert)
                        let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                            // handle response here.
                        }
                        alertController.addAction(OKAction)
                        self.present(alertController, animated: true){
                            
                        }
                    }
                    
                    let responseString = String(data: data, encoding: .utf8)
                    print("responseString = \(responseString)")
                    UIPasteboard.general.string = responseString;
                    let alertController = UIAlertController(title: "Success!", message: responseString! + "\nSuccesfully copied to clipboard!", preferredStyle: .alert)
                    let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        // handle response here.
                    }
                    alertController.addAction(OKAction)
                    self.present(alertController, animated: true){
                        
                    }
                    self.textView.text = "Success! Your paste is at " + responseString!;
                }
                task.resume()
            }else{
                let alertController = UIAlertController(title: "Error!", message: "Not connected to the internet!", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default) { (action) in
                    // handle response here.
                }
                alertController.addAction(OKAction)
                self.present(alertController, animated: true){
                    
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        edit();
    }
    func textViewDidChange(_ textView: UITextView) {
        isCurrentlyEditing = true;
        submitButton.isEnabled = false;
        submitButton.title = nil;
        
        doneButton.title = "Done";
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
    
    //credit to http://stackoverflow.com/questions/39558868/check-internet-connection-ios-10
    //Simple check if internet is available
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
}