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
    var refreshControl = UIRefreshControl()
    
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
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    @objc func refresh(_ refreshControl: UIRefreshControl) {
        fetchUsers(isRefresh: true)
    }
    private func fetchUsers(isRefresh: Bool = false) {
        SVProgressHUD.show()
        if isRefresh {
            users.removeAll()
        }
        DataStore.shared.getAllUsers { (users, error) in
            SVProgressHUD.dismiss()
            if self.refreshControl.isRefreshing {
                self.refreshControl.endRefreshing()
            }
            if let error = error {
                self.showErrorWith(title: "Error", msg: error.localizedDescription)
                return
            }
            if let users = users {
                self.users = users.filter({$0.fullName != nil && $0.fullName != "" && $0.id != DataStore.shared.localUser?.id})
                self.users.sort(by: {$0.fullName! < $1.fullName!})
                self.tableView.refreshControl?.endRefreshing()
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
        cell.blockingDelegate = self
        let user = users[indexPath.row]
        cell.blockingDelegate = self
        cell.setData(user: user)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let user = users[indexPath.row]
        openProfileFor(user: user)
        
    }
}
extension SearchUsersViewController: BlockUsersCellDelegate {
    func didBlockUser(user: User, isBlock: Bool) {
        guard var localUser = DataStore.shared.localUser, let userId = user.id else {return}
        if localUser.blockedUsersID == nil {
            localUser.blockedUsersID = [String]()
        }
        if isBlock {
            localUser.blockedUsersID?.append(userId)
        } else {
            localUser.blockedUsersID?.removeAll(where: {$0 == user.id})
        }
        localUser.save()
        tableView.reloadData()
//        let notification = NotificationCenter(name: Notification.Name("ReloadFeedAfterUserAction"))
        NotificationCenter.default.post(name: Notification.Name("ReloadFeedAfterUserAction"), object: nil)
    }
}

