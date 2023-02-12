//
//  WorkoutDetailView.swift
//  Onslaught
//
//  Created by Bryce Eppler on 2023-02-12.
//

import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    var formattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        guard let formattedDate = dateFormatter.date(from: workout.date) else {
            return "Invalid Date"
        }
        dateFormatter.dateFormat = "MMM dd"
        return dateFormatter.string(from: formattedDate)
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Title: \(workout.title)")
            Text("Date: \(formattedDate)")
            ScrollView{
                Text(workout.workout_str!)
            }
            HStack (alignment:.center) {
                Button(action: {
                    // skip
                }) {
                    Text("Skip")
                        .foregroundColor(.white)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                }
                Button(action: {
                    // add action for complete button here
                }) {
                    Text("Complete")
                        .foregroundColor(.white)
                        .padding()
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(10)
                }
            }
            .frame(minWidth:0, maxWidth:.infinity)
            
            
        }
        .padding()
    }

}

struct WorkoutDetailView_Previews: PreviewProvider {
    static var previews: some View {
        WorkoutDetailView(workout: Workout(id:1, title:"Sample Workout", workout_number: 1, workout_str: #"""
Single Handle pushdowns
This week we are using the single handles, tons of wrist freedom and great way to pump the tris. Once you find a good working weight, nail 4 sets of 10.
Total Work Sets: 4
Goal: Activate and Supramax pump
RPE: 9
Video: https://www.youtube.com/watch?v=QMVRFB83CSk

Dumbell pronated kick backs
Control the negative, and then ram the dumbells up. 4 sets of 8 reps and your tris will be jacked up.
Total Work Sets: 4 Goal: Supramax pump RPE: 9
Video:      https://www.youtube.com/watch?v=WQRJacR4tuc

Pushdown on assisted chin machine
Just when you thought your tris were going to explode, lets tack on 4 more sets of pushdowns for sets of 12-15.
Total Work Sets: 4 Goal: Supramax pump RPE: 9
Video: https://www.youtube.com/watch?v=LLQPUECpGaU

Biceps
E-Z bar curls
After 3-4 warm up, bang out 3 working sets of 8 to get some blood into the biceps.
Total Work Sets: 3 Goal: Supramax pump RPE: 9

Dumbell preacher curls
Some single arm curling here, go down slow and squeeze hard at the top.
Total Work Sets: 3 Goal: Supramax pump RPE: 9-10
Pinwheel curls
Another single arm movement that will take your pump to the next level. 3 sets of 10 to finish.
Total Work Sets: 3 Goal: Supramax pump RPE: 9-10
"""#, date: "2023-03-23T05:26:28.540Z"))
    }
}
