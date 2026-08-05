# testing.nvim

如果你想要用`nvim -l my_script.lua`的方式來執行腳本，有時候又想要對腳本寫測試

此時，這個套件可以幫助您做測試

## 範例:

請參考

- [testing_spec.lua](tests/testing_spec.lua)

## CLI

只要導入[lua/testing.lua](lua/testing.lua)即可，例如:

```sh
nvim -u testing.lua -l my_script.lua
```


---

如果在你的nvim中已用`vim.pack.add({ "https://github.com/CarsonSlovoka/testing.nvim" })`

那麼就可以直接

```sh
nvim -u NORC -l myscript.lua
```


| 啟動方式              | 讀 init.lua | 載入 plugins | syntax/filetype  |
| ---                   | :--:        | :--:         | :--:             |
| `nvim`                |          ✅ |          ✅  |               ✅ |
| `nvim -u NORC`        |          ❌ |          ✅  |               ✅ |
| `nvim -u NONE`        |          ❌ |          ❌  |               ❌ |
| `nvim --noplugin`     |          ✅ |          ❌  |               ✅ |


> [!TIP] `:help --noplugin`


> [!NOTE] 也可以[參考](https://github.com/CarsonSlovoka/nvim/commit/abb41095a621f495bff1e14d40710fa1fa82cf4d)

### 批量跑測試

```sh
fd _test -e lua -x nvim -u NORC -l {} # 用fdfind找出所有_test.lua的檔案

# 也可以這樣
fd _test -e lua -X bash -c '
  for f; do
    echo "$(realpath $f)"
    nvim -u NORC -l $f
  done
' bash
```
