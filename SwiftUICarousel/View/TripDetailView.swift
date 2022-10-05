//
//  TripDetailView.swift
//  Whats On Melbourne
//
//  Created by Handy Hasan on 24/9/2022.
//

import SwiftUI
import EventKit
import EventKitUI

struct TripDetailView: View {
    let destination: String
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                ZStack {
                    VStack(alignment: .leading, spacing: 5) {
                        
                        VStack(alignment: .leading, spacing: 5) {
                            Text(self.destination)
                                .font(.system(.title, design: .rounded))
                                .fontWeight(.heavy)
                            
                            
                            //                            HStack(spacing: 3) {
                            //                                ForEach(1...5, id: \.self) { _ in
                            //                                    Image(systemName: "star.fill")
                            //                                        .foregroundColor(.yellow)
                            //                                        .font(.system(size: 15))
                            //                                }
                            //
                            //                                Text("5.0")
                            //                                    .font(.system(.headline))
                            //                                    .padding(.leading, 10)
                            //                            }
                            
                        }
                        .padding(.bottom, 30)
                        
                        
                        Text("Description")
                            .font(.system(.headline))
                            .fontWeight(.medium)
                        
                        Text("Growing up in Michigan, I was lucky enough to experience one part of the Great Lakes. And let me assure you, they are great. As a photojournalist, I have had endless opportunities to travel the world and to see a variety of lakes as well as each of the major oceans. And let me tell you, you will be hard pressed to find water as beautiful as the Great Lakes.")
                            .padding(.bottom, 40)
                        
                        Button(action: {
                            // tap me
                            let today = NSDate()
                            CalendarService.addEventToCalendar(title: "TITLE",
                                                               description: "DESCRIPTION",
                                                               startDate: NSDate() as Date    ,
                                                               endDate: NSDate() as Date,
                                                               completion: { (success, error) in
                                if success {
                                    CalendarService.openCalendar(with: NSDate() as Date)
                                } else if let error = error {
                                    print(error)
                                }
                            })
                            
                        }) {
                            Text("Save to Calendar")
                                .font(.system(.headline, design: .rounded))
                                .fontWeight(.heavy)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                            
                                .cornerRadius(20)
                        }
                        
                    }
                    .padding()
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .topLeading)
                    .cornerRadius(15)
                    
                    
                }
                .offset(y: 15)
            }
            .offset(y:180)
        }
        
    }
}

struct TripDetailView_Previews: PreviewProvider {
    static var previews: some View {
        TripDetailView(destination: "London").background(Color.black)
    }
}



func gotoAppleCalendar(date: NSDate) {
    let interval = date.timeIntervalSinceReferenceDate
    let url = NSURL(string: "calshow:\(interval)")!
    UIApplication.shared.openURL(url as URL)
}


final class CalendarService {
    
    class func openCalendar(with date: Date) {
        guard let url = URL(string: "calshow:\(date.timeIntervalSinceReferenceDate)") else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    class func addEventToCalendar(title: String,
                                  description: String?,
                                  startDate: Date,
                                  endDate: Date,
                                  completion: ((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        DispatchQueue.global(qos: .background).async { () -> Void in
            let eventStore = EKEventStore()
            
            eventStore.requestAccess(to: .event, completion: { (granted, error) in
                if (granted) && (error == nil) {
                    let event = EKEvent(eventStore: eventStore)
                    event.title = title
                    event.startDate = startDate
                    event.endDate = endDate
                    event.notes = description
                    event.calendar = eventStore.defaultCalendarForNewEvents
                    do {
                        try eventStore.save(event, span: .thisEvent)
                    } catch let e as NSError {
                        DispatchQueue.main.async {
                            completion?(false, e)
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        completion?(true, nil)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion?(false, error as NSError?)
                    }
                }
            })
        }
    }
}
