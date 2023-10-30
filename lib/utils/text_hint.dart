keywordHint(int idx) {
  switch (idx) {
    case 0:
      return '키워드';
    case 1:
      return '최대8자';
    case 2:
      return '        ';
    case 3:
      return '        ';
    case 4:
      return '        ';
    case 5:
      return '        ';
    case 6:
      return '        ';
    case 7:
      return '        ';
    case 8:
      return '        ';
    case 9:
      return '        ';
  }
}

searchType(idx) {
  switch (idx) {
    case 0:
      return '클래스';
    case 1:
      return '배움교환';
    case 2:
      return '배움모임';
  }
}

shareType(int idx) {
  switch (idx) {
    case 0:
      return 'FREE';
    case 1:
      return 'COFFEE';
    case 2:
      return 'TRAFFIC';
    case 3:
      return 'PLACE_COST';
    case 0:
      return 'NONE';
  }
}

shareTypeIdx(String? type) {
  switch (type) {
    case 'FREE':
      return 0;
    case 'COFFEE':
      return 1;
    case 'TRAFFIC':
      return 2;
    case 'PLACE_COST':
      return 3;
    case 'NONE':
      return 0;
    default:
      return 0;
  }
}

shareSelectText(int index) {
  switch (index) {
    case 0:
      return '💚 무료로 배움 나눔해요';
    case 1:
      return '☕ 커피값이면 돼요';
    case 2:
      return '🚘 교통비만 주세요';
    case 3:
      return '🏠 장소 대여비만 받을게요';
    case 4:
      return '💚 무료로 배움 나눔해요';
  }
}

communityType(int idx) {
  switch (idx) {
    // case 0:
    //   return '알려주세요';
    case 0:
      return '배움교환';
    case 1:
      return '배움모임';
    // case 3:
    //   return '얘기해요';
    default:
      return '';
  }
}

communityDescription(int idx) {
  switch (idx) {
    // case 0:
    //   return '원하는 클래스 요청하기';
    case 0:
      return '재능 주고받을 이웃찾기';
    case 1:
      return '같이 배울 이웃 모으기';
    // case 3:
    //   return '배움과 관련된 모든 이야기';
    default:
      return '';
  }
}

communityTypeCreate(int idx) {
  switch (idx) {
    // case 0:
    //   return 'LET_ME_KNOW';
    case 0:
      return 'EXCHANGE';
    case 1:
      return 'WITH_ME';
    // case 3:
    //   return 'TALK';
    default:
      return '';
  }
}

communityTypeIdx(String type) {
  switch (type) {
    // case 'LET_ME_KNOW':
    //   return 0;
    case 'EXCHANGE':
      return 0;
    case 'WITH_ME':
      return 1;
    default:
      return 2;
    // case 'TALK':
    //   return 3;
  }
}

myCreateCommunityStatus(int idx) {
  switch (idx) {
    case 0:
      return '전체';
    case 1:
      return '진행중';
    case 2:
      return '임시저장';
    case 3:
      return '진행완료';
  }
}

myCreateCommunityStatusText(String text) {
  switch (text) {
    case 'NORMAL':
      return '진행중';
    case 'TEMP':
      return '임시저장';
    case 'DONE':
      return '진행완료';
  }
}

myCreateCommunityStatusIdxType(int idx) {
  switch (idx) {
    case 1:
      return 'NORMAL';
    case 2:
      return 'TEMP';
    case 3:
      return 'DONE';
  }
}

communityChangeType(int idx) {
  switch (idx) {
    case 0:
      return 'all';
    case 1:
      return communityTypeCreate(0);
    case 2:
      return communityTypeCreate(1);
    case 3:
      return communityTypeCreate(2);
    case 4:
      return communityTypeCreate(3);
  }
}

reviewTypeText(String type) {
  switch (type) {
    case 'TYPE_0':
      return '🍀 편안하고 즐거운';
    case 'TYPE_1':
      return '🤓 꼼꼼하고 준비된';
    case 'TYPE_2':
      return '🐣 눈높이 클래스';
    case 'TYPE_3':
      return '✍️ 전문적인';
    case 'TYPE_4':
      return '🎯 원하던 목적달성';
  }
}

reviewTypeTextFinish(String type) {
  switch (type) {
    case 'TYPE_0':
      return '• 편안하고 즐거운';
    case 'TYPE_1':
      return '• 꼼꼼하고 준비된';
    case 'TYPE_2':
      return '• 눈높이 클래스';
    case 'TYPE_3':
      return '• 전문적인';
    case 'TYPE_4':
      return '• 원하던 목적달성';
  }
}

contentCheckListText(int index) {
  switch (index) {
    case 0:
      return '추천대상\n→ 누가 들으면 좋은지 알 수 있나요?';
    case 1:
      return '알려줄 내용\n→ 무엇을 배울 수 있는지 알 수 있나요?';
    case 2:
      return '수업방식\n→ 어떻게, 어디서 진행되는지 알 수 있나요?';
    case 3:
      return '대표 이미지\n→ 클래스와 관련된 이미지인가요?';
  }
}

introduceCheckListText(int index) {
  switch (index) {
    case 0:
      return '쌤 소개\n→ 쌤에 대해 충분히 어필해주셨나요?';
    case 1:
      return '모든 내용이 충분히 구체적인가요?';
  }
}
