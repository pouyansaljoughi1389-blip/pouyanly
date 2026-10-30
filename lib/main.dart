import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(PouyanlyApp(store: store));
}

class AppStore extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool onboarded = false;
  String goal = 'مکالمه روزمره';
  String selfLevel = 'متوسط';
  int dailyMinutes = 15;
  String studyTime = 'شب';
  String cefr = 'A2';
  int xp = 0;
  int coins = 0;
  int completedLessons = 0;
  int streak = 0;
  int lessonProgress = 0;
  bool reminderEnabled = false;
  bool darkMode = false;
  Map<String, int> skillScores = {};
  List<Map<String, dynamic>> reviewWords = [];
  Set<String> completedUnits = {};

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    onboarded = _prefs.getBool('onboarded') ?? false;
    goal = _prefs.getString('goal') ?? goal;
    selfLevel = _prefs.getString('selfLevel') ?? selfLevel;
    dailyMinutes = _prefs.getInt('dailyMinutes') ?? dailyMinutes;
    studyTime = _prefs.getString('studyTime') ?? studyTime;
    cefr = _prefs.getString('cefr') ?? cefr;
    xp = _prefs.getInt('xp') ?? 0;
    coins = _prefs.getInt('coins') ?? 0;
    completedLessons = _prefs.getInt('completedLessons') ?? 0;
    streak = _prefs.getInt('streak') ?? 0;
    lessonProgress = _prefs.getInt('lessonProgress') ?? 0;
    reminderEnabled = _prefs.getBool('reminderEnabled') ?? false;
    darkMode = _prefs.getBool('darkMode') ?? false;
    skillScores = Map<String, int>.from(jsonDecode(_prefs.getString('skillScores') ?? '{}'));
    reviewWords = List<Map<String, dynamic>>.from(jsonDecode(_prefs.getString('reviewWords') ?? '[]'));
    completedUnits = Set<String>.from(jsonDecode(_prefs.getString('completedUnits') ?? '[]'));
  }

  Future<void> save() async {
    await _prefs.setBool('onboarded', onboarded);
    await _prefs.setString('goal', goal);
    await _prefs.setString('selfLevel', selfLevel);
    await _prefs.setInt('dailyMinutes', dailyMinutes);
    await _prefs.setString('studyTime', studyTime);
    await _prefs.setString('cefr', cefr);
    await _prefs.setInt('xp', xp);
    await _prefs.setInt('coins', coins);
    await _prefs.setInt('completedLessons', completedLessons);
    await _prefs.setInt('streak', streak);
    await _prefs.setInt('lessonProgress', lessonProgress);
    await _prefs.setBool('reminderEnabled', reminderEnabled);
    await _prefs.setBool('darkMode', darkMode);
    await _prefs.setString('skillScores', jsonEncode(skillScores));
    await _prefs.setString('reviewWords', jsonEncode(reviewWords));
    await _prefs.setString('completedUnits', jsonEncode(completedUnits.toList()));
    notifyListeners();
  }

  Future<void> finishOnboarding(String g, String l, int m, String t) async {
    goal = g; selfLevel = l; dailyMinutes = m; studyTime = t;
    await save();
  }

  Future<void> finishPlacement(Map<String, int> scores) async {
    skillScores = scores;
    final values = scores.values.toList();
    final avg = values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
    cefr = avg >= 85 ? 'B2' : avg >= 70 ? 'B1' : avg >= 50 ? 'A2' : avg >= 30 ? 'A1' : 'A1';
    onboarded = true;
    await save();
  }

  Future<void> completeLesson() async {
    completedLessons++;
    xp += 25;
    coins += 10;
    lessonProgress++;
    streak = streak == 0 ? 1 : streak;
    if (lessonProgress >= 3) completedUnits.add('unit1');
    await save();
  }

  Future<void> markWordReviewed(int index, bool known) async {
    if (index < 0 || index >= reviewWords.length) return;
    final word = reviewWords[index];
    final mastery = (word['mastery'] as int? ?? 0) + (known ? 1 : -1);
    word['mastery'] = mastery.clamp(0, 5);
    word['due'] = DateTime.now().add(Duration(days: known ? (mastery >= 4 ? 7 : 2) : 1)).toIso8601String();
    coins += known ? 2 : 0;
    await save();
  }
}

class PouyanlyApp extends StatelessWidget {
  final AppStore store;
  const PouyanlyApp({super.key, required this.store});
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (_, __) => MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'POUYANLY',
      themeMode: store.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      builder: (context, child) => Directionality(textDirection: TextDirection.rtl, child: child!),
      home: !store.onboarded ? WelcomeScreen(store: store) : HomeScreen(store: store),
    ),
  );
}

