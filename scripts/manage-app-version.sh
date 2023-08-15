#!/bin/bash

# local環境で実行する場合:
# $ ./scripts/manage-app-version.sh
#
# 自分で(major|minor|patch|build)を選択し、PRの作成をすることができる
#
# $ ./scripts/manage-app-version.sh patch-hotfix
#
# Hotfix用裏コマンド。最新のリリースタグからbranchを生やす。
#
# CI上で実行する場合:
# $ ./scripts/manage-app-version.sh (major|minor|patch|build)
#
# 引数に指定したversionのupdateが行われる

if ! type "gh" > /dev/null 2>&1; then
    errorLog "gh not found. please install with `brew install gh` & auth with `gh auth login`"
    exit 1
fi

CURRENT_VERSION=$(cat .app-version)
VERSION_REGEX="([0-9]+).([0-9]+).([0-9]+)-([0-9]+)"

if [[ $CURRENT_VERSION =~ $VERSION_REGEX ]]; then
  VERSION_MAJOR=${BASH_REMATCH[1]}
  VERSION_MINOR=${BASH_REMATCH[2]}
  VERSION_PATCH=${BASH_REMATCH[3]}
  VERSION_BUILD=${BASH_REMATCH[4]}
fi

# ビルドナンバーは前のビルドナンバーに対して100インクリメントする
# インクリメント前のビルドナンバーのsuffixが00ではない場合は00になるように切り捨てる
# eg. 3.8.0-300 -> 3.8.0-400, 3.8.0-521 -> 3.8.0-600 (ビルドナンバーのみの更新時)
UPDATED_BUILD_NUM=$((((VERSION_BUILD + 100) / 100) * 100))

UPDATED_MAJOR="$((VERSION_MAJOR + 1)).0.0-$UPDATED_BUILD_NUM"
UPDATED_MINOR="$VERSION_MAJOR.$((VERSION_MINOR + 1)).0-$UPDATED_BUILD_NUM"
UPDATED_PATCH="$VERSION_MAJOR.$VERSION_MINOR.$(($VERSION_PATCH + 1))-$UPDATED_BUILD_NUM"
UPDATED_BUILD="$VERSION_MAJOR.$VERSION_MINOR.$VERSION_PATCH-$UPDATED_BUILD_NUM"

echo '👻 リリース作業を開始します...'
echo "👻 現在の WINTICKET App のバージョンは $CURRENT_VERSION です"

PS3='👻 アップデートするバージョンの状態を選択してください: '

SELECTION_MAJOR="Major($UPDATED_MAJOR)"
SELECTION_MINOR="Minor($UPDATED_MINOR)"
SELECTION_PATCH="Patch($UPDATED_PATCH)"
SELECTION_BUILD="Build-Only($UPDATED_BUILD)"

UPDATING_VERSION="-"

if [ $# != 1 ]; then
  select ANSWER in $SELECTION_MAJOR $SELECTION_MINOR $SELECTION_PATCH $SELECTION_BUILD; do
    if [ -z "$ANSWER" ]; then
      continue
  else
    case "$ANSWER" in
    "$SELECTION_MAJOR") UPDATING_VERSION=$UPDATED_MAJOR ;;
    "$SELECTION_MINOR") UPDATING_VERSION=$UPDATED_MINOR ;;
    "$SELECTION_PATCH") UPDATING_VERSION=$UPDATED_PATCH ;;
    "$SELECTION_BUILD") UPDATING_VERSION=$UPDATED_BUILD ;;
    esac
    break
    fi
  done

  echo "👻 $UPDATING_VERSION にアップデートし、Pull Requestの作成を行います"
  read -p "👻 よろしいですか(y/n): " yn
  case "$yn" in
  [yY]*) ;;
  *) exit 0 ;;
  esac
else
  case "$1" in
    "major" ) UPDATING_VERSION=$UPDATED_MAJOR ;;
    "minor" ) UPDATING_VERSION=$UPDATED_MINOR ;;
    "patch" ) UPDATING_VERSION=$UPDATED_PATCH ;;
    "build" ) UPDATING_VERSION=$UPDATED_BUILD ;;
    "patch-hotfix" ) UPDATING_VERSION=$UPDATED_BUILD ;;
    * ) echo "$1 は不適切です。major、minor、patch、build のいずれかを入力してください" exit 1 ;;
  esac

  git config --local user.email "github-actions@users.noreply.github.com"
  git config --local user.name "github-actions"
fi

DEFAULT_BRANCH="main"
BRANCH_NAME="release-$UPDATING_VERSION"

if [ $# != 1 ] && [ "$1" == 'patch-hotfix' ]; then
  DEFAULT_BRANCH=$CURRENT_VERSION
  BRANCH_NAME="hotfix-$UPDATING_VERSION"
fi

if [ $# != 1 ]; then
  git checkout $DEFAULT_BRANCH
  git pull origin $DEFAULT_BRANCH
else
  echo "UPDATING_VERSION=$UPDATING_VERSION" >> $GITHUB_ENV
fi

git checkout -b $BRANCH_NAME

# .app-version を今回リリースするversionに書き換える
echo $UPDATING_VERSION | tee .app-version
git add .app-version

if [[ $UPDATING_VERSION != $UPDATED_BUILD ]]; then

# RELEASENOTES.mdに今回のversionについて追記する
BUILD_NAME=`echo $UPDATING_VERSION | sed -e 's/\([0-9\.]*\)-\(.*\)/\1/g'`
CURRENT_NOTE=`cat RELEASENOTES.md`
cat > RELEASENOTES.md << EOF
## $BUILD_NAME
WINTICKETをご利用いただきありがとうございます。今回のアップデートは次の通りになります。

- 軽微な不具合の改善・デザイン修正をおこないました。

$CURRENT_NOTE
EOF
git add RELEASENOTES.md

fi

git commit -m "[ota] release: bump app version to $UPDATING_VERSION"
git push origin --no-verify $BRANCH_NAME

BODY_FILE_PATH="scripts/pr-body-templates/release-pr-body.md"

if [ $# != 1 ] && [ "$1" == 'patch-hotfix' ]; then
  BODY_FILE_PATH="scripts/pr-body-templates/hotfix-pr-body.md"
fi

gh pr create \
  --body-file $BODY_FILE_PATH \
  --title "release: bump app version to $UPDATING_VERSION" \
  --head $BRANCH_NAME \
  --repo "ostk0069/git-tag-workflow"

exit 0