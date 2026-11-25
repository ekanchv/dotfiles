return {
  -- Rocq/Coq, Proof-General style interactive stepping with goals + info panels.
  -- BACKEND: an opam switch with rocq-core + coqide-server (provides coqidetop),
  -- plus pynvim in the python3 provider venv (else Coqtail's commands don't register).
  {
    "whonore/Coqtail",
    ft = "coq",
    init = function()
      -- map .v to filetype `coq` so the lazy `ft` trigger fires
      vim.filetype.add({ extension = { v = "coq" } })

      -- Coqtail's built-in maps live under <leader>r ("rocq") instead of the default
      -- <leader>c, which is the LSP "code" group (ca/cr/cf). Coqtail README "Mappings":
      --   rc start  rq stop  rG jump to end  rT to top  rE jump to error
      --   rs Search  rh Check  ra About  rp Print  rf Locate  rgd goto def  rr restore panels
      vim.g.coqtail_map_prefix = "<leader>r"
      -- No insert-mode maps: with <Space> as leader they'd fire while typing
      -- (a space followed by r and j/k/l/T/G/E/r).
      vim.g.coqtail_noimap = 1

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("coqtail_keys", { clear = true }),
        pattern = "coq",
        callback = function(ev)
          -- Find coqidetop without needing the shell's opam env. Precedence, as in opam:
          -- an explicit `opamswitch <sw>` ($OPAMSWITCH, already on PATH) > the switch
          -- linked to this project (`opam switch link <sw> .` creates `_opam`) >
          -- coqidetop already on PATH > opam's global switch (where setup/install.sh
          -- puts Rocq on Ubuntu).
          local function use(bin)
            if vim.fn.executable(bin .. "/coqidetop") == 1 then
              vim.b[ev.buf].coqtail_coq_path = bin
              return true
            end
          end
          if not vim.env.OPAMSWITCH then
            local file = vim.api.nvim_buf_get_name(ev.buf)
            local opam = vim.fs.find("_opam", { upward = true, path = vim.fs.dirname(file), limit = 1 })[1]
            if not (opam and use(opam .. "/bin")) and vim.fn.executable("coqidetop") == 0 then
              local root = vim.env.OPAMROOT or vim.fn.expand("~/.opam")
              local ok, lines = pcall(vim.fn.readfile, root .. "/config")
              local sw = ok and vim.iter(lines):map(function(l) return l:match('^switch: "(.-)"') end):next()
              if sw then
                use((sw:find("/") and sw .. "/_opam" or root .. "/" .. sw) .. "/bin")
              end
            end
          end

          -- quick single-key stepping
          local function m(lhs, rhs, desc)
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = "rocq: " .. desc })
          end
          m("<localleader>j", "<cmd>RocqNext<CR>", "step forward")
          m("<localleader>k", "<cmd>RocqUndo<CR>", "step back")
          m("<localleader>l", "<cmd>RocqToLine<CR>", "run to cursor")

          pcall(function()
            require("which-key").add({ { "<leader>r", group = "rocq", buffer = ev.buf } })
          end)
        end,
      })
    end,
  },
}
