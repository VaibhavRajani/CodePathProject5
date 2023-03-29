//
//  PostCell.swift
//  BeReal
//
//  Created by Vaibhav Rajani on 3/21/23.
//
import UIKit
import Alamofire
import AlamofireImage

class PostCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    private var imageDataRequest: DataRequest?
    
    func configure(with post: Post) {
        // Set up the cell with the given post object
        
        // Username
        if let user = post.user {
            usernameLabel.text = user.username
        }
        
        // Image
        if let imageFile = post.imageFile, let imageUrl = imageFile.url {
            // Use AlamofireImage to fetch the remote image from the URL
            imageDataRequest = AF.request(imageUrl).responseImage { [weak self] response in
                switch response.result {
                case .success(let image):
                    // Set the image view's image to the fetched image
                    self?.postImageView.image = image
                case .failure(let error):
                    print("❌ Error fetching image: \(error.localizedDescription)")
                }
            }
        }
        
        // Caption
        captionLabel.text = post.caption
        
        // Date
        if let date = post.createdAt {
            dateLabel.text = DateFormatter.postFormatter.string(from: date)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // Reset the cell's state when it is reused
        
        // Reset the image view's image
        postImageView.image = nil
        
        // Cancel any ongoing image download request
        imageDataRequest?.cancel()
    }
}
