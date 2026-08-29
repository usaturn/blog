#!/bin/bash

set -u

sudo mkdir -p /home/vscode/.local/bin
sudo chown -R vscode:vscode /home/vscode/.local

cat .devcontainer/zshrc.txt >> ${HOME}/.zshrc
sudo perl -pi -e 's@http://archive\.ubuntu\.com@https://archive.ubuntu.com@g; s@http://security\.ubuntu\.com@https://security.ubuntu.com@g' /etc/apt/sources.list.d/ubuntu.sources
sudo apt update && sudo apt install -y vim tig ripgrep fzf bubblewrap
echo "Setting up Japanese locale..."
sudo perl -pi -e 's/# ja_JP\.UTF-8/ja_JP.UTF-8/' /etc/locale.gen
sudo locale-gen
echo "Locale setup completed."

echo "Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash
echo "Installing Codex CLI..."
yarn global add @openai/codex@latest
echo "Installing Grok Build..."
curl -fsSL https://x.ai/cli/install.sh | bash

YARN_GLOBAL_BIN="$(yarn global bin 2>/dev/null || true)"
if [ -n "$YARN_GLOBAL_BIN" ] && [ -d "$YARN_GLOBAL_BIN" ]; then
    export PATH="$YARN_GLOBAL_BIN:$PATH"
fi
export PATH="$HOME/.local/bin:$PATH"

echo "Installing glab..."
if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is required to install glab." >&2
    exit 1
fi

glab_release_json="$(curl -fsSL "https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest")" || {
    echo "Failed to fetch the latest glab release metadata." >&2
    exit 1
}

glab_tag="$(printf '%s\n' "$glab_release_json" | python3 -c '
import json, re, sys
try:
    data = json.load(sys.stdin)
except json.JSONDecodeError:
    sys.exit(1)
tag = data.get("tag_name") or ""
if not re.match(r"^v[0-9]", tag):
    sys.exit(1)
print(tag)
')" || {
    echo "Failed to parse glab release tag_name." >&2
    exit 1
}

glab_version="${glab_tag#v}"

case "$(uname -m)" in
    x86_64)
        glab_arch="amd64"
        ;;
    aarch64)
        glab_arch="arm64"
        ;;
    *)
        echo "Unsupported architecture for glab: $(uname -m)" >&2
        exit 1
        ;;
esac

glab_tmpdir="$(mktemp -d)" || {
    echo "Failed to create a temporary directory for glab." >&2
    exit 1
}
trap 'rm -rf "${glab_tmpdir}"; trap - EXIT' EXIT

glab_tarball_url="https://gitlab.com/gitlab-org/cli/-/releases/${glab_tag}/downloads/glab_${glab_version}_linux_${glab_arch}.tar.gz"
if ! curl -fsSL -o "${glab_tmpdir}/glab.tar.gz" "${glab_tarball_url}"; then
    echo "Failed to download glab from ${glab_tarball_url}." >&2
    exit 1
fi

if ! tar -xzf "${glab_tmpdir}/glab.tar.gz" -C "${glab_tmpdir}"; then
    echo "Failed to extract glab tarball." >&2
    exit 1
fi

if [ ! -f "${glab_tmpdir}/bin/glab" ]; then
    echo "glab binary missing from release tarball." >&2
    exit 1
fi

if ! cp "${glab_tmpdir}/bin/glab" "${HOME}/.local/bin/glab"; then
    echo "Failed to install glab to ${HOME}/.local/bin/glab." >&2
    exit 1
fi
chmod +x "${HOME}/.local/bin/glab"

rm -rf "${glab_tmpdir}"
trap - EXIT

if ! command -v glab >/dev/null 2>&1; then
    echo "glab installation completed without placing glab on PATH." >&2
    exit 1
fi
if ! glab version; then
    echo "glab version verification failed." >&2
    exit 1
fi

# Install uv
curl -LsSf https://astral.sh/uv/install.sh | sh

echo "Installing pi..."
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
pi install npm:pi-subagents
pi install git:github.com/obra/superpowers
pi install npm:pi-mcp-adapter
pi update
uv run python scripts/add_pi_skills_setting.py

echo "Installing Starship..."
curl -sS https://starship.rs/install.sh | sh -s -- -y
mkdir -p "${HOME}/.config"
cp .devcontainer/starship.toml "${HOME}/.config/starship.toml"

mkdir -p "${HOME}/bin"
cp .devcontainer/herdr-git-status.bash "${HOME}/bin/herdr-git-status.bash"
chmod +x "${HOME}/bin/herdr-git-status.bash"
cp .devcontainer/herdr-status-updater.bash "${HOME}/bin/herdr-status-updater.bash"
chmod +x "${HOME}/bin/herdr-status-updater.bash"
# herdrstart は PATH 上の herdr-status-updater（拡張子なし）を呼ぶ
cp .devcontainer/herdr-status-updater.bash "${HOME}/bin/herdr-status-updater"
chmod +x "${HOME}/bin/herdr-status-updater"
mkdir -p "${HOME}/.local/bin" && [ -d "${HOME}/.local/bin" ] && export PATH="${HOME}/.local/bin:${PATH}"

echo "Installing Herdr..."
if ! (set -o pipefail; curl -fsSL https://herdr.dev/install.sh | sh); then
    echo "Herdr installation failed." >&2
    exit 1
fi

if ! mkdir -p "${HOME}/.config/herdr"; then
    echo "Failed to create Herdr config directory." >&2
    exit 1
fi
if [ ! -f "${HOME}/.config/herdr/config.toml" ]; then
    if ! cp .devcontainer/herdr.toml "${HOME}/.config/herdr/config.toml"; then
        echo "Failed to place Herdr config." >&2
        exit 1
    fi
fi

if ! command -v herdr >/dev/null 2>&1; then
    echo "Herdr installation completed without placing herdr on PATH." >&2
    exit 1
fi
if ! herdr --version; then
    echo "Herdr version verification failed." >&2
    exit 1
fi

