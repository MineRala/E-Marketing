# E-Marketing

DummyJSON tabanlı E-Ticaret iOS uygulaması. Girişten sonra alt sekmede Ana Sayfa ve Ürünler vardır. Ana sayfada temsili kampanya banner’ları ve `GET /products/categories` kategorileri görünür; kategoriye dokunmak sayfa açmaz. Ürünler `GET /auth/products` ile `limit` ve `skip` kullanılarak sayfalanır.

Test kullanıcısı (DummyJSON): `emilys` / `emilyspass`

## Mimari

**MVVM.** TCA bu görevde login, session ve tek bir korumalı API için gereksiz indirection üretir. MVVM ViewModel’i XCTest ile doğrudan beslemeyi kolaylaştırır.

Katmanlar:

- **Presentation:** `AuthenticationView` / `AuthenticationViewModel`, `HomeView` / `HomeViewModel`, `ProductListView` / `ProductListViewModel`, `MainTabView`. ViewModel ekran durumunu tutar: form, yükleniyor, toast, sekme dönüşünde listeyi koruma.
- **Domain:** `Product`, `ProductPage` ve `ProductCategory` API’den bağımsız varlıklardır; `Decodable` değildir. `LoginUseCase` boş alanı keser, kullanıcı adını kırpar, repository’ye yazar ve `SessionStore.completeLogin()` çağırır. `ProductPagination` sayfa boyu, `skip`, tekrarlayan id ve `hasMore` kararını verir; `FetchProductPageUseCase` bunu repository’ye uygular. `FetchCategoriesUseCase` listeyi `Catalog.prepare` ile kurar: boş slug veya ad düşer, http(s) olmayan adres düşer, aynı slug tekrar etmez, ad sırasına dizilir. `SessionStore` oturumun tek kaynağıdır. Toast bilmez; `SessionNotice` yayınlar.
- **Data:** `AuthRepository`, `CatalogRepository`, `ProductRepository`. `ProductDTO`, `ProductPageDTO` ve `ProductCategoryDTO` DummyJSON cevabını çözer ve alan alan domain varlığına çevirir. Repository HTTP ve Keychain bilir; sayfa birleştirmez, kategori elemez.
- **Core:** `APIClient`, `AuthRequestInterceptor`, `KeychainService`, `AppError`

Bağımlılıklar protokol üzerinden `AppContainer` içinde enjekte edilir. ViewModel somut `URLSession`, Keychain veya repository görmez.

`isAuthenticated` `SessionStore`’dadır. Kök `RootView` buna göre Auth veya sekmeleri basar.

## Durum Yönetimi

- `SessionStore`, `AuthenticationViewModel`, `HomeViewModel` ve `ProductListViewModel`: `@StateObject` / `@ObservedObject`. Session uygulama ömrü boyunca `AppContainer`’dadır. View model’ler `RootView`’de `@StateObject` ile yaratılır. Sekme değişince ürün sayfası ve yüklenmiş liste korunur; `loadInitial` liste doluysa yeniden istek atmaz. Çıkış ve 401 `isAuthenticated`’ı kapatınca `clearSession()` listeyi, `hasMore` ve yükleme bayraklarını sıfırlar. Sonraki giriş birinci sayfayı yeniden çeker.
- `ToastManager`: `@ObservedObject`. Önceki sürümde toast `AppContainer` üzerinden okunuyordu ve SwiftUI invalidation kaçırıyordu. Oturum olayını `RootView` dinler: `session.notice` doluysa toast basar ve notice’ı temizler. Açılışta süresi dolmuş token, view görünmeden notice olarak kalır; `.task(id:)` ilk çizimde onu gösterir.
- Form alanları `@Published`; token asla `@Published` / `AppStorage` / `UserDefaults` değil.

## Arayüz

