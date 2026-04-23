import SwiftUI
import FirebaseFirestore

// MARK: - Explore (Placeholder)

struct ExploreView: View {
    var body: some View {
        NavigationStack {
            EmptyStateView(
                icon: "map.fill",
                title: "Explore All Stations",
                subtitle: "Browse wine bars by metro line — coming soon."
            )
            .navigationTitle("Explore")
        }
    }
}

// MARK: - Favorites

struct FavoritesView: View {
    @ObservedObject private var favorites = FavoritesManager.shared
    private let allBars = SampleData.wineBars

    private var favoriteBars: [WineBar] {
        favorites.favorites(from: allBars)
    }

    var body: some View {
        NavigationStack {
            Group {
                if favoriteBars.isEmpty {
                    emptyState
                } else {
                    favoritesList
                }
            }
            .navigationTitle("Favorites")
            .background(Color(.systemGroupedBackground))
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.rosé.opacity(0.7))
            Text("No Saved Bars Yet")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.burgundy)
            Text("Tap the ♡ on any wine bar to save it here for later.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Favorites List

    private var favoritesList: some View {
        ScrollView {
            VStack(spacing: 14) {
                ForEach(favoriteBars) { bar in
                    FavoriteBarRow(bar: bar)
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
    }
}

// MARK: - Favorite Bar Row

struct FavoriteBarRow: View {
    let bar: WineBar
    @ObservedObject private var favorites = FavoritesManager.shared

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(AppTheme.burgundy.opacity(0.12))
                    .frame(width: 50, height: 50)
                Image(systemName: bar.imageSystemName)
                    .foregroundStyle(AppTheme.wine)
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(bar.name)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(bar.subtitle)
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
                    .lineLimit(1)
                HStack(spacing: 8) {
                    Label("\(bar.rating, specifier: "%.1f")", systemImage: "star.fill")
                        .font(.caption.bold())
                        .foregroundStyle(AppTheme.gold)
                    Text("·")
                        .foregroundStyle(AppTheme.subtleText)
                    Label(bar.nearestStation, systemImage: "tram.fill")
                        .font(.caption)
                        .foregroundStyle(AppTheme.subtleText)
                }
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    favorites.toggle(bar)
                }
            } label: {
                Image(systemName: "heart.fill")
                    .foregroundStyle(AppTheme.rosé)
                    .font(.title3)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

// MARK: - Profile (Placeholder)

struct ProfileView: View {
    @StateObject private var auth = AuthService.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if auth.currentUser == nil {
                    SignInView()
                } else {
                    UserProfileView()
                }
            }
            .navigationTitle("Profile")
        }
    }
}

// MARK: - Sign In View

struct SignInView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "wineglass.fill")
                .font(.system(size: 60))
                .foregroundStyle(AppTheme.wine)
            Text("Wine on the Line")
                .font(.title.bold())
                .foregroundStyle(AppTheme.burgundy)
            Text("Sign in to write reviews and track your favourite wine bars")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            GoogleSignInButton()
            Spacer()
        }
    }
}

// MARK: - Google Sign In Button