ThemeData _theme(Brightness brightness) {
  const seed = Color(0xFF6558D3);
  final dark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true, brightness: brightness, colorScheme: ColorScheme.fromSeed(seedColor: seed, brightness: brightness),
    scaffoldBackgroundColor: dark ? const Color(0xFF10111A) : const Color(0xFFF7F7FC),
    fontFamily: 'Roboto',
    cardTheme: CardThemeData(color: dark ? const Color(0xFF1B1C29) : Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22))),
    appBarTheme: AppBarTheme(backgroundColor: dark ? const Color(0xFF10111A) : const Color(0xFFF7F7FC), elevation: 0, centerTitle: false),
  );
}

const ink = Color(0xFF24233A);
const violet = Color(0xFF6558D3);
const mint = Color(0xFF36B99A);

class WelcomeScreen extends StatelessWidget {
  final AppStore store;
  const WelcomeScreen({super.key, required this.store});
  @override
  Widget build(BuildContext context) => Scaffold(body: SafeArea(child: Padding(
    padding: const EdgeInsets.all(26), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Spacer(),
      Container(width: 76, height: 76, decoration: BoxDecoration(color: violet.withOpacity(.12), borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.auto_awesome_rounded, color: violet, size: 40)),
      const SizedBox(height: 28),
      const Text('POUYANLY', textDirection: TextDirection.ltr, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 3, color: violet)),
      const SizedBox(height: 12),
      const Text('انگلیسی را\nواقعی یاد بگیر.', style: TextStyle(fontSize: 36, height: 1.35, fontWeight: FontWeight.w900, color: ink)),
      const SizedBox(height: 14),
      Text('یک مسیر یادگیری که با سطح، هدف و زمان تو هماهنگ می‌شود.', style: TextStyle(fontSize: 16, height: 1.8, color: Colors.grey.shade600)),
      const SizedBox(height: 30),
      Row(children: const [FeatureChip(icon: Icons.offline_bolt, text: 'آفلاین'), SizedBox(width: 8), FeatureChip(icon: Icons.route, text: 'شخصی‌سازی'), SizedBox(width: 8), FeatureChip(icon: Icons.school, text: 'CEFR')]),
      const Spacer(),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => OnboardingScreen(store: store))), child: const Text('شروع یادگیری', style: TextStyle(fontWeight: FontWeight.bold)))),
      const SizedBox(height: 12), Center(child: Text('یادگیری بهتر، هر روز کمی.', style: TextStyle(color: Colors.grey.shade500))),
    ]),
  )));
}

class FeatureChip extends StatelessWidget {
  final IconData icon; final String text;
  const FeatureChip({super.key, required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9), decoration: BoxDecoration(color: violet.withOpacity(.08), borderRadius: BorderRadius.circular(30)), child: Row(children: [Icon(icon, size: 15, color: violet), const SizedBox(width: 5), Text(text, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700))]));
}

class OnboardingScreen extends StatefulWidget {
  final AppStore store;
  const OnboardingScreen({super.key, required this.store});
  @override State<OnboardingScreen> createState() => _OnboardingScreenState();
}
class _OnboardingScreenState extends State<OnboardingScreen> {
  int page = 0; String goal = 'مکالمه روزمره'; String level = 'متوسط'; int minutes = 15; String time = 'شب';
  final goals = ['مکالمه روزمره','تحصیل','مهاجرت','سفر','کار','آزمون IELTS','علاقه شخصی'];
  final levels = ['کاملاً مبتدی','کمی آشنا','متوسط','پیشرفته','مطمئن نیستم'];
  final times = ['صبح','ظهر','عصر','شب','ساعت دلخواه'];
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => page == 0 ? Navigator.pop(context) : setState(() => page--)), title: Text('شناخت بهتر تو  •  ${page+1}/4')),
    body: Padding(padding: const EdgeInsets.all(22), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: (page+1)/4, minHeight: 6, color: violet)),
      const SizedBox(height: 30),
      Text(['برای چه می‌خواهی انگلیسی یاد بگیری؟','سطح فعلی خودت را چطور می‌بینی؟','روزانه چقدر زمان داری؟','چه زمانی راحت‌تری؟'][page], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
      const SizedBox(height: 8), Text('بعداً هم می‌توانی این تنظیمات را تغییر بدهی.', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 22), Expanded(child: SingleChildScrollView(child: Wrap(spacing: 10, runSpacing: 10, children: page == 0 ? goals.map((x)=>ChoiceTile(text:x, selected:goal==x, onTap:()=>setState(()=>goal=x))).toList() : page == 1 ? levels.map((x)=>ChoiceTile(text:x, selected:level==x, onTap:()=>setState(()=>level=x))).toList() : page == 2 ? [5,10,15,20,30,45].map((x)=>ChoiceTile(text: x==45?'بیشتر از ۳۰ دقیقه':'$x دقیقه', selected:minutes==x, onTap:()=>setState(()=>minutes=x))).toList() : times.map((x)=>ChoiceTile(text:x, selected:time==x, onTap:()=>setState(()=>time=x))).toList())),),
      SizedBox(width: double.infinity, child: FilledButton(onPressed: () async { if(page<3){setState(()=>page++);} else { await widget.store.finishOnboarding(goal,level,minutes,time); if(!mounted)return; Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>PlacementScreen(store:widget.store))); } }, child: Text(page==3?'شروع آزمون تعیین سطح':'ادامه'))),
    ])));
}

