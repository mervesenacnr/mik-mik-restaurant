# Mik Mik · Lunch Rush

Godot 4.7.1 ile yapılmış tek oyunculu, üstten açılı 3D restoran/sürü savunma roguelike prototipi. Fare şefle servis yaparken çevrenden gelen kedi ve köpek sürülerinden kaçarsın. Tüm restoran işlemleri ve silahlar otomatik çalışır.

## Oyna

`Oyna.command` dosyasını çalıştır veya `project.godot` dosyasını Godot ile açıp F5 kullan. Menüde **Mutfağı aç** düğmesine tıkla.

- **WASD veya yön tuşları:** hareket.
- **Space:** dash; dash boyunca hasar koruması.
- **ESC:** duraklatma menüsünü aç/kapat. Zorunlu yükseltme seçimini atlamaz.
- **Fareyle kart seç:** mutfak veya savaş yükseltmesi.
- Sağ üst düğmeler: mola ve ses.

## Fareler, kıyafetler ve kalıcı ilerleme

Başlangıç menüsünde üç sekme bulunur: **Fareler & stil**, **Başlangıç statları**, **Başarımlar**. Tüm karakterler faredir; tüy ve kıyafet rengi dörder uyumlu paletten seçilir, 3D önizleme anında güncellenir. Dört göz şekli (yuvarlak, keskin, uykulu, oval) seçilebilir. Renkler, göz şekli, karakter, kıyafet ve zorluk seçimi kaydedilir. Eski RGB kayıtları en yakın palet rengine taşınır.

| Fare | Başlangıç özelliği | Açılış |
| --- | --- | --- |
| Mik | Dengeli başlangıç | Başlangıçta açık |
| Zıp | %15 hızlı, +1 tabak | Toplam 10 servis |
| Tok | +24 can, %15 silah hasarı, %8 daha yavaş | Toplam 75 düşman |
| Nane | %25 pişirme, %20 temizlik hızı | Toplam 50 servis |

Şef kıyafeti başlangıçta açıktır. Gezgin kıyafeti 10 servis, Muhafız 75 düşman, Kraliyet ilk zafer ile açılır. Kıyafetler kozmetiktir; karakter bonuslarını değiştirmez. Altı başarımın koşulları, ilerlemesi ve ödülleri menüde görünür. Açıldığında oyun içinde kısa bir bildirim gösterilir. Başarımlar koşular arasında birikir.

**Kalıcı bahşiş:** servis başına 1, her 10 düşmanda 1, zaferde 30; dördüncü vardiyaya ilk ulaşmada 20, ilk zor zaferde 50 ek bahşiş. Bu kasa koşu altını ve iki XP havuzundan ayrıdır. Can (+8), hareket (+%3), silah hasarı (+%5), pişirme (+%5), temizlik (+%5) eğitimlerinin her biri beş kademedir. Kademeler 10/20/30/40/50 bahşiş tutar; bonuslar yeni koşuda uygulanır ve eşya slotu kullanmaz. Aynı eğitimin kademeleri toplanır, karakter bonusuyla çarpılır.

| Zorluk | Düşman canı | Hasar | Hız | Akın başına ek düşman | Açılış |
| --- | --- | --- | --- | --- | --- |
| Öğle | ×1 | ×1 | ×1 | 0 | Başlangıç |
| Yoğun mesai | ×1,35 | ×1,25 | ×1,15 | 2 | Başlangıç |
| Kâbus | ×1,8 | ×1,6 | ×1,3 | 4 | İlk zafer |

Profil `user://mik_profile.cfg` içinde, eski altın rekorundan ayrı tutulur. Kirli profil en geç üç saniyede bir, koşu sonu, yeniden başlama ve normal pencere kapanışında kaydedilir. Ani işlem sonlandırmada son üç saniyelik ilerleme kaybolabilir. Yeni özellikler eski rekor kaydını silmez. Başarımlar yereldir; Steam/platform entegrasyonu içermez.

## Büyük harita ve kamera

64 × 52 birimlik restoran bahçesi, on masa ve mutfak pavyonu. Masalar arasında en az 8 birim vardır. Kamera önceki sürümdeki **23,5 ortografik boyutu ve bakış açısını** korur; karakteri yumuşakça izler. Haritanın tamamını aynı anda göstermek için uzaklaşmaz.

Ekran kenarında yuvarlak müşteri portreleri, yön okları, yemek/işlem rozetleri ve sabır halkaları görünür. Masalarda metin yerine sipariş defteri, fırın, tabak, çatal-kaşık ve sünger sembolleri kullanılır. Sol üstte mutfak ve savaş için altışar eşya slotu ve ayrı XP çubukları vardır. Eşya üzerine gelince açıklaması açılır.

