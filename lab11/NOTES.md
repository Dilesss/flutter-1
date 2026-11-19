# Practice 11 — A Real Server (lab11)

## Level 1 — Postman first

`GET https://jsonplaceholder.typicode.com/users` → **200**, `Content-Type: application/json; charset=utf-8`, body is a **list of 10 users**.
`GET …/users/1` → **200**, one object.

Key names (exact): `id, name, username, email, address, phone, website, company`.
Nested once: `address`, `company`. Nested twice: `address.geo`.
Could be absent/null: none in the real data — I treat only `website` as optional (`String?`). `company.bs` exists but I do not read it.

### User

| field    | JSON type | Dart type                                   | nullable? |
|----------|-----------|---------------------------------------------|-----------|
| id       | number    | int                                         | no        |
| name     | string    | String                                      | no        |
| username | string    | String                                      | no        |
| email    | string    | String                                      | no        |
| address  | object    | Address                                     | no        |
| phone    | string    | String (+ getter phoneDigits)               | no        |
| website  | string    | String?                                     | yes (my choice) |
| company  | object    | ({String name, String catchPhrase}) record  | no        |

### Address

| field   | JSON type | Dart type | nullable? |
|---------|-----------|-----------|-----------|
| street  | string    | String    | no        |
| suite   | string    | String    | no        |
| city    | string    | String    | no        |
| zipcode | string    | String    | no        |
| geo     | object    | Geo       | no        |

### Geo (inside address)

| field | JSON type             | Dart type                 | nullable? |
|-------|-----------------------|---------------------------|-----------|
| lat   | string ("-37.3159")   | double (double.parse)     | no        |
| lng   | string ("81.1496")    | double (double.parse)     | no        |

### Company

| field       | JSON type | Dart type      | nullable? |
|-------------|-----------|----------------|-----------|
| name        | string    | String         | no        |
| catchPhrase | string    | String         | no        |
| bs          | string    | — (not used)   | —         |

### Statuses

- `GET …/users/999` → **404 Not Found**, body is an empty object **`{}`**. → `NotFoundException`.
- `POST …/users` with `Content-Type: application/json` and a JSON body → **201 Created**; the server returns what I sent **plus `"id": 11`**. (Nothing is really saved.)
- `GET …/users?id=3` → **200**, a **list of one** user `[ {...} ]`, not an object.

## Level 3 — the only class that knows http

```
$ grep -rn "package:http" lib/
lib/core/api/api_client.dart
lib/features/users/user_repository.dart
```

`http.Client()` is created by `ApiClient.live()` (= `ApiClient(http.Client())`), called from `main.dart` — so main.dart is still the only place the chain is built, and http does not leak into it.

## Level 5 — two kinds of "no network"

| test                                   | time until Offline view |
|----------------------------------------|-------------------------|
| Airplane mode (SocketException)        | *(paste, ~under 1 s)*   |
| Wi-Fi without internet (Timeout)       | *(paste, ~10 s)*        |

Screenshots: `screenshot_timeout.png` (row with no status, ~10 000 ms), `screenshot_200.png` (200 row with body).
