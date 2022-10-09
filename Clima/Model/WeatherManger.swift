//
//  WeatherManger.swift

//
//  Created by Qurt on 8/2/22.


import Foundation
import CoreLocation
protocol weatherManagerDelegate {
    func didUpadteWeather(_ weatherManger:WeatherManger, weather: WeatherModel)
    func didFaildWithError(error: Error)
}
struct WeatherManger {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=52458c4554e25f208c229ef0e7df5a01&units=metric"
    var delegate: weatherManagerDelegate?
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
        
    }
    
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urllString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urllString)
    }
    func performRequest(with urlString: String) {
        if let url = URL(string: urlString) {
            let sesstion = URLSession(configuration:.default)
            let task = sesstion.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    self.delegate?.didFaildWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJason(safeData) {
                        self.delegate?.didUpadteWeather(self, weather: weather)
                    }
                    
                }
            }
            task.resume()
        }
        
    }
    func parseJason(_ weatherData:  Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
           
                  
        }
        catch {
            delegate?.didFaildWithError(error: error)
            return nil
        }
        
    }
   
   
}
