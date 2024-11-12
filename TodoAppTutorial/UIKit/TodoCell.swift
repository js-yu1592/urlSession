//
//  TodoCell.swift
//  TodoAppTutorial
//
//  Created by 유준상 on 10/7/24.
//

import UIKit

class TodoCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var selectionSwitch: UISwitch!
    
    var delegate: MainVCDelegate?
    var todo: Todo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(todo: Todo) {
        self.todo = todo
    }
    
    @IBAction func ChangedSelectionSwitch(_ sender: UISwitch) {
        guard let todo = todo else { return }
        
        let newTodo = Todo(
            id: todo.id,
            title: todo.title,
            isDone: sender.isOn,
            createdAt: todo.createdAt,
            updatedAt: todo.updatedAt
        )

        delegate?.editTodo(newTodo: newTodo)
    }
    
    @IBAction func didTapEditButton(_ sender: UIButton) {
        let alert = UIAlertController(title: "수정할 내용을 입력해주세요", message: nil, preferredStyle: .alert)
        let ok = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            guard let self,
            let todo = self.todo else { return }
            let newTodo = Todo(
                id: todo.id,
                title: alert.textFields?[0].text ?? "",
                isDone: selectionSwitch.isOn,
                createdAt: todo.createdAt,
                updatedAt: todo.updatedAt
            )

            delegate?.editTodo(newTodo: newTodo)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addTextField()
        alert.addAction(ok)
        alert.addAction(cancel)
        
        delegate?.presentEditAlert(alert: alert)
    }
    
    @IBAction func didTapDeleteButton(_ sender: UIButton) {
        guard let todoId = todo?.id else { return }
        delegate?.deleteTodo(todoId: todoId)
    }
    
}
