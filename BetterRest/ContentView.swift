//
//  ContentView.swift
//  BetterRest
//
//  Created by Zach Mommaerts on 9/11/23.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var recommendedBedTime: Date {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            return sleepTime
        } catch {
            return Date.now
        }
    }
    
    var body: some View {
        NavigationView(){
            Form{
                Section {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you want to wake up?")
                        .font(.headline)
                }
                
                Section {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep")
                        .font(.headline)
                }
                
                Section {
                    Picker(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text(String($0))
                        }
                    }
                } header: {
                    Text("Daily coffe intake")
                        .font(.headline)
                }
                
                Text(recommendedBedTime.formatted(date: .omitted, time: .shortened))
                    .font(.largeTitle)
            }
            .navigationBarTitle("BetterRest")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
