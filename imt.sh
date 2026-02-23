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
        text_setup="إعداد مجلد ISO"
        text_mount="ضم ملف ISO"
        text_unmount="إلغاء ضم ملف ISO"
        text_show="عرض الملفات المضمومة"
        text_extract="فك ضغط ملف ISO"
        text_settings="الإعدادات"
        text_exit="خروج"
        text_success="تمت العملية بنجاح"
        text_failed="فشلت العملية"
        text_choose="اختر خياراً"
        text_invalid="اختيار غير صحيح"
        text_no_files="لا توجد ملفات مضمومة"
        text_mounted="الملفات المضمومة حالياً"
        text_select="اختر ملف ISO"
        text_select_dir="اختر مجلد الوجهة"
        text_overwrite="استبدال الكل"
        text_skip="تخطي الملفات الموجودة"
        text_cancel="إلغاء العملية"
        text_existing="الملفات الموجودة مسبقاً"
        text_mount_point="نقطة الضم"
        text_language="اللغة الحالية: العربية"
        text_settings_menu="قائمة الإعدادات"
        text_switch_lang="تبديل اللغة إلى الإنجليزية"
        text_check_updates="التحقق من التحديثات"
        text_about="حول البرنامج"
        text_back="عودة"
        text_no_updates="لا توجد تحديثات متاحة"
        text_update_available="تحديث متوفر!"
        text_update_now="تحديث الآن؟"
        text_downloading_update="جاري تحميل التحديث..."
        text_update_success="تم التحديث بنجاح"
        text_update_failed="فشل التحديث"
        text_about_info="GT-IMT v$CURRENT_VERSION\n\nأداة متقدمة لإدارة وضم ملفات ISO\nتم التطوير بواسطة: SalehGNUTUX\n\nالمستودع: https://github.com/SalehGNUTUX/gt-imt\nالرخصة: GPL-2.0"
    else
        # English texts
        text_title="GT-IMT - ISO Mount Tool"
        text_setup="Setup ISO folder"
        text_mount="Mount ISO File"
        text_unmount="Unmount ISO File"
        text_show="Show mounted files"
        text_extract="Extract ISO file"
        text_settings="Settings"
        text_exit="Exit"
        text_success="Operation successful"
        text_failed="Operation failed"
        text_choose="Choose option"
        text_invalid="Invalid choice"
        text_no_files="No files mounted"
        text_mounted="Currently mounted files"
        text_select="Select ISO file"
        text_select_dir="Select destination folder"
        text_overwrite="Overwrite all"
        text_skip="Skip existing"
        text_cancel="Cancel operation"
        text_existing="Existing files"
        text_mount_point="Mount point"
        text_language="Current language: English"
        text_settings_menu="Settings Menu"
        text_switch_lang="Switch to Arabic"
        text_check_updates="Check for updates"
        text_about="About"
        text_back="Back"
        text_no_updates="No updates available"
        text_update_available="Update available!"
        text_update_now="Update now?"
        text_downloading_update="Downloading update..."
        text_update_success="Update successful"
        text_update_failed="Update failed"
        text_about_info="GT-IMT v$CURRENT_VERSION\n\nAdvanced ISO management and mounting tool\nDeveloped by: SalehGNUTUX\n\nRepository: https://github.com/SalehGNUTUX/gt-imt\nLicense: GPL-2.0"
    fi
}

load_texts

# Enable case-insensitive matching
shopt -s nocasematch

# Function to display logo
display_logo() {
  echo -e "\033[1;36m"
  cat << "EOF"

   ______ ___________   _____ _____ 
  / __/ _ |_  __/ __/  / __/ |__/ |/
 / _// __ |/ / / _/   / _/  | | |   
/_/ /_/ |_/_/ /_/     /___/ |_| |_/  
                                     
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

# Function to check dependencies
check_dependencies() {
    missing=()

    if ! command -v zenity &> /dev/null; then
        missing+=("zenity")
    fi

    if ! command -v 7z &> /dev/null; then
        missing+=("p7zip")
    fi

    if ! command -v mount &> /dev/null; then
        missing+=("mount")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        if [ "$lang" = "ar" ]; then
            zenity --error --text="الإعتماديات الناقصة:\n\n${missing[*]}\n\nالرجاء تثبيتها قبل المتابعة." --width=400
        else
            zenity --error --text="Missing dependencies:\n\n${missing[*]}\n\nPlease install them before proceeding." --width=400
        fi
        return 1
    fi
    return 0
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
            echo "| 1. إلغاء الضم             |"
            echo "| 0. رجوع                   |"
        else
            echo "| 1. Unmount                |"
            echo "| 0. Back                   |"
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
            echo "| 0. رجوع                   |"
        else
            echo "| 1. $text_select          |"
            echo "| 2. $text_show            |"
            echo "| 0. Back                   |"
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
        if [ "$lang" = "ar" ]; then
            zenity --error --text="الأداة 7z غير مثبتة!\n\nالرجاء تثبيتها بأحد الأمرين:\n\nsudo apt install p7zip-full   # لأوبونتو/ديبيان\nsudo yum install p7zip        # لـRHEL/CentOS" --width=500
        else
            zenity --error --text="7z tool not installed!\n\nPlease install with:\n\nsudo apt install p7zip-full   # Ubuntu/Debian\nsudo yum install p7zip        # RHEL/CentOS" --width=500
        fi
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
            echo "| 1. فك الضغط هنا           |"
            echo "| 2. فك الضغط في مجلد آخر   |"
            echo "| 0. رجوع                   |"
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
            echo "| 1. إنشاء مجلد ISO جديد   |"
            echo "| 2. فتح مدير الملفات       |"
            echo "| 0. رجوع                   |"
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
    
    local files=("imt.sh" "install.sh" "README.md" "imt-icon.png" "version.txt")
    local base_url="https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main"
    
    for file in "${files[@]}"; do
        if command -v curl &> /dev/null; then
            curl -s -f -L -o "$file" "$base_url/$file" 2>/dev/null
        elif command -v wget &> /dev/null; then
            wget -q -O "$file" "$base_url/$file" 2>/dev/null
        fi
    done
    
    if [ -f "imt.sh" ]; then
        if [ -f "/usr/local/bin/imt" ]; then
            sudo cp "/usr/local/bin/imt" "/usr/local/bin/imt.backup" 2>/dev/null
        fi
        sudo cp "imt.sh" "/usr/local/bin/imt"
        sudo chmod +x "/usr/local/bin/imt"
        
        # تحديث الأيقونة إذا وجدت
        if [ -f "imt-icon.png" ]; then
            sudo cp "imt-icon.png" "/usr/share/icons/hicolor/256x256/apps/imt.png" 2>/dev/null
        fi
        
        echo "$remote_version" > "$version_file"
        
        rm -rf "$temp_dir"
        return 0
    else
        rm -rf "$temp_dir"
        return 1
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
        echo "| 0. $text_back              |"
        echo "=============================="
        echo ""
        read -p "$text_choose [0-3]: " settings_choice

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
                    echo "✓ تم التبديل إلى العربية"
                else
                    echo "✓ Switched to English"
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
                    if [ "$lang" = "ar" ]; then
                        read -p "$text_update_now (y/n): " update_choice
                    else
                        read -p "$text_update_now (y/n): " update_choice
                    fi
                    
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
    if ! check_dependencies; then
        if [ "$lang" = "ar" ]; then
            echo "الاعتماديات الناقصة تمنع تشغيل البرنامج."
        else
            echo "Missing dependencies prevent the tool from running."
        fi
        exit 1
    fi

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
