# lspctl.nvim

## INTRODUCTIONS - 概要

> a simple list for lsp client provided by [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

<https://github.com/user-attachments/assets/e59844bd-8054-4737-86e3-c426b49de14a>

`lspctl` is show `floating window` sourced by `LspInfo` and provide related actions for
you
`lspctl` は `LspInfo` を `floating window` を利用して表示するプラグインです

Also, you can `start`, `stop`, `restart` for the displayed plugin
また、表示しているプラグインに対して `start`, `stop`, `restart` を行うことができます

## VERSIONS - バージョニング

- feature / 最新版:
  - <https://github.com/clxmochamalefic/lspctl.nvim>
- stable / 安定版:
  - nothing yet / まだありません

## HOW TO INSTALLATION - インストール方法

> [!NOTE]
> all examples are written in |lazy.nvim|
> 以下の例はすべて |lazy.nvim| で書かれています

### VANILLA - 最小構成

```lua
  {
    "clxmochamalefic/lspctl.nvim"
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    lazy = true,
    cmd = { "Lspctl", },
    config = function()
      require("lspctl").setup()
    end,
  },
```

### with KEYBIND - キーバインドあり

```lua
  {
    "clxmochamalefic/lspctl.nvim"
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    lazy = true,
    cmd = { "Lspctl", },
    opt = {
      -- this binds are default, you can change it
      -- ここの設定はデフォルトですから、ご自由に変更してください
      info = "h",
      start = "s",
      stop = "x",
      restart = "r",
      close = "q",
    },
    config = function(_, opt)
      require("lspctl").setup(opt)
    end,
  },
```

## HOW TO USE - 使い方

### English

1. `:Lspctl` to open lspctl window
2. the window is display that running LSP server name
3. you can use `j` or `k` to move cursor and select LSP server
4. and you can execute an action if press to configured binded key
   (see also => `:help lspctl-interface-key-bindings`)

### 日本語

1. `:Lspctl` で lspctl のウィンドウを開きます
2. `lspctl` のウィンドウに起動中のLSPサーバ名が表示されます
3. `j` / `k` でカーソル移動を実施し、任意のLSPサーバを選択します
4. キーバインドで設定しているキーを押すことで、
   選択したLSPサーバに対してアクションを実行します
   (詳しくは `:help lspctl-interface-key-bindings` を参照してください)

## INTERFANCE - インターフェース

### COMMANDS - コマンド

#### :Lspctl

show |lspctl| ui window
|lspctl| のウィンドウを表示します

### ACTIONS - アクション

#### start

start selected LSP server
選択した LSP server を起動します

#### stop

stop selected LSP server
選択した LSP server を終了します

#### restart

restart selected LSP server
選択した LSP server を再起動します
