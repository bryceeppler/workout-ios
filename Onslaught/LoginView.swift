import SwiftUI


struct User: Codable {
    var id: Int
    var username: String
}

struct LoginView: View {
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var isSuccess = false
    
    
    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .padding()
                .background(Color("Paper"))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color("Paper"))
                .cornerRadius(5.0)
                .padding(.bottom, 20)
            
            Button(action: {
                self.isLoading = true
                self.login()
            }) {
                Text("Login")
            }
            .disabled(isLoading)
            .padding()
            
            
            if isLoading {
                ActivityIndicator(isAnimating: isLoading, style: .large)
            }
        }
        .padding()
    }
    
    private func login() {
        guard let url = URL(string: "http://10.0.0.101:3000/login") else {
            return
        }
        
        let parameters = ["username": username, "password": password]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters)
        URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 {
                    self.isLoading = false
                    self.isSuccess = true

                    do {
                        let user = try JSONDecoder().decode(User.self, from: data)
                        UserDefaults.standard.set(try? PropertyListEncoder().encode(user), forKey: "user")

                        DispatchQueue.main.async {
                            self.username = ""
                            self.password = ""
                            self.isSuccess = false
                        }
                        if self.isSuccess {
                            DispatchQueue.main.async {
                                self.navigateToContentView()
                            }
                        }
                    } catch {
                        print("Error decoding user: \(error.localizedDescription)")
                    }
                } else {
                    self.isLoading = false
                    print("Error: \(error?.localizedDescription ?? "")")
                }
   
        }.resume()
    }
    private func navigateToContentView() {
        let contentView = ContentView()
        let keyWindow = UIApplication.shared.connectedScenes
          .filter({$0.activationState == .foregroundActive})
          .map({$0 as? UIWindowScene})
          .compactMap({$0})
          .first?.windows
          .filter({$0.isKeyWindow}).first
        keyWindow?.rootViewController = UIHostingController(rootView: contentView)
    }
}

struct ActivityIndicator: UIViewRepresentable {
    typealias UIViewType = UIActivityIndicatorView
    let isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}


struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
