return {
  -- Code-aware spell check: spelunker splits camelCase / snake_case identifiers
  -- into sub-words and checks each against the dictionary, so programming code
  -- gets meaningful spelling diagnostics (native :set spell can't split snake_case
  -- because `_` is a keyword char).
  {
    "kamykn/spelunker.vim",
    event = { "BufReadPre", "BufNewFile" },
    init = function()
      -- spelunker draws its own highlights, so leave Vim's native spell off.
      vim.opt.spell = false
      vim.g.enable_spelunker_vim = 1
      -- 2 = check only the words currently displayed in the window (fast on big
      -- files); 1 would check the whole buffer.
      vim.g.spelunker_check_type = 2
      -- skip things that aren't prose/identifiers and would just be noise.
      vim.g.spelunker_disable_uri_checking = 1
      vim.g.spelunker_disable_email_checking = 1
      vim.g.spelunker_disable_account_name_checking = 1 -- @handles
      vim.g.spelunker_disable_acronym_checking = 1 -- ALLCAPS
      vim.g.spelunker_disable_backquoted_checking = 1 -- `code`
      -- ignore very short fragments (i, x, fn, ...) that camel/snake splitting yields.
      vim.g.spelunker_target_min_char_len = 4
    end,
    config = function()
      local map = vim.keymap.set
      -- Z-prefixed corrections (only ZZ/ZQ are native, so these are collision-free):
      map("n", "Zl", function()
        vim.fn["spelunker#correct_from_list"]()
      end, { desc = "spell: correct word under cursor" })
      map("n", "ZL", function()
        vim.fn["spelunker#correct_all_from_list"]()
      end, { desc = "spell: correct all occurrences" })
      map("n", "Zg", function()
        vim.fn["spelunker#execute_with_target_word"]("spellgood")
      end, { desc = "spell: add word to dictionary" })
      map("n", "Zw", function()
        vim.fn["spelunker#execute_with_target_word"]("spellwrong")
      end, { desc = "spell: mark word as wrong" })
      -- toggle in the <leader>u (ui/toggle) namespace, alongside uf/um/up.
      -- spelunker#toggle#toggle() flips the flag AND clears/redraws its matchadd
      -- highlights (it highlights via matchadd, not syntax, so this is the only
      -- correct way to turn it off).
      map("n", "<leader>uz", function()
        vim.fn["spelunker#toggle#toggle"]()
        vim.notify("spelunker: " .. (vim.g.enable_spelunker_vim == 1 and "on" or "off"))
      end, { desc = "spell: toggle spelunker" })
    end,
  },
}
