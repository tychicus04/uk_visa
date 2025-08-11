// lib/features/chapters/data/chapter_content.dart

class ChapterSection {
  final String title;
  final List<String> paragraphs;
  final List<String> bulletPoints;

  const ChapterSection({
    required this.title,
    required this.paragraphs,
    this.bulletPoints = const [],
  });
}

class ChapterContentData {
  final int id;
  final String title;
  final String? imageUrl;
  final String? imageCaption;
  final List<ChapterSection> sections;
  final List<String> keyPoints;

  const ChapterContentData({
    required this.id,
    required this.title,
    this.imageUrl,
    this.imageCaption,
    required this.sections,
    required this.keyPoints,
  });
}

class ChapterContent {
  static ChapterContentData? getChapterContent(int chapterId) {
    switch (chapterId) {
      case 1:
        return _chapter1Content;
      case 2:
        return _chapter2Content;
      case 3:
        return _chapter3Content;
      case 4:
        return _chapter4Content;
      case 5:
        return _chapter5Content;
      default:
        return null;
    }
  }

  static const ChapterContentData _chapter1Content = ChapterContentData(
    id: 1,
    title: 'The Values and Principles of the UK',
    imageUrl: 'assets/images/uk_parliament.jpg',
    imageCaption: 'The Houses of Parliament in Westminster, London',
    sections: [
      ChapterSection(
        title: 'Introduction',
        paragraphs: [
          'Britain is a fantastic place to live: a modern, thriving society with a long and illustrious history. Our people have been at the heart of the world\'s political, scientific, industrial and cultural development. We are proud of our record of welcoming new migrants who will add to the diversity and dynamism of our national life.',
          'Applying to become a permanent resident or citizen of the UK is an important decision and commitment. You will be agreeing to accept the responsibilities which go with permanent residence and to respect the laws, values and traditions of the UK. Good citizens are an asset to the UK. We welcome those seeking to make a positive contribution to our society.',
          'Passing the Life in the UK test is part of demonstrating that you are ready to become a permanent migrant to the UK. This handbook is designed to support you in your preparation. It will help you to integrate into society and play a full role in your local community. It will also help ensure that you have a broad general knowledge of the culture, laws and history of the UK.',
        ],
      ),
      ChapterSection(
        title: 'The values and principles of the UK',
        paragraphs: [
          'British society is founded on fundamental values and principles which all those living in the UK should respect and support. These values are reflected in the responsibilities, rights and privileges of being a British citizen or permanent resident of the UK. They are based on history and traditions and are protected by law, customs and expectations. There is no place in British society for extremism or intolerance.',
        ],
        bulletPoints: [
          'Democracy',
          'The rule of law',
          'Individual liberty',
          'Tolerance of those with different faiths and beliefs',
          'Participation in community life',
        ],
      ),
      ChapterSection(
        title: 'The Citizenship Pledge',
        paragraphs: [
          'As part of the citizenship ceremony, new citizens pledge to uphold these values. The pledge is:',
          '"I will give my loyalty to the United Kingdom and respect its rights and freedoms. I will uphold its democratic values. I will observe its laws faithfully and fulfil my duties and obligations as a British citizen."',
        ],
      ),
      ChapterSection(
        title: 'Responsibilities and Freedoms',
        paragraphs: [
          'Flowing from the fundamental principles are responsibilities and freedoms which are shared by all those living in the UK and which we expect all residents to respect.',
          'If you wish to be a permanent resident or citizen of the UK, you should:',
        ],
        bulletPoints: [
          'Respect and obey the law',
          'Respect the rights of others, including their right to their own opinions',
          'Treat others with fairness',
          'Look after yourself and your family',
          'Look after the area in which you live and the environment',
        ],
      ),
      ChapterSection(
        title: 'Rights in the UK',
        paragraphs: [
          'In return, the UK offers:',
        ],
        bulletPoints: [
          'Freedom of belief and religion',
          'Freedom of speech',
          'Freedom from unfair discrimination',
          'A right to a fair trial',
          'A right to join in the election of a government',
        ],
      ),
      ChapterSection(
        title: 'Taking the Life in the UK Test',
        paragraphs: [
          'The Life in the UK test handbook will help prepare you for taking the Life in the UK test. The test consists of 24 questions about important aspects of life in the UK. Questions are based on ALL parts of the handbook. The 24 questions will be different for each person taking the test at that test session.',
          'You need to get at least 18 questions (75%) correct in order to pass.',
          'You can only take the test at a registered and approved Life in the UK test centre. There are about 60 test centres around the UK. You can only take the test using a computer.',
        ],
      ),
    ],
    keyPoints: [
      'The UK is founded on democracy, rule of law, individual liberty, tolerance, and community participation',
      'New citizens pledge loyalty and promise to uphold democratic values',
      'Residents must respect laws, treat others fairly, and look after their community',
      'The UK offers freedom of belief, speech, fair trial, and democratic participation',
      'The Life in the UK test has 24 questions and requires 75% to pass',
    ],
  );

