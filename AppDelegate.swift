//
//  AppDelegate.swift
//  EuskApp
//
//  Created by etudiant on 14/03/2025.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    // Trie et retourne les traductions sous forme de tableau de paires [fr, eu]
    public static func asSortedArr() -> [[String]] {
        // Tableau vide pour stocker les traductions
        var tabTranslations: [[String]] = []

        // Transforme le dictionnaire [fr: eu] en tableau de tableaux [fr, eu]
        for (fr, eu) in AppDelegate.getTrans() {
            // Ajoute chaque paire au tableau
            tabTranslations.append([fr, eu])
        }

        // Tri à bulles : ordre alphabétique des mots français (colonne [0])
        for i in 0..<tabTranslations.count - 1 {
            for j in i+1..<tabTranslations.count {
                // Si le mot à la position i vient après le mot à la position j dans l'alphabet
                if tabTranslations[i][0].lowercased() > tabTranslations[j][0].lowercased() { // Compare les mots en ignorant la casse
                    // Échange les deux lignes pour les mettre dans le bon ordre
                    let temp = tabTranslations[i]
                    tabTranslations[i] = tabTranslations[j]
                    tabTranslations[j] = temp
                }
            }
        }

        return tabTranslations
    }

    // Dictionnaire global des traductions
    public static var translations: [String: String] = [:]

    // Retourne les traductions existantes
    public static func getTrans() -> [String: String] {
        return AppDelegate.translations
    }

    // Ajoute une nouvelle traduction et l'enregistre dans le fichier
    public static func addTrans(original: String, translation: String) {
        translations[original] = translation
        writeTrans()
    }

    // Retourne l'URL du fichier à partir de son nom
    private static func getUrl(_ filename:String)->URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
    }

    // Charge les traductions depuis le fichier JSON
    public static func loadTrans() {
        translations = loadJSON(getUrl("translations.json"))!
    }

    // Décode le JSON en dictionnaire de traductions
    private static func loadJSON (_ anURL : URL) -> [String: String]? {
        let decoder = JSONDecoder()
        let data:Data

        // Tente de lire les données du fichier
        do {
            data = try Data(contentsOf: anURL)
        }
        catch {
            // Retourne un dictionnaire vide si le fichier est introuvable
            return [:]
        }

        // Décode les données en [String: String]
        return try! decoder.decode([String: String].self, from: data)
    }

    // Sauvegarde les traductions dans le fichier JSON
    public static func writeTrans() {
        let encoder = JSONEncoder()
        // Encode les traductions
        let data = try! encoder.encode(translations)
        // Récupère l'URL du fichier
        let url = getUrl("translations.json")

        // Crée / remplace le fichier avec les données
        let fmanager = FileManager.default
        fmanager.createFile(atPath: url.path(), contents: data)
    }

    // Initialise Firebase et charge les traductions
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        AppDelegate.loadTrans()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
