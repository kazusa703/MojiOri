# MojiOri（もじおり）— CLAUDE.md v1.0

## アプリ概要

**MojiOri（もじおり）** は、ユーザーが入力したテキストをタイポグラフィックアートに変換するiOSアプリ。テンプレートを選び、テキストを入力するだけで、文字がテクスチャ・パターンとなったプロフェッショナルなデジタルロゴアートを生成する。

**コンセプト**: 「文字を織る」— テキストが重なり、繰り返し、変形し、一枚のアート作品になる。

**ターゲット**: デザイン初心者〜中級者、SNS投稿用のビジュアル作成、ロゴ・サムネイル素材が欲しいクリエイター

**収益モデル**: AdMob（バナー＋エクスポート時インタースティシャル）＋ ¥480一回購入（Pro：広告除去＋将来テンプレート追加）

---

## 技術スタック

| 項目 | 技術 |
|---|---|
| UI | SwiftUI |
| データ | SwiftData（テンプレート設定・履歴保存） |
| レンダリング（メイン描画） | Core Graphics (`CGContext`, `CGPattern`, `CGBlendMode`) |
| レンダリング（フィルタ） | Core Image (`CIFilter` チェーン) |
| テキスト描画 | Core Text (`CTFrameDraw`) |
| 広告 | Google AdMob（バナー＋インタースティシャル） |
| 課金 | StoreKit 2（¥480 一回購入） |
| エクスポート | `UIGraphicsImageRenderer` → Photos / Share Sheet |
| ビルド管理 | XcodeGen (`project.yml`) |
| ローカライズ | 日本語・英語（初期から） |
| 最小対応 | iOS 17.0+ |

---

## テンプレート定義

### Template A：「Typo Art — Classic」

**完成イメージ**: 黒背景に赤い小文字テキストが全面に敷き詰められ、前面に白い大きなタイトル文字がドロップシャドウ付きで配置される。

**ユーザー入力**:
- `backgroundText`: 背景テクスチャ用テキスト（例: "the Digital Typo as Art"）
- `titleText`: 前面タイトル（例: "the\nDigital\nTypo\nas\nArt"）— 改行で分割入力

**レンダリングパイプライン**:

```
Step 1: 背景テクスチャ生成
  - CGContext (1500x1500px) を黒で塗りつぶし
  - backgroundText を Helvetica Compressed 相当 / 16pt / 行送り11.5pt で
    繰り返し描画（白テキスト）
  - テキストをコピー→ペーストで文字組を作成する要領で
    CGContext上に同一テキストを行・列で敷き詰め

Step 2: テキストテクスチャの複製・拡大
  - Step1の結果をCGImageとして取得
  - オプションバーに相当: 変形を確定し拡大（125%）
  - 複製元のレイヤーをCGContextに再描画

Step 3: レイヤースタイル適用
  - テクスチャレイヤーに対し:
    - wrinkles パターンオーバーレイ（CIFilter or タイルテクスチャ合成）
    - レイヤースタイル→ドロップシャドウ相当の処理

Step 4: 照明効果の適用
  - レイヤースタイルを適用した文字レイヤーに対し:
    - 下のレイヤーと結合 → フィルター→描画→照明効果
    - iOS実装: CIHighlightShadowAdjust + CIRadialGradient でスポットライト模擬
    - 不透明度20%

Step 5: テキストカラーの変更
  - 非表示に設定したレイヤーを選択
  - カラーを変更後、レイヤーパレットの描画モードを選択
  - テキストカラー: #7A1616（暗赤色）
  - 描画モード: 覆い焼き（リニア）
  - iOS実装: CGBlendMode.plusLighter or カスタム CIColorKernel

Step 6: 文字組の移動
  - 選択したレイヤーの不透明度を80%に設定
  - ツールボックスから移動ツールで文字組を左方向に移動
  - iOS実装: CGContext上でオフセット描画

Step 7: タイトル文字の制作
  - 右側のスペースに横書き文字ツールで titleText を入力
  - フォント: Helvetica Extra Compressed / 600pt / 行送り50pt
  - テキストの中央揃え
  - レイヤースタイル: ドロップシャドウ
    - 不透明度100, スプレッド20, サイズ30
    - 描画モード: 覆い焼き(リニア)
  - iOS実装: Core Text で大文字描画 + CGContext.setShadow

Step 8: 最終合成
  - タイトル画像の下に文字を配置
  - レイヤー画像を統合
  - iOS実装: UIGraphicsImageRenderer で全レイヤー順次描画
```

