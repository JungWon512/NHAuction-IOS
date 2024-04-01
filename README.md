# NHAuction-iOS Release Note


## version 1.0.6
- build version 202302091730
- 관전모드 Native 화면 회전기능 추가 개발 
- 관전모드 회전기능 추가에 따른 화면회전버튼 추가로 그 옆에 스피커 버튼이랑 둘다 작게 변경 
- Firebase dynamicLink 추가 개발
- 웹뷰에서 관전,응찰 Native화면 들어갈때 연속 터치(클릭)시 소캣 중복 연결되던 이슈 해결 

## version 1.0.5
- build version 202205231450
- Code Warning 수정
- 관전모드 접속 시 상세정보 미노출 이슈 수정

## version 1.0.4
- build version 202204281500
- 관전 모드에서 "진행 중인 경매가 없습니다." 팝업 삭제. (경매 진행 전에도 접속은 가능해야 함.)
- 영상 개수 고정으로 4개씩 나오는 이슈 수정, KKO_SVC_CNT 타입이 String으로 되어있어 맞지 않아 Default 값인 4로 표시되고 있었던 것.
- WebView 3D Touched 비활성화 처리
- 실시간 경매/관전 화면 진입 시 스피커 상태 Default Off 처리
- 실시간 경매/관전 종료 시 KakaoConnect close 처리
- 관전 모드의 경우 찜 가격 API 미호출 처리
- 영상 onComplete 이벤트 발생 시 사운드 On/Off 처리하는 로직 추가 (default가 Off인 상태여도 사운드가 나오는 버그 수정)
- BaseWKWebView init 하는 경우 deleteCache 하도록 수정
- 실시간 경매 응찰 화면 내 기존 "취소" 버튼 텍스트 "응찰\n취소" 문구로 수정
- 실시간 경매 응찰 화면 내 기존 “←” 버튼 텍스트 “지움” 문구로 수정
- 실시간 경매 응찰 화면 내 "지움" 버튼 선택 시 입력된 경매 번호, 응찰 금액 삭제. (삭제 후 "0" 또는 "공백" 상태는 기존의 로직에 따름.)
- 실시간 경매/관전 화면 내 상단 스크롤 영역 Bounce, Indicator 비활성화 처리

## version 1.0.3
- build version 202204201430
- 관전모드 Native 화면 추가 개발
- 실시간/관전 모드 상단의 경매 정보 영역 Layout 구성 StackView로 변경
- 팝업 원버튼 attributedText 적용되지 않는 이슈 해결
- 스피커 이미지 수정, on/off 이미지 사이즈가 달라 버튼 선택 시 비정상적으로 보이는 이슈 해결
