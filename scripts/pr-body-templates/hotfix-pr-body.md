## 注意事項

以下の項目を読んでからこちらの作業に当たってください

- 作業にはダブルチェックを兼ねて二人以上で行うこと
- tagの作成までは `update-branch` , `git pull`, `git pull origin main` の実行を行わないこと

## リリースTODO

1. このPRで変更のあるファイル(eg. .app-version, RELEASENOTES.md)の差分に間違いはないか確認する
2. 審査対象がiOSのみ、Androidのみであれば[こちらのルール](https://github.com/WinTicket/app/discussions/4987)に従って `.app-version` を更新する
3. 取り込みたいcommitをcherry-pickで追加する
4. このbranchのcommit historyが最新のリリースからcherry-pickで追加したもののみになっているか確認する(この時、変更差分ファイルは.app-version, RELEASENOTES.md, cherry-pickした差分ファイルのみであることを確認する)
5. `git tag $今回のversionとビルドナンバー`
6. `git push origin $今回のversionとビルドナンバー`
7. このPRを通常のPR同様mainに取り込む(この時、変更差分ファイルは.app-version, RELEASENOTES.mdのみであることを確認する)