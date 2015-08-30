//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Alp Eren Can on 16/08/15.
//  Copyright © 2015 Alp Eren Can. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let memeTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeColorAttributeName: UIColor.blackColor(),
            NSStrokeWidthAttributeName: -3.0]
        
        topTextField.delegate = self;
        bottomTextField.delegate = self;
        
        topTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.defaultTextAttributes = memeTextAttributes
        
        topTextField.textAlignment = NSTextAlignment.Center;
        bottomTextField.textAlignment = NSTextAlignment.Center;
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        shareButton.enabled = (imageView.image != nil) ? true : false
        
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.unsubscribeFromKeyboardNotifications()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pickImageFromCamera(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.allowsEditing = true
        
        self.presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func pickImageFromAlbum(sender: AnyObject) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        imagePickerController.allowsEditing = true
        
        self.presentViewController(imagePickerController, animated: true, completion: nil)
        
    }
    
    @IBAction func shareMeme(sender: AnyObject) {
        let memedImage = generateMemedImage()
        
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        self.presentViewController(activityController, animated: true, completion: nil)
        
        activityController.completionWithItemsHandler = {
            (activity, success, items, error) in
            self.save()
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func save() -> Meme {
        
        let meme = Meme(topText: topTextField.text, bottomText: bottomTextField.text, image: imageView.image, memedImage: generateMemedImage())
        
        print("Meme saved.")
        
        return meme
        
    }
    
    func generateMemedImage() -> UIImage {
        
        topToolbar.hidden = true;
        bottomToolbar.hidden = true;
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        topToolbar.hidden = false;
        bottomToolbar.hidden = false;
        
        return memedImage
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // only shift if editing in bottomTextField and the view hasn't been shifted already
        if bottomTextField.editing && self.view.frame.origin.y == 0 {
            self.view.frame.origin.y -= getKeyboardHeight(notification);
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // only shift back if editing in bottomTextField and the view has already been shifted
        if bottomTextField.editing && self.view.frame.origin.y != 0 {
            self.view.frame.origin.y += getKeyboardHeight(notification);
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo;
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.CGRectValue().height
    }
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // MARK: - UIImagePicker methods
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            
            if picker.sourceType == UIImagePickerControllerSourceType.Camera {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
        
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: UITextField methods
    
    var firstTimeEditingTop = true;
    var firstTimeEditingBottom = true;
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        if (textField == topTextField && firstTimeEditingTop) {
            textField.text = "";
        }
        
        if (textField == bottomTextField && firstTimeEditingBottom) {
            textField.text = "";
        }
        
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if (textField == topTextField && firstTimeEditingTop) {
            firstTimeEditingTop = false;
        }
        
        if (textField == bottomTextField && firstTimeEditingBottom) {
            firstTimeEditingBottom = false;
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true
    }
    
}

