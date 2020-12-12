//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by Thao Nguyen on 06/12/2020.
//

import UIKit

class SearchResultCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(red: 20/255, green: 160/255, blue: 160/255, alpha: 0.5)
        selectedBackgroundView = selectedView
        // Initialization code
    }

    // MARK: - Outlet variable
    @IBOutlet weak var nameLabel : UILabel!
    @IBOutlet weak var artistNameLabel : UILabel!
    @IBOutlet weak var artworkImageView : UIImageView!
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    

}