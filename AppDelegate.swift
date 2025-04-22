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

    public static func asSortedArr() -> [[String]] {
        // Tableau vide pour stocker les traductions sous la forme : [[français, basque]]
        var tabTranslations: [[String]] = []

        // Transforme le dictionnaire [fr: eu] en tableau de tableaux [fr, eu]
        for (fr, eu) in AppDelegate.getTrans() {
            // Ajouter chaque paire au tableau
            tabTranslations.append([fr, eu])
        }

        // Trie à bulles : ordre alphabétique des mots français (colonne [0]) en ignorant la casse
        for i in 0..<tabTranslations.count - 1 {
            for j in i+1..<tabTranslations.count {
                // Si le mot à la position i vient après le mot à la position j dans l'alphabet
                if tabTranslations[i][0].lowercased() > tabTranslations[j][0].lowercased() {
                    // Échanger les deux lignes pour les mettre dans le bon ordre
                    let temp = tabTranslations[i]
                    tabTranslations[i] = tabTranslations[j]
                    tabTranslations[j] = temp
                }
            }
        }

        return tabTranslations
    }

    public static var translations: [String: String] = [:]

    public static func getTrans() -> [String: String] {
        return AppDelegate.translations
    }

    public static func addTrans(original: String, translation: String) {
        translations[original] = translation
        writeTrans()
    }

    private static func getUrl(_ filename:String)->URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(filename)
    }

    public static func loadTrans() {
        translations = loadJSON(getUrl("translations.json"))!
    }
    
    private static func loadJSON (_ anURL : URL) -> [String:String]? {
        let decoder = JSONDecoder()
        let data:Data
        do {
            data = try Data(contentsOf: anURL)
        }
        catch {
            return [:]
        }
        return try! decoder.decode([String:String].self, from: data)
    }

    public static func writeTrans() {
        let encoder = JSONEncoder()
        let data = try! encoder.encode(translations)
        let url = getUrl("translations.json")
        let fmanager = FileManager.default
        fmanager.createFile(atPath: url.path(), contents: data)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        AppDelegate.loadTrans()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

}