**パラメータテーブル（カスタマイズ可能）**:

| パラメータ | デフォルト値 | 説明 |
|---|---|---|
| `backgroundColor` | `#000000` | 背景色 |
| `textureTextColor` | `#7A1616` | テクスチャテキストの色 |
| `titleTextColor` | `#FFFFFF` | タイトル文字色 |
| `textureFont` | Helvetica Neue Condensed | テクスチャフォント |
| `textureFontSize` | 16pt | テクスチャフォントサイズ |
| `titleFont` | Helvetica Neue Condensed Bold | タイトルフォント |
| `titleFontSize` | 自動計算（キャンバス比） | タイトルフォントサイズ |
| `shadowOpacity` | 1.0 | ドロップシャドウ不透明度 |
| `shadowSpread` | 20 | シャドウスプレッド |
| `shadowSize` | 30 | シャドウぼかし半径 |
| `textureOpacity` | 0.8 | テクスチャレイヤー不透明度 |
| `blendMode` | `.plusLighter` | テクスチャ描画モード |

---

### Template B：「Typo Art — Neon」

**完成イメージ**: Template Aと同じ手法だが、緑系カラースキームで展開。テキストテクスチャが発光するネオン風の仕上がり。

**ユーザー入力**:
- `backgroundText`: 背景テクスチャ用テキスト
- `titleText`: 前面タイトル

**レンダリングパイプライン**: Template Aと同一構造。以下のパラメータが異なる:

| パラメータ | Template B 値 | 差分説明 |
|---|---|---|
| `textureTextColor` | `#C8990D`（金緑） | 緑系に変更 |
| `titleTextColor` | `#FFFFFF` | 同じ |
| `blendMode` | `.colorDodge` | 覆い焼きカラー |
| `patternOverlay` | wrinkles パターン | パターンオーバーレイ追加 |
| `shadowBlendMode` | `.linearBurn` | シャドウ描画モード |

**追加処理**:
- Step 3でパターンオーバーレイ（wrinklesテクスチャ）をCIFilterまたはタイル合成で適用
- 描画モード: 覆い焼き(リニア) → 前面レイヤーパレットの描画

---

### Template C：「Logo Pattern — Sphere」

**完成イメージ**: テキストをパターンとして敷き詰め、球面変形で立体的に歪ませた背景に、大きなタイトル文字を配置。モノクロまたは色調補正で統一感のある仕上がり。

**ユーザー入力**:
- `patternText`: パターン用テキスト（例: "pattern logo"）
- `titleText`: 前面タイトル（例: "pattern\nlogo"）

**レンダリングパイプライン**:

