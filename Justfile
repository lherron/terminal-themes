# lsd-theme: Warm Graphite theme for lsd, vivid, p10k, and claude-code

# Install theme files
install:
    cp lsd/*.yaml ~/.config/lsd/
    mkdir -p ~/.config/vivid/themes
    cp vivid/themes/warm-graphite.yml ~/.config/vivid/themes/
    @# p10k: symlink if not already linked to this repo
    @if [ ! -L ~/.p10k.zsh ] || [ "$(readlink ~/.p10k.zsh)" != "$(pwd)/p10k/p10k.zsh" ]; then \
        rm -f ~/.p10k.zsh; \
        ln -s "$(pwd)/p10k/p10k.zsh" ~/.p10k.zsh; \
        echo "Linked ~/.p10k.zsh → $(pwd)/p10k/p10k.zsh"; \
    fi
    @# claude-code: symlink statusline script
    @mkdir -p ~/.claude
    @chmod +x claude-code/statusline-command.sh
    @if [ ! -L ~/.claude/statusline-command.sh ] || [ "$(readlink ~/.claude/statusline-command.sh)" != "$(pwd)/claude-code/statusline-command.sh" ]; then \
        rm -f ~/.claude/statusline-command.sh; \
        ln -s "$(pwd)/claude-code/statusline-command.sh" ~/.claude/statusline-command.sh; \
        echo "Linked ~/.claude/statusline-command.sh → $(pwd)/claude-code/statusline-command.sh"; \
    fi
    @echo "Installed. Run 'source ~/.zshrc' to apply."

# Sync changes from ~/.config back to repo
sync:
    cp ~/.config/lsd/colors.yaml lsd/
    cp ~/.config/lsd/config.yaml lsd/
    cp ~/.config/vivid/themes/warm-graphite.yml vivid/themes/
    @echo "Synced from ~/.config to repo."
    @echo "(p10k syncs automatically via symlink)"

# Test the theme
test:
    @echo "=== lsd -la ==="
    lsd -la
    @echo ""
    @echo "=== lsd --tree --depth 1 ==="
    lsd --tree --depth 1
    @echo ""
    @echo "=== lsd -la --git ==="
    lsd -la --git

# Reload shell and test
reload:
    @echo "Run: source ~/.zshrc && just test"
