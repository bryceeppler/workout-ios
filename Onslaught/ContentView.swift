import SwiftUI

struct Workout: Codable {
    var id: Int
    var title: String
    var workout_number: Int
    var workout_str: String?
    var date: String
}


struct ContentView: View {
    @State private var workouts: [Workout] = []
    func formatDate(date: String) -> String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
         guard let formattedDate = dateFormatter.date(from: date) else {
             return "Invalid Date"
         }
         dateFormatter.dateFormat = "MMM dd"
         return dateFormatter.string(from: formattedDate)
     }
    
    


    var body: some View {
        let userData = UserDefaults.standard.value(forKey: "user") as? Data
        let user = try? PropertyListDecoder().decode(User.self, from: userData ?? Data())

        NavigationView{
            VStack (alignment: .leading, spacing: 20) {
                //  username
                HStack () {
                    Image("bigwipes")
                        .resizable()
                        .frame(width:64, height:64)
                        .background(Color("Paper"))
                        .clipShape(Circle())
                        .padding(.trailing, 20)
                    VStack (alignment: .leading){
                        Text(user?.username ?? "")
                            .bold()
                            .font(.system(size:24))
                        Text("45 points")
                    }
                }
                .frame(minWidth:0, maxWidth: .infinity, alignment: .leading)
                
                //  upcoming
                Text("Upcoming")
                    .font(.system(size:24))
                ForEach(workouts.prefix(3), id: \.id) { workout in
                    NavigationLink(destination: WorkoutDetailView(workout:workout)) {
                        HStack {
                            Text(workout.title)
                            Spacer()
                            Text(formatDate(date:workout.date))
                        }
                        .padding(25)
                        .background(Color("Paper"))
                        .cornerRadius(5)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .frame(minHeight:0, maxHeight: .infinity, alignment: .top)
            .padding(20)
            .onAppear(perform: loadWorkouts)
        }
    }
    private func loadWorkouts() {
        let url = URL(string: "http://10.0.0.101:3000/workouts/")!
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                if let workouts = try? decoder.decode([Workout].self, from: data) {
                    DispatchQueue.main.async {
                        self.workouts = workouts
                    }
                    for workout in workouts {
                        print(workout.date)
                    }
                } else {
                    print("err decoding json")
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