class ChoiceTile extends StatelessWidget {
  final String text; final bool selected; final VoidCallback onTap;
  const ChoiceTile({super.key, required this.text, required this.selected, required this.onTap});
  @override Widget build(BuildContext context) => InkWell(onTap:onTap, borderRadius:BorderRadius.circular(16), child: AnimatedContainer(duration:const Duration(milliseconds:160), padding:const EdgeInsets.symmetric(horizontal:18,vertical:15), decoration:BoxDecoration(color:selected?violet.withOpacity(.10):Theme.of(context).cardColor,borderRadius:BorderRadius.circular(16),border:Border.all(color:selected?violet:Colors.grey.withOpacity(.18),width:selected?1.6:1)), child:Row(mainAxisSize:MainAxisSize.min,children:[if(selected)const Icon(Icons.check_circle,color:violet,size:18),if(selected)const SizedBox(width:7),Text(text,style:TextStyle(fontWeight:selected?FontWeight.bold:FontWeight.w500))])));
}

class TestQuestion {
  final String skill, prompt, answer, explanation, level; final List<String> options; final String? passage;
  const TestQuestion(this.skill,this.prompt,this.options,this.answer,this.explanation,this.level,{this.passage});
}
final testQuestions = <TestQuestion>[
  const TestQuestion('واژگان','معنی واژهٔ «borrow» چیست؟',['قرض گرفتن','قرض دادن','خریدن','فروختن'],'قرض گرفتن','Borrow یعنی چیزی را موقتاً از کسی گرفتن.','A1'),
  const TestQuestion('گرامر','She ___ to school every day.',['go','goes','going','gone'],'goes','برای سوم‌شخص مفرد در زمان حال ساده، به فعل s اضافه می‌کنیم.','A1'),
  const TestQuestion('خواندن','متن: “Tom usually walks to work, but today he is taking the bus.” تام امروز چگونه به محل کار می‌رود؟',['پیاده','با اتوبوس','با قطار','با دوچرخه'],'با اتوبوس','عبارت today he is taking the bus به برنامهٔ امروز اشاره می‌کند.','A2'),
  const TestQuestion('شنیداری','تمرین شنیداری (نسخه متنی): “The train leaves at half past six.” قطار چه ساعتی حرکت می‌کند؟',['۶:۱۵','۶:۳۰','۷:۳۰','۵:۳۰'],'۶:۳۰','Half past six یعنی ساعت شش و نیم. در این نسخه متن جایگزین فایل صوتی است.','A2',passage:'The train leaves at half past six.'),
  const TestQuestion('واژگان','نزدیک‌ترین معنی «reliable» کدام است؟',['قابل اعتماد','گران‌قیمت','موقت','پیچیده'],'قابل اعتماد','Reliable یعنی کسی یا چیزی که بتوان به آن اعتماد کرد.','B1'),
  const TestQuestion('گرامر','If I ___ more time, I would learn another language.',['have','had','will have','am having'],'had','در شرطی نوع دوم، بعد از if از گذشته ساده استفاده می‌کنیم.','B1'),
  const TestQuestion('خواندن','“Despite the heavy rain, the event went ahead as planned.” کدام گزینه درست است؟',['رویداد لغو شد','رویداد طبق برنامه برگزار شد','باران متوقف شد','رویداد زودتر شروع شد'],'رویداد طبق برنامه برگزار شد','Despite یعنی با وجودِ؛ went ahead یعنی برگزار/اجرا شد.','B2'),
  const TestQuestion('گرامر','By the time we arrived, the film ___.',['starts','has started','had started','will start'],'had started','برای اتفاقی که قبل از یک زمان در گذشته رخ داده، Past Perfect می‌آید.','B2'),
  const TestQuestion('واژگان','«ambiguous» به چه معناست؟',['دوپهلو و مبهم','کاملاً دقیق','بی‌اهمیت','قابل پیش‌بینی'],'دوپهلو و مبهم','Ambiguous یعنی دارای بیش از یک برداشت یا معنای روشن‌نبوده.','C1'),
  const TestQuestion('گرامر','No sooner ___ the announcement than the audience applauded.',['had she made','she had made','has she made','she makes'],'had she made','پس از No sooner در ابتدای جمله، وارونگی و Past Perfect به‌کار می‌رود.','C1'),
  const TestQuestion('نوشتن','کدام جمله رسمی‌تر و مناسب‌تر برای مقاله است؟',['Kids get lots of stuff online.','Children access a wide range of online resources.','Kids grab things on the web.','Children get loads of things online.'],'Children access a wide range of online resources.','در نوشتار رسمی، واژگان دقیق‌تر و لحن خنثی مناسب‌تر است.','B2'),
  const TestQuestion('نوشتن','یک جمله انگلیسی درباره هدفت بنویس. (برای MVP این پاسخ خودارزیابی می‌شود.)',['I want to improve my English.','I want improve English.','I improving English.','I English want.'],'I want to improve my English.','ساختار درست: want + to + فعل ساده.','A2'),
];

