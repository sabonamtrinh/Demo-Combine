//
//  ViewModel.swift
//  Demo-Combine
//
//  Created by namtrinh on 09/11/2021.
//

import Foundation
import Combine

class ViewModel {
    @Published var coins: [SimpleCoin] = []
    @Published var isLoading = false
    
    private var disposables = Set<AnyCancellable>()
    let action = PassthroughSubject<Action, Never>()
    let state = CurrentValueSubject<State, Never>(.initial)
    
    init() {
        state.sink { [weak self] state in
            self?.processState(state)
        }.store(in: &disposables)
        
        action.sink { [weak self] action in
            self?.processAction(action)
        }.store(in: &disposables)
    }
    
    enum State {
        case initial
        case fetched
        case error(message: String)
        case reloadCell(indexPath: IndexPath)
    }
    
    enum Action {
        case fetchData(name: String)
        case reset(name: String)
    }
    
    private func processState(_ state: State) {
        switch state {
        case .initial:
            isLoading = false
        case .fetched:
            isLoading = true
        case .error(message: let message):
            print("Error: ", message)
        case .reloadCell(let indexPath):
            print("Reload Cell at", indexPath)
        }
    }
    
    private func processAction(_ action: Action) {
        switch action {
        case .fetchData(let name):
            fetchCoin(forName: name)
        case .reset(let name):
            coins = []
            fetchCoin(forName: name)
        }
    }
    
    func fetchCoin(forName name: String) {
        APIService.shared.request(url: name, expecting: Response<SimpleDataCoin>.self)
            .map(\.data.coins)
            .replaceError(with: [])
            .assign(to: \.coins, on: self)
            .store(in: &disposables)
    }
    
}
