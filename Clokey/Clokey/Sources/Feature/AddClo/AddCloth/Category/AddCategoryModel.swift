struct AddCategoryModel {
    let name: String
    let buttons: [String]

    static let allCategories: [AddCategoryModel] = [
        AddCategoryModel(
            name: "상의",
            buttons: ["티셔츠", "니트/스웨터", "맨투맨", "후드티", "셔츠/블라우스", "반팔티", "나시", "기타"]
        ),
        AddCategoryModel(
            name: "하의",
            buttons: ["청바지", "반바지", "트레이닝/조거팬츠", "면바지", "슈트팬츠/슬랙스", "레깅스", "미니스커트", "미디스커트", "롱스커트", "원피스", "투피스", "기타"]
        ),
        AddCategoryModel(
            name: "아우터",
            buttons: ["숏패딩/헤비 아우터", "무스탕/퍼", "후드집업", "점퍼/바람막이", "가죽자켓", "청자켓", "슈트/블레이저", "가디건", "아노락", "후리스/양털", "코트", "롱패딩", "패딩조끼", "기타"]
        ),
        AddCategoryModel(
            name: "기타",
            buttons: ["신발", "가방", "모자", "머플러", "시계", "양말/레그웨어", "주얼리", "벨트", "선글라스/안경", "기타"]
        )
    ]
    
    static func getCategory(at index: Int) -> AddCategoryModel? {
        guard index >= 0, index < allCategories.count else { return nil }
        return allCategories[index]
    }
}
