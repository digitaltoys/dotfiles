# dotfiles

macOS 기준 개발 환경을 빠르게 재현하기 위한 dotfiles 저장소입니다.

## 핵심 내용

- `install.sh` 한 번으로 Homebrew 패키지, 설정 링크, Neovim, mise, bun, 커스텀 스크립트, macOS 기본 설정까지 순서대로 적용합니다.
- 기본적으로 `set -e`로 에러 시 중단하지만, `brew bundle` 실패는 경고만 출력하고 다음 단계를 계속 진행합니다.
- 주요 설정 파일은 심볼릭 링크로 연결하므로, 저장소 파일을 수정하면 실제 환경에 바로 반영됩니다.

## 빠른 시작

```bash
cd ~/dotfiles
./install.sh
```

설치 후:

```bash
source ~/.zshrc
```

## 스크립트 사용법

### 1) install.sh

전체 환경 부트스트랩 스크립트입니다.

```bash
./install.sh
```

주요 동작:

- Homebrew 미설치 시 자동 설치
- `Brewfile` 패키지 설치 (`brew bundle`)
- `fzf-tab` 설치
- LazyVim starter 준비(없을 때만)
- 각종 설정 심볼릭 링크 생성
- `mise` 도구 설치/신뢰 설정
- `bun/global-packages.txt` 기반 전역 패키지 설치(개별 실패 무시)
- `scripts/dev`를 `~/.local/bin/dev`로 링크
- macOS에서 `macos.sh` 실행

실패 처리:

- `brew bundle` 실패 시 스크립트는 중단하지 않고 계속 진행
- 마지막에 재시도 명령 안내:
  - `brew bundle --file="$DOTFILES_DIR/Brewfile"`

### 2) macos.sh

macOS 시스템 기본 설정 스크립트입니다.

```bash
./macos.sh
```

주요 설정:

- 키보드 반복 속도/지연
- 마우스/트랙패드 가속, 스크롤 방향
- Finder 표시 옵션(확장자, 숨김 파일, 경로/상태 바 등)
- Dock 자동 숨김/크기/최근 앱 표시
- 스크린샷 저장 위치/포맷/그림자

주의:

- `sudo` 권한이 필요합니다.
- 일부 변경은 로그아웃/재시작 후 반영됩니다.

### 3) scripts/dev

`tmux + git worktree` 기반 개발 세션 관리 스크립트입니다.
`install.sh` 실행 후 `dev` 명령으로 사용할 수 있습니다.

```bash
dev
dev <name>
dev -l
dev -c <name>
dev -c --all
dev -c --orphans
```

주요 사용 패턴:

- `dev`: 현재 디렉터리에서 tmux 세션 시작
- `dev s1`: `../.worktrees/<repo>/s1` 워크트리 생성 후 세션 시작
- `dev -l`: 워크트리 세션 목록 + tmux 활성 상태 확인
- `dev -c s1`: 해당 세션 정리(tmux, worktree, branch)
- `dev -c --all`: 현재 레포 세션 전체 정리
- `dev -c --orphans`: tmux가 없는 orphan worktree 세션 정리

생성되는 tmux 윈도우:

- `code`: `opencode`
- `git`: `lazygit`
- `term`: 일반 터미널

## 주요 파일

- `Brewfile`: Homebrew 패키지 목록
- `bun/global-packages.txt`: bun 전역 패키지 목록
- `mise/.mise.toml`: 런타임/도구 버전 정의