class PlacementScreen extends StatefulWidget {
  final AppStore store; const PlacementScreen({super.key,required this.store});
  @override State<PlacementScreen> createState()=>_PlacementScreenState();
}
class _PlacementScreenState extends State<PlacementScreen> {
  int index=0, correct=0; final Map<String,int> total={}; final Map<String,int> hits={}; String? selected;
  void answer(String value) { if(selected!=null)return; setState(()=>selected=value); final q=testQuestions[index]; total[q.skill]=(total[q.skill]??0)+1; if(value==q.answer){correct++;hits[q.skill]=(hits[q.skill]??0)+1;} }
  Future<void> next() async { if(selected==null)return; if(index<testQuestions.length-1){setState(() { index++; selected = null; });} else { final scores=<String,int>{}; for(final s in ['واژگان','گرامر','خواندن','شنیداری','نوشتن']){ scores[s]=total[s]==null?0:((hits[s]??0)*100/total[s]!).round(); } scores['مکالمه']=0; await widget.store.finishPlacement(scores); if(!mounted)return; Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>ResultsScreen(store:widget.store))); } }
  @override Widget build(BuildContext context){final q=testQuestions[index]; return Scaffold(appBar:AppBar(title:const Text('آزمون تعیین سطح'),actions:[TextButton(onPressed:() async { await widget.store.finishPlacement({'واژگان':0,'گرامر':0,'خواندن':0,'شنیداری':0,'نوشتن':0,'مکالمه':0}); if(!context.mounted)return; Navigator.pushReplacement(context,MaterialPageRoute(builder:(_)=>ResultsScreen(store:widget.store))); },child:const Text('فعلاً رد شو'))]),body:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LinearProgressIndicator(value:(index+1)/testQuestions.length,minHeight:6,borderRadius:BorderRadius.circular(8)),const SizedBox(height:18),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text('سؤال ${index+1} از ${testQuestions.length}',style:TextStyle(color:Colors.grey.shade600)),Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:violet.withOpacity(.1),borderRadius:BorderRadius.circular(20)),child:Text('${q.skill} • ${q.level}',style:const TextStyle(color:violet,fontWeight:FontWeight.bold,fontSize:12)))]),const SizedBox(height:28),if(q.passage!=null)Container(width:double.infinity,padding:const EdgeInsets.all(16),decoration:BoxDecoration(color:mint.withOpacity(.10),borderRadius:BorderRadius.circular(16)),child:Text(q.passage!,textDirection:TextDirection.ltr,style:const TextStyle(fontSize:17,fontWeight:FontWeight.w600))),const SizedBox(height:16),Text(q.prompt,style:const TextStyle(fontSize:22,fontWeight:FontWeight.w800,height:1.5)),const SizedBox(height:24),...q.options.map((o)=>Padding(padding:const EdgeInsets.only(bottom:10),child:OptionButton(text:o,selected:selected==o,correct:selected!=null&&o==q.answer,onTap:()=>answer(o)))),if(selected!=null)Container(width:double.infinity,padding:const EdgeInsets.all(14),margin:const EdgeInsets.only(top:8),decoration:BoxDecoration(color:(selected==q.answer?mint:Colors.orange).withOpacity(.10),borderRadius:BorderRadius.circular(16)),child:Text('${selected==q.answer?'آفرین! پاسخ درست است.':'این بار نه؛ پاسخ درست: ${q.answer}'}\n${q.explanation}',style:const TextStyle(height:1.6))),const Spacer(),SizedBox(width:double.infinity,child:FilledButton(onPressed:selected==null?null:next,child:Text(index==testQuestions.length-1?'مشاهده نتیجه':'سؤال بعدی')))])));}
}

class OptionButton extends StatelessWidget {final String text;final bool selected,correct;final VoidCallback onTap;const OptionButton({super.key,required this.text,required this.selected,required this.correct,required this.onTap});@override Widget build(BuildContext context){final active=selected;final color=active?(correct?mint:Colors.deepOrange):Colors.grey.withOpacity(.20);return InkWell(onTap:onTap,borderRadius:BorderRadius.circular(15),child:Container(width:double.infinity,padding:const EdgeInsets.all(16),decoration:BoxDecoration(borderRadius:BorderRadius.circular(15),border:Border.all(color:color,width:active?1.8:1),color:active?color.withOpacity(.09):Theme.of(context).cardColor),child:Row(children:[Expanded(child:Text(text,style:TextStyle(fontWeight:active?FontWeight.bold:FontWeight.w500))),if(active)Icon(correct?Icons.check_circle:Icons.cancel,color:correct?mint:Colors.deepOrange)])));}}

