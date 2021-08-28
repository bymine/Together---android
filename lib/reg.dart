//정규식 표현
final regEmail = RegExp(r'^[a-zA-Z0-9]+$');
final regNickname = RegExp(r'^[가-힣a-zA-Z0-9]+$');
final regName = RegExp(r'^[가-힣]+$');
final regPhone = RegExp(r'^[0-9]+$');
final regPassword = RegExp(
    r"^(?=.*[A-Za-z])(?=.*\\d)(?=.*[$@$!%*#?&])[A-Za-z\\d$@$!%*#?&]{8,16}$");
