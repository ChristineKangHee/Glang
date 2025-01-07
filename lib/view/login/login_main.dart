// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
//
// /*
// import 'package:firebase_auth/firebase_auth.dart'; 랑 충돌이 나고있다.
// 그래서 kakao.~~ 로 사용하여 오류가 나지 않게 함
//  */
// import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
//
// class LoginPage extends StatefulWidget {
//   const LoginPage({Key? key}) : super(key: key);
//
//   @override
//   _LoginPageState createState() => _LoginPageState();
// }
//
//
// class _LoginPageState extends State<LoginPage> {
//   final _usernameController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;  // 로딩 상태 관리 변수
//
//   // Firestore instance
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//   //////////////////////////////////////////////////////////////////////
//   ///////                    Google Sign-In                      ///////
//   //////////////////////////////////////////////////////////////////////
//
//   Future<UserCredential> signInWithGoogle() async {
//     await GoogleSignIn().signOut();  // 현재 로그인한 계정을 로그아웃
//     final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
//     final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;
//     final credential = GoogleAuthProvider.credential(
//       accessToken: googleAuth?.accessToken,
//       idToken: googleAuth?.idToken,
//     );
//     UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
//
//     // Firestore에 사용자 정보 저장
//     User? user = userCredential.user;
//     if (user != null) {
//       DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
//       DocumentSnapshot docSnapshot = await userDoc.get();
//
//       if (!docSnapshot.exists) {
//         // 문서가 존재하지 않으면 새로 생성
//         await userDoc.set({
//           'name': user.displayName,
//           'email': user.email,
//           'uid': user.uid,
//           'status_message': 'I promise to take the test honestly before GOD.',
//         }, SetOptions(merge: true));
//       } else {
//         // 문서가 존재하면 기존 상태 메시지를 가져옴
//         String statusMessage = docSnapshot['status_message'] ?? 'I promise to take the test honestly before GOD.';
//         await userDoc.set({
//           'name': user.displayName,
//           'email': user.email,
//           'uid': user.uid,
//           'status_message': statusMessage,
//         }, SetOptions(merge: true));
//       }
//     }
//     return userCredential;
//   }
//
//   // Firebase에 사용자 정보를 등록하는 함수
//   Future<void> _registerUserInFirebase(kakao.User kakaoUser) async {
//     final FirebaseAuth _auth = FirebaseAuth.instance;
//     final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//
//     // Firebase Auth에 사용자 등록
//     UserCredential userCredential = await _auth.signInAnonymously();
//     User? firebaseUser = userCredential.user;
//
//     if (firebaseUser != null) {
//       // Firestore에 사용자 정보 저장
//       DocumentReference userDoc = _firestore.collection('users').doc(firebaseUser.uid);
//       await userDoc.set({
//         'kakaoId': kakaoUser.id,
//         'email': kakaoUser.kakaoAccount?.email,
//         'name': kakaoUser.kakaoAccount?.profile?.nickname,
//         'uid': firebaseUser.uid,
//       }, SetOptions(merge: true));
//     }
//   }
//
//   //////////////////////////////////////////////////////////////////////
//   ///////                      이메일 로그인                        ///////
//   //////////////////////////////////////////////////////////////////////
//
//   Future<UserCredential?> signInWithEmailPassword(String email, String password) async {
//     try {
//       UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
//         email: email,
//         password: password,
//       );
//
//       User? user = userCredential.user;
//
//       if (user != null) {
//         // You can perform additional operations like saving user info to Firestore if necessary
//         print('로그인 성공: ${user.email}');
//         return userCredential;
//       }
//     } on FirebaseAuthException catch (e) {
//       // Error handling for Firebase authentication
//       if (e.code == 'user-not-found') {
//         print('No user found for that email.');
//       } else if (e.code == 'wrong-password') {
//         print('Wrong password provided.');
//       }
//     } catch (e) {
//       print('로그인 오류: $e');
//     }
//
//     return null;
//   }
//
//
//   //////////////////////////////////////////////////////////////////////
//   ///////                    Facebook Sign-In                    ///////
//   //////////////////////////////////////////////////////////////////////
//
//   Future<UserCredential?> signInWithFacebook() async {
//
//     try {
//       // Trigger the sign-in flow
//       final LoginResult loginResult = await FacebookAuth.instance.login();
//
//       // Check if login was successful
//       if (loginResult.status == LoginStatus.success && loginResult.accessToken != null) {
//         // Obtain the auth details from the request
//         final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);
//
//         // Sign in to Firebase with the Facebook credentials
//         UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(facebookAuthCredential);
//
//         // Get the logged-in user
//         User? user = userCredential.user;
//
//         // Store user data in Firestore if needed
//         if (user != null) {
//           DocumentReference userDoc = _firestore.collection('users').doc(user.uid);
//           DocumentSnapshot docSnapshot = await userDoc.get();
//
//           if (!docSnapshot.exists) {
//             // If document does not exist, create a new one
//             await userDoc.set({
//               'name': user.displayName,
//               'email': user.email,
//               'uid': user.uid,
//               'status_message': 'I promise to take the test honestly before GOD.',
//             }, SetOptions(merge: true));
//           }
//         }
//
//         return userCredential;
//       } else {
//         print('Facebook login failed: No access token received.');
//         return null;
//       }
//     } catch (e) {
//       print('Facebook login error: $e');
//       return null;
//     }
//   }
//
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     final appState = Provider.of<AppState>(context, listen: false);
//     var screenWidth = MediaQuery.of(context).size.width;
//     var screenHeight = MediaQuery.of(context).size.height;
//
//     //////////////////////////////////////////////////////////////////////
//     ///////            Google Login Function (Handler)             ///////
//     //////////////////////////////////////////////////////////////////////
//     Future<void> _handleSignIn() async {
//       setState(() {
//         _isLoading = true;  // 로딩 상태 활성화
//       });
//
//       try {
//         UserCredential userCredential = await signInWithGoogle();
//         User? user = userCredential.user;
//         if (user != null) {
//           print('로그인 성공: ${user.email}');
//           appState.setUser(user); // 앱 상태에 사용자 설정
//           Navigator.pushNamed(context, '/');
//         } else {
//           print('로그인 실패');
//         }
//       } catch (e) {
//         print('로그인 오류: $e');
//       } finally {
//         setState(() {
//           _isLoading = false;  // 로딩 상태 비활성화
//         });
//       }
//     }
//
//     return Scaffold(
//       body: SafeArea(
//         child: GestureDetector(
//           // GestureDetector를 통해 키보드 이외 영역 선택 시 키보드 사라짐 구현
//           onTap: () => FocusScope.of(context).unfocus(),
//           child: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: <Widget>[
//                 SizedBox(height: screenHeight * 0.2),
//                 //////////////////////////////////////////////////////////////////////
//                 ///////                       간편 로그인                         ///////
//                 //////////////////////////////////////////////////////////////////////
//                 // ****간편 로그인 아이콘****
//                 Container(
//                   width: screenWidth,
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       GestureDetector(
//                         child: Image.asset('assets/images/googleidcon.png'),
//                         onTap: () {
//                           // function 내용
//                           _handleSignIn();
//                         },
//                       ),
//                       SizedBox(width: 12,),
//                       GestureDetector(
//                         child: Image.asset('assets/images/appleicon.png'),
//                         onTap: () {
//                           // function 내용
//                         },
//                       ),
//                       SizedBox(width: 12,),
//
//
//                       GestureDetector(
//                         child: Image.asset('assets/images/kakaotalkicon.png'),
//                         onTap: () async {
//                           kakao.OAuthToken? token;
//                           // 카카오톡 실행 가능 여부 확인
//                           // 카카오톡 실행이 가능하면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
//                           if (await kakao.isKakaoTalkInstalled()) {
//                             try {
//                               kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoTalk();
//                               print('카카오톡으로 로그인 성공');
//                               var provider = OAuthProvider('oidc.kakao'); // 제공업체 id
//                               var credential = provider.credential(
//                                 idToken: token.idToken, // 카카오 로그인에서 발급된 idToken(카카오 설정에서 OpenID Connect가 활성화 되어있어야함)
//                                 accessToken: token.accessToken, // 카카오 로그인에서 발급된 accessToken
//                               );
//                               FirebaseAuth.instance.signInWithCredential(credential);
//                               if (context.mounted) {
//                                 Navigator.pushNamed(context, '/');
//                               }
//                             } catch (error) {
//                               print('카카오톡으로 로그인 실패 $error');
//
//                               // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
//                               // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
//                               if (error is PlatformException && error.code == 'CANCELED') {
//                                 return;
//                               }
//                               // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
//                               try {
//                                 kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoAccount();
//                                 print('카카오계정으로 로그인 성공');
//                                 var provider = OAuthProvider('oidc.kakao'); // 제공업체 id
//                                 var credential = provider.credential(
//                                   idToken: token.idToken, // 카카오 로그인에서 발급된 idToken(카카오 설정에서 OpenID Connect가 활성화 되어있어야함)
//                                   accessToken: token.accessToken, // 카카오 로그인에서 발급된 accessToken
//                                 );
//                                 FirebaseAuth.instance.signInWithCredential(credential);
//                                 if (context.mounted) {
//                                   Navigator.pushNamed(context, '/');
//                                 }
//                               } catch (error) {
//                                 print('카카오계정으로 로그인 실패 $error');
//                               }
//                             }
//                           } else {
//                             try {
//                               kakao.OAuthToken token = await kakao.UserApi.instance.loginWithKakaoAccount();
//                               print('카카오계정으로 로그인 성공');
//                               var provider = OAuthProvider('oidc.kakao'); // 제공업체 id
//                               var credential = provider.credential(
//                                 idToken: token.idToken, // 카카오 로그인에서 발급된 idToken(카카오 설정에서 OpenID Connect가 활성화 되어있어야함)
//                                 accessToken: token.accessToken, // 카카오 로그인에서 발급된 accessToken
//                               );
//                               FirebaseAuth.instance.signInWithCredential(credential);
//                               if (context.mounted) {
//                                 Navigator.pushNamed(context, '/');
//                               }
//                             } catch (error) {
//                               print('카카오계정으로 로그인 실패 $error');
//                             }
//                           }
//                         },
//                       ),
//
//
//                       // FaceBook Login 구현. 추후 사용 가능
//                       // GestureDetector(
//                       //   child: Image.asset('assets/images/facebookicon.png'),
//                       //   onTap: () async {
//                       //     setState(() {
//                       //       _isLoading = true;  // 로딩 상태 활성화
//                       //     });
//                       //
//                       //     try {
//                       //       UserCredential? userCredential = await signInWithFacebook();
//                       //
//                       //       if (userCredential != null) {
//                       //         print('로그인 성공: ${userCredential.user?.email}');
//                       //         appState.setUser(userCredential.user!); // Set the user in AppState
//                       //         Navigator.pushNamed(context, '/');
//                       //       } else {
//                       //         print('Facebook 로그인 실패');
//                       //       }
//                       //     } catch (e) {
//                       //       print('Facebook 로그인 오류: $e');
//                       //     } finally {
//                       //       setState(() {
//                       //         _isLoading = false;  // 로딩 상태 비활성화
//                       //       });
//                       //     }
//                       //   },
//                       // ),
//
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