Yol yükseltmeleri aynı haritada birleştirilir: orta bölmeleri kaldıran bulvar, mutfaktan bahçeye uzanan hız hattı, iki dış kanadı bağlayan fare tünelleri.

## Otomatik restoran döngüsü

1. Masaya yaklaş ve kısa süre dur: sipariş alınır.
2. Mutfak kendi pişirir. Tezgâhın önüne yaklaşınca hazır yemekleri tepsine alırsın.
3. İlgili masaya yaklaş: tabak masaya yay çizerek gider, müşteri yemeye başlar.
4. Yemek bitince altın, mutfak XP’si ve 4 can kazanırsın. Kirli masaya yaklaşarak temizle.

Peynir burger, sebzeli pizza, balkabağı çorbası ve peynir tabağı ayrı 3D modellerdir. Aynı yemek mutfakta, tepside ve masada görünür. Buhar çıkar, porsiyonlar yenildikçe azalır; müşteriler el–ağız ve çiğneme animasyonu yapar. Kart seçiminden sonra farede kısa sıçrama, ışık halkaları ve kıvılcım animasyonu oynar.

## Çevreleyen hayvan sürüleri

Düşmanlar iki kapıdan tek tek değil, karakterin çevresindeki sekiz sektörden kamera dışında doğar. Açılışta 8 saniye hazırlık verilir; düşmanların yaklaşması ayrıca zaman alır. Her akında 4–9 hayvan gelir, akın aralıkları vardiyalarla kısalır. En fazla 96 normal hayvan ve final boss’u bulunur.

| Vardiya | Sürü |
| --- | --- |
| 1 | Sokak kedileri |
| 2 | Kedi ve sokak köpeği |
| 3 | Kara kediler ve sopalı insanlar |
| 4 | Zırhlı buldoglar ve sopalı insanlar |
| 5 | Tilkiler ve seyrek sopalı insanlar |
| 6 | Karışık alfa sürüsü ve Kazan Kıran adlı büyük buldog |

Hayvanlar mobilyaları dolaşır ve birbirlerinden ayrılarak yaklaşır. Kırmızı halka, kısa hazırlıktan sonra gerçekleşecek saldırıyı gösterir. Dash veya hareketle dışına çık. Hasardan sonra kısa dokunulmazlık vardır.

## İki ayrı XP, iki ayrı seçim

**Mutfak XP’si (yeşil):** tamamlanan yemekten gelir. Normal servis 2, öğrenci servisi 3 XP verir. Sadece karakterin servis özellikleri, restoran, müşteri ve yol kartları sunulur.

**Savaş XP’si (mor):** yalnızca canavar yenmekten gelir. Normal hayvan 4, buldog 8, boss 30 XP verir. Yalnızca silah/savaş kartları sunulur. Canavar öldürmek altın veya mutfak XP’si kazandırmaz.

İki havuzun seviyesi, eşiği ve HUD çubuğu ayrıdır. Aynı anda kazanılan seviyeler kaynaklarıyla birlikte sıraya alınır. Seçim sırasında dünya, sabır, kamera, animasyonlar ve savaş durur. İlk savaş seviyesinde üç seçenek de yeni silahtır: bıçak, tava veya biber.

### Otomatik silahlar

- **Soda:** başlangıç silahı; menzildeki en yakın hedefe yönelen atış.
- **Şef bıçakları:** otomatik atılan, birden fazla hayvanı delen bıçaklar. Seviye arttıkça sayı ve hasar artar.
- **Dönen tavalar:** şefin etrafında dönerek temas hasarı verir. Ek seviyeler ek tava getirir.
- **Acı biber:** hareket rotanda kalan, hasar veren ve yavaşlatan bulutlar.
- **Savaş destekleri:** soda basıncı, atış hızı, silah menzili, genel hasar ve servisle tetiklenen savunma zili.

Toplam 25 kart: 17 mutfak/servis ve 8 savaş kartı. Başlangıç sodası bir savaş slotunu kullanır. Boş slotlar varken yeni eşya, dolduktan sonra sahip olunan eşyaların yükseltmeleri sunulur. Eşyalar en fazla IV seviyedir; müşteri ve yol açılımları tek seviyedir.

