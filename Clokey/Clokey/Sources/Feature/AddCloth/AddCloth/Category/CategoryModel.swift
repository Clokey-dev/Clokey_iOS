struct CategoryModel {
    let id: Int64 // 고유 숫자 아이디
    let name: String
    let buttons: [AddCategoryButton]

    struct AddCategoryButton {
        let id: Int64 // 버튼의 고유 숫자 아이디
        let name: String
    }

    static let allCategories: [CategoryModel] = [
        CategoryModel(
            id: 1,
            name: "상의",
            buttons: [
                AddCategoryButton(id: 5, name: "티셔츠"),
                AddCategoryButton(id: 6, name: "니트/스웨터"),
                AddCategoryButton(id: 7, name: "맨투맨"),
                AddCategoryButton(id: 8, name: "후드티"),
                AddCategoryButton(id: 9, name: "셔츠/블라우스"),
                AddCategoryButton(id: 10, name: "반팔티"),
                AddCategoryButton(id: 11, name: "나시"),
                AddCategoryButton(id: 12, name: "기타")
            ]
        ),
        CategoryModel(
            id: 2,
            name: "하의",
            buttons: [
                AddCategoryButton(id: 13, name: "청바지"),
                AddCategoryButton(id: 14, name: "반바지"),
                AddCategoryButton(id: 15, name: "트레이닝/조거팬츠"),
                AddCategoryButton(id: 16, name: "면바지"),
                AddCategoryButton(id: 17, name: "슈트팬츠/슬랙스"),
                AddCategoryButton(id: 18, name: "레깅스"),
                AddCategoryButton(id: 19, name: "미니스커트"),
                AddCategoryButton(id: 20, name: "미디스커트"),
                AddCategoryButton(id: 21, name: "롱스커트"),
                AddCategoryButton(id: 22, name: "원피스"),
                AddCategoryButton(id: 23, name: "투피스"),
                AddCategoryButton(id: 24, name: "기타")
            ]
        ),
        CategoryModel(
            id: 3,
            name: "아우터",
            buttons: [
                AddCategoryButton(id: 25, name: "숏패딩/헤비 아우터"),
                AddCategoryButton(id: 26, name: "무스탕/퍼"),
                AddCategoryButton(id: 27, name: "후드집업"),
                AddCategoryButton(id: 28, name: "점퍼/바람막이"),
                AddCategoryButton(id: 29, name: "가죽자켓"),
                AddCategoryButton(id: 30, name: "청자켓"),
                AddCategoryButton(id: 31, name: "슈트/블레이저"),
                AddCategoryButton(id: 32, name: "가디건"),
                AddCategoryButton(id: 33, name: "아노락"),
                AddCategoryButton(id: 34, name: "후리스/양털"),
                AddCategoryButton(id: 35, name: "코트"),
                AddCategoryButton(id: 36, name: "롱패딩"),
                AddCategoryButton(id: 37, name: "패딩조끼"),
                AddCategoryButton(id: 38, name: "기타")
            ]
        ),
        CategoryModel(
            id: 4,
            name: "기타",
            buttons: [
                AddCategoryButton(id: 39, name: "신발"),
                AddCategoryButton(id: 40, name: "가방"),
                AddCategoryButton(id: 41, name: "모자"),
                AddCategoryButton(id: 42, name: "머플러"),
                AddCategoryButton(id: 43, name: "시계"),
                AddCategoryButton(id: 44, name: "양말/레그웨어"),
                AddCategoryButton(id: 45, name: "주얼리"),
                AddCategoryButton(id: 46, name: "벨트"),
                AddCategoryButton(id: 47, name: "선글라스/안경"),
                AddCategoryButton(id: 48, name: "기타")
            ]
        )
    ]
    
    static func getCategory(at index: Int) -> CategoryModel? {
        guard index >= 0, index < allCategories.count else { return nil }
        return allCategories[index]
    }
}

//extension AddCategoryModel {
//    static func getCategoryByName(_ buttonName: String) -> (String, String)? {
//        for category in allCategories {
//            if let button = category.buttons.first(where: { $0.name == buttonName }) {
//                return (category.name, button.name)
//            }
//        }
//        return nil
//    }
//}

//extension AddCategoryModel {
//    static func getCategoryByName(_ userInput: String) -> (String, String)? {
//        let lowercasedInput = userInput.lowercased()
//
//        for category in allCategories {
//            if let button = category.buttons.first(where: { button in
//                let components = button.name.lowercased().split(separator: "/") //  '/' 기준으로 나누기
//                return components.contains { lowercasedInput.contains($0) } //  사용자 입력에서 키워드 포함 여부 검사
//            }) {
//                return (category.name, button.name)
//            }
//        }
//        return nil
//    }
//}

extension CategoryModel {
    static func getCategoryByName(_ userInput: String) -> (String, String, Int64)? {
        let lowercasedInput = userInput.lowercased()

        for category in allCategories {
            if let button = category.buttons.first(where: { button in
                let components = button.name.lowercased().split(separator: "/") //  '/' 기준으로 나누기
                return components.contains { lowercasedInput.contains($0) } //  사용자 입력에서 키워드 포함 여부 검사
            }) {
                return (category.name, button.name, button.id) //  id 값도 반환
            }
        }
        return nil
    }
}
