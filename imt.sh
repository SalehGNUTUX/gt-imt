#!/bin/bash

# =============================================
# ISO MOUNT TOOL (IMT) - by SalehGNUTUX
# Supports Arabic & English with auto-detection
# =============================================

#!/bin/bash


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
"$TERMINAL" -e "$HERE/usr/bin/imt"


# Initial settings
iso_dir="$HOME/iso"
mnt_dir="/mnt/iso_mounts"  # مسار ثابت لجميع نقاط الضم
temp_file="/tmp/iso_selection.tmp"

# إنشاء مجلد الضم الرئيسي إذا لم يكن موجوداً
sudo mkdir -p "$mnt_dir"
sudo chmod 777 "$mnt_dir"  # إعطاء صلاحيات كافية (يمكن تعديلها حسب الحاجة)

# Language settings (auto/ar/en)
lang="auto"

# Auto-detect system language
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
        text_title="أداة ضم ملفات ISO"
        text_setup="إعداد مجلد ISO"
        text_mount="ضم ملف ISO"
        text_unmount="إلغاء ضم ملف ISO"
        text_show="عرض الملفات المضمومة"
        text_extract="فك ضغط ملف ISO"
        text_switch="التبديل إلى الإنجليزية"
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
    else
        # English texts
        text_title="ISO Mount Tool"
        text_setup="Setup ISO folder"
        text_mount="Mount ISO File"
        text_unmount="Unmount ISO File"
        text_show="Show mounted files"
        text_extract="Extract ISO file"
        text_switch="Switch to Arabic"
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
    fi
}

load_texts

# Enable case-insensitive matching
shopt -s nocasematch

