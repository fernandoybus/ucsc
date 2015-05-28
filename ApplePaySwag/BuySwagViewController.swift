//
//  DetailViewController.swift
//  ApplePaySwag
//
//  Created by Erik.Kerber on 10/17/14.
//  Edited by Eric Cerney on 11/21/14.
//  Copyright (c) 2014 Razeware LLC. All rights reserved.
//

import UIKit
import PassKit
import Parse

class BuySwagViewController: UIViewController {

    var currentPhoto : Photo?
    var currentObject : PFObject?
    
    var imageFiles = [PFFile]()
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    let SupportedPaymentNetworks = [PKPaymentNetworkVisa, PKPaymentNetworkMasterCard, PKPaymentNetworkAmex]
    let ApplePaySwagMerchantID = "merchant.com.y-bus.ucscstore"//"<TODO - Your merchant ID>" // This should be <your> merchant ID

    @IBOutlet weak var applePayButton: UIButton!
    @IBOutlet weak var swagPriceLabel: UILabel!
    @IBOutlet weak var swagTitleLabel: UILabel!
    @IBOutlet weak var swagImage: UIImageView!
    
    var swag: Swag! {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {

        if (!self.isViewLoaded()) {
            return
        }
        
        

        
        //self.swagImage.image = image

        
}
    override func viewDidLoad() {
        super.viewDidLoad()

        let prefs = NSUserDefaults.standardUserDefaults()
        
        self.swagTitleLabel.text = prefs.stringForKey("product")
        self.swagPriceLabel.text =  prefs.stringForKey("price")!
        var price = self.swagPriceLabel.text

        
        var id = prefs.stringForKey("objectId")
        var query = PFQuery(className:"Products")
        query.whereKey("objectId", equalTo: id!)
        query.findObjectsInBackgroundWithBlock {
            (object, error) -> Void in
            
            
            for object1 in object! {
             
                self.imageFiles.append(object1["imageFile"] as! PFFile)
                
                self.imageFiles[0].getDataInBackgroundWithBlock{
                    (imageData, error) -> Void in
                    
                    if error == nil {
                        
                        let image = UIImage(data: imageData!)
                        
                       self.swagImage.image = image
                    }
                    
                    
                }
                

            }
            
        }
        

        
        // GETTING THE IMAGE
        
        //self.swagImage.image = image

    
        var test = PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        NSLog(test ? "Yes" : "No")
        
        if (!PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)){
        
            let alertController = UIAlertController(title: "Apple pay not ready", message:
                "Hi, you device does not support Apple Pay or you haven't set up a card on your Passport App.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
        
        applePayButton.hidden = !PKPaymentAuthorizationViewController.canMakePaymentsUsingNetworks(SupportedPaymentNetworks)
        self.configureView()
    }

    @IBAction func purchase(sender: AnyObject) {
        
        let request = PKPaymentRequest()
        request.merchantIdentifier = ApplePaySwagMerchantID
        request.supportedNetworks = SupportedPaymentNetworks
        request.merchantCapabilities = PKMerchantCapability.Capability3DS
        request.countryCode = "US"
        request.currencyCode = "USD"
        
        
        
        request.paymentSummaryItems = calculateSummaryItemsFromSwag()
        

        request.requiredShippingAddressFields = PKAddressField.PostalAddress
    
        request.requiredShippingAddressFields = PKAddressField.All


            var shippingMethods = [PKShippingMethod]()
            
            for shippingMethod in ShippingMethod.ShippingMethodOptions {
                let method = PKShippingMethod(label: shippingMethod.title, amount: shippingMethod.price)
                method.identifier = shippingMethod.title
                method.detail = shippingMethod.description
                shippingMethods.append(method)
            }
            
            request.shippingMethods = shippingMethods

        
        let applePayController = PKPaymentAuthorizationViewController(paymentRequest: request)
        applePayController.delegate = self
        presentViewController(applePayController, animated: true, completion: nil)
    }
    
    func calculateSummaryItemsFromSwag() -> [PKPaymentSummaryItem] {
        var summaryItems = [PKPaymentSummaryItem]()
      
      var itemPrice = NSString(string: self.swagPriceLabel.text!)
//        var string = NSString(string: mySwiftString)
        var itemPrice2 = itemPrice.doubleValue
        
        
      summaryItems.append(PKPaymentSummaryItem(label: self.swagTitleLabel.text, amount: NSDecimalNumber(string: self.swagPriceLabel.text) ))
        
//        summaryItems.append(PKPaymentSummaryItem(label: self.swagTitleLabel.text, amount: 10.00 ))
        
        
        var shipPrice = 0.0
//        switch (swag.swagType) {
//        case .Delivered(let method):
//            summaryItems.append(PKPaymentSummaryItem(label: "Shipping", amount: method.price))

            summaryItems.append(PKPaymentSummaryItem(label: "Shipping", amount: 10.00))
            shipPrice = 10.00
//            shipPrice = Int(method.price)
        
//        case .Electronic:
//            break
//            shipPrice = 0
//        }
        
        var totalPrice = String(stringInterpolationSegment: itemPrice2 + shipPrice)

//        summaryItems.append(PKPaymentSummaryItem(label: "UCSC Store", amount: NSDecimalNumber(string: totalPrice)))
        summaryItems.append(PKPaymentSummaryItem(label: "UCSC Store", amount: NSDecimalNumber(string: totalPrice) ))
        
        

        
        
        
        
        
        return summaryItems
    }
}

extension BuySwagViewController: PKPaymentAuthorizationViewControllerDelegate {
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didAuthorizePayment payment: PKPayment!, completion: ((PKPaymentAuthorizationStatus) -> Void)!) {

        // 1
        let shippingAddress = self.createShippingAddressFromRef(payment.shippingAddress)

        // 2
        //Stripe.setDefaultPublishableKey("pk_test_KDAdC1g7X8MS01gD0VuwbR1R")
        let prefs = NSUserDefaults.standardUserDefaults()
        var stripe = prefs.stringForKey("stripe")
        NSLog(stripe!)
        
        Stripe.setDefaultPublishableKey(stripe!)
        
        // 3
        STPAPIClient.sharedClient().createTokenWithPayment(payment) {
            (token, error) -> Void in
            
            if (error != nil) {
                //NSLog(error!)
                
                completion(PKPaymentAuthorizationStatus.Failure)
                return
            }
            
            // 4
            let shippingAddress = self.createShippingAddressFromRef(payment.shippingAddress)
            
            // 5
            //let url = NSURL(string: "http://192.168.1.4:5000/pay")
            
            let prefs = NSUserDefaults.standardUserDefaults()
            var server = prefs.stringForKey("server")
            
           if (server == "approve"){
            

                completion(PKPaymentAuthorizationStatus.Success)
            
            
            //SAVING TO PARSE
            let post = PFObject(className: "Sales")
            post["product"] = self.swagTitleLabel.text
            post["price"] = self.swagPriceLabel.text
            let prefs = NSUserDefaults.standardUserDefaults()
            
            post["firstname"]  = prefs.stringForKey("firstname")
            post["lastname"]  = prefs.stringForKey("lastname")
            post["street"]  = prefs.stringForKey("street")
            post["city"]  = prefs.stringForKey("city")
            post["state"]  = prefs.stringForKey("state")
            post["zip"]  = prefs.stringForKey("zip")
 
            

            
            
            post.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
                
                
                if success == false {
                    
                    self.activityIndicator.stopAnimating()
                    UIApplication.sharedApplication().endIgnoringInteractionEvents()
                    
                    self.displayAlert("Could Not Save Sale", error: "Please try again later")
                    
                } else {
                    
   
                    
                    post.saveInBackgroundWithBlock{(success: Bool, error: NSError?) -> Void in
                        
                        self.activityIndicator.stopAnimating()
                        UIApplication.sharedApplication().endIgnoringInteractionEvents()
                        
                        if success == false {
                            
                            self.displayAlert("Could Not Save Sale", error: "Please try again later")
                            
                        } else {
                            
                            //self.displayAlert("Product Created!", error: "Your new product is ready to be sold!")
                            
                            // Update - change 0 to false
                            
                            //self.photoSelected = false
                        
                            
                            println("Saved Sale successfully")
                            
                        }
                        
                    }
                    
                }
            }
            
           }
           else{
            
            
            let url = NSURL(string: server!)
            println("the url = \(url!)")
            
            
            
            let request = NSMutableURLRequest(URL: url!)
            request.HTTPMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // 6
            let body = ["stripeToken": token!.tokenId,
                        "amount": self.swag.total().decimalNumberByMultiplyingBy(NSDecimalNumber(string: "100")),
                        "description": self.swag.title,
                        "shipping": [
                            "city": shippingAddress.City!,
                            "state": shippingAddress.State!,
                            "zip": shippingAddress.Zip!,
                            "firstName": shippingAddress.FirstName!,
                            "lastName": shippingAddress.LastName!]
            ]
            
            var error: NSError?
            request.HTTPBody = NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions(), error: &error)
            
            // 7
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) { (response, data, error) -> Void in
                if (error != nil) {
                    completion(PKPaymentAuthorizationStatus.Failure)
                } else {
                    completion(PKPaymentAuthorizationStatus.Success)
                }
            }
                
          }
        }
    }
    
    func paymentAuthorizationViewControllerDidFinish(controller: PKPaymentAuthorizationViewController!) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func createShippingAddressFromRef(address: ABRecord!) -> Address {
        var shippingAddress: Address = Address()
        
        shippingAddress.FirstName = ABRecordCopyValue(address, kABPersonFirstNameProperty)?.takeRetainedValue() as? String
        shippingAddress.LastName = ABRecordCopyValue(address, kABPersonLastNameProperty)?.takeRetainedValue() as? String
        
        let addressProperty : ABMultiValueRef = ABRecordCopyValue(address, kABPersonAddressProperty).takeUnretainedValue() as ABMultiValueRef
        if let dict : NSDictionary = ABMultiValueCopyValueAtIndex(addressProperty, 0).takeUnretainedValue() as? NSDictionary {
            shippingAddress.Street = dict[String(kABPersonAddressStreetKey)] as? String
            shippingAddress.City = dict[String(kABPersonAddressCityKey)] as? String
            shippingAddress.State = dict[String(kABPersonAddressStateKey)] as? String
            shippingAddress.Zip = dict[String(kABPersonAddressZIPKey)] as? String
        }
        
        let prefs = NSUserDefaults.standardUserDefaults()
        prefs.setValue(shippingAddress.FirstName, forKey: "firstname")
        prefs.setValue(shippingAddress.LastName, forKey: "lastname")
        prefs.setValue(shippingAddress.Street, forKey: "street")
        prefs.setValue(shippingAddress.City, forKey: "city")
        prefs.setValue(shippingAddress.State, forKey: "state")
        prefs.setValue(shippingAddress.Zip, forKey: "zip")

        
        return shippingAddress
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didSelectShippingAddress address: ABRecord!, completion: ((PKPaymentAuthorizationStatus, [AnyObject]!, [AnyObject]!) -> Void)!) {
        let shippingAddress = createShippingAddressFromRef(address)
        
        switch (shippingAddress.State, shippingAddress.City, shippingAddress.Zip) {
        case (.Some(let state), .Some(let city), .Some(let zip)):
            completion(.Success, nil, nil)
        default:
            completion(.InvalidShippingPostalAddress, nil, nil)
        }
    }
    
    func paymentAuthorizationViewController(controller: PKPaymentAuthorizationViewController!, didSelectShippingMethod shippingMethod: PKShippingMethod!, completion: ((PKPaymentAuthorizationStatus, [AnyObject]!) -> Void)!) {
        let shippingMethod = ShippingMethod.ShippingMethodOptions.filter {(method) in method.title == shippingMethod.identifier}.first!
        swag.swagType = SwagType.Delivered(method: shippingMethod)
        completion(PKPaymentAuthorizationStatus.Success, calculateSummaryItemsFromSwag())
    }
    
    func displayAlert(title:String, error:String) {
        
        var alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
}

