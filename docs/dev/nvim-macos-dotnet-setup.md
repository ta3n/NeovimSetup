# Neovim + .NET IDE Setup — macOS Apple Silicon

Terminal-first .NET development environment. LazyVim as base, csharp-ls for LSP,
dotnet format for formatting. No over-engineering — daily coding ready.

---

## Prerequisites (đã cài sẵn)

| Tool | Version | Cài bằng |
|------|---------|----------|
| Neovim | 0.12.2 | `brew install neovim` |
| .NET SDK | 10 / 9 / 8 | microsoft.com/dotnet |
| csharp-ls | latest | `dotnet tool install --global csharp-ls` |
| ripgrep | 15.x | `brew install ripgrep` |
| fd | 10.x | `brew install fd` |
| lazygit | 0.61+ | `brew install lazygit` |
| fzf | 0.73+ | `brew install fzf` |
| node | 20.x | nvm |

PATH cần có trong `~/.zshrc` (đã có):
```zsh
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
```

---

## Cài đặt ban đầu

### 1. Setup đã được thực hiện

Config tại `~/.config/nvim/` đã bao gồm:
- LazyVim starter (base configuration)
- `lua/plugins/csharp.lua` — C# LSP + treesitter + formatter
- `lua/plugins/extras.lua` — kulala.nvim (REST client)

### 2. Khởi động lần đầu

```bash
nvim
```

Khi mở lần đầu, LazyVim sẽ tự động:
1. Clone `lazy.nvim` plugin manager
2. Tải và cài tất cả plugins (mất ~2-5 phút tùy mạng)
3. Compile treesitter parsers

Nếu cần force sync:
```
:Lazy sync
```

Nếu treesitter chưa tự cài C#:
```
:TSInstall c_sharp
```

### 3. Kiểm tra LSP

Mở một file `.cs` bất kỳ:
```bash
nvim src/MyProject/Controllers/SomeController.cs
```

Trong Neovim:
```
:LspInfo          # csharp_ls phải hiển thị "attached"
:checkhealth lsp  # kiểm tra toàn bộ LSP health
```

---

## Cấu trúc config

```
~/.config/nvim/
├── init.lua                          # LazyVim bootstrap entry
├── lua/
│   ├── config/
│   │   ├── lazy.lua                  # Plugin manager setup
│   │   ├── options.lua               # Neovim options
│   │   ├── keymaps.lua               # Custom keymaps
│   │   └── autocmds.lua              # Autocommands
│   └── plugins/
│       ├── csharp.lua                # C# LSP + treesitter + formatter
│       ├── extras.lua                # REST client (kulala.nvim)
│       └── example.lua               # LazyVim examples (disabled)
└── docs/dev/
    ├── nvim-macos-dotnet-setup.md    # (this file)
    └── template.editorconfig         # Copy to project root
```

---

## Keymaps quan trọng (LazyVim defaults)

`<leader>` = Space

### Navigation
| Keymap | Action |
|--------|--------|
| `<leader><space>` | Find files (snacks picker) |
| `<leader>/` | Search in project (live grep) |
| `<leader>ff` | Find files |
| `<leader>fg` | Find in git files |
| `<leader>fb` | Find buffers |
| `<leader>fr` | Recent files |
| `<C-p>` | Find files (telescope fallback) |

