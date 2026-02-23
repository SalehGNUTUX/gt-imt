#!/bin/bash

# =============================================
# GT-IMT - ISO Mount Tool by SalehGNUTUX
# Version: 2.0.0
# Supports Arabic & English
# =============================================

if [ "$EUID" -ne 0 ]; then
    if command -v pkexec &> /dev/null; then
        exec pkexec "$0" "$@"
    else
        echo "Please run as root"
        exit 1
    fi
fi

HERE="$(dirname "$(readlink -f "${0}")")"

# Detect default terminal
if [ -n "$(command -v x-terminal-emulator)" ]; then
    TERMINAL="x-terminal-emulator"
elif [ -n "$(command -v gnome-terminal)" ]; then
    TERMINAL="gnome-terminal"
elif [ -n "$(command -v konsole)" ]; then
    TERMINAL="konsole"
elif [ -n "$(command -v xterm)" ]; then
    TERMINAL="xterm"
else
    echo "No terminal emulator found!"
    exit 1
fi

# Run the tool in detected terminal
if [ -f "$HERE/usr/bin/imt" ]; then
    "$TERMINAL" -e "$HERE/usr/bin/imt"
else
    "$TERMINAL" -e "$0"
fi

# Initial settings
iso_dir="$HOME/iso"
mnt_dir="/mnt/iso_mounts"
temp_file="/tmp/iso_selection.tmp"
lang_file="$HOME/.config/gt-imt/language"
version_file="$HOME/.config/gt-imt/version"
update_check_file="$HOME/.config/gt-imt/last_update_check"

# إنشاء مجلد الضم الرئيسي إذا لم يكن موجوداً
sudo mkdir -p "$mnt_dir"
sudo chmod 777 "$mnt_dir"

# الإصدار الحالي
CURRENT_VERSION="2.0.0"

# إنشاء مجلد الإعدادات
mkdir -p "$HOME/.config/gt-imt"

# Language settings (auto/ar/en)
lang="auto"

# Load saved language if exists
if [ -f "$lang_file" ]; then
    lang=$(cat "$lang_file")
fi

# Auto-detect system language if set to auto
if [ "$lang" = "auto" ]; then
    system_lang=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)
    if [ "$system_lang" = "ar" ]; then
        lang="ar"
    else
        lang="en"
    fi
fi

# Load language texts
load_texts() {
    if [ "$lang" = "ar" ]; then
        # Arabic texts
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
        text_missing_zenity="⚠️ الأمر zenity غير مثبت! لا يمكن فتح مدير الملفات الرسومي.\n\nللتثبيت:\n   • أوبونتو/ديبيان: sudo apt install zenity\n   • فيدورا: sudo dnf install zenity\n   • آرتش: sudo pacman -S zenity\n   • أوبن سوزي: sudo zypper install zenity"
        text_missing_7z="⚠️ الأمر 7z غير مثبت! لا يمكن فك ضغط الملفات.\n\nللتثبيت:\n   • أوبونتو/ديبيان: sudo apt install p7zip-full\n   • فيدورا: sudo dnf install p7zip\n   • آرتش: sudo pacman -S p7zip\n   • أوبن سوزي: sudo zypper install p7zip"
    else
        # English texts
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
        text_missing_zenity="⚠️ zenity is not installed! Cannot open graphical file dialog.\n\nTo install:\n   • Ubuntu/Debian: sudo apt install zenity\n   • Fedora: sudo dnf install zenity\n   • Arch: sudo pacman -S zenity\n   • OpenSUSE: sudo zypper install zenity"
        text_missing_7z="⚠️ 7z is not installed! Cannot extract files.\n\nTo install:\n   • Ubuntu/Debian: sudo apt install p7zip-full\n   • Fedora: sudo dnf install p7zip\n   • Arch: sudo pacman -S p7zip\n   • OpenSUSE: sudo zypper install p7zip"
    fi
}

load_texts

# Enable case-insensitive matching
shopt -s nocasematch

# Function to display logo
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

