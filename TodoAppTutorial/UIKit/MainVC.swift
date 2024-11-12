//
//  MainVC.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 9/30/24.
//

import Foundation
import UIKit
import SwiftUI

protocol MainVCDelegate {
    func editTodo(newTodo: Todo)
    func deleteTodo(todoId: Int)
    func presentEditAlert(alert: UIAlertController)
}

class MainVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var todos: [Todo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .systemBackground
        attribute()
    }
    
    private func attribute() {
        tableView.register(TodoCell.uinib, forCellReuseIdentifier: TodoCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 150
        tableView.rowHeight = UITableView.automaticDimension
    }
    
    @IBAction func didTapAddTodoButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "할 일을 적어주세요", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self else { return }
            
            let todo = Todo(
                id: 0,
                title: alert.textFields?[0].text ?? "",
                isDone: false,
                createdAt: "", 
                updatedAt: ""
            )
        }
        
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        alert.addTextField()
        alert.addAction(ok)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
}

extension MainVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: TodoCell.identifier,
            for: indexPath
        ) as? TodoCell else { return UITableViewCell() }
        
        let todo = todos[indexPath.row]
        cell.bind(todo: todo)
        cell.delegate = self
        
        return cell
    }
    
}

extension MainVC {
    private struct VCRepresentable: UIViewControllerRepresentable {
        
        let mainVC: MainVC
        
        func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
        
        func makeUIViewController(context: Context) -> some UIViewController {
            return mainVC
        }
    }
    
    func getRepresentable() -> some View {
        VCRepresentable(mainVC: self)
    }
}

extension MainVC: MainVCDelegate {
    
    func editTodo(newTodo: Todo) { }
    
    func deleteTodo(todoId: Int) { }
    
    func presentEditAlert(alert: UIAlertController) {
        self.present(alert, animated: true)
    }
}
