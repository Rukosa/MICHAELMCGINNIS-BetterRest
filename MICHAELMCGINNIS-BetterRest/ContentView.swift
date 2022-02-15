//
//  ContentView.swift
//  MICHAELMCGINNIS-BetterRest
//
//  Created by Michael Mcginnis on 2/14/22.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    var desiredBedTime: String{
        var sleepingTime = ""
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            sleepingTime = sleepTime.formatted(date: .omitted, time: .shortened)
        }catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            showingAlert = true
        }
        return sleepingTime
    }
    /*
    func calculateBedtime(){
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "Your ideal bedtime is..."
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
            desiredBedTime = alertMessage
        }catch{
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
        showingAlert = true
    }*/
    static var defaultWakeTime: Date{
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    var body: some View {
        NavigationView{
            Form{
                Section{
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute).labelsHidden()
                } header: {
                    Text("When do you want to wake up?").font(.body)
                }
                Section{
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12, step: 0.25)
                } header: {
                    Text("Desired amount of sleep").font(.body)
                }
                Section{
                    Picker("Cups: ", selection: $coffeeAmount){
                        ForEach((1...20), id: \.self){
                            Text("\($0)")
                        }
                    }
                }header: {
                    Text("Daily coffee intake").font(.body)
                }
                Section{
                    Text("\(desiredBedTime)")
                }header: {
                    Text("Desired bedtime: ").font(.body)
                }
            }.navigationTitle("BetterRest")
            /*
                .toolbar{
                    Button("Calculate", action: calculateBedtime)
                }
             */
                .alert(alertTitle, isPresented: $showingAlert){
                    Button("OK"){}
                } message: {
                    Text(alertMessage)
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
