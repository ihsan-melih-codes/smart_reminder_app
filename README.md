# Smart Reminder

Smart Reminder, Flutter ile geliştirilmiş çok ekranlı bir hatırlatıcı uygulamasıdır. Uygulama; hatırlatıcı oluşturma, listeleme, arama, silme, öncelik belirleme ve Android üzerinde zamanlanmış yerel bildirim gönderme özelliklerini içerir. Veriler cihaz üzerinde Hive veritabanında saklanır.

## Kullanılan Teknolojiler

- **Flutter**: Mobil ve web arayüzlerinin geliştirilmesi için kullanılmıştır.
- **Dart**: Uygulamanın ana programlama dilidir.
- **Material Design 3**: Tema, buton, form, kart ve menü gibi arayüz bileşenlerinde kullanılmıştır.
- **Hive**: Hatırlatıcıların cihaz üzerinde kalıcı olarak saklanmasını sağlar.
- **Hive Flutter**: Hive veritabanının Flutter uygulaması içinde kolay başlatılması ve dinlenmesi için kullanılmıştır.
- **Hive Generator / Build Runner**: `Reminder` modelinin Hive adapter kodunun üretilmesi için kullanılmıştır.
- **Flutter Local Notifications**: Android tarafında yerel bildirim oluşturmak ve zamanlamak için kullanılmıştır.
- **Timezone**: Bildirimlerin seçilen tarih ve saate göre zamanlanmasını destekler.
- **Flutter Lints**: Kod kalitesi ve standart Flutter kurallarının korunması için kullanılmıştır.

## Mimari Yapı

Proje, Flutter'ın temel klasör yapısı üzerine sade ve okunabilir bir mimariyle kurulmuştur. Kodlar görevlerine göre `models`, `screens`, `services` ve `widgets` klasörlerine ayrılmıştır.

```text
lib/
├── main.dart
├── models/
│   ├── reminder.dart
│   └── reminder.g.dart
├── screens/
│   ├── home_screen.dart
│   ├── add_note_screen.dart
│   └── info_screen.dart
├── services/
│   ├── notification_service.dart
│   ├── notification_service_mobile.dart
│   └── notification_service_web.dart
└── widgets/
    └── custom_design_container.dart
```

- `main.dart`: Hive veritabanını, model adapter'ını ve bildirim servisini başlatır. Uygulama rotalarını tanımlar.
- `models/reminder.dart`: Hatırlatıcı veri modelini içerir.
- `screens/home_screen.dart`: Kayıtlı hatırlatıcıları listeler, arama ve silme işlemlerini yönetir.
- `screens/add_note_screen.dart`: Yeni hatırlatıcı ekleme formunu içerir.
- `screens/info_screen.dart`: Uygulamanın ödev/proje özelliklerini açıklayan bilgi ekranıdır.
- `services/notification_service.dart`: Platforma göre doğru bildirim servisinin seçilmesini sağlar.
- `services/notification_service_mobile.dart`: Android için gerçek yerel bildirim işlemlerini yapar.
- `services/notification_service_web.dart`: Web platformunda bildirim fonksiyonları için uyumlu boş servis sağlar.
- `widgets/custom_design_container.dart`: Form alanlarında tekrar kullanılan özel tasarım kapsayıcı bileşendir.

## Özellikler

- Hatırlatıcı ekleme
- Başlık ve açıklama girme
- Düşük, orta ve yüksek öncelik seçme
- Tarih ve saat seçerek hatırlatma zamanı belirleme
- Hatırlatıcıları kalıcı olarak kaydetme
- Hatırlatıcıları tarihe göre sıralı listeleme
- Başlık, açıklama veya önceliğe göre arama yapma
- Hatırlatıcı silme
- Silinen hatırlatıcıya ait bildirimi iptal etme
- Android üzerinde zamanlanmış yerel bildirim kurma
- Web üzerinde kayıt, listeleme, arama ve silme özelliklerini kullanma
- Drawer menü ile ekranlar arasında geçiş yapma
- Boş liste ve arama sonucu bulunamadı durumları için kullanıcı arayüzü gösterme

