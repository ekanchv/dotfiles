return {
  {
    "Julian/lean.nvim",
    -- coq: also load for Rocq files so they get the same `\` symbol input (config below)
    ft = { "lean", "coq" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "nvim-lua/plenary.nvim",
    },
    -- Configured via vim.g.lean_config (lean.setup() is deprecated). The leanls
    -- server is managed by elan (NOT Mason). Completion is inherited from the
    -- global vim.lsp.config("*") capabilities (blink.cmp).
    init = function()
      vim.g.lean_config = {
        -- lean.nvim's built-in maps sit directly on <LocalLeader> (= <Space>) and
        -- shadow global maps like <leader>x (close buffer). The same maps are
        -- defined under <LocalLeader>l in the FileType autocmd below instead.
        mappings = false,
        lsp = { enable = true },
        infoview = {
          autoopen = true,
          show_processing = true,
        },
        abbreviations = {
          enable = true, -- unicode input: \to -> → (Space converts, Tab converts without a space)
          -- One table shared by Lean and Rocq buffers. Adds the Iris symbols from
          -- https://gitlab.mpi-sws.org/iris/iris/-/blob/master/docs/editor.md that Lean's
          -- table lacks; Lean already has \all \ex \to \and \or \fun \lam \iff \empty
          -- \comp \"o \_a.. \_x with the same meaning.
          extra = {
            mult = "⋅",
            ent = "⊢",
            valid = "✓",
            box = "□",
            bbox = "■",
            later = "▷",
            latert = "▶",
            pred = "φ",
            ccomp = "◎",
            sep = "∗",
            lc = "⌜",
            rc = "⌝",
            Lc = "⎡",
            Rc = "⎤",
            Lam = "Λ",
            Sig = "Σ",
            af = "◯",
            auth = "●",
            frag = "◯",
            gname = "γ",
            incl = "≼",
            update = "⇝",
            -- Iris meaning wins over Lean's (Lean: ⋄, ⁻¹, å). \-1 and \inv still give ⁻¹.
            diamond = "◇",
            ["-"] = "∖",
            aa = "●",
            -- keep the ASCII "or" `\/` as typed (Lean's default turns it into ⧸)
            ["/"] = "\\/",
          },
        },
      }

      -- Same keys as lean.nvim's defaults, just behind an extra `l`.
      local maps = {
        { "i", "LeanInfoviewToggle", "toggle infoview" },
        { "<Tab>", "LeanGotoInfoview", "jump to infoview" },
        { "x", "LeanInfoviewAddPin", "pin goal state" },
        { "c", "LeanInfoviewClearPins", "clear pins" },
        { "p", "LeanInfoviewPinTogglePause", "pause/unpause pins" },
        { "dx", "LeanInfoviewSetDiffPin", "set diff pin" },
        { "dc", "LeanInfoviewClearDiffPin", "clear diff pins" },
        { "dd", "LeanInfoviewToggleAutoDiffPin", "toggle auto-diff" },
        { "dt", "LeanInfoviewToggleNoClearAutoDiffPin", "toggle auto-diff + clear pins" },
        { "w", "LeanInfoviewEnableWidgets", "enable widgets" },
        { "W", "LeanInfoviewDisableWidgets", "disable widgets" },
        { "v", "LeanInfoviewViewOptions", "infoview view options" },
        { "s", "LeanInfoviewAcceptSuggestion", "accept suggestion" },
        { "\\", "LeanAbbreviationsReverseLookup", "how to type char under cursor" },
        { "r", "LeanRestartFile", "restart server for file" },
      }

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("lean_keys", { clear = true }),
        pattern = "lean",
        callback = function(ev)
          for _, m in ipairs(maps) do
            vim.keymap.set("n", "<localleader>l" .. m[1], "<cmd>" .. m[2] .. "<CR>", {
              buffer = ev.buf,
              desc = "lean: " .. m[3],
            })
          end
          -- interactive hover; configs/lspconfig.lua skips its K for lean buffers
          vim.keymap.set("n", "K", "<cmd>LeanHover<CR>", { buffer = ev.buf, desc = "lean: hover" })

          pcall(function()
            require("which-key").add({
              { "<localleader>l", group = "lean", buffer = ev.buf },
              { "<localleader>ld", group = "diff pins", buffer = ev.buf },
            })
          end)
        end,
      })
    end,
    config = function()
      -- Lean buffers get abbreviations automatically; also enable them in Rocq files.
      require("lean.abbreviations").enable("*.v")
    end,
  },
}
