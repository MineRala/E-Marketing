# E-Marketing

DummyJSON tabanlı E-Ticaret iOS uygulaması. Şu an kimlik doğrulama (login / session / Keychain / interceptor) senior değerlendirme kriterlerine göre tamamlanmıştır. Home bir oturum kabuğudur; ürün listeleme ve sayfalama bir sonraki teslimatta eklenecektir.

Test kullanıcısı (DummyJSON): `emilys` / `emilyspass`

## Mimari

**MVVM + ince Domain.** TCA bu görevde login, session ve tek bir korumalı API için gereksiz indirection üretir. MVVM ViewModel’i XCTest ile doğrudan beslemeyi kolaylaştırır.

Katmanlar:

- **Presentation:** `AuthenticationView` / `AuthenticationViewModel`, `HomeView`
- **Domain:** `AuthRepositoryProtocol`, `SessionStore` (oturum tek kaynağı)
- **Data:** `AuthRepository`, DummyJSON DTO’ları
- **Core:** `APIClient`, `AuthRequestInterceptor`, `KeychainService`, `AppError`

Bağımlılıklar protokol üzerinden `AppContainer` içinde enjekte edilir. ViewModel somut `URLSession` veya Keychain görmez.

Oturum durumu `AuthenticationViewModel` içinde tutulmaz. ViewModel yalnızca form + login use-case’idir; `isAuthenticated` `SessionStore`’dadır. Kök `RootView` buna göre Auth veya Home basar.

## Durum Yönetimi

- `SessionStore` ve `AuthenticationViewModel`: `@StateObject` / `@ObservedObject`. Session uygulama ömrü boyunca `AppContainer`’dadır; Auth VM `RootView`’de `@StateObject` ile yaratılır ki login formu klavye turlarında yeniden init olmasın.
- `ToastManager`: `@ObservedObject`. Önceki sürümde toast `AppContainer` üzerinden okunuyordu ve SwiftUI invalidation kaçırıyordu.
- Form alanları `@Published`; token asla `@Published` / `AppStorage` / `UserDefaults` değil.

## Ağ Katmanı

Üçüncü parti (Alamofire) yok. `URLSession` yeterli, testte `URLProtocol` ile değiştirilebilir, token header’ı bizim interceptor’da kalır.

- Dedicated `URLSessionConfiguration`: 30s request / 60s resource timeout, `waitsForConnectivity = false`
- `HTTPDataLoading` protokolü session’ı soyutlar
- `AuthRequestInterceptor` korumalı isteğe `Authorization: Bearer` ekler
- Login `authenticated: false` gider; eski token login’e yapışmaz
- `APIClient` istek/yanıtı loglamaz; hata `AppError` enum’una map edilir (token string’i yok)

## Kimlik Doğrulama

1. `POST https://dummyjson.com/auth/login` (`expiresInMins: 30`)
2. `accessToken` Keychain’e yazılır (`kSecClassGenericPassword`, `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`, service `com.MineRala.E-Marketing`)
3. `LoginResponse` Presentation’a dönmez; repository token’ı kaydeder ve biter
4. `SessionStore.completeLogin()` → Home
5. Cold start: Keychain’de token varsa Home
6. Çıkış Yap / 401: Keychain silinir, Auth’a dönüş

Korumalı uçta 401: interceptor’sız status map → `AppError.unauthorized` → `UnauthorizedDispatcher` (MainActor) → `SessionStore.handleUnauthorized()`. Login 401’i `invalidCredentials`’tır, oturumu kapatmaz.

`LoginResponse.description` / `debugDescription` token içermez. Konsola request dump yok.

## Sayfalama

Ürün listesi henüz yok. Plan: `limit`/`skip`, inflight + end-of-list guard, ViewModel’de sayfa durumu (sekme değişiminde korunur). `GET /auth/products` endpoint’i `APIEndpoint.products` olarak hazırdır.

## Hata Yönetimi

`NetworkErrorMapper` status ve `URLError` kodlarını `AppError`’a çevirir:

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

Kullanıcıya toast ile Türkçe mesaj. `CancellationError` toast üretmez.

## Performans

Auth kapsamında: token bellek cache’lenmez, her korumalı istekte Keychain okunur (sızıntı yüzeyi küçük). Liste/görsel cache ürün ekranında eklenecek (`List` / `LazyVStack`, image pipeline).

Login, SwiftUI `.task(id:)` ile çalışır. View kaybolunca (Home’a geçiş) task iptal edilir; `Button { Task { } }` kullanılmaz.

## Test

| Ne | Neden |
|---|---|
| `AuthenticationViewModelTests` | loading, başarı, boş alan, hatalı giriş, token’ın repository üzerinden yazılması |
| `SessionStoreTests` | restore, logout, 401’de oturum kapatma |
| `APIClientTests` | URLProtocol: 200, korumalı 401, login 401, timeout, malformed JSON, 429 |
| `AuthRequestInterceptorTests` | Bearer ekleme / override etmeme |
| `AuthRepositoryTests` | login token kaydı, login’de Authorization yok |
| `LoginResponseRedactionTests` | description’da token yok |
| XCUITest | `--ui-testing` ile network’süz login → Home → logout |

UI test gerçek DummyJSON’a gitmez (`UITestingAuthRepository` + `InMemoryKeychainStore`).

Xcode’da `E-Marketing` scheme → Test.

## İyileştirme Alanları

- Refresh token rotasyonu ve 401’de sessiz yenileme (DummyJSON refresh endpoint)
- Keychain access group / iCloud sync kapalı tutuldu; production’da biometric unlock ayrı karar
- Structured logging (os.Logger) PII redaction ile; crash reporter’a request header scrub
- Ürün listesi, kategoriler, görsel cache, pagination
- UI test planı ve ürün listesi geçişi
- Certificate pinning (DummyJSON için gerekmez; production API’de)

## Çalıştırma

Xcode 16, iOS 18.4+. Scheme: **E-Marketing**.
