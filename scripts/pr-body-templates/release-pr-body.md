## リリースTODO

- [ ] metadata(キーワードやスクリーンショット)の更新(必要があれば)
  - [ ] Android
  - [ ] iOS(ja)
  - [ ] iOS(en)
- [ ] [Feature Flag](https://github.com/WinTicket/app/blob/main/packages/app/lib/foundation/flag/flag.dart)の更新(必要があれば)
  - [ ] WIP -> Opsの変更があった場合はFirebase consoleにRemote Configを追加の対応も
- [ ] [Milestone](https://github.com/WinTicket/app/milestones)を確認し、今回のリリースに入るべき差分が入っているか(不要な差分が入っていないか)
  - [ ] 100%Completedになっているか(なっていない場合は解消もしくは次のMilestoneに移す)
- [ ] 前回のリリースからのVRTの結果を確認し、問題がないか
- [ ] 自動テストの結果を確認し、問題がないか
  - [ ] [Sentry iOS](https://winticket.sentry.io/issues/?project=4504252694659072&query=E2E%3Ayes&referrer=issue-list&statsPeriod=14d)を確認し、怪しいエラーがないか
  - [ ] [Sentry Android](https://winticket.sentry.io/issues/?project=6143287&query=E2E%3Ayes&referrer=issue-list&statsPeriod=14d)を確認し、怪しいエラーがないか