class ResultsScreen extends StatelessWidget {final AppStore store;const ResultsScreen({super.key,required this.store});@override Widget build(BuildContext context){final avg=store.skillScores.values.isEmpty?0:store.skillScores.values.reduce((a,b)=>a+b)~/store.skillScores.length;return Scaffold(appBar:AppBar(title:const Text('نتیجه تعیین سطح')),body:Padding(padding:const EdgeInsets.all(22),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Container(width:double.infinity,padding:const EdgeInsets.all(24),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF6558D3),Color(0xFF8C7FEA)]),borderRadius:BorderRadius.circular(24)),child:Column(children:[const Text('سطح پیشنهادی تو',style:TextStyle(color:Colors.white70)),const SizedBox(height:8),Text(store.cefr,style:const TextStyle(fontSize:54,fontWeight:FontWeight.w900,color:Colors.white)),Text('امتیاز تقریبی $avg از ۱۰۰',style:const TextStyle(color:Colors.white))])),const SizedBox(height:24),const Text('نمای مهارت‌ها',style:TextStyle(fontSize:20,fontWeight:FontWeight.w800)),const SizedBox(height:14),Expanded(child:ListView(children:store.skillScores.entries.map((e)=>Padding(padding:const EdgeInsets.only(bottom:15),child:Column(children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[Text(e.key,style:const TextStyle(fontWeight:FontWeight.w600)),Text(e.key=='مکالمه'?'نیازمند ارزیابی گفتاری': '${e.value}٪',style:TextStyle(color:Colors.grey.shade600,fontSize:12))]),const SizedBox(height:7),ClipRRect(borderRadius:BorderRadius.circular(9),child:LinearProgressIndicator(value:e.value/100,minHeight:8,color:e.value>=60?mint:violet,backgroundColor:Colors.grey.withOpacity(.15)))]))).toList())),Container(padding:const EdgeInsets.all(13),decoration:BoxDecoration(color:Colors.orange.withOpacity(.10),borderRadius:BorderRadius.circular(14)),child:const Text('محدودیت نسخه اولیه: گفتار با تشخیص صدا ارزیابی نمی‌شود و شنیداری فعلاً با متن جایگزین شده است. نتیجه، تخمین آموزشی است نه مدرک رسمی CEFR.',style:TextStyle(fontSize:12,height:1.6))),const SizedBox(height:14),SizedBox(width:double.infinity,child:FilledButton(onPressed:()=>Navigator.pushAndRemoveUntil(context,MaterialPageRoute(builder:(_)=>HomeScreen(store:store)),(r)=>false),child:const Text('ساخت مسیر یادگیری من')))])));}}

class HomeScreen extends StatefulWidget {final AppStore store;const HomeScreen({super.key,required this.store});@override State<HomeScreen> createState()=>_HomeScreenState();}
class _HomeScreenState extends State<HomeScreen>{int tab=0;@override Widget build(BuildContext context){final pages=[Dashboard(store:widget.store,onNavigate:(v)=>setState(()=>tab=v)),PathScreen(store:widget.store),ReviewScreen(store:widget.store),ProfileScreen(store:widget.store)];return Scaffold(body:SafeArea(child:pages[tab]),bottomNavigationBar:NavigationBar(selectedIndex:tab,onDestinationSelected:(v)=>setState(()=>tab=v),destinations:const[NavigationDestination(icon:Icon(Icons.home_outlined),selectedIcon:Icon(Icons.home),label:'خانه'),NavigationDestination(icon:Icon(Icons.route_outlined),selectedIcon:Icon(Icons.route),label:'مسیر'),NavigationDestination(icon:Icon(Icons.style_outlined),selectedIcon:Icon(Icons.style),label:'مرور'),NavigationDestination(icon:Icon(Icons.person_outline),selectedIcon:Icon(Icons.person),label:'پروفایل') ]));}}