Renkler `AppColor`, yazı, boşluk, köşe ve ortak yüzeyler `AppStyle` içindedir. Metinler `AppFont` üzerinden Montserrat kullanır (Regular, Medium, SemiBold, Bold). Simgeler sistem fontunda kalır. Ekran zemini `appScreen()`, liste kartı `appCard()`, giriş formu `appPanel()`, alan `appField()` kullanır. Böylece punto ve yarıçap view içinde tekrarlanmaz. Üçüncü parti bir tasarım kiti yok; bu üç ekranın ortak dili buradan gelir.

## Ağ Katmanı

Üçüncü parti yok. API için Alamofire, görsel için Kingfisher (veya SDWebImage / Nuke) eklenmedi. İkisi de `URLSession` ile çözülüyor. API isteği testte `URLProtocol` ile değiştirilebiliyor, token header’ı bizim interceptor’da kalıyor. Görsel indirme `NSCache` ve uygulamanın kendi disk klasörünü kullanır. `URLCache` DummyJSON `Cache-Control: no-store` başlığında diske yazmadığı için görsel oturumunda kapalıdır. Hücre boyutu ImageIO ile küçültülür. Progressive JPEG ve öncelik kuyruğu yok; o ihtiyaç çıkınca kütüphane eklemek daha doğru olur.

- Dedicated `URLSessionConfiguration`: 30s request / 60s resource timeout, `waitsForConnectivity = false`
- `HTTPDataLoading` protokolü session’ı soyutlar
- `AuthRequestInterceptor` korumalı isteğe `Authorization: Bearer` ekler. Token yoksa veya JWT `exp` geçmişse istek ağa çıkmaz; `unauthorized` olur ve oturum kapanır
- Login `authenticated: false` gider; eski token login’e yapışmaz
- `APIClient` istek/yanıtı loglamaz; hata `AppError` enum’una map edilir (token string’i yok)

## Kimlik Doğrulama

