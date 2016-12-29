//
//  NewEntry.swift
//  Rabbit Food
//
//  Created by Christian Raroque on 7/8/15.
//  Copyright (c) 2015 AloaLabs. All rights reserved.
//

import UIKit
import CoreData

class NewEntry: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var postField: UITextView!
    @IBOutlet weak var postFieldChartCount: UILabel!
    @IBOutlet weak var postFieldBottom: NSLayoutConstraint!
    
   // var hexmain = "#02C39A"
    var hexmain = UIColor()
    var hexcell = "#F15352"
    
    var type = "New Entry"
    var placeHolderText = "Life is really simple, but we insist on making it complicated. - Confucius"
    var typeKey = "None"
    
    var previousEntry = "None"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Do any additional setup after loading the view.
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        
        //    self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: ""), forBarMetrics: UIBarMetrics.Default)
        //    self.navigationController?.navigationBar.shadowImage = UIImage(named: "")
        
        self.navigationController?.navigationBar.barTintColor = hexmain
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 20)!, NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.tintColor = colorWithHexString("#ffffff")
        navigationController?.hidesBarsOnSwipe = false
        
        self.title = type
        
        self.view.backgroundColor = hexmain
        
        let backButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEntry.popToRoot(_:)))
        let postButton = UIBarButtonItem(title: "Save", style: UIBarButtonItemStyle.plain, target: self, action: #selector(NewEntry.post(_:)))
        navigationItem.rightBarButtonItem = postButton
        
        
        navigationItem.leftBarButtonItem = backButton
        NotificationCenter.default.addObserver(self, selector: #selector(NewEntry.keyboardWasShown(_:)), name:NSNotification.Name.UIKeyboardWillShow, object: nil);
        
        setUpFields()
    }
    
    func setUpFields() {
        
        var borderColor : UIColor = colorWithHexString("#D2D2D2")
        postField.layer.borderColor = borderColor.cgColor
        postField.layer.borderWidth = 1.0
        postField.delegate = self
        
        if let font = UIFont(name: "Avenir", size: 25) {
            postField.font = UIFont(name: "Avenir", size: 25)!
            self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Avenir", size: 20)!, NSForegroundColorAttributeName: UIColor.white]
            self.navigationController?.navigationBar.tintColor = colorWithHexString("#f4f4f4")
        }
        
        postFieldChartCount.text = "\(0)"
        if(previousEntry == "None") {
            postField.text = placeHolderText
            postField.textColor = UIColor.lightGray
            postField.selectedTextRange = postField.textRange(from: postField.beginningOfDocument, to: postField.beginningOfDocument)
        } else {
            NSLog("something was entered")
            postField.text = previousEntry
            postField.textColor = UIColor.black
        }
        
        
        postField.becomeFirstResponder()
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with:text)
        
        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.characters.count == 0 {
            
            textView.text = placeHolderText
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            
            return false
        } else if (textView.textColor == UIColor.lightGray && text.characters.count > 0) {
            textView.text = nil
            textView.textColor = UIColor.black
        }
        
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    
    func textViewDidChange(_ textView: UITextView)
    {
        postFieldChartCount.text = "\(textView.text.characters.count)"
    }

    
    func popToRoot(_ sender:UIBarButtonItem){
       // self.dismissViewControllerAnimated(true, completion: nil)
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func post(_ sender:UIBarButtonItem){
        NSLog("yuh")
        if(postField.text.characters.count == 0 || self.postField.text.isBlank || self.postField.textColor == UIColor.lightGray) {
            var alert = UIAlertView(title: "Have a good day", message: "Write some stuff out :) try not to go a single day with a 0 at the bottom right", delegate: self, cancelButtonTitle: "Got it")
            alert.show()
        } else {
            
            // The day today (start of the day)
            var today = Date()
            let cal = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
            let startOfDay = cal!.startOfDay(for: today)
            
            // Done posting
            let appDelegate =
            UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.managedObjectContext!
      
            // Pull the last entry
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Day")
            let sortDescriptor = NSSortDescriptor(key: "date", ascending: false)
            fetchRequest.sortDescriptors = [sortDescriptor]
            fetchRequest.fetchLimit = 1
            var error: NSError?
            
            do {
                let results =
                    try managedContext.fetch(fetchRequest)
                var entries = results as! [NSManagedObject]
                if(results.count != 0) {
                    NSLog("the results is not 0")
                    let lastDay = results[0]
                    //   managedContext.deleteObject(lastDay as NSManagedObject)
                    //   managedContext.save(nil)
                    
                    if let dateOfLastEntry = (lastDay as AnyObject).value(forKey: "date") as? NSDate {
                        // Check if there is an entry
                        NSLog("date of lastEntry is \(dateOfLastEntry) and start of day is \(startOfDay)")
                        if(dateOfLastEntry as Date == startOfDay) {
                            // Something already exists, so update it instead of creating a new entry
                            NSLog("Last entry was today, update current one")
                            let day = lastDay
                            (day as AnyObject).setValue(postField.text, forKey: "\(typeKey)")
                            try managedContext.save()
                        } else {
                            // The last entry was not made today, so we can create a new one
                            NSLog("last entry was not today, creating a new one")
                            let entity =  NSEntityDescription.entity(forEntityName: "Day",
                                                                     in:
                                managedContext)
                            let day = NSManagedObject(entity: entity!,
                                                      insertInto:managedContext)
                            
                            day.setValue(startOfDay, forKey: "date")
                            day.setValue(postField.text, forKey: "\(typeKey)")
                            try managedContext.save()
                        }
                    } else {
                        // There was no entry
                        NSLog("no entry found, creating a new one")
                        let entity =  NSEntityDescription.entity(forEntityName: "Day",
                                                                 in:
                            managedContext)
                        let day = NSManagedObject(entity: entity!,
                                                  insertInto:managedContext)
                        
                        day.setValue(startOfDay, forKey: "date")
                        day.setValue(postField.text, forKey: "\(typeKey)")
                        try managedContext.save()
                    }
                } else {
                    // There was no entry
                    NSLog("no entry found, creating a new one")
                    let entity =  NSEntityDescription.entity(forEntityName: "Day",
                                                             in:
                        managedContext)
                    let day = NSManagedObject(entity: entity!,
                                              insertInto:managedContext)
                    
                    day.setValue(startOfDay, forKey: "date")
                    day.setValue(postField.text, forKey: "\(typeKey)")
                    try managedContext.save()
                }
            } catch let error as NSError {
                print("Could not fetch \(error), \(error.userInfo)")
            }
            

            
            self.navigationController?.popViewController(animated: true)
            
            
        }
    }
    
    func keyboardWasShown(_ notification: Notification) {
        var info = (notification as NSNotification).userInfo!
        let keyboardFrame: CGRect = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.postFieldBottom.constant = keyboardFrame.size.height
        })
    }

}