## Kullanıcı Sistemi

Uygulamada üyelik, giriş yapma veya uzak sunucuya bağlı kullanıcı hesabı sistemi bulunmamaktadır. Smart Reminder tek kullanıcı mantığıyla çalışır. Kullanıcının oluşturduğu hatırlatıcılar sadece kullanılan cihazda veya tarayıcı ortamında saklanır.

Bu yapı sayesinde uygulama çevrimdışı kullanılabilir. Kullanıcı verileri herhangi bir sunucuya gönderilmez; kayıtlar yerel Hive veritabanında tutulur.

## Veritabanı

Veritabanı olarak Hive kullanılmaktadır. Uygulama açılırken `main.dart` içinde Hive başlatılır, `ReminderAdapter` kaydedilir ve `remindersBox` isimli kutu açılır.

`Reminder` modeli şu alanlardan oluşur:

- `title`: Hatırlatıcının başlığı
- `description`: Hatırlatıcının açıklaması
- `dateTime`: Bildirim veya hatırlatma zamanı
- `priority`: Hatırlatıcının öncelik seviyesi

Hatırlatıcı eklendiğinde veri `Hive.box<Reminder>('remindersBox')` üzerinden kaydedilir. Ana ekranda `ValueListenableBuilder` kullanılarak Hive kutusu dinlenir; yeni kayıt, silme veya değişiklik olduğunda liste otomatik olarak güncellenir.

## Bildirim Sistemi

Bildirim sistemi platforma göre ayrılmıştır:

- Android tarafında `flutter_local_notifications` paketi kullanılır.
- Bildirimler `zonedSchedule` ile seçilen tarih ve saate göre zamanlanır.
- Bildirim kanalı `reminder_channel` adıyla oluşturulur.
- Bildirimlerde uygulama simgesi kullanılır.
- Geçmiş bir tarih seçilirse bildirim zamanlanmaz.
- Hatırlatıcı silindiğinde aynı ID'ye sahip bildirim de iptal edilir.

Web platformunda tarayıcı uyumluluğu için ayrı bir servis dosyası kullanılmıştır. Web servisinde bildirim fonksiyonları boş çalışır; bu nedenle web sürümünde hatırlatıcı kaydı yapılır ancak yerel bildirim kurulmaz.

## State Management

Projede harici bir state management paketi kullanılmamıştır. State yönetimi Flutter'ın kendi yapılarıyla sağlanmıştır:

- `StatefulWidget`: Ana ekran ve hatırlatıcı ekleme ekranında ekran durumunu yönetir.
- `setState`: Arama metni, seçilen tarih/saat ve öncelik değişimlerini arayüze yansıtır.
- `TextEditingController`: Form alanları ve arama kutusu değerlerini takip eder.
- `ValueListenableBuilder`: Hive veritabanındaki değişiklikleri dinleyerek hatırlatıcı listesini otomatik günceller.
- `Navigator`: Ekran geçişlerini ve hatırlatıcı kaydedildikten sonra mesaj dönmeyi sağlar.

Bu yaklaşım, uygulamanın kapsamı için yeterli ve anlaşılır bir state management yapısı sunar.

## Ekranlar

- **Ana ekran**: Hatırlatıcıları listeler, arama yapar ve kayıt siler.
- **Yeni hatırlatıcı ekranı**: Başlık, açıklama, öncelik, tarih ve saat bilgisi alarak yeni kayıt oluşturur.
- **Bilgi ekranı**: Uygulamanın proje gereksinimlerini nasıl karşıladığını açıklar.

## Çalıştırma

Bağımlılıkları yüklemek için:

```bash
flutter pub get
```

Android veya varsayılan cihaz üzerinde çalıştırmak için:

```bash
flutter run
```

Web üzerinde çalıştırmak için:

```bash
flutter run -d chrome
```

Web çıktısı almak için:

```bash
flutter build web
```

Hive adapter kodunu yeniden üretmek gerekirse:

```bash
flutter pub run build_runner build
```
