//얘넨 카테고리 버튼에 해당하는 내용들 걍 다 적어둔 Model입니다. 카테고리 버튼 관련해서는 얘네만 계속 재사용할 거 같아요
struct CustomCategoryModel {
    let name: String
    let categoryId: Int
    let buttons: [(title: String, categoryId: Int)]

    static func getCategories(for index: Int) -> CustomCategoryModel? {
        
        switch index {
        case 1:
            return CustomCategoryModel(
                name: "상의",
                categoryId: 1,
                buttons: [
                    ("티셔츠", 5), ("니트/스웨터", 6), ("맨투맨", 7), ("후드티", 8),
                    ("셔츠/블라우스", 9), ("반팔티", 10), ("나시", 11), ("기타", 12)
                ]
            )
        case 2:
            return CustomCategoryModel(
                name: "하의",
                categoryId: 2,
                buttons: [
                    ("청바지", 13), ("반바지", 14), ("트레이닝/조거팬츠", 15), ("면바지", 16),
                    ("슈트팬츠/슬랙스", 17), ("레깅스", 18), ("미니스커트", 19),
                    ("미디스커트", 20), ("롱스커트", 21), ("원피스", 22), ("투피스", 23), ("기타", 24)
                ]
            )
        case 3:
            return CustomCategoryModel(
                name: "아우터",
                categoryId: 3,
                buttons: [
                    ("숏패딩/헤비 아우터", 25), ("무스탕/퍼", 26), ("후드집업", 27),
                    ("점퍼/바람막이", 28), ("가죽자켓", 29), ("청자켓", 30),
                    ("슈트/블레이저", 31), ("가디건", 32), ("아노락", 33),
                    ("후리스/양털", 34), ("코트", 35), ("롱패딩", 36),
                    ("패딩조끼", 37), ("기타", 38)
                ]
            )
        case 4:
            return CustomCategoryModel(
                name: "기타",
                categoryId: 4,
                buttons: [
                    ("신발", 39), ("가방", 40), ("모자", 41), ("머플러", 42),
                    ("시계", 43), ("양말/레그웨어", 44), ("주얼리", 45),
                    ("벨트", 46), ("선글라스/안경", 47), ("기타", 48)
                ]
            )
        default:
            return nil
        }
    }
}
