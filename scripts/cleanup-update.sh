#!/bin/bash

set -euo pipefail

# --- Colors for nice output ---
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
RESET="\e[0m"

echo -e "${GREEN}Starting Arch Linux update & cleanup...${RESET}"
echo

# --- Step 1: Update pacman database and system ---
echo -e "${YELLOW}Updating system packages...${RESET}"
doas pacman -Syu --noconfirm

# --- Step 2: Remove unused dependencies ---
echo -e "${YELLOW}Removing unused dependencies...${RESET}"
doas pacman -Rns $(pacman -Qtdq 2>/dev/null || echo "") || true

# --- Step 3: Clean pacman cache (keep 3 latest versions) ---
echo -e "${YELLOW}Cleaning package cache...${RESET}"
doas paccache -r -k3

# --- Step 4: Update AUR packages (if yay installed) ---
if command -v yay >/dev/null 2>&1; then
    echo -e "${YELLOW}Updating AUR packages...${RESET}"
    yay -Syu --noconfirm
fi

# --- Step 5: Update Flatpak packages (if installed) ---
if command -v flatpak >/dev/null 2>&1; then
    echo -e "${YELLOW}Updating Flatpak packages...${RESET}"
    flatpak update -y
fi

# --- Step 6: Update Snap packages (if installed) ---
if command -v snap >/dev/null 2>&1; then
    echo -e "${YELLOW}Updating Snap packages...${RESET}"
    doas snap refresh
fi

# --- Step 7: Optional cleanup: orphaned Flatpak runtimes ---
if command -v flatpak >/dev/null 2>&1; then
    echo -e "${YELLOW}Removing unused Flatpak runtimes...${RESET}"
    flatpak uninstall --unused -y
fi

echo
echo -e "${GREEN}System update & cleanup complete!${RESET}"

