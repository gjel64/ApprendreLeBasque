//
//  CloudAPI.swift
//  EuskApp
//
//  Created by etudiant on 22/04/2025.
//
import Foundation
import AVFoundation

class CloudAPI {
    static let apiKey = "AIzaSyCkCLyb9OGA07Nlq1lGbVCKvJ1-qQzzwLU"
    static var audioPlayer: AVAudioPlayer?

    // MARK: - Traduction
    static func translate(text: String, targetLang: String, completion: @escaping (String?) -> Void) {
        let urlString = "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("URL invalide")
            completion(nil)
            return
        }
        
        let parameters: [String: Any] = ["q": text, "target": targetLang, "format": "text"]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Erreur réseau : \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Code HTTP : \(httpResponse.statusCode)")
            }
            
            guard let data = data else {
                print("Données vides")
                completion(nil)
                return
            }
            
            // Afficher la réponse brute pour débogage
            if let jsonStr = String(data: data, encoding: .utf8) {
                print("Réponse JSON brute : \(jsonStr)")
            }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dataObject = json["data"] as? [String: Any],
               let translations = dataObject["translations"] as? [[String: Any]],
               let translatedText = translations.first?["translatedText"] as? String {
                
                DispatchQueue.main.async {
                    completion(translatedText)
                }
            } else {
                print("Erreur de parsing JSON")
                completion(nil)
            }
        }
        task.resume()
    }

    // MARK: - Text-to-Speech
    static func audio(text: String, targetLang: String) {
        let urlString = "https://texttospeech.googleapis.com/v1/text:synthesize?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("URL TTS invalide")
            return
        }

        let parameters: [String: Any] = [
            "input": ["text": text],
            "voice": ["languageCode": targetLang, "ssmlGender": "NEUTRAL"],
            "audioConfig": ["audioEncoding": "MP3"]
        ]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil, let data = data else {
                print("Erreur TTS : \(error?.localizedDescription ?? "inconnue")")
                return
            }

            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let audioContent = result["audioContent"] as? String,
               let audioData = Data(base64Encoded: audioContent) {

                DispatchQueue.main.async {
                    do {
                        audioPlayer = try AVAudioPlayer(data: audioData)
                        audioPlayer?.prepareToPlay()
                        audioPlayer?.play()
                    } catch {
                        print("Erreur de lecture audio : \(error)")
                    }
                }
            } else {
                print("Erreur parsing réponse TTS")
            }
        }.resume()
    }
    
    // MARK: - Text-to-Speech
    static func analyzeSyntax(text: String, targetLang: String = "fr", completion: @escaping ([String]) -> Void) {
        let urlString = "https://language.googleapis.com/v1/documents:analyzeSyntax?key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            print("URL invalide")
            completion([])
            return
        }
        
        let parameters: [String: Any] = [
            "document": [
                "type": "PLAIN_TEXT",
                "language": targetLang,
                "content": text
            ],
            "encodingType": "UTF8"
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Erreur : \(error?.localizedDescription ?? "inconnue")")
                completion([])
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                if let tokens = json?["tokens"] as? [[String: Any]] {
                    var result: [String] = []
                    for token in tokens {
                        let text = token["text"] as? [String: String]
                        let partOfSpeech = token["partOfSpeech"] as? [String: Any]
                        if let word = text?["content"], let tag = partOfSpeech?["tag"] as? String {
                            result.append("\(word) → \(tag)")
                        }
                    }
                    DispatchQueue.main.async {
                        completion(result)
                    }
                } else {
                    print("Parsing JSON échoué")
                    completion([])
                }
            } catch {
                print("Erreur JSON : \(error)")
                completion([])
            }
        }
        task.resume()
    }
}