  static const ChapterContentData _chapter2Content = ChapterContentData(
    id: 2,
    title: 'What is the UK?',
    imageUrl: 'assets/images/uk_map.png',
    imageCaption: 'Map showing the nations of the United Kingdom',
    sections: [
      ChapterSection(
        title: 'The Nations of the UK',
        paragraphs: [
          'The UK is made up of England, Scotland, Wales and Northern Ireland. The rest of Ireland is an independent country.',
          'The official name of the country is the United Kingdom of Great Britain and Northern Ireland. "Great Britain" refers only to England, Scotland and Wales, not to Northern Ireland. The words "Britain", "British Isles" or "British", however, are used here to refer to everyone in the UK.',
        ],
      ),
      ChapterSection(
        title: 'Crown Dependencies and Overseas Territories',
        paragraphs: [
          'There are also several islands which are closely linked with the UK but are not part of it: the Channel Islands and the Isle of Man. These have their own governments and are called "Crown dependencies".',
          'There are also several British overseas territories in other parts of the world, such as St Helena and the Falkland Islands. They are also linked to the UK but are not part of it.',
        ],
      ),
      ChapterSection(
        title: 'Government Structure',
        paragraphs: [
          'The UK is governed by the parliament sitting in Westminster. Scotland, Wales and Northern Ireland also have parliaments or assemblies of their own, with devolved powers in defined areas.',
        ],
      ),
    ],
    keyPoints: [
      'The UK consists of England, Scotland, Wales, and Northern Ireland',
      'Great Britain refers only to England, Scotland, and Wales',
      'Crown Dependencies include Channel Islands and Isle of Man',
      'The UK has overseas territories like St Helena and Falkland Islands',
      'Westminster Parliament governs the UK, with devolved powers to other nations',
    ],
  );

  static const ChapterContentData _chapter3Content = ChapterContentData(
    id: 3,
    title: 'A Long and Illustrious History',
    imageUrl: 'assets/images/stonehenge.jpg',
    imageCaption: 'Stonehenge, one of Britain\'s most famous prehistoric monuments',
    sections: [
      ChapterSection(
        title: 'Early Britain',
        paragraphs: [
          'The history of Britain can be traced back to the Stone Age. Over thousands of years, many different peoples came to Britain, including the Celts, Romans, Anglo-Saxons, Vikings, and Normans.',
          'Each group brought their own culture, language, and customs, which helped shape the Britain we know today.',
        ],
      ),
      ChapterSection(
        title: 'Roman Britain (43-410 AD)',
        paragraphs: [
          'The Romans invaded Britain in 43 AD under Emperor Claudius. They built roads, towns, and Hadrian\'s Wall to keep out the Scottish tribes.',
          'The Romans brought Christianity, the Latin language, and Roman law to Britain. They left in 410 AD when Rome itself was under attack.',
        ],
      ),
      ChapterSection(
        title: 'Anglo-Saxons and Vikings (410-1066)',
        paragraphs: [
          'After the Romans left, tribes from northern Europe, including the Angles, Saxons, and Jutes, came to Britain. They established kingdoms and brought the English language.',
          'Vikings from Denmark and Norway began raiding Britain in 789 AD and later settled in many areas. They had a significant influence on the English language and culture.',
        ],
      ),
      ChapterSection(
        title: 'The Norman Conquest (1066)',
        paragraphs: [
          'In 1066, William the Conqueror, Duke of Normandy, defeated King Harold at the Battle of Hastings. This began Norman rule in England.',
          'The Normans built many castles and cathedrals. They brought the French language to the court and government, which influenced the development of English.',
        ],
      ),
      ChapterSection(
        title: 'Medieval Period',
        paragraphs: [
          'The Middle Ages saw the development of Parliament, beginning with King John signing Magna Carta in 1215, which limited the power of the king.',
          'The Black Death (1348-1350) killed about one-third of Britain\'s population, leading to social and economic changes.',
          'This period saw the Wars of the Roses (1455-1485), a civil war between the Houses of Lancaster and York.',
        ],
      ),
    ],
    keyPoints: [
      'Britain\'s history spans from the Stone Age to modern times',
      'Romans ruled Britain from 43-410 AD, bringing roads, towns, and Christianity',
      'Anglo-Saxons brought the English language and established kingdoms',
      'Vikings influenced British culture and language from 789 AD',
      'Norman Conquest in 1066 brought French influence and Norman architecture',
      'Magna Carta (1215) limited royal power and led to parliamentary development',
    ],
  );

