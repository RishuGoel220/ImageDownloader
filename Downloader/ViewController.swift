

//
//  ViewController.swift
//  Downloader
//
//  Created by Rishu Goel on 08/08/16.
//  Copyright © 2016 Rishu Goel. All rights reserved.
//

import UIKit

class ViewController: UIViewController, NSURLSessionDownloadDelegate ,UIDocumentInteractionControllerDelegate{
    
    var downloadTask: NSURLSessionDownloadTask!
    var backgroundSession: NSURLSession!
    
    
    // Mark: Properties
    @IBOutlet weak var urlTextField: UITextField!
    
    @IBOutlet weak var progressView: UIProgressView!
    
    // Mark: actions
    @IBAction func downloadButton(sender: UIButton) {
        let textres: String = urlTextField.text!
        
        let url = NSURL(string: textres)!
        downloadTask = backgroundSession.downloadTaskWithURL(url)
        downloadTask.resume()
    }
    
    
    // Mark: Delegate functions
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        //
    }
    
    func showFileWithPath(path: String, isimage: Bool){
        if isimage == true{
            let isFileFound:Bool? = NSFileManager.defaultManager().fileExistsAtPath(path)
            if isFileFound == true{
                let viewer = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: path))
                viewer.delegate = self
                viewer.presentPreviewAnimated(true)
            }
            
        }
        else{
                let alertController = UIAlertController(title: "Download Application", message:
                    "File Download Complete", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        
        
    }
    
    
    lazy var downloadsSession: NSURLSession = {
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let session = NSURLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //urlTextField.delegate=self
        let backgroundSessionConfiguration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("backgroundSession")
        backgroundSession = NSURLSession(configuration: backgroundSessionConfiguration, delegate:self, delegateQueue: NSOperationQueue.mainQueue())
        progressView.setProgress(0.0, animated: false)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didFinishDownloadingToURL location: NSURL){
        
        let path = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true)
        let documentDirectoryPath:String = path[0]
        let fileManager = NSFileManager()
        
        // file name extract
        let a : String = urlTextField.text!
        let rangeOfIndex = a.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "/"), options: .BackwardsSearch)
        let fileName : String = a.substringFromIndex(rangeOfIndex!.endIndex)
        let rangeOfIndex2 = a.rangeOfCharacterFromSet(NSCharacterSet(charactersInString: "."), options: .BackwardsSearch)
        let extensionName : String = a.substringFromIndex(rangeOfIndex2!.endIndex)
        
        
        let destinationURLForFile = NSURL(fileURLWithPath: documentDirectoryPath.stringByAppendingString("/\(fileName)"))
        
        var isimage : Bool
        if extensionName=="jpg"{
            isimage=true
        }
        else{
            isimage=false
        }
        
        
        
        if fileManager.fileExistsAtPath(destinationURLForFile.path!){
            showFileWithPath(destinationURLForFile.path!, isimage: isimage)
        }
        else{
            do {
                try fileManager.moveItemAtURL(location, toURL: destinationURLForFile)
                // show file
                showFileWithPath(destinationURLForFile.path!, isimage: isimage)
            }catch{
                print("An error occurred while moving file to destination url")
            }
        }
    }
    
    func URLSession(session: NSURLSession,
                    downloadTask: NSURLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                                 totalBytesWritten: Int64,
                                 totalBytesExpectedToWrite: Int64){
        progressView.setProgress(Float(totalBytesWritten)/Float(totalBytesExpectedToWrite), animated: true)
    }
    
    func URLSession(session: NSURLSession,
                    task: NSURLSessionTask,
                    didCompleteWithError error: NSError?){
        downloadTask = nil
        progressView.setProgress(0.0, animated: true)
        if (error != nil) {
            print(error?.description)
        }else{
            print("The task finished transferring data successfully")
        }
    }
    
    func documentInteractionControllerViewControllerForPreview(controller: UIDocumentInteractionController) -> UIViewController{
        return self
    }

}