### LSP
| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gr` | Go to references |
| `gI` | Go to implementation |
| `K` | Hover documentation |
| `<leader>cr` | Rename symbol |
| `<leader>ca` | Code action |
| `<leader>cf` | Format file |
| `]d` / `[d` | Next/prev diagnostic |
| `<leader>cd` | Line diagnostics |

### Diagnostics (Trouble)
| Keymap | Action |
|--------|--------|
| `<leader>xx` | Toggle diagnostics panel |
| `<leader>xw` | Workspace diagnostics |
| `<leader>xd` | Document diagnostics |
| `<leader>xq` | Quickfix list |

### Git (gitsigns + lazygit)
| Keymap | Action |
|--------|--------|
| `<leader>gg` | Open lazygit |
| `]h` / `[h` | Next/prev hunk |
| `<leader>ghs` | Stage hunk |
| `<leader>ghr` | Reset hunk |
| `<leader>ghb` | Blame line |
| `<leader>ghd` | Diff hunk |

### REST Client (kulala.nvim)
| Keymap | Action |
|--------|--------|
| `<leader>Rr` | Run HTTP request under cursor |
| `<leader>Ra` | Run all requests in file |
| `<leader>Rv` | Toggle response view |
| `<leader>Re` | Set environment |
| `<leader>Rc` | Copy as cURL |

### Buffer / Window
| Keymap | Action |
|--------|--------|
| `<leader>bd` | Delete buffer |
| `<S-h>` / `<S-l>` | Prev/next buffer |
| `<C-h/j/k/l>` | Navigate windows |
| `<leader>-` / `<leader>\|` | Split horizontal/vertical |

---

## Daily Workflow

### Coding
```bash
# Mở project (từ thư mục chứa .sln)
cd ~/projects/MyService
nvim .

# Hoặc mở file cụ thể
nvim src/MyService.Api/Program.cs
```

### Run API
```bash
dotnet watch run --project src/MyService.Api
```

### Test
```bash
dotnet test                              # tất cả tests
dotnet test --filter "Category=Unit"    # filter theo category
dotnet test --logger "console;verbosity=detailed"
```

### Docker infra (local)
```bash
docker compose up -d postgres redis rabbitmq
docker compose logs -f
```

### Build
```bash
dotnet build                  # full build
dotnet build --tl             # terminal logger (đẹp hơn)
dotnet clean && dotnet build  # clean build
```

### Search nhanh
```bash
rg "IUserRepository"          # search text trong project
rg "class.*Controller" --type cs
fd "*.cs" --type f            # find files
fd "appsettings" --type f
```

### Git
```bash
lazygit                       # TUI full-featured
# hoặc dùng <leader>gg trong nvim
```

---

## Formatter Setup

### dotnet format (mặc định)
Chạy tự động khi lưu file (nếu project có `.sln` hoặc `.csproj` ở trên).

Chạy thủ công:
```
:lua require("conform").format()
```
Hoặc keymap: `<leader>cf`

Chạy từ terminal:
```bash
dotnet format                          # toàn bộ project
dotnet format --include "**/*.cs"      # tất cả .cs files
dotnet format --verify-no-changes      # chỉ check, không sửa (dùng cho CI)
```

### Tắt auto-format nếu chưa cần
Thêm vào `lua/config/options.lua`:
```lua
vim.g.autoformat = false
```

### Dùng CSharpier thay thế (tùy chọn)
CSharpier nhanh hơn và hoạt động per-file tốt hơn. Dùng khi team đã thống nhất.
```bash
dotnet tool install --global csharpier
```

Sau đó trong `lua/plugins/csharp.lua`, đổi:
```lua
formatters_by_ft = { cs = { "csharpier" } },
```
Và uncomment block `csharpier` trong `formatters`.

---

## .editorconfig

Copy `docs/dev/template.editorconfig` vào root của project:
```bash
cp ~/.config/nvim/docs/dev/template.editorconfig /path/to/project/.editorconfig
```

File này định nghĩa code style cho C# và được `dotnet format` tôn trọng.

---

## REST Client (.http files)

Tạo file `requests/auth.http`:
```http
### Login
POST http://localhost:5000/api/auth/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "secret"
}

### Get users
GET http://localhost:5000/api/users
Authorization: Bearer {{token}}
```

Đặt cursor vào request và nhấn `<leader>Rr` để chạy.

Environments: tạo file `.env` trong project root:
```
BASE_URL=http://localhost:5000
TOKEN=your-jwt-token-here
```

---

## Debug (Optional — setup sau)

Giai đoạn đầu nên dùng:
- `dotnet CLI` cho build/test errors
- Rider hoặc VS Code fallback cho debug phức tạp
- `Console.WriteLine` / `ILogger` + `dotnet watch`

Khi workflow ổn định, có thể setup:
```
nvim-dap + netcoredbg
```

Cài netcoredbg:
```bash
brew install samsung/netcoredbg/netcoredbg
```

Thêm vào `lua/plugins/`:
```lua
{ import = "lazyvim.plugins.extras.dap.core" }
-- sau đó tạo lua/plugins/dap-dotnet.lua
```

---

## Troubleshooting

### csharp-ls không attach
```bash
# Kiểm tra binary
which csharp-ls
csharp-ls --version

# Kiểm tra PATH
echo $PATH | tr ':' '\n' | grep dotnet

# Restart LSP
:LspRestart
```

### Treesitter C# không highlight
```
:TSInstall c_sharp
:TSUpdate c_sharp
```

### Plugin không load
```
:Lazy         # mở Lazy UI, nhấn S để sync
:checkhealth  # kiểm tra tổng thể
```

### dotnet format lỗi "not a .NET project"
Đảm bảo bạn đang mở file `.cs` từ thư mục có chứa `.sln` hoặc `.csproj` ở trên.
`require_cwd = true` trong config sẽ skip format nếu không tìm thấy project root.

### Xem LSP logs
```
:LspLog
```

---

## Alternative: roslyn.nvim

Nếu sau này muốn upgrade LSP lên Microsoft Roslyn (mạnh hơn, IDE-grade):
- Plugin: `seblj/roslyn.nvim`
- Yêu cầu: download Roslyn LSP binary riêng
- Ưu điểm: full Roslyn analysis, refactoring, import suggestions tốt hơn
- Nhược điểm: nặng hơn, setup phức tạp hơn, cần binary từ VS/Rider

Không nên setup ngay — csharp-ls đủ tốt cho daily coding.

---

*Setup ngày 2026-05-31. macOS Apple Silicon, nvim 0.12.2, .NET 10.*