  static const ChapterContentData _chapter4Content = ChapterContentData(
    id: 4,
    title: 'A Modern, Thriving Society',
    imageUrl: 'assets/images/london_eye.jpg',
    imageCaption: 'The London Eye, a symbol of modern Britain',
    sections: [
      ChapterSection(
        title: 'The UK Today',
        paragraphs: [
          'The UK today is a more diverse society than it was 100 years ago, in both ethnic and religious terms. Post-war immigration means that nearly 10% of the population has a parent or grandparent born outside the UK.',
          'The UK continues to be a multinational and multiracial society with a rich and varied culture. This section will tell you about the different parts of the UK and some important places.',
        ],
      ),
      ChapterSection(
        title: 'Religion and Beliefs',
        paragraphs: [
          'The UK is historically a Christian country, but today people practice many different religions or no religion at all.',
          'The established Church in England is the Church of England (Anglican Church). In Scotland, it is the Presbyterian Church of Scotland.',
          'Other major religions practiced in the UK include Islam, Hinduism, Sikhism, Judaism, and Buddhism.',
        ],
      ),
      ChapterSection(
        title: 'Festivals and Traditions',
        paragraphs: [
          'The UK celebrates many festivals throughout the year, including Christmas, Easter, and religious festivals from many faiths.',
          'National days include St David\'s Day (Wales), St Patrick\'s Day (Northern Ireland), St George\'s Day (England), and St Andrew\'s Day (Scotland).',
          'Other important celebrations include Bonfire Night (Guy Fawkes Night) on November 5th and Remembrance Day on November 11th.',
        ],
      ),
      ChapterSection(
        title: 'Sports',
        paragraphs: [
          'Sport plays an important part in British culture. Football is the UK\'s most popular sport, with separate national teams for England, Scotland, Wales, and Northern Ireland.',
          'Other popular sports include rugby, cricket, tennis, golf, and horse racing. The UK hosted the Olympic Games in London in 2012.',
        ],
      ),
      ChapterSection(
        title: 'Arts and Culture',
        paragraphs: [
          'The UK has a rich cultural heritage. William Shakespeare is probably the most famous British writer, and his plays are performed all over the world.',
          'The UK has produced many famous musicians, including The Beatles, The Rolling Stones, and more recently, Adele and Ed Sheeran.',
          'British television, film, and literature are enjoyed worldwide. The BBC is a famous British broadcaster.',
        ],
      ),
    ],
    keyPoints: [
      'The UK is a diverse, multiracial society with people from many backgrounds',
      'Christianity is the historical religion, but many faiths are practiced today',
      'National days celebrate each nation: St David\'s, St Patrick\'s, St George\'s, and St Andrew\'s',
      'Football is the most popular sport, with cricket, rugby, and tennis also important',
      'The UK has rich cultural traditions in literature, music, film, and television',
      'London hosted the Olympic Games in 2012',
    ],
  );

  static const ChapterContentData _chapter5Content = ChapterContentData(
    id: 5,
    title: 'The UK Government, the Law and Your Role',
    imageUrl: 'assets/images/houses_of_parliament.jpg',
    imageCaption: 'The Houses of Parliament and Big Ben in Westminster',
    sections: [
      ChapterSection(
        title: 'The Development of British Democracy',
        paragraphs: [
          'Democracy is a system of government where the whole adult population gets a say. This might be by direct voting or by choosing representatives to make decisions on their behalf.',
          'At the turn of the 19th century, Britain was not a democracy as we know it today. Only men over 21 who owned property could vote.',
          'The voting franchise grew over the 19th century. By 1918, most men over 21 and women over 30 could vote. In 1928, all men and women over 21 could vote. In 1969, the voting age was reduced to 18.',
        ],
      ),
      ChapterSection(
        title: 'The British Constitution',
        paragraphs: [
          'A constitution is a set of principles by which a country is governed. The British constitution is not written down in any single document, so it is described as "unwritten".',
          'This is because the UK has never had a revolution that led to a completely new system of government. Instead, institutions have developed over hundreds of years.',
        ],
      ),
      ChapterSection(
        title: 'The Role of the Monarch',
        paragraphs: [
          'The UK is a constitutional monarchy. This means that the king or queen is the head of state but elected politicians hold the real power.',
          'The monarch gives formal approval to new laws passed by Parliament and meets regularly with the Prime Minister.',
        ],
      ),
      ChapterSection(
        title: 'Parliament',
        paragraphs: [
          'Parliament is made up of the House of Commons and the House of Lords.',
          'The House of Commons is more important. Its members (MPs) are elected by the people. The political party with the most MPs forms the government.',
          'The House of Lords reviews and suggests changes to new laws. Most of its members are appointed, not elected.',
        ],
      ),
      ChapterSection(
        title: 'Elections and Voting',
        paragraphs: [
          'UK citizens aged 18 and over can vote in elections. EU citizens can vote in local elections and elections to devolved parliaments.',
          'Elections to the House of Commons must be held at least every five years. The political party that wins the most seats forms the government.',
        ],
      ),
      ChapterSection(
        title: 'The Legal System',
        paragraphs: [
          'There are different legal systems in England and Wales, Scotland, and Northern Ireland.',
          'Criminal law relates to crimes against the whole community. Civil law is used to settle disputes between individuals or groups.',
          'Everyone has the right to a fair trial and to be represented by a lawyer.',
        ],
      ),
    ],
    keyPoints: [
      'The UK is a constitutional monarchy with an unwritten constitution',
      'Parliament consists of the House of Commons (elected) and House of Lords',
      'All UK citizens aged 18+ can vote in general elections',
      'Elections must be held at least every five years',
      'The monarch is head of state but elected politicians hold real power',
      'There are separate legal systems for different parts of the UK',
      'Everyone has the right to a fair trial and legal representation',
    ],
  );
}