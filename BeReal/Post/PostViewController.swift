//
//  PostViewController.swift
//  BeReal
//
//  Created by Vaibhav Rajani on 3/21/23.
//

import UIKit
import PhotosUI
import ParseSwift

class PostViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet private weak var shareButton: UIBarButtonItem!
    @IBOutlet private weak var captionTextField: UITextField!
    @IBOutlet private weak var previewImageView: UIImageView!
    
    // MARK: - Properties
    
    private var pickedImage: UIImage?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Actions
    
    @IBAction private func onPickedImageTapped(_ sender: UIBarButtonItem) {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.preferredAssetRepresentationMode = .current
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        
        present(picker, animated: true)
    }
    
    @IBAction private func onShareTapped(_ sender: Any) {
        view.endEditing(true)
        
        guard let image = pickedImage,
              let imageData = image.jpegData(compressionQuality: 0.1) else {
            return
        }
        
        let imageFile = ParseFile(name: "image.jpg", data: imageData)
        
        var post = Post()
        post.imageFile = imageFile
        post.caption = captionTextField.text
        post.user = User.current
        
        post.save { [weak self] result in
            if var currentUser = User.current {
                currentUser.lastPostedDate = Date()
                
                currentUser.save { [weak self] result in
                    switch result {
                    case .success(let user):
                        print("✅ User Saved! \(user)")
                        
                        DispatchQueue.main.async {
                            self?.navigationController?.popViewController(animated: true)
                        }
                        
                    case .failure(let error):
                        self?.showAlert(description: error.localizedDescription)
                    }
                }
            }
        }
    }
    
    @IBAction private func onTakePhotoTapped(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("❌📷 Camera not available")
            return
        }
        
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .camera
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        present(imagePicker, animated: true)
    }
    
    @IBAction private func onViewTapped(_ sender: Any) {
        view.endEditing(true)
    }
    
    // MARK: - Private Methods
    
    private func showAlert(description: String? = nil) {
        let alertController = UIAlertController(title: "Oops...", message: "\(description ?? "Please try again...")", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
}

extension PostViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        
        provider.loadObject(ofClass: UIImage.self) { [weak self] object, error in
            guard let image = object as? UIImage else {
                self?.showAlert()
                return
            }
            
            DispatchQueue.main.async {
                self?.previewImageView.image = image
                self?.pickedImage = image
            }
        }
    }
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        // Dismiss the image picker
        picker.dismiss(animated: true)

        // Get the edited image from the info dictionary (if `allowsEditing = true` for image picker config).
        // Alternatively, to get the original image, use the `.originalImage` InfoKey instead.
        guard let image = info[.editedImage] as? UIImage else {
            print("❌📷 Unable to get image")
            return
        }

        // Set image on preview image view
        previewImageView.image = image

        // Set image to use when saving post
        pickedImage = image
    }

}
