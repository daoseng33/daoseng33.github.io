# 專案工作規則

- 一律用繁體中文與使用者溝通。
- 開始任何工作前，先閱讀本檔案。
- 本專案是 Jekyll + GitHub Pages，使用 `jekyll-theme-chirpy`。
- 本專案站台時區為 `Asia/Taipei`。建立或更新文章日期時，必須用工具取得台北時間，不要憑模型記憶猜測。
  - 建議指令：`TZ=Asia/Taipei ruby -rtime -e 'puts Time.now.iso8601(3)'`

## 新文章與草稿

- 使用者要求建立新文章時，預設先建立草稿到 `_drafts/`。
- 如果 `_drafts/` 尚不存在，第一次建立草稿時可以自動建立該資料夾。
- 草稿檔名格式使用：
  `_drafts/文章標題或slug.md`
- 如果使用者尚未提供完整標題，先使用合理的暫定 slug，例如：
  `_drafts/untitled.md`
  或依主題建立 `_drafts/<topic-slug>.md`。
- 只有在使用者明確要求發布、上架、建立正式文章，或指定 `_posts/` 時，才建立正式文章檔案。
- 正式文章檔名格式使用：
  `_posts/YYYY-MM-DD-文章標題或slug.md`

## Front Matter 樣板

建立草稿或正式文章時，使用以下 front matter：

```yaml
---
layout: post
title: "<使用者提供的標題；若未提供則留空或填暫定標題>"
date: "<AI 取得的台北時間 ISO8601，例如 2026-04-19T10:30:06.000+08:00>"
categories:
  - 文章
tags: []
lastmod: "<同 date；若修改既有文章則更新為當下台北時間>"
---
```

## 分類與標籤

- 若使用者提供分類或標籤，優先使用使用者提供的內容。
- 若使用者未提供分類，預設：
  `categories: ["文章"]`
- 若使用者未提供標籤，不要自行發明標籤；使用：
  `tags: []`
- 可參照既有文章給出建議，但不要未經確認就新增推測性標籤。
- 若標題或內容包含「轉貼」、「分享」，可以建議使用 `分享` tag。
- 若主題明確延續憂鬱症、低谷、黑狗等既有文章脈絡，可以建議沿用 `黑狗` tag，但需要使用者確認。

## 內容佔位

- 草稿正文可以保留簡短佔位，讓使用者補齊，例如：

```md
<!-- 開場或摘要：待補 -->
```

## 修改文章

- 修改既有文章時，若有實質內容變更，更新 `lastmod` 為當下台北時間。
- 不要任意改動既有文章的 `date`，除非使用者明確要求。

## Dev Container 與 Git 工作流

- 若專案已用 VS Code Dev Container 開啟，文章編輯與 Jekyll 驗證優先在 container 內執行。
- Container 內的專案路徑通常是：
  `/workspaces/daoseng33.github.io`
- Mac 本機專案路徑是：
  `/Users/daoseng33/Workspace/daoseng33.github.io`
- Dev Container 內的檔案是本機 repo 的掛載內容，修改文章、草稿與設定會同步反映到本機工作樹。
- 新增或修改文章後，優先在 container 內執行：
  `./tools/test.sh`
  或：
  `bundle exec jekyll build`
- `commit` 與 `push` 優先在 Mac 本機執行，避免 container 內 SSH key、ssh-agent、GitHub 認證與本機不一致。
- 若必須在 container 內 push，需先確認：
  `ssh -T git@github.com`
  與：
  `ssh-add -l`
  都正常。
- 若 container 內 build 通過、本機 commit/push，提交前仍需在最終使用的環境確認 `git status`，避免提交到錯誤路徑或漏掉檔案。

## 驗證

- 新增或修改文章後，建議執行：
  `./tools/test.sh`
  或：
  `bundle exec jekyll build`
- 不要在未經使用者要求時改動 `_config.yml`、GitHub Actions、theme 設定或外掛。