```
Step 1: パターンテキスト登録
  - 新規のグレースケール画像 (1500x360px, 350dpi 相当)
  - 「pattern logo」を登録
  - フォント: Times Regular / 61pt / 字送り-10 / カラー #C5C5C5
  - ツールボックスから横書き文字ツールで入力

Step 2: パターン化
  - フィルター→ぼかし→ぼかし(ガウス) 半径4.0 適用
  - iOS実装: CIGaussianBlur (inputRadius: 4.0)
  - 続いて編集→パターンを定義
  - 作成した文字をパターンに登録

Step 3: パターン塗りつぶし
  - 新規RGB画像 (1500x1500px) を開く
  - 続いてレイヤー→新規塗りつぶしレイヤー→パターンを選択
  - 作成したパターンで塗りつぶし（比率15）
  - iOS実装: CGPattern でタイリング描画

Step 4: 自由変形 — 球面効果
  - 手順3で複製した画像のコピーに対し
  - 編集→自由変形を選択、レイヤーを複製
  - オプションバーの左、基準点の位置から
  - Y=-2.5, W:100%, H:98%
  - 変形を確定後、レイヤーを複製
  - iOS実装: CIBumpDistortion or CIPerspectiveTransform

Step 5: 変形の再実行
  - 手順4で複製したレイヤー(背景のコピー2)を選択
  - 実行、複製したレイヤーの数と画像の変化を確認しながら
  - 下図の通りに編集→変形→再実行、レイヤーを複製の作業を繰り返す
  - iOS実装: 同一変形を複数回適用（5-6回繰り返し）

Step 6: レイヤー結合・追加変形
  - 手順5に続いて、下図の通りに編集→変形→再実行
  - レイヤーを複製を繰り返した後
  - 非表示レイヤーを結合
  - 変形の再実行を繰り返す
  - iOS実装: 変形済みレイヤーをCGContextで順次合成

Step 7: 球面フィルタ適用
  - 手順6で結合したレイヤーに対し
  - レイヤーパレットの描画モードを乗算に設定
  - 続いてフィルター→変形→球面を適用
  - 球面: 量35, モード:標準
  - iOS実装: CIBumpDistortion (inputRadius, inputScale: 0.35)

Step 8: 背景非表示・階調反転
  - 手順6で非表示にした「背景」を表示に設定した後
  - レイヤー画像を統合を実行
  - 続いて、階調の反転を実行
  - iOS実装: CIColorInvert

Step 9: グラデーション合成
  - レイヤー新規塗りつぶしレイヤー→グラデーションを選択
  - を塗りつぶした後、レイヤーパレットの描画モードを選択
  - グラデーションエディタで編集したグラデーションを重ね描画
  - 描画モード: 焼き込み(リニア)
  - 塗り80%, 不透明度100
  - さらにレイヤーの内部不透明度を設定
  - iOS実装: CGGradient + CGBlendMode.colorBurn

Step 10: 色調補正・最終仕上げ
  - レイヤー→新規調整レイヤー→色相・彩度
  - グレースケール画像に適用
  - 色相: 190, 彩度: 70, 明度: 0
  - 彩度のカラー: チェック
  - iOS実装: CIHueAdjust + CIColorControls
  - 最後にレイヤー画像を統合の下に文字を配置
  - 手順10で作成した画像を統合を実行して完成

Step 11: タイトル配置
  - タイトルテキストを配置
  - フォント: Times Regular / 30pt / 字送り-10 / 字送り-20
  - レイヤー→画像を統合
  - iOS実装: Core Text + 最終コンポジット
```

**パラメータテーブル**:

| パラメータ | デフォルト値 | 説明 |
|---|---|---|
| `backgroundColor` | `#000000` | 背景色 |
| `patternTextColor` | `#C5C5C5` | パターンテキスト色 |
| `titleTextColor` | `#FFFFFF` | タイトル文字色 |
| `patternFont` | Times New Roman | パターンフォント |
| `patternFontSize` | 61pt相当 | パターンフォントサイズ |
| `gaussianBlurRadius` | 4.0 | ぼかし半径 |
| `patternScale` | 15 | パターンタイリング比率 |
| `spherizeAmount` | 35 | 球面変形量 |
| `hueShift` | 190 | 色相値 |
| `saturation` | 70 | 彩度値 |
| `gradientBlendMode` | `.colorBurn` | グラデーション描画モード |
| `gradientOpacity` | 0.8 | グラデーション不透明度 |
| `titleFont` | Times New Roman | タイトルフォント |
| `titleFontSize` | 30pt相当 | タイトルフォントサイズ |

---

## データモデル

### SwiftData Models