class Dashboard extends StatelessWidget {final AppStore store;final ValueChanged<int> onNavigate;const Dashboard({super.key,required this.store,required this.onNavigate});@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.fromLTRB(20,16,20,24),children:[Row(children:[Container(width:44,height:44,decoration:BoxDecoration(color:violet.withOpacity(.12),borderRadius:BorderRadius.circular(14)),child:const Icon(Icons.auto_awesome,color:violet)),const SizedBox(width:10),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('POUYANLY',textDirection:TextDirection.ltr,style:TextStyle(letterSpacing:2,fontWeight:FontWeight.w900,color:violet)),Text('مسیر یادگیری تو') ])),IconButton(onPressed:()=>onNavigate(3),icon:const Icon(Icons.settings_outlined))]),const SizedBox(height:24),Text('سلام! آماده‌ای ادامه بدیم؟',style:Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight:FontWeight.w900)),const SizedBox(height:6),Text('هر روز کمی تمرین، یک قدم به تسلط نزدیک‌تر.',style:TextStyle(color:Colors.grey.shade600)),const SizedBox(height:20),Container(padding:const EdgeInsets.all(20),decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF6558D3),Color(0xFF8578E8)]),borderRadius:BorderRadius.circular(24)),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('سطح فعلی',style:TextStyle(color:Colors.white70)),Container(padding:const EdgeInsets.symmetric(horizontal:12,vertical:6),decoration:BoxDecoration(color:Colors.white.withOpacity(.18),borderRadius:BorderRadius.circular(30)),child:Text(store.cefr,style:const TextStyle(color:Colors.white,fontWeight:FontWeight.bold)))]),const SizedBox(height:16),Text('${store.xp} XP',style:const TextStyle(color:Colors.white,fontSize:30,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text('${store.completedLessons} درس تکمیل‌شده  •  هدف روزانه ${store.dailyMinutes} دقیقه',style:const TextStyle(color:Colors.white70)),const SizedBox(height:16),ClipRRect(borderRadius:BorderRadius.circular(8),child:LinearProgressIndicator(value:(store.completedLessons%5)/5,minHeight:8,backgroundColor:Colors.white24,color:Colors.white))])),const SizedBox(height:18),Row(children:[StatCard(icon:Icons.local_fire_department,color:Colors.orange,label:'روز متوالی',value:'${store.streak}'),const SizedBox(width:10),StatCard(icon:Icons.monetization_on,color:const Color(0xFFE6AD32),label:'سکه‌ها',value:'${store.coins}'),const SizedBox(width:10),StatCard(icon:Icons.bolt,color:violet,label:'امتیاز',value:'${store.xp}')]),const SizedBox(height:24),Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[const Text('برنامه امروز',style:TextStyle(fontSize:19,fontWeight:FontWeight.w900)),Text('${store.dailyMinutes} دقیقه',style:const TextStyle(color:violet,fontWeight:FontWeight.bold))]),const SizedBox(height:12),Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(children:[Row(children:[Container(width:48,height:48,decoration:BoxDecoration(color:mint.withOpacity(.12),borderRadius:BorderRadius.circular(15)),child:const Icon(Icons.menu_book_rounded,color:mint)),const SizedBox(width:12),const Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[Text('درس پیشنهادی',style:TextStyle(fontWeight:FontWeight.w800)),Text('Daily routines • واژگان و حال ساده',style:TextStyle(fontSize:12,color:Colors.grey))])),const Text('۸ دقیقه',style:TextStyle(fontSize:12,color:Colors.grey))]),const SizedBox(height:16),SizedBox(width:double.infinity,child:FilledButton(onPressed:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonScreen(store:store))),child:const Text('شروع درس')))]))),const SizedBox(height:14),Card(child:ListTile(leading:const Icon(Icons.refresh_rounded,color:violet),title:const Text('مرور هوشمند لغات',style:TextStyle(fontWeight:FontWeight.bold)),subtitle:const Text('لغات را از حافظه کوتاه‌مدت به بلندمدت منتقل کن.'),trailing:const Icon(Icons.chevron_left),onTap:()=>onNavigate(2))),const SizedBox(height:14),Card(child:ListTile(leading:const Icon(Icons.map_outlined,color:mint),title:const Text('ادامه مسیر یادگیری'),subtitle:const Text('واحدها و درس‌های بعدی را ببین.'),trailing:const Icon(Icons.chevron_left),onTap:()=>onNavigate(1)))]);}

class StatCard extends StatelessWidget{final IconData icon;final Color color;final String label,value;const StatCard({super.key,required this.icon,required this.color,required this.label,required this.value});@override Widget build(BuildContext context)=>Expanded(child:Container(padding:const EdgeInsets.symmetric(vertical:14,horizontal:8),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(18)),child:Column(children:[Icon(icon,color:color),const SizedBox(height:6),Text(value,style:const TextStyle(fontWeight:FontWeight.w900,fontSize:18)),Text(label,style:TextStyle(fontSize:10,color:Colors.grey.shade600))])));}

