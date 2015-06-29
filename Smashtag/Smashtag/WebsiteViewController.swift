//
//  WebsiteViewController.swift
//  Smashtag
//
//  Created by Vojta Molda on 6/7/15.
//  Copyright (c) 2015 Stanford University. All rights reserved.
//

import UIKit

class WebsiteViewController: UIViewController, UIWebViewDelegate {
    
    var websiteURL: NSURL? = nil
    
    @IBOutlet weak var websiteView: UIWebView! {
        didSet {
            websiteView.delegate = self
            websiteView.scalesPageToFit = true
        }
    }
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    // MARK: View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchWebsite()
    }
    
    func fetchWebsite() {
        if websiteURL != nil {
            websiteView.loadRequest(NSURLRequest(URL: websiteURL!))
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Web view delegate
    
    func webViewDidStartLoad(webView: UIWebView) {
        spinner.startAnimating()
    }
    
    func webViewDidFinishLoad(webView: UIWebView) {
        spinner.stopAnimating()
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        spinner.stopAnimating()
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    }

}