```swift
// テンプレート定義（プリセット、SwiftDataではなくenum/struct）
enum TemplateType: String, Codable, CaseIterable {
    case typoArtClassic   // Template A
    case typoArtNeon      // Template B
    case logoPatternSphere // Template C
}

// テンプレートごとの入力フィールド定義
struct TemplateInputField: Codable {
    let id: String          // "backgroundText", "titleText", etc.
    let label: String       // 表示ラベル（ローカライズキー）
    let placeholder: String // プレースホルダー
    let isMultiline: Bool   // 改行入力対応
    let maxLength: Int      // 最大文字数
}

// ユーザーの作成履歴
@Model
final class ArtworkHistory {
    var id: UUID
    var templateType: String        // TemplateType.rawValue
    var inputTexts: [String: String] // フィールドID → 入力テキスト
    var thumbnailData: Data?        // サムネイル（JPEG）
    var createdAt: Date
    var isFavorite: Bool

    init(templateType: TemplateType, inputTexts: [String: String]) {
        self.id = UUID()
        self.templateType = templateType.rawValue
        self.inputTexts = inputTexts
        self.thumbnailData = nil
        self.createdAt = Date()
        self.isFavorite = false
    }
}

// Pro購入状態（UserDefaults or SwiftData）
@Model
final class PurchaseState {
    var isPro: Bool
    var purchaseDate: Date?

    init() {
        self.isPro = false
        self.purchaseDate = nil
    }
}
```

### テンプレートごとの入力フィールド

```swift
extension TemplateType {
    var inputFields: [TemplateInputField] {
        switch self {
        case .typoArtClassic:
            return [
                TemplateInputField(
                    id: "backgroundText",
                    label: "background_text",
                    placeholder: "the Digital Typo as Art",
                    isMultiline: false,
                    maxLength: 100
                ),
                TemplateInputField(
                    id: "titleText",
                    label: "title_text",
                    placeholder: "the\nDigital\nTypo\nas\nArt",
                    isMultiline: true,
                    maxLength: 200
                )
            ]
        case .typoArtNeon:
            return [
                TemplateInputField(
                    id: "backgroundText",
                    label: "background_text",
                    placeholder: "TypeArt TypoArt",
                    isMultiline: false,
                    maxLength: 100
                ),
                TemplateInputField(
                    id: "titleText",
                    label: "title_text",
                    placeholder: "type",
                    isMultiline: true,
                    maxLength: 200
                )
            ]
        case .logoPatternSphere:
            return [
                TemplateInputField(
                    id: "patternText",
                    label: "pattern_text",
                    placeholder: "pattern logo",
                    isMultiline: false,
                    maxLength: 80
                ),
                TemplateInputField(
                    id: "titleText",
                    label: "title_text",
                    placeholder: "pattern\nlogo",
                    isMultiline: true,
                    maxLength: 200
                )
            ]
        }
    }
}
```

---

## 画面構成

### Tab 1: ギャラリー（Home）
- テンプレート一覧（3つのカード形式）
- 各カードにプレビュー画像＋テンプレート名
- タップ → エディター画面へ push 遷移
- 下部: AdMob バナー広告（Free時のみ）

### Tab 2: 履歴（History）
- 作成済みアートのグリッド表示（LazyVGrid, 2列）
- サムネイルタップ → 詳細画面（再エクスポート・再編集）
- スワイプ削除対応
- お気に入りフィルター
- Empty State: ContentUnavailableView

### Tab 3: 設定（Settings）
- Pro購入ボタン（¥480）+ 「購入を復元」ボタン
- 価格・利用規約・Privacy Policy 明記
- エクスポート品質設定（1x / 2x / 3x）
- エクスポート形式（PNG / JPEG）
- アプリ情報・ライセンス

### エディター画面（Push from Tab 1）
- 上部: リアルタイムプレビュー（UIImage表示）
- 中部: テキスト入力フィールド群（テンプレートに応じて動的生成）
- 下部: 「生成」ボタン → エクスポート確認
- ナビゲーションバー: 戻る（chevron自動）

### エクスポート画面（Sheet from エディター）
- フルスクリーンプレビュー
- 「写真に保存」「シェア」ボタン
- Free: インタースティシャル広告表示後にエクスポート実行
- Pro: 広告なしで即エクスポート

---

## レンダリングエンジン設計

### RendererProtocol

```swift
protocol TemplateRenderer {
    var templateType: TemplateType { get }
    func render(inputs: [String: String], size: CGSize) async -> UIImage?
}
```

### 共通ユーティリティ

