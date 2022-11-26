//
//  ViewController.swift
//  Lab3
//
//  Created by Manmohan Singh on 2022-11-23.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var locatioSearch: UITextField!
    
    @IBOutlet weak var location: UILabel!
    
    @IBOutlet weak var temprature: UILabel!
    
    @IBOutlet weak var condition: UILabel!
    
    @IBOutlet weak var image1: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locatioSearch.delegate = self
        loadImage()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        print(textField.text ?? "")
        loadWeather(search: locatioSearch.text)
       
        return true
        
    }
    
    
    @IBAction func change(_ sender: Any) {
        loadTemp(search: locatioSearch.text)
//        loadWeather(search: locatioSearch.text)
    }
    @IBAction func onTapLocation(_ sender: Any) {
    }
    
    @IBAction func onTapSearch(_ sender: Any) {
        loadWeather(search: locatioSearch.text)
       
    }
    private func loadWeather(search: String?){
        guard let search = search else{
            return
        }
        
        guard  let url = getURL(query: search) else {
            print("Could not get URL")
            return
        }
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) {data, response, error in
            print("Network call completed")
            
            guard error == nil else{
                print("recieved error")
                return
            }
            guard let data = data else{
                print("No data found")
                return
            }
            
            if let weatherResponse = self.parseJson(data: data) {
                print(weatherResponse.location.name)
                print(weatherResponse.current.temp_c)
                print(weatherResponse.current.condition.text)
                
                DispatchQueue.main.sync {
                    self.location.text = weatherResponse.location.name
                    self.temprature.text = "\(weatherResponse.current.temp_c)C"
                    self.condition.text = weatherResponse.current.condition.text
                }
            }
        }
        
        dataTask.resume()
    }
    private func loadImage(){
        let config = UIImage.SymbolConfiguration(paletteColors: [
            .systemBlue, .systemTeal])
        image1.preferredSymbolConfiguration = config
        image1.image = UIImage(systemName: "cloud.fill")
    }
    private func loadTemp(search: String?){
        guard let search = search else{
            return
        }
        
        guard  let url = getURL(query: search) else {
            print("Could not get URL")
            return
        }
        let session = URLSession.shared
        
        let dataTask = session.dataTask(with: url) {data, response, error in
            print("Network call completed")
            
            guard error == nil else{
                print("recieved error")
                return
            }
            guard let data = data else{
                print("No data found")
                return
            }
            if let weatherResponse = self.parseJson(data: data) {
               
                print(weatherResponse.current.temp_f)
               
                
                DispatchQueue.main.sync {
                    
                    self.temprature.text = "\(weatherResponse.current.temp_f)F"
                    
                }
            }
            
        }
        
        dataTask.resume()
            
        
      
    }
    
//    private func loadTemp(search: String?) {
//        guard let search = search else{
//            return
//        }
//    }
    private func getURL(query: String) -> URL? {
        let baseUrl = "https://api.weatherapi.com/v1/"
        let currentEndpoint = "current.json"
        let apiKey = "fcf05284ee914501ad775107222511"
        guard let url = "\(baseUrl)\(currentEndpoint)?key=\(apiKey)&q=\(query)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return nil
        }
        print(url)
        return URL(string: url)
    }
    private func parseJson(data: Data) -> weatherResponse? {
        let decoder = JSONDecoder()
        var weather: weatherResponse?
        
        do{
            weather = try decoder.decode(weatherResponse.self, from: data)
        }
        catch{
            print("Error decoding")
        }
        return weather
    }
}
    struct weatherResponse: Decodable {
        let location: Location
        let current: weather
    }
    struct Location: Decodable {
        let name: String
    }
    struct weather: Decodable {
        let temp_c: Float
        let temp_f: Float
        let condition: weatherCondition
    }
    struct weatherCondition: Decodable {
        let text: String
        let code: Int
    }


