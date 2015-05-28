//
//  CreateProductViewController.swift
//  UCSC Store
//
//  Created by Gisele Sardas on 16/05/15.
//  Copyright (c) 2015 Razeware LLC. All rights reserved.
//

import UIKit
import Parse

class CreateProductViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageview: UIImageView!
    
    var imagePicker: UIImagePickerController!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    @IBOutlet weak var product: UITextField!
    
    @IBOutlet weak var price: UITextField!
    
    @IBOutlet weak var category: UIPickerView!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBAction func choose_image(sender: AnyObject) {
        
        
        var image = UIImagePickerController()
        image.delegate = self
        image.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        image.allowsEditing = false
        
        self.presentViewController(image, animated: true, completion: nil)

    }

    
    @IBAction func take(sender: AnyObject) {
        
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .Camera
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        //imagePicker.dismissViewControllerAnimated(true, completion: nil)
        self.dismissViewControllerAnimated(false, completion: nil)
        imageview.image = info[UIImagePickerControllerOriginalImage] as? UIImage
    }

    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        println("Image Selected")
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        imageview.image = image
        
    }

    @IBAction func save_product(sender: AnyObject) {
        
        
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        
        
        
   let post = PFObject(className: "Products")
   post["product"] = product.text
   post["price"] = price.text
   post["category"] =  textLabel.text
 
        
   post.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
            
            
            if success == false {
                
                self.activityIndicator.stopAnimating()
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                
                self.displayAlert("Could Not Save Item", error: "Please try again later")
                
            } else {
                
                let imageData = UIImagePNGRepresentation(self.imageview.image)
                
                let imageFile = PFFile(name: "image.png", data: imageData)
                
                post["imageFile"] = imageFile
                
                post.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    if success == false {
                        
                        self.displayAlert("Could Not Save Item", error: "Please try again later")
                        
                    } else {
                        
                        self.displayAlert("Product Created!", error: "Your new product is ready to be sold!")
                        
                        // Update - change 0 to false
                        
                        //self.photoSelected = false
                        
                        self.imageview.image = UIImage(named: "315px-Blank_woman_placeholder.svg")
                        
                        self.product.text = ""
                        self.price.text = ""
                        
                        println("Saved Successfully")
                        
                    }
                    
                }
                
            }
        }
        
    }
    
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        textLabel.text = colors[row]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var colors = ["Courses","Books","Events", "T-shirts","Sweatshirt","Mugs","Study Equipment","Cheering Equipment"]
    
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return colors.count
    }
    
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return colors[row]
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
