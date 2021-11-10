//
//  ViewController.swift
//  Demo-Combine
//
//  Created by namtrinh on 29/10/2021.
//

import UIKit
import Combine

final class ViewController: UIViewController {

    @IBOutlet private weak var listCoinTableView: UITableView!
    @IBOutlet private weak var searchBar: UISearchBar!
    
    private var coins = [SimpleCoin]()
    private var viewModel = ViewModel()
    private var subscriptions = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dismissKeyboard()
        setUp()
        bindToView()
    }

    private func setUp() {
        searchBar.delegate = self
        
        listCoinTableView.delegate = self
        listCoinTableView.dataSource = self
        listCoinTableView.register(SimpleCoinTableViewCell.nib,
                                   forCellReuseIdentifier: SimpleCoinTableViewCell.reuseIdentifier)
        
        listCoinTableView.refreshControl = UIRefreshControl()
        listCoinTableView.refreshControl?.addTarget(self,
                                                 action: #selector(handleRefreshControl),
                                                 for: .valueChanged)
    }
    
    @objc private func handleRefreshControl() {
        guard let name = searchBar.searchTextField.text else {
            return
        }
        viewModel.action.send(.fetchData(name: name))
        listCoinTableView.refreshControl?.endRefreshing()
    }
    
    private func bindToView() {
        viewModel.$coins
            .debounce(for: .seconds(0.5), scheduler: DispatchQueue.main)
            .sink(receiveValue: { [weak self] coins in
                guard let self = self else { return }
                self.coins = coins
                self.listCoinTableView.reloadData()
            })
            .store(in: &subscriptions)
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let name = searchBar.searchTextField.text else {
            return
        }
        viewModel.action.send(.fetchData(name: name))
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        guard let name = searchBar.searchTextField.text else {
            return
        }
        viewModel.action.send(.reset(name: name))
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = listCoinTableView.dequeueReusableCell(withIdentifier: SimpleCoinTableViewCell.reuseIdentifier)
                as? SimpleCoinTableViewCell else {
            return UITableViewCell()
        }
        cell.configureCell(coin: coins[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
