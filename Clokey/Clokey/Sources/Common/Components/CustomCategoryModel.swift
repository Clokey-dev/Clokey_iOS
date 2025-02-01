//얘넨 카테고리 버튼에 해당하는 내용들 걍 다 적어둔 Model입니다. 카테고리 버튼 관련해서는 얘네만 계속 재사용할 거 같아요
struct CustomCategoryModel {
    let name: String
    let buttons: [String]

    static func getCategories(for index: Int) -> CustomCategoryModel? {
        switch index {

        case 1:
            return CustomCategoryModel(
                name: "상의",
                buttons: ["티셔츠", "니트/스웨터", "맨투맨", "후드티", "셔츠/블라우스", "반팔티", "나시", "기타"]
                
            )
        case 2:
            return CustomCategoryModel(
                name: "하의",
                buttons: ["청바지", "반바지", "트레이닝/조거팬츠", "면바지", "슈트팬츠/슬랙스", "레깅스", "원피스", "투피스", "기타"]
            )
        case 3:
            return CustomCategoryModel(
                name: "아우터",
                buttons: ["숏패딩/헤비 아우터", "무스탕/퍼", "후드집업", "점퍼/바람막이", "가죽자켓", "청자켓", "슈트/블레이저 자켓", "가디건", "아노락", "후리스/양털","코드", "롱패딩", "패딩조끼", "기타"]
            )
        case 4:
            return CustomCategoryModel(
                name: "기타",
                buttons: ["신발", "가방", "모자", "머플러", "시계", "양말/레그웨어", "주얼리", "벨트", "선글라스/안경", "기타"]
            )
        default:
            return nil
        }
    }
}
