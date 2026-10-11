# 🎛️ Smart Masjid Admin — لوحة التحكم السحابية لشاشات المساجد

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture%20(Feature--Based)-0D6B4B)
![State Management](https://img.shields.io/badge/State%20Management-Cubit%20%2F%20BLoC-blueviolet)
![Firebase](https://img.shields.io/badge/Firebase-Auth%20%26%20Firestore-FFCA28?logo=firebase&logoColor=black)
![Responsive](https://img.shields.io/badge/UI-Adaptive%20(Mobile%20%26%20Web%2FDesktop)-success)

تطبيق **Smart Masjid Admin (`masjid_admin`)** هو لوحة التحكم السحابية المخصّصة لإدارة نظام شاشات المساجد الذكي (**Smart Masjid TV**) عن بُعد وفي الوقت الفعلي (Real-Time). يتيح لإمام المسجد أو المشرف التحكم الكامل في محتوى الشاشة، أوقات الإقامة، البث المباشر الفوري للآيات والأحاديث، الشريط الإخباري السفلي، وضبط التاريخ الهجري حسب الرؤية الشرعية من خلال الهاتف المحمول أو المتصفح/الكمبيوتر.

---

## ✨ المميزات الرئيسية (Key Features)

### 1. 📚 إدارة مجموعات العرض والأذكار (`Collections Management`)
- إنشاء مجموعات عرض جديدة، تعديل عناوينها الظاهرة على الشاشة، تفعيلها أو إيقافها، أو حذفها.
- **إعادة الترتيب بالسحب والإفلات (`Drag & Drop Reordering`)**: تحديد أولوية ظهور المجموعات بالتناوب على شاشة المسجد.
- **قسم خاص للأذكار الثابتة**: تحكم مباشر في نصوص **أذكار بعد الصلاة**، **أذكار الصباح**، و**أذكار المساء**.
- حماية ذكية تمنع إيقاف أو حذف المجموعة الوحيدة النشطة لضمان عدم بقاء شاشة المسجد فارغة.

### 2. 📝 إدارة النصوص والبث المباشر الفوري (`Messages & Live Broadcast`)
- إضافة وتعديل وحذف وترتيب الآيات والأحاديث والأدعية مع تحديد:
  - النص الأساسي، المصدر/الراوي (`subText`)، والفضل/الشرح (`fadl`).
  - مدة بقاء النص على الشاشة بالثواني (`duration`).
  - حجم الخط المخصص (`fontSize`) أو تركه فارغاً ليتم تحجيمه تلقائياً حسب طول النص على الشاشة.
- **محرك بحث عربي ذكي بدون تشكيل (`Tashkeel-Insensitive Arabic Search`)**: بحث فوري داخل النصوص يتجاهل الحركات والتشكيل وعلامات الوقف القرآنية ويوحّد أشكال الهمزات والألف والتاء المربوطة.
- **ميزة البث المباشر (`Live Cast`)**: بضغطة زر واحدة، يمكن للإمام تثبيت آية أو حديث معيّن ليظهر فوراً على شاشة المسجد (أثناء درس أو موعظة) وإيقافه في أي وقت للعودة للتبديل التلقائي.

### 3. ⏱️ ضبط أوقات الإقامة (`Iqama Countdown Settings`)
- التحكم في دقائق الانتظار بين الأذان والإقامة لكل صلاة من الصلوات الخمس (`الفجر`, `الظهر`, `العصر`, `المغرب`, `العشاء`).
- أزرار اختيار سريعة (`Quick Presets`) مع شريط تمرير (`Slider`) وأزرار زيادة/نقصان دقيقة بدقيقة.
- تحديث فوري على شاشة المسجد فور الحفظ دون الحاجة لإعادة تشغيل الشاشة.

### 4. 📰 الشريط الإخباري وضبط التقويم الهجري (`Ticker & Hijri Offset`)
- **إدارة الشريط السفلي**: إضافة تنبيهات وإعلانات المسجد، تفعيل/إخفاء أي رسالة مؤقتاً، وترتيب ظهورها بالسحب والإفلات.
- **معاينة حية (`Live Ticker Preview`)**: شريط معاينة داخل لوحة التحكم يعرض كيف ستظهر الرسائل المفعّلة متصلة ببعضها على شاشة المسجد.
- **ضبط التاريخ الهجري حسب الرؤية الشرعية (`Hijri Offset`)**: تقديم أو تأخير التاريخ الهجري (`-2`, `-1`, `0 تلقائي`, `+1`, `+2` يوم) مع انعكاس التغيير لحظياً على شاشة المسجد.

### 5. 🎨 تصميم متجاوب بهوية بصرية احترافية (`Adaptive Emerald & Gold UI`)
- واجهة مستخدم مبنية بنظام تصميم موحّد (`AdminTheme`) يجمع بين الزمردي الملكي والذهبي الدافئ مع خط `Tajawal`.
- **تخطيط متجاوب (`AdaptiveScaffold`)**: يتحول تلقائياً بين شريط جانبي احترافي (`Sidebar`) على شاشات الويب والكمبيوتر، وشريط تنقل سفلي (`Bottom NavigationBar`) على الهواتف الذكية.
- **نظام تحديث إصدارات ذكي (`VersionBumper`)**: يرفع رقم إصدار القسم المعدّل فقط (`messages_version`, `iqama_version`, `ticker_version`) في Firestore لتقليل استهلاك البيانات على شاشة المسجد.

---

## 🏗️ الهيكلة المعمارية (Clean Architecture + Cubit)

تم تطوير التطبيق باستخدام **Feature-Based Clean Architecture** مع **`flutter_bloc` (Cubit)**:

```text
lib/
├── core/
│   ├── theme/            # نظام التصميم الموحد (AdminTheme - Emerald & Gold)
│   ├── utils/            # أداة رفع إصدارات الكاش السحابي (VersionBumper)
│   └── widgets/          # الهيكل المتجاوب للموبايل والديسكتوب (AdaptiveScaffold)
└── features/
    ├── auth/             # المصادقة السحابية التلقائية (Firebase Anonymous Auth)
    ├── collections/      # إدارة المجموعات وترتيبها
    │   ├── domain/       # CollectionItem Entity & CollectionsRepository
    │   ├── data/         # CollectionItemModel & CollectionsRepositoryImpl
    │   └── presentation/ # CollectionsCubit, CollectionsState, CollectionsScreen
    ├── messages/         # إدارة النصوص، البحث الذكي، والبث المباشر
    │   ├── domain/       # AdminMessage, LiveDisplayState, MessagesRepository
    │   ├── data/         # AdminMessageModel & MessagesRepositoryImpl
    │   └── presentation/ # MessagesCubit, MessagesState, MessagesScreen
    ├── iqama/            # إدارة أوقات الإقامة للصلوات الخمس
    │   ├── domain/       # IqamaRepository
    │   ├── data/         # IqamaRepositoryImpl
    │   └── presentation/ # IqamaCubit, IqamaState, IqamaScreen
    ├── ticker/           # إدارة الشريط الإخباري والفارق الهجري
    │   ├── domain/       # AdminTickerItem & AdminTickerRepository
    │   ├── data/         # AdminTickerItemModel & AdminTickerRepositoryImpl
    │   └── presentation/ # AdminTickerCubit, AdminTickerState, TickerScreen
    └── dashboard/        # الشاشة الرئيسية المجمّعة (DashboardScreen)
```

---

## 🧪 الاختبارات والفحص (Testing & Static Analysis)

يحتوي المشروع على اختبارات وحدات (`Unit Tests`) لجميع الـ Cubits (`CollectionsCubit`, `MessagesCubit`, `IqamaCubit`, `AdminTickerCubit`):

```bash
flutter test
dart analyze
```

---

## 🚀 طريقة التشغيل (Getting Started)

1. تثبيت الحزم:
   ```bash
   flutter pub get
   ```
2. تشغيل لوحة التحكم (موبايل / ويب / ويندوز):
   ```bash
   flutter run
   ```
