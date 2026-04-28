//
//  FriendsView.swift
//  want-space
//
//  Created by Amna on 2026-04-28.
//

import SwiftUI

struct FriendsView: View {
    @StateObject private var friendsService = FriendsService.shared
    @StateObject private var auth = AuthService.shared
    @State private var searchText = ""
    @State private var showInviteSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if auth.currentUser == nil {
                    notSignedInView
                } else {
                    friendsContent
                }
            }
            .navigationTitle("Friends")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showInviteSheet = true
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .foregroundStyle(AppTheme.burgundy)
                    }
                }
            }
            .sheet(isPresented: $showInviteSheet) {
                AddFriendView()
            }
            .onAppear {
                friendsService.fetchFriends()
                friendsService.fetchPendingRequests()
            }
        }
    }

    private var notSignedInView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "person.2.slash")
                .font(.system(size: 56))
                .foregroundStyle(AppTheme.rosé)
            Text("Sign in to add friends")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.burgundy)
            Text("Go to your Profile tab to sign in first")
                .font(.subheadline)
                .foregroundStyle(AppTheme.subtleText)
            Spacer()
        }
    }

    private var friendsContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if !friendsService.pendingRequests.isEmpty {
                    pendingRequestsSection
                }
                friendsListSection
            }
            .padding()
        }
    }

    private var pendingRequestsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Friend Requests")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.burgundy)
            ForEach(friendsService.pendingRequests) { request in
                FriendRequestRow(request: request)
            }
        }
    }

    private var friendsListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("My Friends")
                .font(.title3.bold())
                .foregroundStyle(AppTheme.burgundy)
            if friendsService.friends.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "person.2")
                        .font(.system(size: 40))
                        .foregroundStyle(AppTheme.rosé.opacity(0.7))
                    Text("No friends yet — add some!")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.subtleText)
                    Button {
                        showInviteSheet = true
                    } label: {
                        Text("Add Friends")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(AppTheme.burgundy)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                ForEach(friendsService.friends) { friend in
                    FriendRow(friend: friend)
                }
            }
        }
    }
}

// MARK: - Friend Request Row

struct FriendRequestRow: View {
    let request: FriendRequest
    @StateObject private var friendsService = FriendsService.shared

    var body: some View {
        HStack {
            Circle()
                .fill(AppTheme.champagne)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(AppTheme.wine)
                )
            VStack(alignment: .leading, spacing: 2) {
                Text(request.fromUsername)
                    .font(.headline)
                Text("wants to be your friend")
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
            }
            Spacer()
            HStack(spacing: 8) {
                Button {
                    friendsService.acceptRequest(request)
                } label: {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.metroGreen)
                }
                Button {
                    friendsService.declineRequest(request)
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.rosé)
                }
            }
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

// MARK: - Friend Row

struct FriendRow: View {
    let friend: FriendProfile

    var body: some View {
        HStack(spacing: 14) {
            if let urlString = friend.profileImageURL, let url = URL(string: urlString) {
                AsyncImage(url: url) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(AppTheme.champagne)
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(AppTheme.champagne)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundStyle(AppTheme.wine)
                    )
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(friend.username)
                    .font(.headline)
                Text("Wine enthusiast")
                    .font(.caption)
                    .foregroundStyle(AppTheme.subtleText)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(AppTheme.subtleText)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

// MARK: - Add Friend View

struct AddFriendView: View {
    @StateObject private var friendsService = FriendsService.shared
    @StateObject private var auth = AuthService.shared
    @State private var searchText = ""
    @State private var showShareSheet = false
    @State private var inviteLink = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Search by username
                VStack(alignment: .leading, spacing: 8) {
                    Text("Search by username")
                        .font(.headline)
                        .foregroundStyle(AppTheme.burgundy)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(AppTheme.subtleText)
                        TextField("Enter username...", text: $searchText)
                            .onChange(of: searchText) { _ in
                                friendsService.searchUsers(by: searchText)
                            }
                    }
                    .padding(10)
                    .background(AppTheme.secondaryBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                    ForEach(friendsService.searchResults) { user in
                        if user.id != auth.currentUser?.uid {
                            SearchUserRow(user: user)
                        }
                    }
                }

                Divider()

                // Share invite link
                VStack(alignment: .leading, spacing: 8) {
                    Text("Invite via link")
                        .font(.headline)
                        .foregroundStyle(AppTheme.burgundy)
                    Text("Share your personal invite link with friends")
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.subtleText)
                    Button {
                        inviteLink = friendsService.generateInviteLink()
                        showShareSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "link")
                            Text("Share Invite Link")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppTheme.burgundy)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Add Friends")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheet(items: [inviteLink])
            }
        }
    }
}

// MARK: - Search User Row

struct SearchUserRow: View {
    let user: UserProfile
    @StateObject private var friendsService = FriendsService.shared
    @State private var requestSent = false

    var body: some View {
        HStack {
            Circle()
                .fill(AppTheme.champagne)
                .frame(width: 44, height: 44)
                .overlay(
                    Image(systemName: "person.fill")
                        .foregroundStyle(AppTheme.wine)
                )
            Text(user.username)
                .font(.headline)
            Spacer()
            Button {
                friendsService.sendFriendRequest(to: user)
                requestSent = true
            } label: {
                Text(requestSent ? "Sent!" : "Add")
                    .font(.caption.bold())
                    .foregroundStyle(requestSent ? AppTheme.subtleText : .white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(requestSent ? AppTheme.secondaryBackground : AppTheme.burgundy)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
            }
            .disabled(requestSent)
        }
        .padding()
        .background(AppTheme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 3)
    }
}

// MARK: - Share Sheet

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
