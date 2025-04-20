//
//  VisualisationTVC.swift
//  EuskApp
//
//  Created by etudiant on 08/04/2025.
//

import UIKit

class VisualisationTVC: UITableViewController {

    private var unRefreshControl : UIRefreshControl!
    private var listTranslations: [[String]] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialise le "Glisser pour rafraîchir"
        unRefreshControl = UIRefreshControl()
        unRefreshControl.attributedTitle =
        NSAttributedString(string: "Glisser pour rafraîchir")

        // Quand on tire pour rafraîchir, appelle rechargerTableView()
        unRefreshControl.addTarget(self, action:
                        #selector(VisualisationTVC.loadTableView), for: UIControl.Event.valueChanged)

        // Ajoute ce contrôle à la tableView
        self.tableView.addSubview(self.unRefreshControl)

        // Recharge la tableView une première fois au chargement
        loadTableView()
    }

    @objc func loadTableView(){
        listTranslations = AppDelegate.asSortedArr()

        // Recharge les données de la table
        self.tableView.reloadData()

        // Arrête l'animation de "Glisser pour rafraîchir"
        self.unRefreshControl.endRefreshing()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listTranslations.count // Nombre de lignes = nombre de traductions
    }

    // Remplit chaque cellule avec un mot français + sa traduction basque
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transCell", for: indexPath)

        cell.textLabel?.text = listTranslations[indexPath.row][0] // [0] -> Mot en français
        cell.detailTextLabel?.text = listTranslations[indexPath.row][1] // [1] -> Mot en basque
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewDetail" {
            if let indexPath = tableView.indexPathForSelectedRow,
               let destinationVC = segue.destination as? DetailVC {
                let wordFr = listTranslations[indexPath.row][0]
                let wordEu = listTranslations[indexPath.row][1]
                destinationVC.original = wordFr
                destinationVC.translation = wordEu
                /*
                let wordsTranslated = AppDelegate.asSortedArr()
                destinationVC.word = wordsTranslated[indexPath.row][0]
                destinationVC.translation = wordsTranslated[indexPath.row][1]
                 */
            }
        }
    }

}
