//
//  feedViewController.swift
//  Instagram
//
//  Created by Rob Percival on 08/09/2014.
//  Copyright (c) 2014 Appfish. All rights reserved.
//

import UIKit
import Parse

class TableViewController: UITableViewController {
    

    var photos = [Photo]()
    
    var ids = [String]()
    var products = [String]()
    var prices = [String]()
    var images = [UIImage]()
    var imageFiles = [PFFile]()
    
    var server = "approve"
    var stripe = "test"
    
    
    var refresher:UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // QUERYING KEYS
        
        
        var querykeys = PFQuery(className:"Settings")
        querykeys.limit = 1
        querykeys.findObjectsInBackgroundWithBlock {
            (object, error) -> Void in
            

            
            for object1 in object! {
                
                
                println(object1["server"])
                println(object1["stripe"])
                self.server = object1["server"] as! String
                self.stripe = object1["stripe"] as! String
                
                let prefs = NSUserDefaults.standardUserDefaults()
                prefs.setValue(self.server, forKey: "server")
                prefs.setValue(self.stripe, forKey: "stripe")
                
                var server = prefs.stringForKey("server")
                if (server == "approve"){
                    println(server)
                }
                else{
                let url = NSURL(string: server!)
                    //println("the url = \(url!)")
                }
                var stripe = prefs.stringForKey("stripe")
                NSLog(stripe!)
                
            }
            
            println(self.server)
            println(self.stripe)
            

        }
        
        
        
        
         //QUERYING PRODUCTS
        
        var query = PFQuery(className:"Products")
        query.findObjectsInBackgroundWithBlock {
            (objectproducts, error) -> Void in
            
            
                            for objectprod1 in objectproducts! {
                                
                   
                                
                                self.products.append(objectprod1["product"] as! String)
                                self.prices.append(objectprod1["price"] as! String)
                                self.imageFiles.append(objectprod1["imageFile"] as! PFFile)
                                var id = objectprod1.objectId
                                self.ids.append((id as String?)!)
                                self.tableView.reloadData()
                            }
        
        }
        
        
        
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: "refresh", forControlEvents:UIControlEvents.ValueChanged)
        self.tableView.addSubview(refresher)
        
        
}
    
    
    
    
    func updateTable(){
        
        self.products.removeAll(keepCapacity: true)
        self.prices.removeAll(keepCapacity: true)
        self.images.removeAll(keepCapacity: true)
        self.imageFiles.removeAll(keepCapacity: true)
        self.ids.removeAll(keepCapacity: true)
    
        var query = PFQuery(className:"Products")
        query.findObjectsInBackgroundWithBlock {
            (object, error) -> Void in
            
            
            for object1 in object! {
                
                
                
                self.products.append(object1["product"] as! String)
                self.prices.append(object1["price"] as! String)
                self.imageFiles.append(object1["imageFile"] as! PFFile)
                var id = object1.objectId
                self.ids.append((id as String?)!)
                self.tableView.reloadData()
            }
            
        }
        
        self.refresher.endRefreshing()
    
    }
    
    
    
    
    
    
    func refresh(){
    
        println("refreshed")
        updateTable()
    }
    
    
    
    
    
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        // Get the new view controller using [segue destinationViewController].
        var detailScene = segue.destinationViewController as! BuySwagViewController
        
        // Pass the selected object to the destination view controller.
        if let indexPath = self.tableView.indexPathForSelectedRow() {
            //let selectedPhoto = photos[indexPath.row]
            //detailScene.currentPhoto = selectedPhoto
            let row2 = Int(indexPath.row)
            
            let prefs = NSUserDefaults.standardUserDefaults()
            prefs.setValue(products[row2], forKey: "product")
            prefs.setValue(prices[row2], forKey: "price")
            prefs.setValue(ids[row2], forKey: "objectId")


            
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return products.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Update - replaced as with as!
        
        var myCell:cell = self.tableView.dequeueReusableCellWithIdentifier("Cell") as! cell
        
        NSLog(products[indexPath.row])
        NSLog("%i",indexPath.row)
        myCell.titleLabel.text = products[indexPath.row]
        myCell.priceLabel.text = prices[indexPath.row]
        //NSLog(indexPath.row)
        imageFiles[indexPath.row].getDataInBackgroundWithBlock{
            (imageData, error) -> Void in
            
            if error == nil {
                
                let image = UIImage(data: imageData!)
                
                myCell.postedImage.image = image
            }
            
            
        }
        
        return myCell
        
    }
    
    
    
    
}
