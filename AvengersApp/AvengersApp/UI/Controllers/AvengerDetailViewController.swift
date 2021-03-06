//
//  AvengerDetailViewController.swift
//  AvengersApp
//
//  Created by Jorge on 26/04/2020.
//  Copyright © 2020 Jorge. All rights reserved.
//

import UIKit

protocol AvengerDetailViewControllerDelegate: AnyObject {
    func onPowerPersist()
}

final class AvengerDetailViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var imageAvenger: UIImageView!
    @IBOutlet weak var powerAvenger: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var biographyAvenger: UITextView!

    // MARK: - Properties
    private let databaseProvider = DatabaseProvider()
    private var hero: Hero?
    private var villain: Villain?
    private weak var delegate: AvengerDetailViewControllerDelegate?
    private let cellId: String = String(describing: UITableViewCell.self)

    // MARK: - Life cycle functions
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        loadAvengerData()
    }

    // MARK: - Public functions
    func configure(hero: Hero? = nil,
                   villain: Villain? = nil,
                   delegate: AvengerDetailViewControllerDelegate) {
        self.hero = hero
        self.villain = villain
        self.delegate = delegate
    }

    // MARK: - Private functions
    private func setupUI() {
        imageAvenger.layer.cornerRadius = 8
        configureTableView()
    }

    private func configureTableView() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }

    private func loadAvengerData() {
        if let hero = self.hero {
            self.title = hero.name
            if let image = UIImage(named: hero.image ?? "") {
                imageAvenger.image = image
            }
            powerAvenger.image = hero.power.imagePower()
            biographyAvenger.text = hero.biography
        } else if let villain = self.villain {
            self.title = villain.name
            if let image = UIImage(named: villain.image ?? "") {
                imageAvenger.image = image
            }
            powerAvenger.image = villain.power.imagePower()
            biographyAvenger.text = villain.biography
        }
    }

    private func showData() {
        tableView.reloadData()
    }

    // MARK: - IBActions
    @IBAction func pencilPowerTapped(_ sender: UIButton) {
        let avengerPowerVC = AvengerPowerViewController()
        if let hero = self.hero {
            avengerPowerVC.configure(hero: hero, delegate: self)
        } else if let villain = self.villain {
            avengerPowerVC.configure(villain: villain, delegate: self)
        }
        self.navigationController?.pushViewController(avengerPowerVC, animated: true)
    }

}

// MARK:  - UITableViewDataSource
extension AvengerDetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let hero = self.hero {
            return hero.battles?.count ?? 0
        } else if let villain = self.villain {
            return villain.battles?.count ?? 0
        } else {
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)

        if let battle = getBattleBy(pos: indexPath.row),
            let winnerType = WinnerType.init(rawValue: Int(battle.winner)) {
            cell.textLabel?.text = textBattle(battle: battle, txtAvenger: winnerType.textHero)
            cell.backgroundColor = winnerType.colorHero
        }

        return cell
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        switch editingStyle {
            case .delete:
                if deleteBattleBy(pos: indexPath.row) == true {
                    showData()
                }

            default:
                break
        }
    }

    private func textBattle(battle: Battle, txtAvenger: String) -> String {
        var textBattle = ""
        if let titleBattle = battle.title {
            textBattle.append(titleBattle + " ")
        }
        textBattle.append("(\(txtAvenger))")
        return textBattle
    }

    private func getBattles() -> NSOrderedSet? {
        if let hero = self.hero {
            return hero.battles
        } else if let villain = self.villain {
            return villain.battles
        }
        return nil
    }

    private func getBattleBy(pos: Int) -> Battle? {
        if let battles = getBattles() {
            if pos < battles.count {
                return battles[pos] as? Battle
            }
        }
        return nil
    }

    private func deleteBattleBy(pos: Int) -> Bool {
        if let battle = getBattleBy(pos: pos) {
            return databaseProvider.deleteBatte(battle: battle)
        }
        return false
    }

}

// MARK: - UITableViewDelegate
extension AvengerDetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }

}

// MARK: - AvengerPowerViewControllerDelegate
extension AvengerDetailViewController: AvengerPowerViewControllerDelegate {

    func onChangePower(newPower: Int) {
        if let hero = self.hero {
            hero.power = Int16(newPower)
            powerAvenger.image = hero.power.imagePower()
        } else if let villain = self.villain {
            villain.power = Int16(newPower)
            powerAvenger.image = villain.power.imagePower()
        }

        if databaseProvider.persistAll() == true {
            delegate?.onPowerPersist()
        } else {
            print("🤬 persistAll power")
        }
    }
    
}