class PathScreen extends StatelessWidget{final AppStore store;const PathScreen({super.key,required this.store});final units=const [('A1','شروع هوشمند','سلام و معرفی، اطلاعات شخصی، زمان حال ساده'),('A2','زندگی روزمره','برنامه روزانه، خرید، سفر و ارتباط'),('B1','ارتباط مستقل','تجربه‌ها، برنامه‌ها و بیان نظر'),('B2','انگلیسی پیشرفته','بحث، استدلال و متن‌های پیچیده'),('C1','تسلط حرفه‌ای','زبان آکادمیک و ظرافت‌های معنا'),('C2','نزدیک به بومی','درک و تولید زبان در سطح بسیار پیشرفته')];@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[const Text('نقشه یادگیری',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900)),const SizedBox(height:6),Text('از ${store.cefr} شروع کن؛ مسیر با پیشرفتت باز می‌شود.',style:TextStyle(color:Colors.grey.shade600)),const SizedBox(height:20),...units.map((u){final unlocked=['A1','A2'].contains(u.$1)||u.$1==store.cefr;final done=store.completedUnits.contains('unit1')&&u.$1=='A1';return Padding(padding:const EdgeInsets.only(bottom:12),child:Card(child:ListTile(contentPadding:const EdgeInsets.all(14),leading:Container(width:48,height:48,alignment:Alignment.center,decoration:BoxDecoration(color:unlocked?violet.withOpacity(.12):Colors.grey.withOpacity(.12),borderRadius:BorderRadius.circular(15)),child:Text(u.$1,style:TextStyle(color:unlocked?violet:Colors.grey,fontWeight:FontWeight.w900))),title:Text(u.$2,style:const TextStyle(fontWeight:FontWeight.w800)),subtitle:Text(u.$3,style:const TextStyle(fontSize:11,height:1.5)),trailing:Icon(done?Icons.check_circle:unlocked?Icons.play_circle_outline:Icons.lock_outline,color:done?mint:unlocked?violet:Colors.grey),onTap:unlocked?()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonScreen(store:store))):null)));})]);}

class LessonScreen extends StatefulWidget{final AppStore store;const LessonScreen({super.key,required this.store});@override State<LessonScreen> createState()=>_LessonScreenState();}
class _LessonScreenState extends State<LessonScreen>{int step=0;String? choice;bool done=false;final qs=[('I ___ up at seven every morning.',['wake','wakes','waking','woke'],'wake','با I از شکل ساده فعل استفاده می‌کنیم. برای he/she/it در حال ساده معمولاً s اضافه می‌شود.'),('معنی «get dressed» چیست؟',['لباس پوشیدن','صبحانه خوردن','بیدار شدن','به خواب رفتن'],'لباس پوشیدن','Get dressed یعنی لباس پوشیدن؛ مثلاً I get dressed after breakfast.'),('کدام جمله درباره عادت روزانه درست است؟',['She go to work.','She goes to work.','She going to work.','She gone to work.'],'She goes to work.','برای سوم‌شخص مفرد (she) در حال ساده به فعل s اضافه می‌کنیم.')];@override Widget build(BuildContext context){final q=qs[step];return Scaffold(appBar:AppBar(title:const Text('Daily routines'),leading:IconButton(onPressed:()=>Navigator.pop(context),icon:const Icon(Icons.close))),body:Padding(padding:const EdgeInsets.all(22),child:done?Column(mainAxisAlignment:MainAxisAlignment.center,children:[const Icon(Icons.celebration_rounded,color:violet,size:72),const SizedBox(height:18),const Text('درس عالی بود!',style:TextStyle(fontSize:27,fontWeight:FontWeight.w900)),const SizedBox(height:8),const Text('۲۵ XP و ۱۰ سکه دریافت کردی.'),const SizedBox(height:22),SizedBox(width:double.infinity,child:FilledButton(onPressed:()=>Navigator.pop(context),child:const Text('بازگشت به خانه')))]):Column(crossAxisAlignment:CrossAxisAlignment.start,children:[LinearProgressIndicator(value:(step+1)/qs.length,minHeight:6),const SizedBox(height:24),Text('تمرین ${step+1} از ${qs.length}',style:TextStyle(color:Colors.grey.shade600)),const SizedBox(height:22),Text(q.$1,style:const TextStyle(fontSize:23,fontWeight:FontWeight.w900,height:1.5)),const SizedBox(height:20),...q.$2.map((o)=>Padding(padding:const EdgeInsets.only(bottom:10),child:OptionButton(text:o,selected:choice==o,correct:choice!=null&&o==q.$3,onTap:()=>setState(()=>choice=o)))),if(choice!=null)Container(padding:const EdgeInsets.all(14),decoration:BoxDecoration(color:(choice==q.$3?mint:Colors.orange).withOpacity(.1),borderRadius:BorderRadius.circular(15)),child:Text('${choice==q.$3?'درست گفتی!':'پاسخ درست: ${q.$3}'}\n${q.$4}',style:const TextStyle(height:1.6))),const Spacer(),SizedBox(width:double.infinity,child:FilledButton(onPressed:choice==null?null:()async{if(step<qs.length-1){setState(() { step++; choice = null; });}else{await widget.store.completeLesson();if(!mounted)return;setState(()=>done=true);}},child:Text(step==qs.length-1?'پایان درس':'ادامه')))])));}}