```swift
// テキストテクスチャ生成（Template A, B共通）
final class TextTextureGenerator {
    /// テキストを繰り返し描画してテクスチャ画像を生成
    func generateTexture(
        text: String,
        font: UIFont,
        textColor: UIColor,
        backgroundColor: UIColor,
        canvasSize: CGSize,
        lineSpacing: CGFloat
    ) -> CGImage? {
        // CGContext でビットマップ生成
        // Core Text で行ごとにテキスト描画
        // テキストが画面全体を埋めるまで繰り返し
    }
}

// パターンタイリング（Template C）
final class PatternTiler {
    /// テキストからパターンを生成し、タイリング描画
    func generatePattern(
        text: String,
        font: UIFont,
        textColor: UIColor,
        tileSize: CGSize,
        scale: CGFloat
    ) -> CGImage? {
        // CGPattern コールバックでタイル描画
    }
}

// レイヤー合成エンジン
final class LayerCompositor {
    /// 複数のCGImageをブレンドモード指定で合成
    func composite(
        layers: [(image: CGImage, blendMode: CGBlendMode, opacity: CGFloat, offset: CGPoint)]，
        canvasSize: CGSize
    ) -> CGImage? {
        // UIGraphicsImageRenderer で順次描画
    }
}

// CIFilterチェーン
final class FilterChain {
    func applyGaussianBlur(to image: CIImage, radius: Double) -> CIImage
    func applySpherize(to image: CIImage, center: CGPoint, radius: Double, scale: Double) -> CIImage
    func applyHueAdjust(to image: CIImage, angle: Double) -> CIImage
    func applyColorControls(to image: CIImage, saturation: Double, brightness: Double) -> CIImage
    func applyInvert(to image: CIImage) -> CIImage
    func applyGradientOverlay(to image: CIImage, blendMode: CIBlendMode, opacity: Double) -> CIImage
}
```

### Renderer実装

```swift
final class TypoArtClassicRenderer: TemplateRenderer {
    let templateType: TemplateType = .typoArtClassic
    private let textureGenerator = TextTextureGenerator()
    private let compositor = LayerCompositor()
    private let filterChain = FilterChain()

    func render(inputs: [String: String], size: CGSize) async -> UIImage? {
        // Step 1-8 を順次実行
        // 非同期でバックグラウンド処理
    }
}

final class TypoArtNeonRenderer: TemplateRenderer { ... }
final class LogoPatternSphereRenderer: TemplateRenderer { ... }
```

---

## Phase分割

### Phase 1（MVP）
- [ ] テンプレート選択画面（3テンプレートのカード表示）
- [ ] エディター画面（テキスト入力＋プレビュー）
- [ ] Template A「Typo Art — Classic」レンダリング実装
- [ ] エクスポート（写真保存＋Share Sheet）
- [ ] 基本UI（タブ2つ: ギャラリー＋設定）

### Phase 2（残りテンプレート）
- [ ] Template B「Typo Art — Neon」レンダリング実装
- [ ] Template C「Logo Pattern — Sphere」レンダリング実装
- [ ] 履歴タブ（SwiftData保存＋グリッド表示）
- [ ] リアルタイムプレビュー（低解像度で入力中プレビュー）

### Phase 3（収益化）
- [ ] AdMob統合（バナー＋インタースティシャル）
- [ ] StoreKit 2 Pro購入（¥480）
- [ ] 「購入を復元」ボタン
- [ ] 設定画面完成

### Phase 4（ポリッシュ）
- [ ] カスタマイズUI（色・フォント・ブレンドモード変更）
- [ ] お気に入り機能
- [ ] エクスポート品質設定（1x/2x/3x, PNG/JPEG）
- [ ] App Storeスクリーンショット・メタデータ
- [ ] レビューリクエスト（エクスポート完了後のみ）

---

## UI/UX チェックリスト

### ナビゲーション・ボタン
- [ ] chevron手動追加しない（NavigationLink自動）
- [ ] テンプレート選択 → エディター: push遷移（階層閲覧）
- [ ] エクスポート確認: sheet（自己完結タスク）
- [ ] Cancel時は確認ダイアログ必須（テキスト入力済みの場合）
- [ ] スワイプバックをカスタムジェスチャーで殺さない
- [ ] タブ2つ（ギャラリー・設定）→ Phase 2で3つ（＋履歴）
- [ ] 全タップ要素44×44pt以上
- [ ] 破壊的アクション → .confirmationDialog + Button(role: .destructive)
- [ ] FABよりtoolbar優先