Köpük ustası IV, Bulaşık perisini; Denge ustası IV, Servis bandını açar. Evrim kartı yalnızca bir kez sunulur; seçilmezse bu koşuda tekrar gelmez. Seçilirse temel eşyanın slotunu devralır. Bulaşık perisi 7 saniyede uzaktan temizler, Servis bandı hazır tabakları uzaktan tepsiye alır. Bu evrimlerden önce mutfak ve kirli masalara yaklaşmak gerekir.

Sipariş alırken defter, temizlerken sünger görünür; fare ellerini hareket ettirir. Tabak alıp servis ederken kısa kol hareketi, yürürken adımlar, yemek ve güç kazanma animasyonları vardır. İnsanlar sopayı kaldırarak saldırılarını belli eder.

## Koşu sonu ve kayıt

Altı vardiya giderek zorlaşır. Kazanmak için son vardiyayı tamamlayıp Kazan Kıran’ı yen. Şefin canı veya restoranın itibarı sıfıra düşerse kaybedersin. Yeni koşuda seviyeler ve silahlar sıfırlanır; en yüksek altın rekoru `user://mik_mik.cfg` içinde saklanır. Altın bu sürümde koşu skorudur; XP yerine kullanılmaz.

## Kaynaklar ve testler

- `scripts/game.gd`: dünya, kamera, servis, UI ve iki kaynaklı ilerleme.
- `scripts/monster_system.gd`: hayvan modelleri, sürüler, yön bulma ve silahlar.
- `scripts/order_indicators.gd`: ekran dışı sipariş/sabır kartları.
- `scripts/food_visual.gd`, `scripts/power_effect.gd`: yemekler ve animasyonlar.

Harici paket veya model indirmesi gerekmez. Büyük zeminde MultiMesh, sürü ayrışmasında uzamsal hücreler kullanılır.

```sh
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -- --smoke-test
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/features_test.gd
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --script res://tests/swarm_test.gd
```

İlk test gerçek fizik kareleriyle WASD, dash, çarpışma ve servis zincirini doğrular. Diğerleri yemek/animasyon testleri, büyük harita erişimi, sabit yakınlıkta kamera takibi, çok yönlü kamera dışı doğum, tür değişimleri, XP ayrımı, bıçak/tava/biber isabeti, sipariş kartları ve 30 saniyelik sürü simülasyonunu kapsar. Testler oyuncu kaydına yazmaz.

`tests/swarm_preview.gd`, gerçek Godot çizicisinde hazırlanmış bir stres/görsel test sahnesi çalıştırır; `captures/swarm/` içine animasyon kareleri ve `captures/` içine oyun/kart görüntüleri kaydeder. Bu önizlemede silahlar ve müşteriler görsel kontrol amacıyla önceden yerleştirilir.

Bu sürüm oynanabilir prototiptir; uzun süreli oyuncu dengelemesi henüz tamamlanmadı.

## Performans ölçümü

Dalga modelleri artık tek karede topluca değil, karelere bölünerek oluşturulur. Düşmanların sabit yüz/gövde ayrıntıları önbellekli tek geometride birleştirilir; hareketli uzuvlar bağımsızdır. `tests/runtime_profile.gd` gerçek çiziciyle aktif savaş ve müşteri döngüsünde kare sürelerini ölçer. M2 üzerindeki örnek ölçümde çizim çağrısı 1598’den 1207’ye, doğum anındaki en yüksek simülasyon süresi 7,17 ms’den 3,68 ms’ye indi. Rastgele koşularda düşman sayıları farklıdır; bu sayılar kontrollü FPS garantisi değildir. Yaklaşık 118 ms’lik tekil uzun kare hâlâ gözlendi; tüm takılmaların giderildiği iddia edilmez.

`tests/loadout_test.gd` slot sınırları, evrim koşulları, tekrar sunulmama, seviye sınırları, insan dalgaları/saldırısı ve işlem animasyonlarını doğrular.

`tests/profile_test.gd`: kalıcı kasa, satın alma maliyetleri/sınırları, başarım açılımları, kayıt–yükleme, renk/kıyafet seçimi, menü düğmeleri, dört karakter, yükseltilmiş can sınırı, zorluk etkileri ve tek seferlik zafer ödülleri. `tests/profile_preview.gd` yeni menülerin gerçek Godot görüntülerini üretir; test ilerlemesi oyuncu profiline yazılmaz.

## Görsel stil

Farelerde çok katmanlı göz, kaş, diş, bıyık, yanak, burun parıltısı, dikiş ve düğme detayları bulunur. Zıp ince gövdeli, uzun ayakkabılı, kurye şapkalı ve çapraz çantalıdır. Tok geniş gövdeli, omuzluklu, eldivenli ve kemerlidir. Nane yapraklı başlık, ot çantası ve şişeler taşır. Mik çift sıra düğmeli şef kıyafeti ve gereç kılıfı kullanır. Seçilen kozmetik kıyafet karakterin temel görünümüne eklenir.