# Function to check dependencies and show helpful message
check_dependencies_runtime() {
    local missing=()
    if ! command -v zenity &> /dev/null; then
        missing+=("zenity")
        echo -e "$text_missing_zenity"
    fi
    if ! command -v 7z &> /dev/null; then
        missing+=("p7zip")
        echo -e "$text_missing_7z"
    fi
    if ! command -v mount &> /dev/null; then
        missing+=("mount")
        if [ "$lang" = "ar" ]; then
            echo "⚠️ الأمر mount غير موجود! هذا أمر أساسي في النظام."
        else
            echo "⚠️ mount command not found! This is a core system utility."
        fi
    fi
    if [ ${#missing[@]} -gt 0 ]; then
        if [ "$lang" = "ar" ]; then
            echo ""
            echo "الرجاء تثبيت الإعتماديات الناقصة ثم أعد تشغيل البرنامج."
            read -p "اضغط Enter للخروج..."
        else
            echo ""
            echo "Please install missing dependencies and restart the program."
            read -p "Press Enter to exit..."
        fi
        exit 1
    fi
}

# Function to show mounted files
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

# Function to unmount ISO
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
        if [ "$lang" = "ar" ]; then
            echo "| 1. $text_unmount             |"
            echo "| 0. $text_back                   |"
        else
            echo "| 1. $text_unmount                |"
            echo "| 0. $text_back                   |"
        fi
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
                        if sudo umount "$mount_point"; then
                            sudo rmdir "$mount_point" 2>/dev/null || true
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
            0)
                return
                ;;
            *)
                echo "$text_invalid"
                sleep 1
                ;;
        esac
    done
}

# Function to select ISO file
select_iso_file() {
    if [ "$lang" = "ar" ]; then
        selected=$(zenity --file-selection --title="$text_select" --file-filter="ملفات القرص | *.iso *.img *.ISO *.IMG" --filename="$iso_dir/" 2>/dev/null)
    else
        selected=$(zenity --file-selection --title="$text_select" --file-filter="Disk files | *.iso *.img *.ISO *.IMG" --filename="$iso_dir/" 2>/dev/null)
    fi

    [ -z "$selected" ] && return 1

    iso_dir=$(dirname "$selected")
    echo "$selected" > "$temp_file"
}

# Main mount function
mount_iso() {
    while true; do
        clear
        display_logo

        echo ""
        echo "=============================="
        echo "|        $text_mount          |"
        echo "=============================="
        if [ "$lang" = "ar" ]; then
            echo "| 1. $text_select          |"
            echo "| 2. $text_show            |"
            echo "| 0. $text_back                   |"
        else
            echo "| 1. $text_select          |"
            echo "| 2. $text_show            |"
            echo "| 0. $text_back                   |"
        fi
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
                            zenity --error --text="نقطة الضم موجودة بالفعل: $mount_point" --width=300
                        else
                            zenity --error --text="Mount point already exists: $mount_point" --width=300
                        fi
                        continue
                    fi

                    if [ ! -d "$mount_point" ]; then
                        sudo mkdir -p "$mount_point"
                        sudo chmod 777 "$mount_point"
                    fi

                    if sudo mount -o loop "$iso_path" "$mount_point"; then
                        if [ "$lang" = "ar" ]; then
                            zenity --info --text="تم الضم بنجاح في: $mount_point" --width=300
                        else
                            zenity --info --text="Successfully mounted at: $mount_point" --width=300
                        fi
                    else
                        sudo rmdir "$mount_point" 2>/dev/null
                        zenity --error --text="$text_failed!" --width=200
                    fi
                fi
                ;;
            2)
                show_mounted
                ;;
            0)
                return
                ;;
            *)
                echo "$text_invalid"
                sleep 1
                ;;
        esac
    done
}

# ISO extraction function
extract_iso() {
    if ! command -v 7z &> /dev/null; then
        echo -e "$text_missing_7z"
        read -p "Press Enter to continue..."
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
        if [ "$lang" = "ar" ]; then
            echo "| 1. $text_extract هنا           |"
            echo "| 2. $text_extract في مجلد آخر   |"
            echo "| 0. $text_back                   |"
        else
            echo "| 1. Extract here           |"
            echo "| 2. Extract to folder      |"
            echo "| 0. Back                   |"
        fi
        echo "=============================="
        echo ""
        read -p "$text_choose [0-2]: " extract_choice

        case $extract_choice in
            1)
                output_dir="$(dirname "$iso_path")/$(basename "$iso_path" .iso)_extracted"
                ;;
            2)
                if [ "$lang" = "ar" ]; then
                    output_dir=$(zenity --file-selection --directory --title="$text_select_dir" 2>/dev/null)
                else
                    output_dir=$(zenity --file-selection --directory --title="$text_select_dir" 2>/dev/null)
                fi
                [ -z "$output_dir" ] && return
                ;;
            0)
                return
                ;;
            *)
                echo "$text_invalid"
                sleep 1
                return
                ;;
        esac

        local extract_option=""
        if [ -d "$output_dir" ] && [ "$(ls -A "$output_dir" 2>/dev/null)" ]; then
            if [ "$lang" = "ar" ]; then
                choice=$(zenity --list --title="$text_existing" --text="المجلد الهدف يحتوي على ملفات موجودة مسبقاً:" --column="خيار" "$text_overwrite" "$text_skip" "$text_cancel" --width=400 --height=200)
            else
                choice=$(zenity --list --title="$text_existing" --text="Target folder contains existing files:" --column="Option" "$text_overwrite" "$text_skip" "$text_cancel" --width=400 --height=200)
            fi

            case $choice in
                "$text_overwrite")
                    rm -rf "${output_dir:?}/"*
                    ;;
                "$text_skip")
                    extract_option="-aou"
                    ;;
                "$text_cancel"|*)
                    return
                    ;;
            esac
        else
            mkdir -p "$output_dir"
        fi

        if [ "$lang" = "ar" ]; then
            echo "جاري فك الضغط، يرجى الانتظار..."
        else
            echo "Extracting, please wait..."
        fi

        if 7z x "$iso_path" -o"$output_dir" $extract_option >/dev/null 2>&1; then
            if [ "$lang" = "ar" ]; then
                zenity --info --text="تم فك الضغط بنجاح في: $output_dir" --width=400
            else
                zenity --info --text="Successfully extracted to: $output_dir" --width=400
            fi
        else
            zenity --error --text="$text_failed!" --width=200
        fi
    fi
    sleep 1
}

