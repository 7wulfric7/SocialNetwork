//
//  LoadingTableViewCell.swift
//  LogInFB
//
//  Created by Deniz Adil on 21.12.20.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {

    lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicatior = UIActivityIndicatorView(style: .medium)
        activityIndicatior.color = .black
        activityIndicatior.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatior.isHidden = false
        return activityIndicatior
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    private func setupViews() {
        contentView.addSubview(activityIndicator)
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[activityMonitor(50)]", options: [.alignAllCenterX], metrics: nil, views: ["activityIndicatior":activityIndicator]))
//        contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[activityMonitor(50)]", options: [.alignAllCenterY], metrics: nil, views: ["activityIndicatior":activityIndicator]))
        activityIndicator.heightAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 50).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
