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
    
    
    @EnvironmentObject private var workoutService: WorkoutService
    var body: some View {
        let userData = UserDefaults.standard.value(forKey: "user") as? Data
        let user = try? PropertyListDecoder().decode(User.self, from: userData ?? Data())
        

        NavigationStack {

            ScrollView(showsIndicators: false){
                UserInfo(user: user)
                
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
