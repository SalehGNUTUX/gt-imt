#!/bin/bash

# =============================================
# GT-IMT - ISO Mount Tool by SalehGNUTUX
# Version: 2.0.0
# Supports Arabic & English
# =============================================

# ============================================
# دوال مساعدة
# ============================================

# تنفيذ أمر بصلاحيات الجذر مع الحفاظ على البيئة
run_as_root() {
    if command -v pkexec &>/dev/null; then
        # pkexec يحافظ على البيئة بشكل أفضل
        pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" "$@"
    else
        # اللجوء إلى sudo
        sudo env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" "$@"
    fi
}

# دالة للحصول على المستخدم الحقيقي
get_real_user() {
    local user=$(logname 2>/dev/null)
    if [ -n "$user" ] && [ "$user" != "root" ]; then
        echo "$user"
        return 0
    fi
    if [ -n "$SUDO_USER" ] && [ "$SUDO_USER" != "root" ]; then
        echo "$SUDO_USER"
        return 0
    fi
    user=$(who am i | awk '{print $1}')
    if [ -n "$user" ] && [ "$user" != "root" ]; then
        echo "$user"
        return 0
    fi
    echo "$USER"
}

# دالة محسنة لفتح مدير الملفات (تعمل تحت المستخدم العادي)
open_file_manager() {
    local dir="$1"

    if [ ! -d "$dir" ]; then
        # إذا كان المجلد يتطلب صلاحيات جذر لإنشائه
        if [[ "$dir" == /mnt/* ]]; then
            run_as_root mkdir -p "$dir"
            run_as_root chmod 777 "$dir"
        else
            mkdir -p "$dir"
        fi
    fi

    if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
        echo "⚠️ لا توجد بيئة رسومية."
        echo "يمكنك الوصول إلى المجلد يدوياً عبر: cd $dir"
        return 1
    fi

    # محاولة xdg-open
    if command -v xdg-open &>/dev/null; then
        xdg-open "$dir" &>/dev/null &
        return 0
    fi

    # محاولة gio
    if command -v gio &>/dev/null; then
        gio open "$dir" &>/dev/null &
        return 0
    fi

    # البحث عن مدير ملفات معروف بناءً على بيئة سطح المكتب
    local fm_list=()
    if [ -n "$XDG_CURRENT_DESKTOP" ]; then
        case "$XDG_CURRENT_DESKTOP" in
            *KDE*|*kde*|*Plasma*) fm_list=("dolphin" "krusader") ;;
            *GNOME*|*gnome*|*Unity*) fm_list=("nautilus" "gnome-open") ;;
            *XFCE*|*xfce*) fm_list=("thunar") ;;
            *Cinnamon*) fm_list=("nemo") ;;
            *MATE*) fm_list=("caja") ;;
            *LXQt*) fm_list=("pcmanfm-qt") ;;
            *LXDE*) fm_list=("pcmanfm") ;;
            *) fm_list=("nautilus" "dolphin" "thunar" "pcmanfm" "caja" "nemo") ;;
        esac
    else
        fm_list=("nautilus" "dolphin" "thunar" "pcmanfm" "caja" "nemo")
    fi

    for fm in "${fm_list[@]}"; do
        if command -v "$fm" &>/dev/null; then
            "$fm" "$dir" &>/dev/null &
            return 0
        fi
    done

    echo "⚠️ تعذر فتح مدير الملفات. المسار: $dir"
    return 1
}

# ============================================
# الإعدادات الأساسية
# ============================================

HERE="$(dirname "$(readlink -f "${0}")")"

# منع حلقة التيرمنال المفرغة (Terminal Recursion Fix)
if [ "$GT_IMT_RUNNING" != "true" ]; then
    export GT_IMT_RUNNING="true"

    # كشف التيرمنال الافتراضي
    if [ -n "$(command -v x-terminal-emulator)" ]; then
        TERMINAL="x-terminal-emulator"
    elif [ -n "$(command -v gnome-terminal)" ]; then
        TERMINAL="gnome-terminal"
    elif [ -n "$(command -v konsole)" ]; then
        TERMINAL="konsole"
    elif [ -n "$(command -v xterm)" ]; then
        TERMINAL="xterm"
    fi

    # تشغيل في تيرمنال جديد فقط إذا لم نكن في واحد بالفعل
    if [ -n "$TERMINAL" ] && [ ! -t 0 ]; then
        if [ -f "$HERE/usr/bin/imt" ]; then
            exec "$TERMINAL" -e "$HERE/usr/bin/imt"
        else
            exec "$TERMINAL" -e "$0"
        fi
    fi
fi

# المسارات
iso_dir="$HOME/iso"
mnt_dir="/mnt/iso_mounts"
temp_file="/tmp/iso_selection.tmp"
lang_file="$HOME/.config/gt-imt/language"
version_file="$HOME/.config/gt-imt/version"
update_check_file="$HOME/.config/gt-imt/last_update_check"

# إنشاء مجلد الضم الرئيسي إذا لم يكن موجوداً (بصلاحيات الجذر)
if [ ! -d "$mnt_dir" ]; then
    run_as_root sh -c "mkdir -p '$mnt_dir' && chmod 777 '$mnt_dir'"
fi

# الإصدار الحالي
CURRENT_VERSION="2.0.0"

# إنشاء مجلد الإعدادات
mkdir -p "$HOME/.config/gt-imt"

# إعدادات اللغة
lang="auto"
if [ -f "$lang_file" ]; then
    lang=$(cat "$lang_file")
fi
if [ "$lang" = "auto" ]; then
    system_lang=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)
    if [ "$system_lang" = "ar" ]; then
        lang="ar"
    else
        lang="en"
    fi
fi

# تحميل النصوص
load_texts() {
    if [ "$lang" = "ar" ]; then
        text_title="GT-IMT - أداة ضم ملفات ISO"
        text_setup="📁 إعداد مجلد ISO"
        text_mount="💿 ضم ملف ISO"
        text_unmount="⏏️ إلغاء ضم ملف ISO"
        text_show="👁️ عرض الملفات المضمومة"
        text_extract="📦 فك ضغط ملف ISO"
        text_settings="⚙️ الإعدادات"
        text_uninstall="🗑️ إزالة البرنامج"
        text_exit="🚪 خروج"
        text_success="✅ تمت العملية بنجاح"
        text_failed="❌ فشلت العملية"
        text_choose="🔍 اختر خياراً"
        text_invalid="⚠️ اختيار غير صحيح"
        text_no_files="📭 لا توجد ملفات مضمومة"
        text_mounted="📌 الملفات المضمومة حالياً"
        text_select="🔎 اختر ملف ISO"
        text_select_dir="📂 اختر مجلد الوجهة"
        text_overwrite="📝 استبدال الكل"
        text_skip="⏭️ تخطي الملفات الموجودة"
        text_cancel="❌ إلغاء العملية"
        text_existing="📋 الملفات الموجودة مسبقاً"
        text_mount_point="📍 نقطة الضم"
        text_language="🌐 اللغة الحالية: العربية"
        text_settings_menu="⚙️ قائمة الإعدادات"
        text_switch_lang="🔤 English"
        text_check_updates="🔄 التحقق من التحديثات"
        text_about="ℹ️ حول البرنامج"
        text_back="🔙 عودة"
        text_no_updates="✅ لا توجد تحديثات متاحة"
        text_update_available="🆕 تحديث متوفر!"
        text_update_now="❓ تحديث الآن؟"
        text_downloading_update="📥 جاري تحميل التحديث..."
        text_update_success="✅ تم التحديث بنجاح"
        text_update_failed="❌ فشل التحديث"
        text_about_info="ℹ️ GT-IMT v$CURRENT_VERSION\n\n📀 أداة متقدمة لإدارة وضم ملفات ISO\n👨‍💻 تم التطوير بواسطة: SalehGNUTUX\n\n📦 المستودع: https://github.com/SalehGNUTUX/gt-imt\n📜 الرخصة: GPL-2.0"
        text_uninstall_confirm="❓ هل أنت متأكد من إزالة البرنامج؟ (سيتم حذف جميع الملفات) [y/N]: "
        text_uninstall_done="✅ تمت إزالة البرنامج بنجاح"
        text_uninstall_cancelled="❌ تم إلغاء الإزالة"
        text_open_mnt="📍 فتح مجلد الضم"
    else
        text_title="GT-IMT - ISO Mount Tool"
        text_setup="📁 Setup ISO folder"
        text_mount="💿 Mount ISO File"
        text_unmount="⏏️ Unmount ISO File"
        text_show="👁️ Show mounted files"
        text_extract="📦 Extract ISO file"
        text_settings="⚙️ Settings"
        text_uninstall="🗑️ Uninstall"
        text_exit="🚪 Exit"
        text_success="✅ Operation successful"
        text_failed="❌ Operation failed"
        text_choose="🔍 Choose option"
        text_invalid="⚠️ Invalid choice"
        text_no_files="📭 No files mounted"
        text_mounted="📌 Currently mounted files"
        text_select="🔎 Select ISO file"
        text_select_dir="📂 Select destination folder"
        text_overwrite="📝 Overwrite all"
        text_skip="⏭️ Skip existing"
        text_cancel="❌ Cancel operation"
        text_existing="📋 Existing files"
        text_mount_point="📍 Mount point"
        text_language="🌐 Current language: English"
        text_settings_menu="⚙️ Settings Menu"
        text_switch_lang="🔤 العربية"
        text_check_updates="🔄 Check for updates"
        text_about="ℹ️ About"
        text_back="🔙 Back"
        text_no_updates="✅ No updates available"
        text_update_available="🆕 Update available!"
        text_update_now="❓ Update now?"
        text_downloading_update="📥 Downloading update..."
        text_update_success="✅ Update successful"
        text_update_failed="❌ Update failed"
        text_about_info="ℹ️ GT-IMT v$CURRENT_VERSION\n\n📀 Advanced ISO management and mounting tool\n👨‍💻 Developed by: SalehGNUTUX\n\n📦 Repository: https://github.com/SalehGNUTUX/gt-imt\n📜 License: GPL-2.0"
        text_uninstall_confirm="❓ Are you sure you want to uninstall? (all files will be removed) [y/N]: "
        text_uninstall_done="✅ Uninstall completed successfully"
        text_uninstall_cancelled="❌ Uninstall cancelled"
        text_open_mnt="📍 Open Mount Directory"
    fi
}
load_texts
shopt -s nocasematch

# ============================================
# دوال الواجهة الرسومية
# ============================================

# التحقق من وجود بيئة رسومية
check_display() {
    if [ -z "$DISPLAY" ] && [ -z "$WAYLAND_DISPLAY" ]; then
        return 1
    fi
    return 0
}

# دالة موحدة لاختيار الملفات
select_file_gui() {
    local title="$1"
    local filter="$2"
    local initial_dir="$3"
    local selected=""

    if ! check_display; then
        return 1
    fi

    if command -v kdialog &> /dev/null; then
        selected=$(kdialog --title "$title" --getopenfilename "$initial_dir" "$filter" 2>/dev/null)
        if [ -n "$selected" ] && [ -f "$selected" ]; then
            echo "$selected"
            return 0
        fi
    fi

    if command -v zenity &> /dev/null; then
        selected=$(zenity --file-selection --title="$title" --file-filter="$filter" --filename="$initial_dir/" 2>/dev/null)
        if [ -n "$selected" ] && [ -f "$selected" ]; then
            echo "$selected"
            return 0
        fi
    fi

    if command -v Xdialog &> /dev/null; then
        selected=$(Xdialog --title "$title" --fselect "$initial_dir/" 0 0 2>/dev/null)
        if [ -n "$selected" ] && [ -f "$selected" ]; then
            echo "$selected"
            return 0
        fi
    fi

    return 1
}

# دالة موحدة لاختيار المجلدات
select_dir_gui() {
    local title="$1"
    local initial_dir="$2"
    local selected=""

    if ! check_display; then
        return 1
    fi

    if command -v kdialog &> /dev/null; then
        selected=$(kdialog --title "$title" --getexistingdirectory "$initial_dir" 2>/dev/null)
        if [ -n "$selected" ] && [ -d "$selected" ]; then
            echo "$selected"
            return 0
        fi
    fi

    if command -v zenity &> /dev/null; then
        selected=$(zenity --file-selection --directory --title="$title" --filename="$initial_dir/" 2>/dev/null)
        if [ -n "$selected" ] && [ -d "$selected" ]; then
            echo "$selected"
            return 0
        fi
    fi

    if command -v Xdialog &> /dev/null; then
        selected=$(Xdialog --title "$title" --fselect "$initial_dir/" 0 0 2>/dev/null)
        if [ -n "$selected" ] && [ -d "$selected" ]; then
            echo "$selected"
            return 0
        fi
    fi

    return 1
}

# ============================================
# دوال عرض المعلومات
# ============================================

display_logo() {
    echo -e "\033[1;36m"
    cat << "EOF"
  /$$$$$$  /$$$$$$$$    /$$$$$$ /$$      /$$ /$$$$$$$$
 /$$__  $$|__  $$__/   |_  $$_/| $$$    /$$$|__  $$__/
| $$  \__/   | $$        | $$  | $$$$  /$$$$   | $$
| $$ /$$$$   | $$ /$$$$$$| $$  | $$ $$/$$ $$   | $$
| $$|_  $$   | $$|______/| $$  | $$  $$$| $$   | $$
| $$  \ $$   | $$        | $$  | $$\  $ | $$   | $$
|  $$$$$$/   | $$       /$$$$$$| $$ \/  | $$   | $$
 \______/    |__/      |______/|__/     |__/   |__/

EOF
    echo -e "\033[1;33m"
    if [ "$lang" = "ar" ]; then
        echo "GT-IMT - أداة إدارة ملفات ISO"
        echo "إصدار $CURRENT_VERSION"
    else
        echo "GT-IMT - ISO Management Tool"
        echo "Version $CURRENT_VERSION"
    fi
    echo -e "\033[0m"
    sleep 1
}

show_mounted() {
    clear
    display_logo
    echo ""
    echo "=============================="
    echo "|   $text_mounted            |"
    echo "=============================="
    echo ""

    mapfile -t mounted < <(findmnt -n -l -o TARGET | grep "^$mnt_dir/" 2>/dev/null || true)

    if [ ${#mounted[@]} -eq 0 ]; then
        echo "    $text_no_files"
    else
        for ((i=0; i<${#mounted[@]}; i++)); do
            echo "    $((i+1)). ${mounted[$i]}"
        done
    fi

    echo ""
    echo "=============================="
    if [ "$lang" = "ar" ]; then
        echo "اضغط Enter للعودة..."
    else
        echo "Press Enter to continue..."
    fi
    read
}

# ============================================
# دوال العمليات الرئيسية
# ============================================

select_iso_file() {
    local selected=""
    echo "🔍 محاولة فتح مدير الملفات..."
    selected=$(select_file_gui "$text_select" "*.iso *.img *.ISO *.IMG" "$iso_dir")

    if [ -z "$selected" ]; then
        echo ""
        echo "📂 الرجاء إدخال المسار يدوياً:"
        read -e -p "> " selected
        selected="${selected/#\~/$HOME}"
    fi

    if [ -z "$selected" ] || [ ! -f "$selected" ]; then
        echo "❌ الملف غير موجود."
        sleep 2
        return 1
    fi

    iso_dir=$(dirname "$selected")
    echo "$selected" > "$temp_file"
    return 0
}

mount_iso() {
    while true; do
        clear
        display_logo
        echo ""
        echo "=============================="
        echo "|        $text_mount          |"
        echo "=============================="
        echo "| 1. $text_select          |"
        echo "| 2. $text_show            |"
        echo "| 0. $text_back              |"
        echo "=============================="
        echo ""
        read -p "$text_choose [0-2]: " choice

        case $choice in
            1)
                if select_iso_file; then
                    iso_path=$(cat "$temp_file")
                    mount_name=$(basename "$iso_path" | sed 's/\.[^.]*$//')
                    mount_point="$mnt_dir/$mount_name"

                    if mount | grep -q "$mount_point"; then
                        if [ "$lang" = "ar" ]; then
                            zenity --error --text="نقطة الضم موجودة بالفعل: $mount_point" --width=300 2>/dev/null || echo "⚠️ نقطة الضم موجودة بالفعل: $mount_point"
                        else
                            zenity --error --text="Mount point already exists: $mount_point" --width=300 2>/dev/null || echo "⚠️ Mount point already exists: $mount_point"
                        fi
                        continue
                    fi

                    # تنفيذ العمليات في طلب استيثاق واحد
                    if run_as_root sh -c "mkdir -p '$mount_point' && chmod 777 '$mount_point' && mount -o loop '$iso_path' '$mount_point'"; then
                        if [ "$lang" = "ar" ]; then
                            zenity --info --text="تم الضم بنجاح في: $mount_point" --width=300 2>/dev/null || echo "✅ تم الضم بنجاح في: $mount_point"
                        else
                            zenity --info --text="Successfully mounted at: $mount_point" --width=300 2>/dev/null || echo "✅ Successfully mounted at: $mount_point"
                        fi
                    else
                        run_as_root rmdir "$mount_point" 2>/dev/null
                        if [ "$lang" = "ar" ]; then
                            zenity --error --text="$text_failed!" --width=200 2>/dev/null || echo "❌ $text_failed"
                        else
                            zenity --error --text="$text_failed!" --width=200 2>/dev/null || echo "❌ $text_failed"
                        fi
                    fi
                fi
                ;;
            2) show_mounted ;;
            0) return ;;
            *) echo "$text_invalid"; sleep 1 ;;
        esac
    done
}

unmount_iso() {
    while true; do
        clear
        display_logo
        mapfile -t mounted < <(findmnt -n -l -o TARGET | grep "^$mnt_dir/" 2>/dev/null || true)

        echo ""
        echo "=============================="
        echo "|     $text_unmount           |"
        echo "=============================="
        echo "| $text_mounted:               |"
        echo ""

        if [ ${#mounted[@]} -eq 0 ]; then
            echo "        $text_no_files"
        else
            for ((i=0; i<${#mounted[@]}; i++)); do
                echo "        $((i+1)). ${mounted[$i]}"
            done
        fi

        echo ""
        echo "=============================="
        echo "| 1. $text_unmount             |"
        echo "| 0. $text_back                |"
        echo "=============================="
        echo ""
        read -p "$text_choose [0-1]: " sub_choice

        case $sub_choice in
            1)
                if [ ${#mounted[@]} -gt 0 ]; then
                    if [ "$lang" = "ar" ]; then
                        read -p "أدخل رقم الملف: " file_num
                    else
                        read -p "Enter file number: " file_num
                    fi

                    if [[ $file_num -ge 1 && $file_num -le ${#mounted[@]} ]]; then
                        mount_point="${mounted[$((file_num-1))]}"
                        # تنفيذ الفك والحذف في طلب واحد
                        if run_as_root sh -c "umount '$mount_point' && rmdir '$mount_point'"; then
                            echo "$text_success"
                        else
                            echo "$text_failed"
                        fi
                        sleep 1
                    else
                        echo "$text_invalid"
                        sleep 1
                    fi
                else
                    echo "$text_no_files"
                    sleep 1
                fi
                ;;
            0) return ;;
            *) echo "$text_invalid"; sleep 1 ;;
        esac
    done
}

extract_iso() {
    if ! command -v 7z &> /dev/null; then
        echo "⚠️ 7z غير مثبت. يرجى تثبيته أولاً."
        read -p "Press Enter..."
        return
    fi

    clear
    display_logo
    echo ""
    echo "=============================="
    echo "|      $text_extract          |"
    echo "=============================="
    echo ""

    if select_iso_file; then
        iso_path=$(cat "$temp_file")
        echo ""
        echo "=============================="
        echo "| 1. $text_extract هنا       |"
        echo "| 2. $text_extract في مجلد آخر |"
        echo "| 0. $text_back              |"
        echo "=============================="
        echo ""
        read -p "$text_choose [0-2]: " extract_choice

        case $extract_choice in
            1) output_dir="$(dirname "$iso_path")/$(basename "$iso_path" .iso)_extracted" ;;
            2)
                echo "🔍 محاولة فتح مدير الملفات..."
                output_dir=$(select_dir_gui "$text_select_dir" "$HOME")
                if [ -z "$output_dir" ]; then
                    echo "📂 الرجاء إدخال المسار يدوياً:"
                    read -e -p "> " output_dir
                    output_dir="${output_dir/#\~/$HOME}"
                fi
                [ -z "$output_dir" ] && return
                ;;
            0) return ;;
            *) echo "$text_invalid"; sleep 1; return ;;
        esac

        local extract_option=""
        if [ -d "$output_dir" ] && [ "$(ls -A "$output_dir" 2>/dev/null)" ]; then
            local choice=""
            if command -v zenity &>/dev/null; then
                if [ "$lang" = "ar" ]; then
                    choice=$(zenity --list --title="$text_existing" --text="المجلد الهدف يحتوي على ملفات موجودة مسبقاً:" --column="خيار" "$text_overwrite" "$text_skip" "$text_cancel" --width=400 --height=200 2>/dev/null)
                else
                    choice=$(zenity --list --title="$text_existing" --text="Target folder contains existing files:" --column="Option" "$text_overwrite" "$text_skip" "$text_cancel" --width=400 --height=200 2>/dev/null)
                fi
            fi

            if [ -z "$choice" ]; then
                echo ""
                echo "$text_existing"
                echo "1) $text_overwrite"
                echo "2) $text_skip"
                echo "3) $text_cancel"
                read -p "$text_choose [1-3]: " manual_choice
                case $manual_choice in
                    1) choice="$text_overwrite" ;;
                    2) choice="$text_skip" ;;
                    *) return ;;
                esac
            fi

            case $choice in
                "$text_overwrite") rm -rf "${output_dir:?}/"* ;;
                "$text_skip") extract_option="-aou" ;;
                *) return ;;
            esac
        else
            mkdir -p "$output_dir"
        fi

        echo "جاري فك الضغط..."
        if 7z x "$iso_path" -o"$output_dir" $extract_option >/dev/null 2>&1; then
            echo "✅ تم فك الضغط بنجاح إلى: $output_dir"
        else
            echo "❌ فشل فك الضغط."
        fi
        sleep 2
    fi
}

setup_iso_dir() {
    while true; do
        clear
        display_logo
        echo ""
        echo "=============================="
        echo "|      $text_setup            |"
        echo "=============================="
        echo "| 1. إنشاء مجلد ISO جديد   |"
        echo "| 2. فتح مجلد ISO الخاص بك  |"
        echo "| 3. $text_open_mnt         |"
        echo "| 0. $text_back              |"
        echo "=============================="
        echo ""
        read -p "$text_choose [0-3]: " sub_choice

        case $sub_choice in
            1)
                mkdir -p "$iso_dir"
                echo "✅ تم إنشاء المجلد: $iso_dir"
                sleep 1
                ;;
            2) open_file_manager "$iso_dir" ;;
            3) open_file_manager "$mnt_dir" ;;
            0) return ;;
            *) echo "$text_invalid"; sleep 1 ;;
        esac
    done
}

check_for_updates() {
    echo "جاري التحقق من التحديثات..."
    local remote_version=""
    if command -v curl &>/dev/null; then
        remote_version=$(curl -s --connect-timeout 5 "https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main/version.txt" 2>/dev/null)
    elif command -v wget &>/dev/null; then
        remote_version=$(wget -qO- --timeout=5 "https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main/version.txt" 2>/dev/null)
    fi
    remote_version=$(echo "$remote_version" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
    date +%s > "$update_check_file"
    if [ -n "$remote_version" ] && [ "$remote_version" != "$CURRENT_VERSION" ]; then
        return 0
    else
        return 1
    fi
}

update_tool() {
    echo "$text_downloading_update"
    local temp_dir="/tmp/gt-imt-update"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    cd "$temp_dir" || return 1
    local files=("imt.sh" "install.sh" "README.md" "version.txt")
    local base_url="https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main"
    for file in "${files[@]}"; do
        if command -v curl &>/dev/null; then
            curl -s -f -L -o "$file" "$base_url/$file" 2>/dev/null
        else
            wget -q -O "$file" "$base_url/$file" 2>/dev/null
        fi
    done
    if [ -f "imt.sh" ]; then
        run_as_root cp "imt.sh" "/usr/local/bin/imt"
        run_as_root chmod +x "/usr/local/bin/imt"
        echo "$text_update_success"
        rm -rf "$temp_dir"
        exec imt
    else
        echo "$text_update_failed"
        rm -rf "$temp_dir"
    fi
}

uninstall_tool() {
    echo ""
    read -p "$text_uninstall_confirm" uninstall_confirm
    if [ "$uninstall_confirm" = "y" ] || [ "$uninstall_confirm" = "Y" ]; then
        echo "🗑️  إزالة الملفات..."
        run_as_root rm -f /usr/local/bin/imt
        run_as_root rm -f /usr/share/applications/gt-imt.desktop
        run_as_root rm -f /usr/share/applications/imt.desktop
        run_as_root rm -f /usr/share/icons/hicolor/*/apps/gt-imt.png
        run_as_root rm -f /usr/share/icons/hicolor/*/apps/imt.png
        rm -rf "$HOME/.config/gt-imt"
        echo "$text_uninstall_done"
        exit 0
    else
        echo "$text_uninstall_cancelled"
        sleep 1
    fi
}

settings_menu() {
    while true; do
        clear
        display_logo
        echo ""
        echo "=============================="
        echo "|     $text_settings_menu     |"
        echo "=============================="
        echo "| 1. $text_switch_lang       |"
        echo "| 2. $text_check_updates     |"
        echo "| 3. $text_about             |"
        echo "| 4. $text_uninstall         |"
        echo "| 0. $text_back              |"
        echo "=============================="
        echo ""
        read -p "$text_choose [0-4]: " settings_choice

        case $settings_choice in
            1)
                if [ "$lang" = "ar" ]; then lang="en"; else lang="ar"; fi
                echo "$lang" > "$lang_file"
                load_texts
                echo "✅ تم التبديل"
                sleep 1
                ;;
            2)
                clear
                display_logo
                if check_for_updates; then
                    echo ""
                    echo "=============================="
                    echo "|   $text_update_available    |"
                    echo "=============================="
                    echo ""
                    read -p "$text_update_now (y/n): " update_choice
                    if [ "$update_choice" = "y" ] || [ "$update_choice" = "Y" ]; then
                        update_tool
                    fi
                else
                    echo ""
                    echo "=============================="
                    echo "|    $text_no_updates        |"
                    echo "=============================="
                    echo ""
                    sleep 2
                fi
                ;;
            3)
                clear
                display_logo
                echo ""
                echo "=============================="
                echo "|        $text_about          |"
                echo "=============================="
                echo ""
                echo -e "$text_about_info"
                echo ""
                echo "=============================="
                echo ""
                read -p "اضغط Enter..."
                ;;
            4) uninstall_tool ;;
            0) return ;;
            *) echo "$text_invalid"; sleep 1 ;;
        esac
    done
}

main_menu() {
    while true; do
        clear
        display_logo
        echo ""
        echo "=============================="
        echo "|     $text_title            |"
        echo "=============================="
        echo "| مسار ISO: $iso_dir"
        echo "| $text_mount_point: $mnt_dir"
        echo "| $text_language"
        echo "=============================="
        echo "| 1. $text_setup            |"
        echo "| 2. $text_mount            |"
        echo "| 3. $text_unmount          |"
        echo "| 4. $text_show             |"
        echo "| 5. $text_extract          |"
        echo "| 6. $text_settings         |"
        echo "| 0. $text_exit              |"
        echo "=============================="
        echo ""
        read -p "$text_choose [0-6]: " choice

        case $choice in
            1) setup_iso_dir ;;
            2) mount_iso ;;
            3) unmount_iso ;;
            4) show_mounted ;;
            5) extract_iso ;;
            6) settings_menu ;;
            0)
                rm -f "$temp_file"
                echo "$text_exit"
                exit 0
                ;;
            *) echo "$text_invalid"; sleep 1 ;;
        esac
    done
}

main_menu
