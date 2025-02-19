////
////  AddProfileViewModel.swift
////  Clokey
////
////  Created by 소민준 on 1/26/25.
////
//
//
//import Foundation
//
//final class AddProfileViewModel {
//    
//    // 사용자 정보 저장 (메모리에서 관리)
//    private var userInfo: ProfileRequest?
//    
//    // MARK: - Methods
//    //  사용자가 프로필을 완료하고 가입 정보를 처리하는 메서드
//    func handleUserSignUp(profileData: ProfileRequest, completion: @escaping (Bool, String) -> Void) {
//        //  일단 사용자 정보 로컬에 저장
//        self.userInfo = profileData
//        
//        //  디버깅용 출력 (JSON 확인)
//        do {
//            let jsonData = try JSONEncoder().encode(profileData)
//            if let jsonString = String(data: jsonData, encoding: .utf8) {
//                print("📡 준비된 API 요청 데이터:\n\(jsonString)")
//            }
//        } catch {
//            print("🚨 JSON 인코딩 오류:", error.localizedDescription)
//        }
//
//        //  실제 서버 요청 코드 (현재는 서버 연결 안 하므로 주석 처리)
//        /*
//        let url = URL(string: "https://yourapi.com/profile")! // 서버 URL 변경 필요
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try? JSONEncoder().encode(profileData)
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("🚨 네트워크 오류:", error.localizedDescription)
//                completion(false, "네트워크 오류 발생")
//                return
//            }
//            
//            guard let data = data else {
//                print("🚨 응답 데이터 없음")
//                completion(false, "서버에서 응답이 없습니다.")
//                return
//            }
//            
//            do {
//                let response = try JSONDecoder().decode(ProfileResponse.self, from: data)
//                if response.isSuccess {
//                    print(" 프로필 설정 완료:", response.message)
//                    completion(true, "프로필 설정 완료")
//                } else {
//                    print("🚨 서버 오류:", response.message)
//                    completion(false, response.message)
//                }
//            } catch {
//                print("🚨 JSON 디코딩 오류:", error.localizedDescription)
//                completion(false, "서버 응답을 처리할 수 없습니다.")
//            }
//        }
//        task.resume()
//        */
//
//        //  서버 요청 없이 성공 처리 (테스트용)
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            completion(true, "프로필 설정 완료")
//        }
//    }
//    
//    //  사용자 정보 확인 (디버깅 용도)
//    func getUserInfo() -> ProfileRequest? {
//        return userInfo
//    }
//}