# ISO directory setup
setup_iso_dir() {
    while true; do
        clear
        display_logo

        echo ""
        echo "=============================="
        echo "|      $text_setup            |"
        echo "=============================="
        if [ "$lang" = "ar" ]; then
            echo "| 1. $text_setup جديد   |"
            echo "| 2. فتح مدير الملفات       |"
            echo "| 0. $text_back                   |"
        else
            echo "| 1. Create new ISO folder  |"
            echo "| 2. Open file manager      |"
            echo "| 0. Back                   |"
        fi
        echo "=============================="
        echo ""
        read -p "$text_choose [0-2]: " sub_choice

        case $sub_choice in
            1)
                mkdir -p "$iso_dir"
                if [ "$lang" = "ar" ]; then
                    zenity --info --text="تم إنشاء المجلد: $iso_dir" --width=200
                else
                    zenity --info --text="Created folder: $iso_dir" --width=200
                fi
                ;;
            2)
                xdg-open "$iso_dir" &
                ;;
            0)
                return
                ;;
            *)
                echo "$text_invalid"
                sleep 1
                ;;
        esac
    done
}

# Function to check for updates
check_for_updates() {
    if [ "$lang" = "ar" ]; then
        echo "جاري التحقق من التحديثات..."
    else
        echo "Checking for updates..."
    fi
    
    local remote_version=""
    if command -v curl &> /dev/null; then
        remote_version=$(curl -s --connect-timeout 5 "https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main/version.txt" 2>/dev/null)
    elif command -v wget &> /dev/null; then
        remote_version=$(wget -qO- --timeout=5 "https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main/version.txt" 2>/dev/null)
    fi
    
    remote_version=$(echo "$remote_version" | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1)
    
    date +%s > "$update_check_file"
    
    if [ -n "$remote_version" ] && [ "$remote_version" != "$CURRENT_VERSION" ]; then
        return 0 # تحديث متوفر
    else
        return 1 # لا يوجد تحديث
    fi
}

