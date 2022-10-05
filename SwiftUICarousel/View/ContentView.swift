//
//  ContentView.swift
//  Whats On Melbourne
//
//  Created by Handy Hasan on 24/9/2022.
//

import SwiftUI

struct NewResult: Identifiable,Equatable,Hashable {
    var id = UUID()
    var newTitle: String
    var newDescription: String
    var newDate: String
    var newLocation: String
    var newImage: String
}

struct ContentView: View {
    @State private var isCardTapped = false
    @State private var currentTripIndex = 2
    @State public var results = [Result]()
    @State public var newResults = [NewResult]()

    @GestureState private var dragOffset: CGFloat = 0
    
    
    func loadData() async{
        guard let url = URL(string: "https://melbourne-todo-final.herokuapp.com/lists") else {
            
            print("Invalid URL")
            return
        }
        
        do {
            
            let (data, _) = try await URLSession.shared.data(from: url)
            if let decodedResponse = try? JSONDecoder().decode([Result].self, from: data) {
                results = decodedResponse
                //this is needed because List need to conform to Identifiable
                for result in results {
                    newResults.append(NewResult(newTitle: result.title,newDescription: result.description, newDate: result.date, newLocation:result.location, newImage:result.image))
                }
                print(newResults)
                
            }
            
        } catch {
        }
    }

    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("What's On Melbourne")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.black)
                
                Text("September 2022")
                    .font(.system(.headline, design: .rounded))
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .padding(.top, 25)
            .padding(.leading, 20)
            .opacity(self.isCardTapped ? 0.1 : 1.0)
            .offset(y: self.isCardTapped ? -100 : 0)
            .task {
                await loadData()
            }
            GeometryReader { outerView in
                HStack(spacing: 0) {
                    ForEach(newResults.indices, id:\.self) { index in
                        GeometryReader { innerView in
                            TripCardView(destination: sampleTrips[index].destination, imageName: newResults[index].newImage, isShowDetails: self.$isCardTapped)
                                .offset(y: self.isCardTapped ? -innerView.size.height * 0.3 : 0)
                        }
                        .padding(.horizontal, self.isCardTapped ? 0 : 20)
                        .opacity(self.currentTripIndex == index ? 1.0 : 0.7)
                        .frame(width: outerView.size.width, height: self.currentTripIndex == index ? (self.isCardTapped ? outerView.size.height : 450) : 400)
                        .onTapGesture {
                            self.isCardTapped = true
                        }
                    }
                }
                .frame(width: outerView.size.width, height: outerView.size.height, alignment: .leading)
                .offset(x: -CGFloat(self.currentTripIndex) * outerView.size.width)
                .offset(x: self.dragOffset)
                .gesture(
                    !self.isCardTapped ?
                        
                    DragGesture()
                        .updating(self.$dragOffset, body: { (value, state, transaction) in
                            state = value.translation.width
                        })
                        .onEnded({ (value) in
                            let threshold = outerView.size.width * 0.65
                            var newIndex = Int(-value.translation.width / threshold) + self.currentTripIndex
                            newIndex = min(max(newIndex, 0), sampleTrips.count - 1)
                            
                            self.currentTripIndex = newIndex
                        })
                    
                    : nil
                )
            }
            .animation(.interpolatingSpring(mass: 0.6, stiffness: 100, damping: 10, initialVelocity: 0.3), value: dragOffset)
            
            if self.isCardTapped {
                TripDetailView(destination: sampleTrips[currentTripIndex].destination)
                    .offset(y: 200)
                    .transition(.move(edge: .bottom))
                    .animation(.interpolatingSpring(mass: 0.5, stiffness: 100, damping: 10, initialVelocity: 0.3))
                
                Button(action: {
                    self.isCardTapped = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(.black)
                        .opacity(0.7)
                        .contentShape(Rectangle())
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topTrailing)
                .padding(.trailing)
                
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