1. `POST https://dummyjson.com/auth/login` (`username`, `password`). `expiresInMins` gönderilmez; DummyJSON access token süresini 60 dakika tutar.
2. `accessToken` Keychain’e yazılır (`kSecClassGenericPassword`, `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, service `com.MineRala.E-Marketing`). Güncellemede silme sorgusu yalnız servis ve hesap kullanır; eski token farklı olsa da kayıt değişir. `refreshToken` giriş gövdesinde çözülür, loga yazılmaz ve Keychain’e konmaz. Dokümanda yenileme ucu yoktur; kullanılmayan bir sır saklanmaz.
3. `LoginResponse` Presentation’a dönmez; repository token’ı kaydeder ve biter
4. `SessionStore.completeLogin()` → Home
5. Cold start: Keychain’de token varsa ve `exp` geçmemişse Home. `exp` okunamıyorsa token geçerli sayılır. `exp` geçmişse Keychain silinir, giriş ekranı açılır
6. Çıkış Yap / 401 / süresi dolmuş token: Keychain silinirse ürün listesi sıfırlanır ve Auth’a dönülür. Çıkışta silme başarısızsa oturum açık kalır; `SessionStore` `.keychain` yayınlar, toast’ı `RootView` basar

Korumalı uçta 401: interceptor’sız status map → `AppError.unauthorized` → `UnauthorizedDispatcher.notify()` isteğin kendi task’ı içinde `MainActor`’a geçer → `SessionStore.handleUnauthorized()`. Ayrı bir `Task` açılmaz. Login 401’i `invalidCredentials`’tır, oturumu kapatmaz. Korumalı 401 oturumu kapatır.

`LoginResponse.description` / `debugDescription` token içermez. Konsola request dump yok.

## Sayfalama

Ürünler sekmesi `GET /auth/products?limit=&skip=` kullanır. Sayfa boyu, `skip` ve listenin bitip bitmediği `ProductPagination` içindedir. Sonraki `skip`, istenen ofset artı cevaptaki ham kayıt sayısıdır. Tekrarlayan id listeye eklenmez ama ofseti geri çekmez; aksi halde aradaki pencere atlanır. Ham sayfa boşsa veya ofset `total`’a ulaştıysa `hasMore` kapanır. Sayfanın tamamı tekrar olsa bile ofset ilerler.

ViewModel bu kararı vermez. Yalnızca aynı anda tek isteği (`isLoading` / `isLoadingNextPage`), sekme dönüşünde dolu listenin yeniden çekilmemesini ve `nextSkip` imlecini tutar. Sonraki sayfa hata verirse toast basılır, yüklenen ürünler durur ve sentinel’de yeniden dene görünür. `.task` kimliği ürün sayısı ile deneme sayısıdır; buton denemeyi artırınca aynı ofset yeniden istenir. Oturum kapanınca `clearSession()` nesli artırır; o nesille başlamış uçuştaki sayfa listeye yazılmaz ve toast üretmez. Listenin sonundaki sentinel `List` içinde lazy durur; görünmeden istek atılmaz.

## Hata Yönetimi

Hata katmanlar arasında `AppError` olarak yürür. View ham `URLError` veya HTTP kodu görmez.

1. `APIClient` ağ hatasını ve HTTP status’unu `NetworkErrorMapper` ile `AppError`’a çevirir. Bozuk JSON `decoding`, HTTP olmayan yanıt `invalidResponse` olur. `CancellationError` olduğu gibi yukarı çıkar.
2. Repository bu hatayı yeniden fırlatır. Ürün URL’i kurulamazsa `invalidResponse` burada üretilir. Keychain yazma ve silme hatası `keychain` olarak yukarı çıkar.
3. ViewModel (`AuthenticationViewModel`, `HomeViewModel`, `ProductListViewModel`) `AppError`’ı yakalar ve `localizedDescription` ile toast gösterir. Tanınmayan hata `unknown` olur.
4. `CancellationError` toast üretmez. Boş kullanıcı adı veya şifre `LoginCredentials` içinde kesilir; buton `canSubmit` ile kapalıdır, istek ve toast yoktur.

Korumalı istekte 401 ayrıdır: `APIClient` status’u `unauthorized` yapar ve fırlatmadan önce, isteğin kendi task’ı içinde `SessionStore.handleUnauthorized()` çağırır. Oturum kapanır ve `SessionNotice.unauthorized` yayınlanır; toast’ı `RootView` basar. ViewModel’ler `.unauthorized` görünce toast basmaz, mesaj iki kez çıkmaz. Login 401’i `invalidCredentials`’tır; ViewModel toast basar, oturum açılmaz. Çıkışta Keychain silinemezse notice `.keychain` kalır, unauthorized’ın üzerine yazılmaz ve oturum açık kalır.

`NetworkErrorMapper` eşlemesi:



| Durum | AppError |
|---|---|
| Login 400/401 | `invalidCredentials` |
| Korumalı 401 | `unauthorized` + session reset |
| 403 | `forbidden` |
| 404 | `notFound` |
| 429 | `rateLimited` |
| 5xx | `server` |
| timeout | `timeout` |
| bağlantı yok / kopma | `network` |
| bozuk JSON | `decoding` |

Toast metni `AppError.errorDescription` üzerinden lokalize edilir.

## Performans

Auth kapsamında: token bellek cache’lenmez, her korumalı istekte Keychain okunur (sızıntı yüzeyi küçük). Ana sayfada kampanyalar yereldir; kategoriler `LazyVGrid` içindedir. Ürün listesi `List` kullanır ve satır `Equatable` olduğu için aynı ürün yeniden çizilmez.

Küçük resim `CachedAsyncImage` + `ImageCache` ile yüklenir. Önbelleği `AppContainer` yaratır; `RootView` onu environment ile verir. Akış: bellek (`NSCache`, en fazla 200 görsel) → Caches altındaki dosya klasörü (100 MB, en eski dosya silinir) → ağ. Dosya adı UUID’dir. Adres ile bu ad `index.json` içinde eşlenir; uygulama yeniden açılınca aynı dosya bulunur. Swift’in `hashValue` değeri her açılışta değiştiği için disk adı olamaz. Sunucu `no-store` gönderse de ikinci istek ağa gitmez. Ürün satırı görseli 76 puntodur. `ImageIO` tam kareyi belleğe almadan en uzun kenarı `76 × ekran ölçeği` piksel olan küçük resim üretir. Diskte orijinal bayt durur; belleğe giren görsel hücre boyutundadır. İstek `async`’tir. Hücre kaybolunca `.task` iptal olur, görünmeyen görsel indirilmeye devam etmez. Kingfisher’ın bu ekranda karşılayacağı ek davranış (placeholder pipeline, prefetch, processor) yok. Bu yüzden bağımlılık eklenmedi.

Login, oturum notice’ı ve toast kapanışı SwiftUI `.task(id:)` ile çalışır. Yeni toast veya ekranın kapanması önceki beklemeyi iptal eder. `Button { Task { } }` kullanılmaz.

## Test

Üç başlık dokümandaki test stratejisine göre. Hepsi XCTest. Network mock’u `URLProtocol` (`MockURLProtocol`).

`E-MarketingTests` katmana göre ayrılır: `Presentation`, `Domain`, `Data`, `Network`, `Storage`, `Support`.

`LoginUseCaseTests` boş kullanıcı adı, boş şifre, kırpılmış kullanıcı adı ve hatalı girişte oturumun açılmamasını doğrular. `ProductPaginationTests` sayfa boyu, `skip`, tekrarlayan id ve `hasMore` kararını ViewModel olmadan doğrular. `FetchCategoriesUseCaseTests` boş, tekrarlayan ve http olmayan kategorilerin elenip ad sırasına dizildiğini doğrular.

### Unit test — ViewModel

Dosya: `E-MarketingTests/Presentation/AuthenticationViewModelTests.swift`. Repository mock’lanır; ağ yok.

| Senaryo | Test |
|---|---|
| Yükleme | `testLoadingIsTrueWhileLoginRequestIsInFlight` |
| Başarı | `testSuccessfulLoginPersistsTokenAndAuthenticatesSession` |
| Hatalı giriş | `testFailedLoginShowsErrorAndDoesNotAuthenticate` |
| Token saklama | Aynı başarı testi: `repository.token == "stored-token"`, oturum açılır, şifre temizlenir |

`HomeViewModelTests`: kategori başarı ve hata. `ProductListViewModelTests`: ilk sayfa, sonraki sayfa, liste sonu, eşzamanlı ikinci isteğin yutulması, sekme dönüşünde yeniden çekmeme, çıkışta listeyi silip yeniden çekme, uçuştaki sayfanın düşürülmesi, sonraki sayfa hatasında aynı ofseti yeniden deneme, tekrarlayan id’de sunucu ofseti, hata toast’ı.

Boş kullanıcı adı veya boş şifrede `canSubmit` false kalır; istek ve toast yok. Buton bu durumda kapalıdır.

### Repository / Network

`URLProtocol` ile mock. Gerçek DummyJSON çağrılmaz.

| Senaryo | Test |
|---|---|
| Başarılı yanıt | `APIClientTests.testSuccessfulJSONResponse`, `AuthRepositoryTests.testLoginSavesAccessTokenAndDoesNotSendBearer` |
| 401 | `APIClientTests.testUnauthorizedOnProtectedRequestNotifiesSession` (oturum kapanır), `testMissingTokenDoesNotReachTheNetwork` (token yokken istek çıkmaz), `testLogin401DoesNotNotifySession` (hatalı giriş, oturum açık kalmaz) |
| Zaman aşımı | `APIClientTests.testTimeoutMapsToTimeoutError` |
| Hatalı format | `APIClientTests.testMalformedJSONMapsToDecoding` |

Aynı katmanda ayrıca: Bearer ekleme (`AuthRequestInterceptorTests`), access token’ın Keychain’e yazılıp çıkışta silinmesi ve refresh token’ın saklanmaması (`AuthRepositoryTests`, `KeychainServiceTests`), kategori listesi ve Bearer (`CatalogRepositoryTests`), ürün listesinde `limit`/`skip` ve Bearer (`ProductRepositoryTests`), 403 / 404 / 429 / 500 ve bağlantı kopması (`APIClientTests`). Görsel bellek, `no-store` altında disk ve hücre boyutuna küçültme `ImageCacheTests` içindedir.

### UI test (XCUITest)

Dosyalar: `AuthenticationUITests`, `HomeUITests`, `ProductListUITests`. Launch argument `--ui-testing`. Ağ yok; `UITestingAuthRepository`, `UITestingCatalogRepository`, `UITestingProductRepository` + `InMemoryKeychainStore`.

| Akış | Test | Durum |
|---|---|---|
| Giriş → ana sayfa | `testSuccessfulLoginNavigatesToHome` | Var |
| Hatalı girişte ekranda kalma | `testFailedLoginStaysOnAuthentication` | Var |
| Ana sayfadan çıkış → giriş | `testLogoutReturnsToAuthentication` | Var |
| Giriş → ana sayfa → ürün listesi | `testLoginHomeThenProductList` | Var |
| Ana sayfa kampanya ve kategoriler | `HomeUITests.testHomeShowsCampaignAndCategories` | Var |
| Kategori kartı sayfa açmaz | `HomeUITests.testCategoryCardDoesNotLeaveHome` | Var |
| Çıkış iptali ana sayfada kalır | `HomeUITests.testLogoutCancelStaysOnHome` | Var |
| Ürün satırı ve fiyat | `ProductListUITests.testProductListShowsFixtureProduct` | Var |
| Sekme dönüşünde liste durur | `ProductListUITests.testSwitchingTabsKeepsTheLoadedProduct` | Var |
| Hatalı girişte toast | `testFailedLoginShowsErrorToast` | Var |
| Kaydırınca sonraki ürün sayfası | `ProductPaginationUITests.testScrollingLoadsTheNextPage` | Var |
| 401 girişe dönüş | `HTTPErrorUITests.testUnauthorizedResponseReturnsToLogin` | Var |
| 403 toast | `HTTPErrorUITests.testForbiddenResponseShowsToast` | Var |
| 404 toast | `HTTPErrorUITests.testNotFoundResponseShowsToast` | Var |
| 429 toast | `HTTPErrorUITests.testRateLimitedResponseShowsToast` | Var |
| 500 toast | `HTTPErrorUITests.testServerErrorResponseShowsToast` | Var |

Xcode’da `E-Marketing` scheme → Test.

## İyileştirme Alanları

- 401’de sessiz yenileme. O uç eklenirse refresh token Keychain’e yazılır. Doküman bu ucu istemez; şu an 401 oturumu kapatır.
- Keychain access group / iCloud sync kapalı tutuldu; production’da biometric unlock ayrı karar
- Küçük resim 76 puntodur (`AppStyle.Size.thumbnail`). Görselin çerçeve ölçüsü değişirse bu sabit de değişir; ImageIO o puntoyla küçültür. Satırın yazı ve boşluğu bu ölçüyü belirlemez. Girişteki logo da aynı sabiti kullanır
- Structured logging (os.Logger) PII redaction ile; crash reporter’a request header scrub
- Ürün detay ekranı (doküman istemiyor)
- Certificate pinning (DummyJSON için gerekmez; production API’de)

## Çalıştırma

Bağımlılık yok. CocoaPods ve Swift Package Manager kullanılmıyor; `E-Marketing.xcodeproj` doğrudan açılır.

1. Xcode 16. Scheme: **E-Marketing**. Hedef: iOS 16.0 veya üzeri simülatör.
2. Run. Uygulama DummyJSON’a çıkar. Giriş: `emilys` / `emilyspass`.
3. Oturum Keychain’de durur. Aynı simülatörde yeniden açılınca giriş atlanır. Çıkış, ana sayfadaki ikondan yapılır.
4. Test aynı scheme üzerinden Product → Test ile koşar. Unit testler `URLProtocol` kullanır, ağa çıkmaz. UI testler `--ui-testing` ile sahte repository açar; DummyJSON çağrılmaz.