### テキスト・フォント
- [ ] Dynamic Type対応システムフォント使用・サイズ直指定禁止
- [ ] SF Symbolsでアイコン統一
- [ ] 日英両方でレイアウトテスト必須

### 色・リスト・フォーム
- [ ] テキスト色は .primary / .secondary 使用・Color.black/white 禁止
- [ ] 背景はセマンティックカラー
- [ ] ダークモード対応
- [ ] 色だけで情報伝えない
- [ ] 空データは Empty State 表示（ContentUnavailableView）
- [ ] スケルトン: .redacted(reason: .placeholder)
- [ ] キーボード回避は自動・手動オフセット禁止
- [ ] @FocusState でフィールド間遷移

### アニメ・アクセシビリティ
- [ ] タップフィードバック scaleEffect(0.95) + haptic ≤0.2s
- [ ] ReduceMotion時アニメ → フェード置換
- [ ] 画像ボタンに .accessibilityLabel 必須
- [ ] 装飾画像は Image(decorative:)

### App Store・課金
- [ ] IAP「購入復元」ボタン必須
- [ ] ペイウォールに価格・課金頻度・利用規約・Privacy Policy明記
- [ ] レビューリクエストはエクスポート完了後のみ・起動時禁止
- [ ] 権限リクエスト（写真保存）は必要な瞬間のみ・起動時一括禁止
- [ ] .ignoresSafeArea 背景のみ・インタラクティブ要素は SafeArea内
- [ ] アイコン 1024px・透過禁止・角丸手動禁止

### レイアウト崩れ対策
- [ ] フルスクリーン → ホーム復帰時のレイアウト崩れ対策

---

## フォント戦略

### iOS利用可能フォント（本の指定との対応）

| 本の指定 | iOS対応フォント | 用途 |
|---|---|---|
| Helvetica Compressed | `.systemFont(ofSize:weight:.heavy)` + condensed trait, or "HelveticaNeue-CondensedBold" | テクスチャテキスト |
| Helvetica Extra Compressed | "HelveticaNeue-CondensedBlack" | タイトル大文字 |
| Times Regular | "TimesNewRomanPSMT" | パターンテキスト・タイトル |

### フォント利用可能性チェック

```swift
// 起動時にフォント利用可能性を確認
let requiredFonts = [
    "HelveticaNeue-CondensedBold",
    "HelveticaNeue-CondensedBlack",
    "TimesNewRomanPSMT"
]
for fontName in requiredFonts {
    assert(UIFont(name: fontName, size: 12) != nil, "Required font not available: \(fontName)")
}
```

---

## エクスポート仕様

| 項目 | 仕様 |
|---|---|
| デフォルト解像度 | 1500×1500px |
| 形式 | PNG（デフォルト）/ JPEG（設定で切替） |
| JPEG品質 | 0.95 |
| メタデータ | Exif不要（プライバシー配慮） |
| 保存先 | フォトライブラリ（PHPhotoLibrary） |
| シェア | UIActivityViewController |
| 権限 | PHAuthorizationStatus.addOnly（保存のみ） |

---

## 広告配置

| 画面 | 広告タイプ | 条件 |
|---|---|---|
| ギャラリー（Home）下部 | バナー（320×50） | Free のみ |
| 履歴タブ下部 | バナー（320×50） | Free のみ |
| エクスポート実行時 | インタースティシャル | Free のみ、3回に1回表示 |

---

## ローカライズキー（初期）

