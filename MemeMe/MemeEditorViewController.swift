//
//  MemeEditorViewController.swift
//  MemeMe
//
//  Created by Ischuk Alexander on 11.05.2020.
//  Copyright © 2020 Ischuk Alexander. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,
UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topTextView: UITextField!
    @IBOutlet weak var bottomTextView: UITextField!
    
    let topLineLabel = "TOP LINE"
    let bottomLineLabel = "BOTTOM LINE"
    
    var topTextEdited = false
    var bottomTextEdited = false
    
    let memeTextAttributes: [NSAttributedString.Key: Any] = [
        NSAttributedString.Key.strokeColor: UIColor.black,
        NSAttributedString.Key.foregroundColor: UIColor.white,
        NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedString.Key.strokeWidth:  -2.0
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Cancel",
            style: .plain,
            target: self,
            action: #selector(onCancelClick)
        )
    }
    
    @objc func onCancelClick() {
        clear()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        prepareViews()
        subscribeToKeyboardNotifications()
    }
    
    func prepareViews() {
        imageView.contentMode = .scaleAspectFit
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        prepareTextField(topTextView, topLineLabel)
        prepareTextField(bottomTextView, bottomLineLabel)
        clear()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromNotifications()
        tabBarController?.tabBar.isHidden = false
    }
    
    func prepareTextField(_ textField: UITextField, _ text: String) {
        textField.delegate = self
        textField.defaultTextAttributes = memeTextAttributes
        textField.autocapitalizationType = .allCharacters
        textField.textAlignment = .center
        textField.adjustsFontSizeToFitWidth = true
        textField.sizeToFit()
        textField.text = text
    }
    
    func clear() {
         topTextView.text = topLineLabel
         bottomTextView.text = bottomLineLabel
         topTextEdited = false
         bottomTextEdited = false
         imageView.image = nil
         shareButton.isEnabled = false
     }
    
    func subscribeToKeyboardNotifications() {
        subscribeToNotifications(#selector(keyboardWillShow(_:)), UIResponder.keyboardWillShowNotification)
        subscribeToNotifications(#selector(keyboardWillHide(_ :)), UIResponder.keyboardWillHideNotification)
    }
    
    func subscribeToNotifications(_ selector: Selector, _ name: NSNotification.Name?) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextView.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        view.frame.origin.y = 0
    }

    func unsubscribeFromNotifications() {
        unsubscfibeFromNotifications(UIResponder.keyboardWillShowNotification)
        unsubscfibeFromNotifications(UIResponder.keyboardWillHideNotification)
    }
    
    func unsubscfibeFromNotifications(_ name: NSNotification.Name?) {
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
    }
    
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickImage(.photoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickImage(.camera)
    }
      
    func pickImage(_ sourceType: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.sourceType = sourceType
        pickerController.delegate = self
        present(pickerController, animated: true, completion: nil)
    }
    
    // receive selected image
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            imageView.image = image
            shareButton.isEnabled = true
        } else {
            print("No image")
        }
        
        dismiss(animated: true, completion: nil)
    }
  
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == topTextView {
            topTextEdited = onTextClick(textField, topTextEdited)
        } else {
            bottomTextEdited = onTextClick(textField, bottomTextEdited)
        }
    }
    
    func onTextClick(_ textField: UITextField, _ isEdited: Bool) -> Bool {
        if(!isEdited) {
            textField.text = ""
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true;
    }
    
    @IBAction func onShareClick(_ sender: Any) {
        let memedImage = generateMemedImage()
        let shareVc = UIActivityViewController.init(activityItems: [memedImage], applicationActivities: nil)
        shareVc.completionWithItemsHandler = { activity, success, items, error in
            if success {
                self.save(memedImage)
            }
        }
        present(shareVc, animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        updateToolbarsVisibility(visible: false)
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        updateToolbarsVisibility(visible: true)
        return memedImage
    }
    
    func updateToolbarsVisibility(visible: Bool) {
        toolbar.isHidden = !visible
        navigationController?.setNavigationBarHidden(!visible, animated: true)
    }
    
    func save(_ memedImage: UIImage) {
        let meme = Meme(
            topText: topTextView.text!,
            bottomText: bottomTextView.text!,
            originalImage: imageView.image!,
            memedImage: generateMemedImage()
        )
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.memes.append(meme)
        navigationController?.popViewController(animated: true)
      }
}
