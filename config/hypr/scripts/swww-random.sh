#!/bin/bash

# Thư mục chứa hình nền
WALLPAPER_DIR="$HOME/Pictures/wallpapers"

# Đảm bảo swww-daemon đang chạy
pgrep -x swww-daemon > /dev/null || (swww-daemon & sleep 0.5)

# Lặp vô hạn đổi hình nền mỗi 90s
LOCKFILE="/tmp/.swww_wallpaper.lock"
exec 9>"$LOCKFILE" || exit 1
flock -n 9 || exit 1

while true; do
    # Lọc ảnh có độ phân giải ≥ 1920x1080 và không lỗi
    img=$(find "$WALLPAPER_DIR" -type f \( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' \) \
        -exec identify -format "%w %h %i\n" {} + 2>/dev/null | \
        awk '$1 >= 1920 && $2 >= 1080 {print $3}' | \
        shuf -n 1)

    # Nếu có ảnh hợp lệ thì đặt làm nền
    if [ -n "$img" ]; then
        swww img "$img" \
            --transition-type grow \
            --transition-fps 60 \
            --transition-duration 1 \
            --transition-pos 0.5,0.5
    fi

    sleep 90
done