```
// Localizable.strings
"app_name" = "MojiOri";
"tab_gallery" = "ギャラリー" / "Gallery";
"tab_history" = "履歴" / "History";
"tab_settings" = "設定" / "Settings";
"template_typo_classic" = "Typo Art — Classic";
"template_typo_neon" = "Typo Art — Neon";
"template_logo_pattern" = "Logo Pattern — Sphere";
"background_text" = "背景テキスト" / "Background Text";
"title_text" = "タイトル" / "Title";
"pattern_text" = "パターンテキスト" / "Pattern Text";
"generate" = "生成" / "Generate";
"export" = "エクスポート" / "Export";
"save_to_photos" = "写真に保存" / "Save to Photos";
"share" = "シェア" / "Share";
"pro_purchase" = "Pro版を購入（¥480）" / "Get Pro (¥480)";
"restore_purchase" = "購入を復元" / "Restore Purchase";
"export_quality" = "エクスポート品質" / "Export Quality";
"export_format" = "エクスポート形式" / "Export Format";
```

---

## プロジェクト構成（XcodeGen）

```
MojiOri/
├── project.yml
├── CLAUDE.md
├── Sources/
│   ├── App/
│   │   └── MojiOriApp.swift
│   ├── Models/
│   │   ├── TemplateType.swift
│   │   ├── TemplateInputField.swift
│   │   ├── ArtworkHistory.swift
│   │   └── PurchaseState.swift
│   ├── Renderers/
│   │   ├── TemplateRenderer.swift          // Protocol
│   │   ├── TypoArtClassicRenderer.swift    // Template A
│   │   ├── TypoArtNeonRenderer.swift       // Template B
│   │   ├── LogoPatternSphereRenderer.swift // Template C
│   │   ├── TextTextureGenerator.swift      // 共通: テクスチャ生成
│   │   ├── PatternTiler.swift              // 共通: パターンタイリング
│   │   ├── LayerCompositor.swift           // 共通: レイヤー合成
│   │   └── FilterChain.swift              // 共通: CIFilterチェーン
│   ├── Views/
│   │   ├── Gallery/
│   │   │   ├── GalleryView.swift
│   │   │   └── TemplateCardView.swift
│   │   ├── Editor/
│   │   │   ├── EditorView.swift
│   │   │   ├── TextInputFieldView.swift
│   │   │   └── PreviewImageView.swift
│   │   ├── Export/
│   │   │   └── ExportSheetView.swift
│   │   ├── History/
│   │   │   ├── HistoryView.swift
│   │   │   └── HistoryItemView.swift
│   │   └── Settings/
│   │       └── SettingsView.swift
│   ├── ViewModels/
│   │   ├── GalleryViewModel.swift
│   │   ├── EditorViewModel.swift
│   │   └── HistoryViewModel.swift
│   ├── Services/
│   │   ├── AdService.swift                // AdMob管理
│   │   ├── PurchaseService.swift          // StoreKit 2
│   │   └── ExportService.swift            // 保存・シェア
│   └── Resources/
│       ├── Localizable.strings
│       ├── Assets.xcassets
│       └── Textures/
│           └── wrinkles.png               // パターンオーバーレイ用テクスチャ
├── Tests/
│   └── RenderTests/
│       ├── TypoArtClassicRenderTests.swift
│       ├── TextTextureGeneratorTests.swift
│       └── FilterChainTests.swift
└── Packages/
```

---

## 自律デバッグループ設定

```bash
# xcodebuild + ios-deploy + timeout で実機ログ自動取得
xcodebuild -project MojiOri.xcodeproj -scheme MojiOri \
  -destination 'platform=iOS,name=<DEVICE_NAME>' \
  build 2>&1 | tee build.log

# ビルド成功後、実機インストール＋ログ取得
ios-deploy --bundle build/Debug-iphoneos/MojiOri.app \
  --debug --verbose 2>&1 | timeout 30 tee run.log
```

---

## 競合・差別化

### 類似アプリ
- Canva: テンプレートベースだが汎用すぎ、タイポグラフィ特化ではない
- Phonto: テキスト追加特化だが、テクスチャ生成機能なし
- Over: テキスト＋デザインだが、テクスチャアート生成なし

### MojiOriの差別化
- **テキスト自体がテクスチャになる**という独自性（Canva/Phontoにはない）
- テンプレート選択→テキスト入力→即生成の3ステップUX
- Photoshopの複雑な手順を自動化し、誰でもプロ品質のタイポアートを作れる
- SNS映えする正方形出力（1500×1500）がデフォルト