Masalara örtü şeridi, kenar halkası, peçete, çatal, baharatlık ve işlemeli minder; mutfağa raf, kavanoz, tabak istifi, fırın tuğlaları ve tencere sapları eklendi. Saksılar çiçekli ve damarlı; yiyeceklerde kızarmış ekmek, susam, marul, pizza kenarı/mantar, çorba garnitürü ve üzüm/kraker ayrıntıları vardır. Düşmanlarda yüz, yaka, zırh ve kıyafet detayları iyileştirildi. Sabit süslemeler ve yenebilir porsiyonlar birleştirilmiş geometri kullanır; porsiyon görünürlüğü ve animasyonlar bağımsız kalır.

`tests/style_test.gd` ESC ile duraklama/devam, tuş tekrarı, dört renk paleti, göz şekilleri, karakter görünümü ve ayrıntılı yemeklerin yenmesini doğrular.

## GitHub çalışma düzeni

Özel repo: https://github.com/mervesenacnr/mik-mik-restaurant . `mervesenacnr` repo sahibidir. İlk aktarım `main` üzerindedir; sonraki her güncelleme yeni bir `codex/<değişiklik>` branch üzerinde test edilip commit ve push edilir. Merge ve görünürlük değişikliği ayrıca istenmedikçe yapılmaz. Çalışma tercihi `AGENTS.md` içinde de kayıtlıdır.

Yüzler, kıyafet ayrıntıları, saksılar ve masa süslemeleri önbellekli birleştirilmiş geometri kullanır. Müşteri yüzleri koşu başlamadan hazırlanır; yeni müşteri geldiğinde ilk kez geometri birleştirme yükü oluşmaz.

Sopalı insanlar üçüncü vardiyadan itibaren doğum havuzunun yaklaşık %10–11’ini oluşturur; kedi ve köpekler sayıca baskındır. Normal zorlukta insan canı 60–69’dur: başlangıç sodasıyla 5, birinci seviye bıçak/tavayla 3 isabet gerekir. İnsan zırhı tek hasar olayını azami canın %34’üyle sınırlar; yüksek geliştirmelerle de tek veya iki vuruşta ölmezler. Alan hasarı tikleri ayrı hasar olaylarıdır; zor modlarda artan can nedeniyle düşük hasarlı silahlar daha fazla isabet gerektirebilir.

## Servis ve savaş animasyonları

- Serviste şef kollarını uzatır; tabak yay çizerek masaya gelir, inişte hafifçe esner ve küçük parçacıklar çıkar. Müşteri tabak inmeden kaşığı kaldırmaz.
- Bekleyen müşteriler etrafa bakar, ayak vurur, ellerini yüzüne götürür ve esner. Sabır düştükçe kıpırdanma artar; yürüyüşte kol ve ayak hareketleri vardır.
- Yemekte el–ağız hareketi, kaşık, yemeğe uygun lokma rengi, çiğneme/ağız hareketi ve azalan porsiyonlar görünür.
- Yemek sonunda müşteri kısa süre durup ödeme hareketi yapar. Üç para masaya düşüp seker, ardından otomatik olarak şefe uçar; toplama hareketi, ses ve miktar yazısı oynar. Para/XP/bahşiş ödülü mantıksal olarak yemek bitiminde bir kez verilir; görsel toplama ikinci ödül üretmez.
- Şef soda ve bıçak atarken elindeki eşya ve kol hareketi görünür. İsabetler küçük parıltı, ezilme ve sendeleme yaratır. Hayvanlar saldırıda öne atılır, insanlar sopayı savurur. Yenilen düşmanlar savaş listesinden hemen çıkarılır, kısa devrilme/küçülme animasyonuyla kaybolur; tekrar vurulamaz ve tekrar XP vermez.
- Bütün bu animasyonlar ESC ve yükseltme seçiminde donar. Darbe efektleri yeniden kullanılır; eşzamanlı efekt ve ölüm sayıları sınırlıdır.

`tests/animation_test.gd` servis sırası, bekleme, ödeme/toplama, duraklama, silah hareketi, kedi/köpek/insan isabet ve ölüm animasyonları ile tek seferlik ödülleri doğrular. `tests/animation_preview.gd` yakın çekim görsel doğrulama sahnelerini oluşturur; gerçek oyunun kamera boyutunu değiştirmez.
