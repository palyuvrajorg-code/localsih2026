class Words {
  final String language;
  const Words(this.language);
  String text(String en, String as, String bn) => switch (language) {
    'as' => as,
    'bn' => bn,
    _ => en,
  };
  String get home => text('Home', 'ঘৰ', 'বাড়ি');
  String get back => text('Back', 'পিছলৈ', 'ফিরে যান');
  String get play => text('Let’s play', 'আহক খেলোঁ', 'চলুন খেলি');
  String get memories => text('My memories', 'মোৰ স্মৃতি', 'আমার স্মৃতি');
  String get today => text('My day', 'মোৰ দিনটো', 'আমার দিন');
  String get help => text('Call for help', 'সহায় বিচাৰক', 'সাহায্য চান');
  String get listen => text('Listen', 'শুনক', 'শুনুন');
  String get speak => text('Speak', 'কওক', 'বলুন');
  String get start => text('Start', 'আৰম্ভ কৰক', 'শুরু করুন');
  String get next => text('Continue', 'আগবাঢ়ক', 'এগিয়ে যান');
  String get again => text('Play again', 'আকৌ খেলক', 'আবার খেলুন');
  String get hint => text('Show me', 'দেখুৱাওক', 'দেখান');
  String get nice => text('Lovely work!', 'বৰ ভাল হৈছে!', 'খুব ভালো হয়েছে!');
  String get gentle => text(
    'Let’s try together.',
    'আহক একেলগে চেষ্টা কৰোঁ।',
    'চলুন একসঙ্গে চেষ্টা করি।',
  );
  String get relax => text(
    'Take your time. There’s no rush.',
    'লাহে লাহে কৰক। খৰখেদা নাই।',
    'ধীরে ধীরে করুন। তাড়া নেই।',
  );
  String get cancel => text('Cancel', 'বাতিল কৰক', 'বাতিল করুন');
  String get save => text('Save', 'সাঁচি ৰাখক', 'সংরক্ষণ করুন');
  String get done => text('Done', 'হৈ গ’ল', 'হয়ে গেছে');
  String get noVoice => text(
    'Voice is unavailable in this language on this device. You can use the buttons.',
    'এই যন্ত্ৰত এই ভাষাৰ কণ্ঠসেৱা উপলব্ধ নহয়। বুটাম ব্যৱহাৰ কৰক।',
    'এই যন্ত্রে এই ভাষার কণ্ঠসেবা নেই। বোতাম ব্যবহার করুন।',
  );
  String get noMemories => text(
    'Your family can add photos here.',
    'আপোনাৰ পৰিয়ালে ইয়াত ফটো যোগ কৰিব পাৰে।',
    'আপনার পরিবার এখানে ছবি যোগ করতে পারে।',
  );
  String get games =>
      text('Choose an activity', 'এটা খেল বাছক', 'একটি খেলা বাছুন');
  String get picture => text('Picture', 'ছবি', 'ছবি');
  String get caregiver =>
      text('Family settings', 'পৰিয়ালৰ ছেটিংছ', 'পরিবারের সেটিংস');
  String date(DateTime date) {
    const enMonths = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const asMonths = [
      'জানুৱাৰী',
      'ফেব্ৰুৱাৰী',
      'মাৰ্চ',
      'এপ্ৰিল',
      'মে’',
      'জুন',
      'জুলাই',
      'আগষ্ট',
      'ছেপ্টেম্বৰ',
      'অক্টোবৰ',
      'নৱেম্বৰ',
      'ডিচেম্বৰ',
    ];
    const bnMonths = [
      'জানুয়ারি',
      'ফেব্রুয়ারি',
      'মার্চ',
      'এপ্রিল',
      'মে',
      'জুন',
      'জুলাই',
      'আগস্ট',
      'সেপ্টেম্বর',
      'অক্টোবর',
      'নভেম্বর',
      'ডিসেম্বর',
    ];
    return '${number(date.day)} ${text(enMonths[date.month - 1], asMonths[date.month - 1], bnMonths[date.month - 1])}';
  }

  String number(num value) {
    final digits = language == 'en' ? '0123456789' : '০১২৩৪৫৬৭৮৯';
    return value
        .toString()
        .split('')
        .map((c) => int.tryParse(c) == null ? c : digits[int.parse(c)])
        .join();
  }
}
