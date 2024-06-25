//
//  TemplateTableViewCell.swift
//  Plumedot
//
//  Created by Md Faizul karim on 7/2/23.
//

import UIKit

class TemplateTableViewCell: UITableViewCell {

    @IBOutlet weak var templeteTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
