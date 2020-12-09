//
//  SearchUsersViewController.swift
//  LogInFB
//
//  Created by Deniz Adil on 25.11.20.
//

import UIKit
import SVProgressHUD
import Kingfisher


class SearchUsersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Search Users"
        fetchUsers()
        setupTableView()
    }
    private func setupTableView() {
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: UserTableViewCell.identifier)
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
    }
    private func fetchUsers() {
        SVProgressHUD.show()
        DataStore.shared.getAllUsers { (users, error) in
            SVProgressHUD.dismiss()
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let users = users {
                self.users = users.filter({$0.fullName != nil && $0.fullName != "" && $0.id != DataStore.shared.localUser?.id})
                self.users.sort(by: {$0.fullName! < $1.fullName!})
                self.tableView.reloadData()
            }
        }
    }
    private func openProfileFor(user: User) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        controller.user = user
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
}
extension SearchUsersViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection sections: Int) -> Int {
        return users.count
    
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.identifier) as! UserTableViewCell
        let user = users[indexPath.row]
        cell.lblName.text = user.fullName
        if let imageUrl = user.imageUrl {
            cell.userImage.kf.setImage(with: URL(string: imageUrl))
        } else {
            cell.userImage.image = UIImage(named: "userPlaceholder")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        openProfileFor(user: user)
        
    }
}

