//
//  AddClothingViewController.swift
//  Clokey
//
//  Created by 소민준 on 1/28/25.
//
import UIKit

class AddClothingViewController: UIViewController {

    // MARK: - UI Components

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "옷의 유형을 입력해주세요!"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "정확한 카테고리 분류를 위해\n새깔+유형 형식의 예시를 참고해주세요."
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let clothingTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "예: 회색 후드티, 검정 슬랙스"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("다음", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.backgroundColor = .white

        // Add subviews
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(clothingTextField)
        view.addSubview(addButton)

        // Set constraints
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            clothingTextField.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            clothingTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            clothingTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            clothingTextField.heightAnchor.constraint(equalToConstant: 50),

            addButton.topAnchor.constraint(equalTo: clothingTextField.bottomAnchor, constant: 30),
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 50)
        ])

        // Add button action
        addButton.addTarget(self, action: #selector(didTapAddButton), for: .touchUpInside)
    }

    // MARK: - Actions

    @objc private func didTapAddButton() {
        guard let clothingType = clothingTextField.text, !clothingType.isEmpty else {
            showAlert(message: "옷의 유형을 입력해주세요.")
            return
        }
        // Handle the clothing type input
        print("옷의 유형: \(clothingType)")
        // Navigate to the next screen or perform other actions
    }

    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}
