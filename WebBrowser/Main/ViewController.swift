//
//  ViewController.swift
//  WebBrowser
//
//  Created by Mereke on 07.03.2023.
//

import UIKit
import SnapKit
import CoreData

class ViewController: UIViewController {

    private let tableView = UITableView()
    private var segmentedControl: UISegmentedControl!
    private var websites: [NSManagedObject] = []
    private var indexOfSelectedWebsite: Int?
    private var deleteButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        loadWebsites()
        let addButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
        addButton.tintColor = .systemBlue
        setInterface()
        setConstraints()
    }

    @objc func segmentedControlChanged() {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            loadWebsites()
            tableView.reloadData()
        case 1:
            websites = websites.filter { $0.value(forKey: "isFavorite") as? Bool == true }
            tableView.reloadData()
        default:
            break
        }
    }

    @objc func deleteButtonTapped() {
        deleteAllWebsites()
    }

    @objc func addButtonTapped() {
        let alertController = UIAlertController(title: "Add", message: nil, preferredStyle: .alert)

        alertController.addTextField { textField in
            textField.placeholder = "Title"
        }
        alertController.addTextField { textField in
            textField.placeholder = "Link"
        }

        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let title = alertController.textFields?[0].text,
               let link = alertController.textFields?[1].text {
                self.saveWebsite(title, link)
                self.tableView.reloadData()
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController: WebViewDelegate {
    func addToFavorite(_ isFavorite: Bool) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        guard let index = indexOfSelectedWebsite, index < websites.count else { return }
        let website = websites[indexOfSelectedWebsite!]
        website.setValue(isFavorite, forKey: "isFavorite")
        do {
            try context.save()
            self.tableView.reloadData()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    private func saveWebsite(_ title: String, _ link: String) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "WebsiteEntity", in: context)!
        let website = NSManagedObject(entity: entity, insertInto: context)
        website.setValue(title, forKeyPath: "title")
        website.setValue(link, forKeyPath: "link")
        website.setValue(false, forKeyPath: "isFavorite")

        do {
            try context.save()
            websites.append(website)
            loadWebsites()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }

    private func loadWebsites() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WebsiteEntity")
        do {
            websites = try context.fetch(fetchRequest)
            websites.reverse()
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    private func deleteAllWebsites() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WebsiteEntity")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)

        do {
            try context.execute(batchDeleteRequest)
            websites.removeAll()
            tableView.reloadData()
            loadWebsites()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
    }

    private func setInterface() {
        tableView.register(TableViewCell.self, forCellReuseIdentifier: TableViewCell.reuseIdentifier)
        tableView.dataSource = self
        tableView.delegate = self

        segmentedControl = UISegmentedControl(items: ["Lists", "Favourites"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        navigationItem.titleView = segmentedControl

        deleteButton.setTitle("Clear", for: .normal)
        deleteButton.setTitleColor(.systemRed, for: .normal)
        deleteButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        view.addSubview(deleteButton)
        view.addSubview(tableView)
    }

    private func setConstraints() {
        tableView.contentInset = .zero
        tableView.separatorInset = .zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 450
        tableView.backgroundColor = .clear

        deleteButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
            $0.leading.equalToSuperview().offset(120)
            $0.trailing.equalToSuperview().inset(120)
        }

        tableView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        websites.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.reuseIdentifier, for: indexPath) as? TableViewCell else {
            return UITableViewCell()
        }
        cell.headerLabel.text = websites[indexPath.row].value(forKey: "title") as? String
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let urlStr = websites[indexPath.row].value(forKey: "link") as? String,
              let url = URL(string: urlStr),
              let splitVC = splitViewController,
              let webNavVC = splitVC.viewControllers.last as? UINavigationController,
              let webVC = webNavVC.topViewController as? WebViewController
        else { return }
        indexOfSelectedWebsite = indexPath.row

        guard let isFavorite = websites[indexPath.row].value(forKey: "isFavorite") as? Bool else { return }
        webVC.updateFavoriteButton(isFavorite: isFavorite)
        webVC.title = websites[indexPath.row].value(forKey: "title") as? String
        webVC.favoriteIsHidden = false
        webVC.loadURL(url)
        splitVC.showDetailViewController(webNavVC, sender: nil)
    }
}

