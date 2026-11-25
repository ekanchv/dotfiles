# Machine setup

Sets up an Ubuntu machine with these dotfiles and the tools they depend on.

```bash
curl -fsSL https://raw.githubusercontent.com/esh-k/dotfiles/main/setup/install.sh | bash
```

The headless layer always installs; you're asked whether to add the GUI layer.
Skip the prompt with `bash -s -- --headless` or `bash -s -- --gui`. Re-running is
safe and upgrades anything whose pinned version changed.

| Layer | From apt | From upstream releases (`versions.env`) |
|---|---|---|
| headless | git (git-core PPA), curl, build tools, cmake (Kitware), ripgrep, fd, fzf, jq, tree, colordiff, ffmpeg, imagemagick, tmux, just, kitty, docker + buildx, opam, clangd | chezmoi + these dotfiles, pyenv + Python, neovim (+ plugins, mason tools, python venv), node, go, tree-sitter CLI, quarto, bazel (bazelisk), rust (rustup), lean (elan), rocq + coqide-server + iris (opam), homebrew, utftex |
| GUI | LaTeX + zathura, clipboard tools | Chrome (amd64 only), Ghostty, JetBrainsMono Nerd Font |

Tools are installed with apt unless Ubuntu's version is too old for the dotfiles
or isn't packaged. Upstream versions are pinned in [`versions.env`](versions.env);
set any of them to `latest` to take the newest release instead.

Rocq and Iris go into opam's global switch `default`, without opam's shell hook:
run `opamswitch default` (from `.bash_aliases`) to put them on PATH in a shell.
Neovim's Coqtail finds the switch by itself. Lean is on PATH through `~/.elan/env`,
which `.bashrc` sources.

## Layout

- `install.sh`: entry point; clones this repo to `~/.local/share/chezmoi` when piped from curl
- `lib/headless.sh`, `lib/gui.sh`: one function per tool
- `test/run.sh --headless|--gui`: install into a fresh Ubuntu container, then run `test/verify.sh`, which exercises each tool (`PLATFORM=linux/amd64` to emulate x86)

## Installing from a branch

`DOTFILES_REF` (default `main`) is the only setting for this. Keep the URL on `main`:
the installer clones `DOTFILES_REF` and runs that branch's copy of `setup/`.

```bash
curl -fsSL https://raw.githubusercontent.com/esh-k/dotfiles/main/setup/install.sh | DOTFILES_REF=<branch> bash
```

The machine then stays on that branch, and `chezmoi update` follows it. Re-run the
curl command without `DOTFILES_REF` to switch it back to `main`. Running
`setup/install.sh` from an existing checkout uses that checkout's branch.

In the container test, `DOTFILES_REF=<branch> test/run.sh --headless` applies that
branch's dotfiles; the `setup/` scripts always come from the local checkout.
