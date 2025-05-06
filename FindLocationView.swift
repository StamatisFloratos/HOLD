import SwiftUI

struct FindLocationView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 40) {
                FindLocationScreen()
                FeelSensationScreen()
                LearnHowToUseScreen()
            }
            .padding(.vertical)
        }
        .background(Color(.systemBackground))
    }
}

// Screen 1
struct FindLocationScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image("find_location") // Replace with your actual asset name
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            Text("Find Location")
                .font(.title2)
                .fontWeight(.bold)
            Text("PF muscles are located between the pubic and the tailbone they control and support your penis.")
                .font(.body)
        }
        .padding()
    }
}

// Screen 2
struct FeelSensationScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image("feel_sensation") // Replace with your actual asset name
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            Text("Feel the Sensation")
                .font(.title2)
                .fontWeight(.bold)
            Text("When you contract the right muscles, you'll feel a lift at the base of your penis and a squeeze near the anus.")
                .font(.body)
        }
        .padding()
    }
}

// Screen 3
struct LearnHowToUseScreen: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image("learn_how_to_use") // Replace with your actual asset name
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
            Text("Learn How to Use")
                .font(.title2)
                .fontWeight(.bold)
            Text("Imagine you're peeing and you suddenly try to stop midstream. The muscles you just used? That's your pelvic floor. That's what we're here to train.")
                .font(.body)
        }
        .padding()
    }
}

struct FindLocationView_Previews: PreviewProvider {
    static var previews: some View {
        FindLocationView()
    }
} 