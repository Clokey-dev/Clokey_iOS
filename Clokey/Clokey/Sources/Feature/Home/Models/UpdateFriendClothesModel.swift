//
//  UpdateFriendClothesModel.swift
//  Clokey
//
//  Created by 한금준 on 1/18/25.
//



import Foundation

struct UpdateFriendClothesModel {
    let profileImage: URL // URL 타입으로 변경
    let name: String
    let date: String
    let clothingImages: [URL] // URL 배열로 변경
}

extension UpdateFriendClothesModel {
    static func dummy() -> [UpdateFriendClothesModel] {
        return [
            UpdateFriendClothesModel(
                profileImage: URL(string: "https://www.example.com/profile_icon.jpg")!,
                name: "티라미수케이크",
                date: "24.11.09",
                clothingImages: [
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!,
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!,
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!
                ]
            ),
            UpdateFriendClothesModel(
                profileImage: URL(string: "https://www.example.com/profile_icon.jpg")!,
                name: "닉네임",
                date: "날짜",
                clothingImages: [
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!,
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!,
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!
                ]
            ),
            UpdateFriendClothesModel(
                profileImage: URL(string: "https://www.example.com/profile_icon.jpg")!,
                name: "닉네임",
                date: "날짜",
                clothingImages: [
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!,
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!,
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!
                ]
            ),
            UpdateFriendClothesModel(
                profileImage: URL(string: "https://www.example.com/profile_icon.jpg")!,
                name: "닉네임",
                date: "날짜",
                clothingImages: [
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!,
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!,
                    URL(string: "https://www.muji.com/wp-content/uploads/sites/12/2021/02/026.jpg")!
                ]
            )
        ]
    }
}
