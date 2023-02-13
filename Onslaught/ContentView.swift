import SwiftUI

struct Workout: Hashable, Codable {
    var id: Int
    var title: String
    var workout_number: Int
    var workout_str: String?
    var date: String
}

struct UserStats: Codable {
    var id: Int
    var username: String
    var coldPlunges: Int
    var completedWorkouts: Int
    var cardioSessions: Int
    var totalPoints: Int
}

struct ActivitySheetView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedType = "Cold Plunge"
    @State private var selectedDate = Date()
    @State private var selectedDuration = 0
    
    let types = ["Cold Plunge", "Cardio"]
    @EnvironmentObject private var workoutService: WorkoutService
    private func submit(userId:Int, duration:Int, date:Date) async {
        let activityType = selectedType
        do {
            try await workoutService.createActivity(userId: userId, duration: selectedDuration, date: selectedDate, type:activityType)
        } catch {
            print("err in submit iceplunge")
        }
    }
    var body: some View {
        let userData = UserDefaults.standard.value(forKey: "user") as? Data
        let user = try? PropertyListDecoder().decode(User.self, from: userData ?? Data())
        NavigationView {
            Form {
                Picker(selection: $selectedType, label: Text("Activity Type")) {
                    ForEach(types, id: \.self) { type in
                        Text(type).tag(type)
                    }
                }.padding(5)
                
                DatePicker(selection: $selectedDate, displayedComponents: .date) {
                    Text("Date")
                }.padding(5)
                
                Stepper(value: $selectedDuration, in: 0...120, step: 1) {
                    Text("Duration (min): \(selectedDuration)")
                }.padding(5)
                         
                         HStack {
                             Button("Discard") {
                                 self.presentationMode.wrappedValue.dismiss()
                             }
                             
                             Spacer()
                             
                             Button("Submit") {
                                 // Perform actions when submit is pressed
                                 // For example: store the selected data in UserDefaults, send it to a server, etc.
                                 Task {
                                     await submit(userId: user?.id ?? 0, duration: selectedDuration, date: selectedDate)
                                     presentationMode.wrappedValue.dismiss()
                                 
                                 
                                 }
                                 
                             }
                         }.padding(10)
                     }
            
                     .navigationBarTitle("New Activity")
                     
                 }
             }
         }
     
                         
                         
                         
                         
                         
                         
struct HistorySheetView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Text("History")
        Button("Press to dismiss") {
            dismiss()
        }
        .font(.title)
        .padding()
    }
}

struct ContentView: View {
    func formatDate(date: String) -> String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
         guard let formattedDate = dateFormatter.date(from: date) else {
             return "Invalid Date"
         }
         dateFormatter.dateFormat = "MMM dd"
         return dateFormatter.string(from: formattedDate)
     }
    
    @State private var showingActivitySheet = false
    @State private var showingHistorySheet = false


    @EnvironmentObject private var workoutService: WorkoutService
    var body: some View {
        let userData = UserDefaults.standard.value(forKey: "user") as? Data
        let user = try? PropertyListDecoder().decode(User.self, from: userData ?? Data())
        

        NavigationStack {

            ScrollView(showsIndicators: false){
                UserInfo(user: user)
                HStack {
                    Button("History") {
                        showingHistorySheet.toggle()
                    }.buttonStyle(.borderedProminent)
                    .sheet(isPresented: $showingHistorySheet) {
                        HistorySheetView()
                    }
                    Button("Activities") {
                        showingActivitySheet.toggle()
                    }.buttonStyle(.borderedProminent)
                    .sheet(isPresented: $showingActivitySheet) {
                        ActivitySheetView()
                    }
                        
                }
                
                Spacer(minLength: 40)
                    
                VStack(alignment: .leading) {
                    //  upcoming
                    Text("Upcoming")
                        .font(.system(size:24))
                    ForEach(workoutService.workouts.prefix(3), id: \.id) { workout in
                        NavigationLink(value: workout) {
                            HStack {
                                Text(workout.title)
                                Spacer()
                                Text(formatDate(date:workout.date))
                            }
                            .padding(25)
                            .background(Color("Paper"))
                            .cornerRadius(5)
                        }
                        .navigationDestination(for: Workout.self) { workout in
                            WorkoutDetailView(workout: workout)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }

                Spacer(minLength: 40)


                VStack(alignment: .leading) {
                    
                    Text("Stats")
                        .font(.system(size:24))
                    Grid {
                        GridRow {
                            VStack {
                                Text("\(workoutService.userStats.filter({ $0.id == user?.id }).first?.completedWorkouts ?? 0)")
                                      .font(.system(size:24))
                                      .bold()
                                Text("workouts")
                            }
                            .padding(4)
                            VStack {
                                Text("\(workoutService.userStats.filter({ $0.id == user?.id }).first?.coldPlunges ?? 0)")                                    .font(.system(size:24))
                                    .bold()
                                Text("cold plunges")
                            }
                            .padding(4)
                            VStack {
                                Text("\(workoutService.userStats.filter({ $0.id == user?.id }).first?.cardioSessions ?? 0)")                                    .font(.system(size:24))
                                    .bold()
                                Text("cardio")
                            }
                            .padding(4)
                        }
                        .frame(minWidth: 0, maxWidth: .infinity)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                }
                Spacer(minLength: 40)
                VStack(alignment: .leading) {
                    
                    Text("Leaderboard")
                        .font(.system(size:24))
                    VStack{
                        let maxTotalPoints = workoutService.userStats.map({ $0.totalPoints }).max() ?? 0
                        ForEach(workoutService.userStats.sorted(by: { $0.totalPoints > $1.totalPoints }).prefix(3), id: \.id) { user in
                            VStack(alignment: .leading){
                                HStack{
                                    Text("\(user.username)")
                                        .bold()
                                    Text("\(user.totalPoints) points")
                                }
                                ProgressView(value: Double(user.totalPoints), total: Double(maxTotalPoints))
                                    .progressViewStyle(.linear)
                                    .accentColor(Color(.green))
                                    .scaleEffect(x:1, y:2)

                            }.padding(10)
                        }
                    }
                    
                }
                
                

            }
            .frame(minHeight:0, maxHeight: .infinity, alignment: .top)
            .padding(20)
            .task {
                try? await workoutService.getUserStatsList()

                try? await workoutService.getWorkoutList(userId:user?.id)
            }
  
        }

    }
}
struct UserInfo: View {
    @EnvironmentObject private var workoutService: WorkoutService
    
    var user: User?
    
    var body: some View {
        HStack () {
            Image("bigwipes")
                .resizable()
                .frame(width:64, height:64)
                .background(Color("Paper"))
                .clipShape(Circle())
                .padding(.trailing, 20)
            VStack (alignment: .leading){
                Text(user?.username ?? "eppler97")
                    .bold()
                    .font(.system(size:24))
                Text("\(workoutService.userStats.filter({ $0.id == user?.id }).first?.totalPoints ?? 0) points")                        }
        }
        .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
    }
}
struct ContentView_Previews: PreviewProvider {
    
    static var previews: some View {
        ContentView()
            .environmentObject(WorkoutService())
    }
}