struct GoogleSignInButton: View {
    var body: some View {
        Button {
            Task {
                guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                      let vc = scene.windows.first?.rootViewController else { return }
                try? await AuthService.shared.signInWithGoogle(presenting: vc)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "globe")
                    .font(.title3)
                Text("Sign in with Google")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppTheme.burgundy)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - User Profile View

struct UserProfileView: View {
    @StateObject private var auth = AuthService.shared
    @State private var showEditProfile = false
    @State private var visitedBars: [UserReview] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHeader
                if auth.userProfile != nil {
                    myReviewsSection
                } else {
                    setupProfileBanner
                }
            }
            .padding()
        }
        .onAppear {
            fetchMyReviews()
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Sign Out") {
                    auth.signOut()
                }
                .foregroundStyle(AppTheme.subtleText)
            }
        }
    }
    
    private func fetchMyReviews() {
        guard let username = auth.userProfile?.username else { return }
        let db = Firestore.firestore()
        db.collection("reviews")
            .whereField("authorName", isEqualTo: username)
            .order(by: "date", descending: true)
            .addSnapshotListener { snapshot, _ in
                guard let documents = snapshot?.documents else { return }
                self.visitedBars = documents.compactMap { try? $0.data(as: UserReview.self) }
            }
    }
    
    private var profileHeader: some View {
        VStack(spacing: 12) {
            if let urlString = auth.userProfile?.profileImageURL,
               let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable()
                        .scaledToFill()
                } placeholder: {
                    Circle().fill(AppTheme.champagne)
                }
                .frame(width: 90, height: 90)
                .clipShape(Circle())
                .overlay(Circle().stroke(AppTheme.wine, lineWidth: 2))
            } else {
                Circle()
                    .fill(AppTheme.champagne)
                    .frame(width: 90, height: 90)
                    .overlay(
                        Image(systemName: "person.fill")
                            .font(.largeTitle)
                            .foregroundStyle(AppTheme.wine)
                    )
            }
            
            if let username = auth.userProfile?.username {
                Text(username)
                    .font(.title3.bold())
                    .foregroundStyle(AppTheme.burgundy)
            } else {
                Text(auth.currentUser?.email ?? "")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtleText)
            }
            
            Button {
                showEditProfile = true
            } label: {
                Text("Edit Profile")
                    .font(.caption.bold())
                    .foregroundStyle(AppTheme.wine)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppTheme.wine, lineWidth: 1)
                    )
            }
        }
    }
    
    private var setupProfileBanner: some View {
        VStack(spacing: 12) {
            Text("Set up your profile")
                .font(.headline)
                .foregroundStyle(AppTheme.burgundy)
            Text("Add a username and photo so your friends know who's reviewing!")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
                .multilineTextAlignment(.center)
            Button {
                showEditProfile = true
            } label: {
                Text("Set Up Profile")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppTheme.burgundy)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
    
    private var myReviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Reviews")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.burgundy)
            if visitedBars.isEmpty {
                Text("You haven't reviewed any bars yet!")
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.subtleText)
            } else {
                ForEach(visitedBars, id: \.id) { review in
                    HStack(spacing: 12) {
                        Image(systemName: "wineglass.fill")
                            .foregroundStyle(AppTheme.wine)
                            .font(.title3)
                            .frame(width: 40, height: 40)
                            .background(AppTheme.champagne)
                            .clipShape(Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(review.barName)
                                .font(.headline)
                            HStack(spacing: 2) {
                                ForEach(0..<review.rating, id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.caption2)
                                        .foregroundStyle(AppTheme.gold)
                                }
                            }
                            Text(review.text)
                                .font(.caption)
                                .foregroundStyle(AppTheme.subtleText)
                                .lineLimit(2)
                        }
                        Spacer()
                        Text(review.formattedDate)
                            .font(.caption2)
                            .foregroundStyle(AppTheme.subtleText)
                    }
                    .padding()
                    .background(AppTheme.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
// MARK: - Edit Profile View

struct EditProfileView: View {
    @StateObject private var auth = AuthService.shared
    @State private var username = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isSaving = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Button {
                    showImagePicker = true
                } label: {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 90, height: 90)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(AppTheme.wine, lineWidth: 2))
                    } else {
                        Circle()
                            .fill(AppTheme.champagne)
                            .frame(width: 90, height: 90)
                            .overlay(
                                Image(systemName: "camera.fill")
                                    .foregroundStyle(AppTheme.wine)
                                    .font(.title2)
                            )
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Username")
                        .font(.subheadline.bold())
                    TextField("Enter username", text: $username)
                        .padding()
                        .background(AppTheme.secondaryBackground)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                
                Button {
                    Task { await saveProfile() }
                } label: {
                    if isSaving {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(AppTheme.burgundy)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    } else {
                        Text("Save Profile")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(username.isEmpty ? AppTheme.subtleText : AppTheme.burgundy)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .disabled(username.isEmpty || isSaving)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(image: $selectedImage)
            }
            .onAppear {
                username = auth.userProfile?.username ?? ""
            }
        }
    }
    
    private func saveProfile() async {
        isSaving = true
        var imageURL = auth.userProfile?.profileImageURL
        
        if let image = selectedImage, let uid = auth.currentUser?.uid {
            imageURL = try? await ProfileImageService.shared.uploadProfileImage(image, userID: uid)
        }
        
        let profile = UserProfile(
            username: username,
            profileImageURL: imageURL
        )
        auth.saveProfile(profile)
        isSaving = false
        dismiss()
    }
}

// MARK: - Image Picker

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            picker.dismiss(animated: true)
        }
    }
}
// MARK: - Empty State

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.rosé)
            Text(title)
                .font(.title3.bold())
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
