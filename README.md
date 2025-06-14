# Neovim Google Translate Plugin

A lightweight Neovim plugin to translate selected or entered text using the **Google Translate API**. Supports translating between any languages, visual mode integration, and auto-detecting the source language.

## ✨ Features

- Translate selected text in visual mode or manual input in normal mode
- Prompts for source and target languages (or preconfigure them)
- Works asynchronously using `curl` and `vim.fn.jobstart`
- Displays translation result using `vim.notify`
- Easy to configure with your API key

---

## 🔧 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "ask-786/translate.nvim",
  config = function()
    require("translate").setup({
      key = os.getenv("GOOGLE_TRANSLATE_API_KEY"),
      translate_from = "auto",  -- Optional: default source language
      translate_to = "en",      -- Optional: default target language
    })
  end,
}
```

---

## 🛠️ Setup

```lua
require("translate").setup({
  key = "YOUR_GOOGLE_TRANSLATE_API_KEY", -- or use os.getenv("...")
  translate_from = nil,  -- Optional: "fr", "ja", or "auto". If nil, you will be prompted.
  translate_to = nil,    -- Optional: "en", "de", etc. If nil, you will be prompted.
})
```

## 📖 Usage

### Visual Mode

1. Select some text.
2. Run Lua command:

   ```lua
   :lua require("translate").translate()
   ```

### Normal Mode

1. Just run:

   ```lua
   :lua require("translate").translate()
   ```

2. You’ll be prompted to enter text, source language, and target language.

---

## ✅ Example

**Input** (in French):

```
Bonjour, comment allez-vous ?
```

**Output**:

```
Translation: Hello, how are you?
```

---

## 📌 Requirements

- `curl` (used under the hood)
- Google Translate API key

  - You can get one from [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
