//
//  LoginViewController.swift
//  UCSC Store
//
//  Created by Gisele Sardas on 16/05/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var username: UITextField!
    
    @IBOutlet weak var password: UITextField!
    
    
    @IBAction func login(sender: AnyObject) {
        
        NSLog("Login Button Clicked")
        NSLog(self.username.text )
        NSLog(self.password.text)
        
        
        if (self.username.text == "ucsc" && self.password.text == "login"){
            
            // SAVE that the user knows the login
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue("1", forKey: "login")

            performSegueWithIdentifier("createproduct", sender: nil)
        
        }
        else{
            NSLog("wrong login")
            let alertController = UIAlertController(title: "Wrong Login", message:
                "the login or password is wrong", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Do any additional setup after loading the view.
        
        // Check if user has logged in once before
        let prefs = NSUserDefaults.standardUserDefaults()
        
        if let loggedin = prefs.stringForKey("login"){
            //if he has logged in once, go to CREATE PRODUCT
            username.text = "ucsc"
            password.text = "login"
            //performSegueWithIdentifier("createproduct2", sender: nil)
            
        }else{
            //Nothing stored in NSUserDefaults yet. Set a value.
            NSLog("No login so far")
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