# Function to update the tool
update_tool() {
    if [ "$lang" = "ar" ]; then
        echo "$text_downloading_update"
    else
        echo "$text_downloading_update"
    fi
    
    local temp_dir="/tmp/gt-imt-update"
    rm -rf "$temp_dir"
    mkdir -p "$temp_dir"
    
    cd "$temp_dir" || return 1
    
    local files=("imt.sh" "install.sh" "README.md" "version.txt")
    local base_url="https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main"
    
    for file in "${files[@]}"; do
        if command -v curl &> /dev/null; then
            curl -s -f -L -o "$file" "$base_url/$file" 2>/dev/null
        elif command -v wget &> /dev/null; then
            wget -q -O "$file" "$base_url/$file" 2>/dev/null
        fi
    done
    
    # تنزيل الأيقونات أيضاً (اختصاراً نكتفي بالأيقونة الرئيسية)
    mkdir -p "icons"
    local icon_sizes=("16x16" "24x24" "32x32" "48x48" "64x64" "128x128" "256x256" "512x512")
    for size in "${icon_sizes[@]}"; do
        local icon_url="$base_url/icons/icons/$size/imt-icon.png"
        local icon_file="icons/$size.png"
        if command -v curl &> /dev/null; then
            curl -s -f -L -o "$icon_file" "$icon_url" 2>/dev/null
        else
            wget -q -O "$icon_file" "$icon_url" 2>/dev/null
        fi
    done
    
    if [ -f "imt.sh" ]; then
        if [ -f "/usr/local/bin/imt" ]; then
            sudo cp "/usr/local/bin/imt" "/usr/local/bin/imt.backup" 2>/dev/null
        fi
        sudo cp "imt.sh" "/usr/local/bin/imt"
        sudo chmod +x "/usr/local/bin/imt"
        
        # تحديث الأيقونات
        for size in "${icon_sizes[@]}"; do
            if [ -f "icons/$size.png" ]; then
                sudo mkdir -p "/usr/share/icons/hicolor/$size/apps"
                sudo cp "icons/$size.png" "/usr/share/icons/hicolor/$size/apps/gt-imt.png"
                sudo cp "icons/$size.png" "/usr/share/icons/hicolor/$size/apps/imt.png"
            fi
        done
        
        if command -v gtk-update-icon-cache &> /dev/null; then
            sudo gtk-update-icon-cache -f /usr/share/icons/hicolor/ &>/dev/null || true
        fi
        
        # تحديث الإصدار
        echo "$remote_version" > "$version_file"
        
        rm -rf "$temp_dir"
        return 0
    else
        rm -rf "$temp_dir"
        return 1
    fi
}

# Function to uninstall the tool
uninstall_tool() {
    echo ""
    read -p "$text_uninstall_confirm" uninstall_confirm
    if [ "$uninstall_confirm" = "y" ] || [ "$uninstall_confirm" = "Y" ]; then
        echo ""
        echo "🗑️  إزالة الملفات..."
        
        # إزالة الملف التنفيذي
        sudo rm -f /usr/local/bin/imt 2>/dev/null
        
        # إزالة مداخل القائمة
        sudo rm -f /usr/share/applications/gt-imt.desktop 2>/dev/null
        sudo rm -f /usr/share/applications/imt.desktop 2>/dev/null
        
        # إزالة الأيقونات
        sudo rm -f /usr/share/icons/hicolor/*/apps/gt-imt.png 2>/dev/null
        sudo rm -f /usr/share/icons/hicolor/*/apps/imt.png 2>/dev/null
        
        # إزالة مجلد الإعدادات
        rm -rf "$HOME/.config/gt-imt" 2>/dev/null
        
        # تحديث قاعدة بيانات الأيقونات
        if command -v gtk-update-icon-cache &> /dev/null; then
            sudo gtk-update-icon-cache -f /usr/share/icons/hicolor/ &>/dev/null || true
        fi
        
        echo "$text_uninstall_done"
        echo ""
        exit 0
    else
        echo "$text_uninstall_cancelled"
        sleep 1
    fi
}

# Settings menu
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
                # تبديل اللغة
                if [ "$lang" = "ar" ]; then
                    lang="en"
                else
                    lang="ar"
                fi
                mkdir -p "$HOME/.config/gt-imt"
                echo "$lang" > "$lang_file"
                load_texts
                if [ "$lang" = "ar" ]; then
                    echo "✅ تم التبديل إلى العربية"
                else
                    echo "✅ Switched to English"
                fi
                sleep 1
                ;;
            2)
                # التحقق من التحديثات
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
                        if update_tool; then
                            echo "$text_update_success"
                            sleep 2
                            exec imt
                        else
                            echo "$text_update_failed"
                            sleep 2
                        fi
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
                # حول البرنامج
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
                if [ "$lang" = "ar" ]; then
                    read -p "اضغط Enter للعودة... " dummy
                else
                    read -p "Press Enter to continue... " dummy
                fi
                ;;
            4)
                # إزالة البرنامج
                uninstall_tool
                ;;
            0)
                return
                ;;
            *)
                echo "$text_invalid"
                sleep 1
                ;;
        esac
    done
}

# Main menu
main_menu() {
    # تحقق من التبعيات أولاً
    check_dependencies_runtime

    while true; do
        clear
        display_logo

        echo ""
        echo "=============================="
        echo "|     $text_title            |"
        echo "=============================="
        if [ "$lang" = "ar" ]; then
            echo "| مسار ISO: $iso_dir"
            echo "| $text_mount_point: $mnt_dir"
        else
            echo "| ISO path: $iso_dir"
            echo "| $text_mount_point: $mnt_dir"
        fi
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
                rm -f "$temp_file" 2>/dev/null
                echo "$text_exit"
                exit 0
                ;;
            *)
                echo "$text_invalid"
                sleep 1
                ;;
        esac
    done
}

# Start the program
main_menu