class ReviewScreen extends StatefulWidget{final AppStore store;const ReviewScreen({super.key,required this.store});@override State<ReviewScreen> createState()=>_ReviewScreenState();}
class _ReviewScreenState extends State<ReviewScreen>{int index=0;bool reveal=false;@override void initState(){super.initState();if(widget.store.reviewWords.isEmpty){widget.store.reviewWords=[{'word':'reliable','meaning':'قابل اعتماد','example':'She is a reliable friend.','translation':'او دوست قابل اعتمادی است.','mastery':1},{'word':'improve','meaning':'بهبود دادن','example':'I want to improve my English.','translation':'می‌خواهم انگلیسی‌ام را بهتر کنم.','mastery':0},{'word':'although','meaning':'اگرچه','example':'Although it was late, we continued.','translation':'اگرچه دیر بود، ادامه دادیم.','mastery':2}];widget.store.save();}}@override Widget build(BuildContext context){final words=widget.store.reviewWords;if(words.isEmpty)return const Center(child:Text('فعلاً لغتی برای مرور نداری.'));final w=words[index%words.length];return ListView(padding:const EdgeInsets.all(20),children:[const Text('مرور هوشمند',style:TextStyle(fontSize:26,fontWeight:FontWeight.w900)),const SizedBox(height:5),Text('یادآوری فعال؛ قبل از دیدن معنی، خودت تلاش کن.',style:TextStyle(color:Colors.grey.shade600)),const SizedBox(height:24),Container(padding:const EdgeInsets.all(24),decoration:BoxDecoration(color:Theme.of(context).cardColor,borderRadius:BorderRadius.circular(24)),child:Column(children:[Text(w['word'],textDirection:TextDirection.ltr,style:const TextStyle(fontSize:32,fontWeight:FontWeight.w900,color:violet)),const SizedBox(height:18),if(reveal)...[Text(w['meaning'],style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),const SizedBox(height:15),Text(w['example'],textDirection:TextDirection.ltr,style:const TextStyle(fontSize:17)),const SizedBox(height:5),Text(w['translation'],style:TextStyle(color:Colors.grey.shade600)),const SizedBox(height:14),Text('میزان تسلط: ${w['mastery']}/۵',style:const TextStyle(fontSize:12,color:violet))]else const Text('معنی این واژه را به خاطر بیاور…',style:TextStyle(color:Colors.grey)),const SizedBox(height:24),if(!reveal)FilledButton(onPressed:()=>setState(()=>reveal=true),child:const Text('نمایش پاسخ'))else Row(children:[Expanded(child:OutlinedButton(onPressed:()async{await widget.store.markWordReviewed(index % words.length,false);setState(()=>{index++,reveal=false});},child:const Text('سخت بود'))),const SizedBox(width:10),Expanded(child:FilledButton(onPressed:()async{await widget.store.markWordReviewed(index % words.length,true);setState(()=>{index++,reveal=false});},child:const Text('بلد بودم')))])])),const SizedBox(height:18),Center(child:Text('کارت ${index+1}  •  ${words.length} واژه در مجموعه',style:TextStyle(color:Colors.grey.shade600))) ]);}}

class ProfileScreen extends StatelessWidget{final AppStore store;const ProfileScreen({super.key,required this.store});@override Widget build(BuildContext context)=>ListView(padding:const EdgeInsets.all(20),children:[const Text('پروفایل و تنظیمات',style:TextStyle(fontSize:25,fontWeight:FontWeight.w900)),const SizedBox(height:18),Card(child:ListTile(leading:const CircleAvatar(backgroundColor:Color(0xFFEEEAFE),child:Icon(Icons.person,color:violet)),title:Text('زبان‌آموز ${store.cefr}',style:const TextStyle(fontWeight:FontWeight.bold)),subtitle:Text('${store.goal} • روزانه ${store.dailyMinutes} دقیقه'))),const SizedBox(height:14),Card(child:Column(children:[SwitchListTile(value:store.darkMode,onChanged:(v)async{store.darkMode=v;await store.save();},title:const Text('حالت تاریک'),secondary:const Icon(Icons.dark_mode_outlined)),const Divider(height:1),SwitchListTile(value:store.reminderEnabled,onChanged:(v)async{store.reminderEnabled=v;await store.save();},title:const Text('یادآور مطالعه'),subtitle:const Text('تنظیم یادآور محلی در نسخه بعدی فعال می‌شود.'),secondary:const Icon(Icons.notifications_active_outlined)),const Divider(height:1),ListTile(leading:const Icon(Icons.schedule),title:const Text('زمان مطالعه'),subtitle:Text('${store.studyTime} • ${store.dailyMinutes} دقیقه'))])),const SizedBox(height:14),Card(child:Column(children:[ListTile(leading:const Icon(Icons.bar_chart),title:const Text('آمار یادگیری'),subtitle:Text('${store.completedLessons} درس • ${store.xp} XP • ${store.coins} سکه')),const Divider(height:1),ListTile(leading:const Icon(Icons.assessment_outlined),title:const Text('نتیجه آزمون تعیین سطح'),subtitle:Text('سطح ${store.cefr}'),onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>ResultsScreen(store:store))))])),const SizedBox(height:18),const Center(child:Text('POUYANLY  •  نسخه آزمایشی ۰.۱.۰',style:TextStyle(color:Colors.grey,fontSize:12))) ]);}