# Function to display logo
display_logo() {
  echo -e "\033[1;36m"
  cat << "EOF"

  ___
 |_ _|
  | |
  | |
 |___|       __  __
            |  \/  |
            | |\/| |
            | |  | |
            |_|  |_|        _____
                           |_   _|
                             | |
                             | |
                             |_|


EOF
  echo -e "\033[1;33m"
  if [ "$lang" = "ar" ]; then
    echo "أداة إدارة ملفات ISO"
    echo "إصدار GNUTUX"
  else
    echo "ISO Management Tool"
    echo "by GNUTUX"
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

    if [ "$lang" = "ar" ]; then
        echo "
        ==============================
        |   $text_mounted            |
        ==============================
        "
    else
        echo "
        ==============================
        |   $text_mounted            |
        ==============================
        "
    fi

    # نعرض فقط الملفات المضمومة في المسار المخصص
    mapfile -t mounted < <(findmnt -n -l -o TARGET | grep "^$mnt_dir/")

    if [ ${#mounted[@]} -eq 0 ]; then
        echo "    $text_no_files"
    else
        for ((i=0; i<${#mounted[@]}; i++)); do
            echo "    $((i+1)). ${mounted[$i]}"
        done
    fi

    if [ "$lang" = "ar" ]; then
        echo "
        ==============================
        اضغط Enter للعودة...
        "
    else
        echo "
        ==============================
        Press Enter to continue...
        "
    fi
    read
}

# Function to unmount ISO
unmount_iso() {
    while true; do
        clear
        display_logo
        # نبحث فقط عن نقاط الضم في المسار المخصص
        mapfile -t mounted < <(findmnt -n -l -o TARGET | grep "^$mnt_dir/")

        if [ "$lang" = "ar" ]; then
            echo "
            ==============================
            |     $text_unmount        |
            ==============================
            | $text_mounted:            |
            "
        else
            echo "
            ==============================
            |     $text_unmount        |
            ==============================
            | $text_mounted:            |
            "
        fi

        if [ ${#mounted[@]} -eq 0 ]; then
            echo "        $text_no_files"
        else
            for ((i=0; i<${#mounted[@]}; i++)); do
                echo "        $((i+1)). ${mounted[$i]}"
            done
        fi

        if [ "$lang" = "ar" ]; then
            echo "
            ==============================
            | 1. إلغاء الضم             |
            | 0. رجوع                   |
            ==============================
            "
            read -p "$text_choose [0-1]: " sub_choice
        else
            echo "
            ==============================
            | 1. $text_unmount         |
            | 0. Back                   |
            ==============================
            "
            read -p "$text_choose [0-1]: " sub_choice
        fi

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
                            sudo rmdir "$mount_point"
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

        if [ "$lang" = "ar" ]; then
            echo "
            ==============================
            |        $text_mount       |
            ==============================
            | 1. $text_select          |
            | 2. $text_show            |
            | 0. رجوع                   |
            ==============================
            "
            read -p "$text_choose [0-2]: " choice
        else
            echo "
            ==============================
            |        $text_mount       |
            ==============================
            | 1. $text_select          |
            | 2. $text_show            |
            | 0. Back                   |
            ==============================
            "
            read -p "$text_choose [0-2]: " choice
        fi

        case $choice in
            1)
                if select_iso_file; then
                    iso_path=$(cat "$temp_file")
                    # إنشاء اسم فريد لنقطة الضم
                    mount_name=$(basename "$iso_path" | cut -d. -f1)
                    mount_point="$mnt_dir/$mount_name"

                    # التحقق من عدم وجود نقطة ضم بنفس الاسم
                    if mount | grep -q "$mount_point"; then
                        if [ "$lang" = "ar" ]; then
                            zenity --error --text="نقطة الضم موجودة بالفعل: $mount_point" --width=300
                        else
                            zenity --error --text="Mount point already exists: $mount_point" --width=300
                        fi
                        continue
                    fi

                    # إنشاء مجلد الضم إذا لم يكن موجوداً
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
                        # إزالة مجلد الضم إذا فشلت العملية
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

    if [ "$lang" = "ar" ]; then
        echo "
        ==============================
        |      $text_extract        |
        ==============================
        "
    else
        echo "
        ==============================
        |      $text_extract        |
        ==============================
        "
    fi

    if select_iso_file; then
        iso_path=$(cat "$temp_file")

        if [ "$lang" = "ar" ]; then
            echo "
            ==============================
            | 1. فك الضغط هنا           |
            | 2. فك الضغط في مجلد آخر   |
            | 0. رجوع                   |
            ==============================
            "
            read -p "$text_choose [0-2]: " extract_choice
        else
            echo "
            ==============================
            | 1. Extract here           |
            | 2. Extract to folder      |
            | 0. Back                   |
            ==============================
            "
            read -p "$text_choose [0-2]: " extract_choice
        fi

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

        if [ -d "$output_dir" ] && [ "$(ls -A "$output_dir")" ]; then
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

        if [ "$lang" = "ar" ]; then
            echo "
            ==============================
            |      $text_setup         |
            ==============================
            | 1. إنشاء مجلد ISO جديد   |
            | 2. فتح مدير الملفات       |
            | 0. رجوع                   |
            ==============================
            "
            read -p "$text_choose [0-2]: " sub_choice
        else
            echo "
            ==============================
            |      $text_setup         |
            ==============================
            | 1. Create new ISO folder  |
            | 2. Open file manager      |
            | 0. Back                   |
            ==============================
            "
            read -p "$text_choose [0-2]: " sub_choice
        fi

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
        echo -e "\033[1;34m"

        if [ "$lang" = "ar" ]; then
            echo "┌──────────────────────────────────────┐"
            echo "│   أداة متقدمة لإدارة ملفات ISO/IMG   │"
            echo "│  مع واجهة سهلة وخصائص متكاملة       │"
            echo "└──────────────────────────────────────┘"
        else
            echo "┌──────────────────────────────────────┐"
            echo "│   Advanced ISO/IMG Management Tool   │"
            echo "│  With easy interface and complete    │"
            echo "│  features                            │"
            echo "└──────────────────────────────────────┘"
        fi

        echo "
        ==============================
        |     $text_title           |
        ==============================
        | $(if [ "$lang" = "ar" ]; then echo "مسار ISO الحالي:"; else echo "Current ISO path:"; fi) $iso_dir
        | $(if [ "$lang" = "ar" ]; then echo "$text_mount_point:"; else echo "$text_mount_point:"; fi) $mnt_dir
        ==============================
        | 1. $text_setup            |
        | 2. $text_mount            |
        | 3. $text_unmount          |
        | 4. $text_show             |
        | 5. $text_extract          |
        | 6. $text_switch            |
        | 0. $text_exit              |
        ==============================
        "

        if [ "$lang" = "ar" ]; then
            read -p "اختر خياراً [0-6]: " choice
        else
            read -p "Choose option [0-6]: " choice
        fi

        case $choice in
            1) setup_iso_dir ;;
            2) mount_iso ;;
            3) unmount_iso ;;
            4) show_mounted ;;
            5) extract_iso ;;
            6)
                if [ "$lang" = "ar" ]; then
                    lang="en"
                    echo "تم التبديل إلى الإنجليزية"
                else
                    lang="ar"
                    echo "تم التبديل إلى العربية"
                fi
                load_texts
                sleep 1
                ;;
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
