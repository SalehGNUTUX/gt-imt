#!/bin/bash

# =============================================
# GT-IMT - ISO Mount Tool Installer
# Developer: SalehGNUTUX
# Version: 2.0.0
# Repository: https://github.com/SalehGNUTUX/gt-imt
# =============================================

TOOL_NAME="GT-IMT"
DEV_NAME="SalehGNUTUX"
REPO_URL="https://github.com/SalehGNUTUX/gt-imt"
RAW_BASE="https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main"
INSTALL_DIR="/usr/local/bin"
CONFIG_DIR="$HOME/.config/gt-imt"
VERSION_FILE="$CONFIG_DIR/version"
INSTALL_BIN="$INSTALL_DIR/imt"
WORK_DIR="$HOME/.gt-imt-src"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error()   { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info()    { echo -e "${BLUE}➜ $1${NC}"; }
print_step()    { echo -e "${CYAN}[*] $1${NC}"; }

# Safe read for curl|bash environment
safe_read() {
    local prompt="$1"
    local varname="$2"
    local answer
    if [ -t 0 ]; then
        read -p "$prompt" answer
    else
        read -p "$prompt" answer < /dev/tty
    fi
    eval "$varname=\$answer"
}

# ============================================
# Banner
# ============================================
show_banner() {
    clear
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}  💿   ${GREEN}GT-IMT - ISO Mount Tool Installer${NC} ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  👨‍💻   Developer: ${YELLOW}$DEV_NAME${NC}            ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}  🌐   $REPO_URL  ${CYAN}║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================
# Language selection
# ============================================
select_language() {
    echo "🌐 Please select language / الرجاء اختيار اللغة:"
    echo "   1) 🇸🇦 العربية (AR)"
    echo "   2) 🇺🇸 English (EN)"
    echo "   3) 🔍 Auto-detect / اكتشاف تلقائي"
    echo ""
    safe_read "Choice [1-3] (default: 3): " lang_choice

    case $lang_choice in
        1)
            LANG_MODE="AR"
            echo -e "${GREEN}✓ تم اختيار اللغة العربية${NC}"
            ;;
        2)
            LANG_MODE="EN"
            echo -e "${GREEN}✓ English language selected${NC}"
            ;;
        *)
            system_lang=$(locale | grep LANG= | cut -d= -f2 | cut -d_ -f1)
            if [ "$system_lang" = "ar" ]; then
                LANG_MODE="AR"
                echo -e "${GREEN}✓ تم اكتشاف اللغة العربية تلقائياً${NC}"
            else
                LANG_MODE="EN"
                echo -e "${GREEN}✓ English auto-detected${NC}"
            fi
            ;;
    esac
    echo ""
}

# ============================================
# Message function
# ============================================
msg() {
    local key="$1"
    if [ "$LANG_MODE" = "AR" ]; then
        case $key in
            checking_net)     echo "🔍 جاري التحقق من الاتصال بالإنترنت..." ;;
            net_ok)           echo "✓ الاتصال بالإنترنت جيد" ;;
            net_fail)         echo "❌ لا يوجد اتصال بالإنترنت. يرجى التحقق والمحاولة مرة أخرى." ;;
            need_sudo)        echo "🔐 جاري التحقق من صلاحيات sudo..." ;;
            sudo_fail)        echo "❌ فشل الحصول على صلاحيات sudo" ;;
            downloading)      echo "📥 جاري تنزيل الملفات إلى: $WORK_DIR" ;;
            download_ok)      echo "✓ تم تنزيل الملفات بنجاح" ;;
            download_fail)    echo "❌ فشل في تنزيل الملفات" ;;
            already_installed) echo "⚠ الأداة مثبتة مسبقاً في: $INSTALL_BIN" ;;
            installed_ver)    echo "   الإصدار المثبت:" ;;
            remote_ver)       echo "   الإصدار المتاح:" ;;
            choose_action)    echo "ماذا تريد أن تفعل؟" ;;
            opt_reinstall)    echo "   1) إعادة التثبيت (نفس الإصدار)" ;;
            opt_update)       echo "   2) تحديث إلى أحدث إصدار" ;;
            opt_remove)       echo "   3) إزالة كاملة وإعادة التثبيت من جديد" ;;
            opt_cancel)       echo "   4) إلغاء العملية والخروج" ;;
            cancelled)        echo "⚠ تم إلغاء العملية" ;;
            removing_old)     echo "🗑️  جاري إزالة النسخة القديمة..." ;;
            remove_ok)        echo "✓ تمت إزالة النسخة القديمة" ;;
            installing)       echo "📦 جاري التثبيت النظامي..." ;;
            install_ok)       echo "🎉 تم تثبيت $TOOL_NAME بنجاح!" ;;
            run_with)         echo "🎯 يمكنك الآن تشغيل الأداة باستخدام:" ;;
            saved_to)         echo "📁 تم حفظ الملفات في:" ;;
            no_dl_tool)       echo "❌ لم يتم العثور على curl أو wget. يرجى تثبيت أحدهما أولاً." ;;
            check_deps)       echo "🔍 جاري التحقق من الاعتماديات المطلوبة..." ;;
            missing_deps)     echo "⚠ الاعتماديات الناقصة:" ;;
            install_deps)     echo "   يمكنك تثبيتها باستخدام الأمر المناسب لنظامك" ;;
            deps_ok)          echo "✓ جميع الاعتماديات مثبتة" ;;
            install_icon)     echo "📸 جاري تثبيت أيقونة البرنامج..." ;;
            icon_ok)          echo "✓ تم تثبيت الأيقونة" ;;
            desktop_ok)       echo "✓ تم إنشاء مدخل القائمة" ;;
            final_message)    echo "🎉 تم تثبيت $TOOL_NAME بنجاح! يمكنك الآن:"
                              echo "   • تشغيل البرنامج عبر الأمر: ${GREEN}imt${NC}"
                              echo "   • أو من قائمة التطبيقات: ${GREEN}GT-IMT${NC}"
                              ;;
            install_deps_prompt) echo "هل تريد تثبيت الاعتماديات المفقودة الآن؟ (قد تحتاج كلمة مرور sudo)" ;;
            install_deps_skip)   echo "تم تخطي تثبيت الاعتماديات. يمكنك تثبيتها يدوياً لاحقاً." ;;
            install_deps_fail)   echo "❌ فشل تثبيت بعض الاعتماديات. يرجى تثبيتها يدوياً." ;;
        esac
    else
        case $key in
            checking_net)     echo "🔍 Checking internet connection..." ;;
            net_ok)           echo "✓ Internet connection OK" ;;
            net_fail)         echo "❌ No internet connection. Please check and try again." ;;
            need_sudo)        echo "🔐 Checking sudo permissions..." ;;
            sudo_fail)        echo "❌ Failed to get sudo permissions" ;;
            downloading)      echo "📥 Downloading files to: $WORK_DIR" ;;
            download_ok)      echo "✓ Files downloaded successfully" ;;
            download_fail)    echo "❌ Failed to download files" ;;
            already_installed) echo "⚠ Tool already installed at: $INSTALL_BIN" ;;
            installed_ver)    echo "   Installed version:" ;;
            remote_ver)       echo "   Available version:" ;;
            choose_action)    echo "What would you like to do?" ;;
            opt_reinstall)    echo "   1) Reinstall (same version)" ;;
            opt_update)       echo "   2) Update to latest version" ;;
            opt_remove)       echo "   3) Uninstall and reinstall fresh" ;;
            opt_cancel)       echo "   4) Cancel and exit" ;;
            cancelled)        echo "⚠ Operation cancelled" ;;
            removing_old)     echo "🗑️  Removing old version..." ;;
            remove_ok)        echo "✓ Old version removed" ;;
            installing)       echo "📦 Installing to system..." ;;
            install_ok)       echo "🎉 $TOOL_NAME installed successfully!" ;;
            run_with)         echo "🎯 You can now run the tool using:" ;;
            saved_to)         echo "📁 Files saved to:" ;;
            no_dl_tool)       echo "❌ Neither curl nor wget found. Please install one first." ;;
            check_deps)       echo "🔍 Checking required dependencies..." ;;
            missing_deps)     echo "⚠ Missing dependencies:" ;;
            install_deps)     echo "   You can install them using the appropriate command for your system" ;;
            deps_ok)          echo "✓ All dependencies are installed" ;;
            install_icon)     echo "📸 Installing application icon..." ;;
            icon_ok)          echo "✓ Icon installed" ;;
            desktop_ok)       echo "✓ Desktop entry created" ;;
            final_message)    echo "🎉 $TOOL_NAME installed successfully! You can now:"
                              echo "   • Run the tool with command: ${GREEN}imt${NC}"
                              echo "   • Or from applications menu: ${GREEN}GT-IMT${NC}"
                              ;;
            install_deps_prompt) echo "Do you want to install missing dependencies now? (sudo password may be required)" ;;
            install_deps_skip)   echo "Skipped dependency installation. You can install them manually later." ;;
            install_deps_fail)   echo "❌ Failed to install some dependencies. Please install them manually." ;;
        esac
    fi
}

# ============================================
# Download function
# ============================================
download_file() {
    local url="$1"
    local dest="$2"

    if command -v curl &>/dev/null; then
        curl -sSL -o "$dest" "$url"
    elif command -v wget &>/dev/null; then
        wget -q -O "$dest" "$url"
    else
        print_error "$(msg no_dl_tool)"
        exit 1
    fi
}

# ============================================
# Internet check
# ============================================
check_internet() {
    print_step "$(msg checking_net)"
    if ! ping -c 1 github.com &>/dev/null 2>&1 && ! ping -c 1 raw.githubusercontent.com &>/dev/null 2>&1; then
        print_error "$(msg net_fail)"
        exit 1
    fi
    print_success "$(msg net_ok)"
    echo ""
}

# ============================================
# Sudo check
# ============================================
check_sudo() {
    print_step "$(msg need_sudo)"
    if ! sudo -v 2>/dev/null; then
        print_error "$(msg sudo_fail)"
        exit 1
    fi
    print_success "OK"
    echo ""
}

# ============================================
# Dependency installation (automatic)
# ============================================
install_dependencies() {
    print_step "$(msg check_deps)"
    local missing=()
    
    # Check for GUI dialog tools
    if ! command -v zenity &> /dev/null && ! command -v kdialog &> /dev/null && ! command -v Xdialog &> /dev/null; then
        missing+=("gui-dialog (zenity/kdialog)")
    fi
    
    if ! command -v 7z &> /dev/null; then
        missing+=("p7zip")
    fi
    
    if ! command -v mount &> /dev/null; then
        missing+=("mount")
    fi
    
    if [ ${#missing[@]} -eq 0 ]; then
        print_success "$(msg deps_ok)"
        return 0
    fi
    
    print_warning "$(msg missing_deps)"
    for dep in "${missing[@]}"; do
        echo "   - $dep"
    done
    echo ""
    
    # Detect package manager
    local pkg_manager=""
    local install_cmd=""
    local packages=()
    
    if command -v apt &>/dev/null; then
        pkg_manager="apt"
        install_cmd="sudo apt update && sudo apt install -y"
        packages=("zenity" "kdialog" "p7zip-full")
    elif command -v dnf &>/dev/null; then
        pkg_manager="dnf"
        install_cmd="sudo dnf install -y"
        packages=("zenity" "kdialog" "p7zip")
    elif command -v yum &>/dev/null; then
        pkg_manager="yum"
        install_cmd="sudo yum install -y"
        packages=("zenity" "kdialog" "p7zip")
    elif command -v pacman &>/dev/null; then
        pkg_manager="pacman"
        install_cmd="sudo pacman -S --noconfirm"
        packages=("zenity" "kdialog" "p7zip")
    elif command -v zypper &>/dev/null; then
        pkg_manager="zypper"
        install_cmd="sudo zypper install -y"
        packages=("zenity" "kdialog" "p7zip")
    else
        echo ""
        print_warning "$(msg install_deps)"
        echo ""
        echo "   # Ubuntu/Debian:"
        echo "   sudo apt install zenity kdialog p7zip-full"
        echo ""
        echo "   # Fedora/RHEL/CentOS:"
        echo "   sudo dnf install zenity kdialog p7zip"
        echo ""
        echo "   # Arch:"
        echo "   sudo pacman -S zenity kdialog p7zip"
        echo ""
        echo "   # OpenSUSE:"
        echo "   sudo zypper install zenity kdialog p7zip"
        echo ""
        safe_read "$(if [ "$LANG_MODE" = "AR" ]; then echo "اضغط Enter للمتابعة دون تثبيت..."; else echo "Press Enter to continue without installing..."; fi)" dummy
        return 1
    fi
    
    echo ""
    print_info "$(msg install_deps_prompt)"
    safe_read "[y/N]: " install_choice
    
    if [ "$install_choice" = "y" ] || [ "$install_choice" = "Y" ]; then
        echo ""
        print_info "جاري التثبيت باستخدام $pkg_manager..."
        if eval "$install_cmd ${packages[*]}"; then
            print_success "$(msg deps_ok)"
            return 0
        else
            print_error "$(msg install_deps_fail)"
            return 1
        fi
    else
        echo ""
        print_warning "$(msg install_deps_skip)"
        return 1
    fi
}

# ============================================
# Version functions
# ============================================
get_remote_version() {
    local tmp_ver=""
    if command -v curl &>/dev/null; then
        tmp_ver=$(curl -sSL "$RAW_BASE/version.txt" 2>/dev/null)
    elif command -v wget &>/dev/null; then
        tmp_ver=$(wget -qO- "$RAW_BASE/version.txt" 2>/dev/null)
    fi
    echo "${tmp_ver:-2.0.0}"
}

get_installed_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo ""
    fi
}

# ============================================
# Download main files
# ============================================
download_files() {
    print_step "$(msg downloading)"
    mkdir -p "$WORK_DIR"

    local files=("imt.sh" "README.md" "install.sh" "version.txt")

    for file in "${files[@]}"; do
        print_info "Downloading $file..."
        download_file "$RAW_BASE/$file" "$WORK_DIR/$file"
        if [ $? -ne 0 ]; then
            if [ "$file" = "version.txt" ]; then
                print_warning "⚠ لم يتم العثور على ملف $file / $file not found"
            else
                print_error "$(msg download_fail): $file"
                exit 1
            fi
        fi
        chmod +x "$WORK_DIR/$file" 2>/dev/null || true
    done

    print_success "$(msg download_ok)"
    echo ""
}

# ============================================
# Download icons from repository structure
# ============================================
download_icons() {
    print_step "📸 تنزيل أيقونات البرنامج / Downloading icons"
    local icon_sizes=("16x16" "24x24" "32x32" "48x48" "64x64" "128x128" "256x256" "512x512")
    local icon_dir="$WORK_DIR/icons"
    mkdir -p "$icon_dir"
    
    local icons_found=0
    for size in "${icon_sizes[@]}"; do
        local icon_url="$RAW_BASE/icons/icons/$size/imt-icon.png"
        local icon_file="$icon_dir/$size.png"
        printf "📄 %-8s ... " "$size"
        
        if command -v curl &>/dev/null; then
            if curl -s -f -L -o "$icon_file" "$icon_url" 2>/dev/null; then
                echo -e "${GREEN}✓${NC}"
                icons_found=1
            else
                echo -e "${YELLOW}⚠ غير موجود${NC}"
            fi
        else
            if wget -q -O "$icon_file" "$icon_url" 2>/dev/null; then
                echo -e "${GREEN}✓${NC}"
                icons_found=1
            else
                echo -e "${YELLOW}⚠ not found${NC}"
            fi
        fi
    done
    
    if [ $icons_found -eq 1 ]; then
        print_success "تم تنزيل بعض الأيقونات / Some icons downloaded"
    else
        print_warning "⚠ لم يتم العثور على أي أيقونات / No icons found"
    fi
    echo ""
}

# ============================================
# Thorough cleanup of old entries
# ============================================
remove_old() {
    print_step "$(msg removing_old)"
    
    # Remove binary
    sudo rm -f "$INSTALL_BIN" 2>/dev/null
    
    # Remove all possible .desktop files
    sudo rm -f /usr/share/applications/gt-imt.desktop 2>/dev/null
    sudo rm -f /usr/share/applications/imt.desktop 2>/dev/null
    sudo rm -f /usr/local/share/applications/gt-imt.desktop 2>/dev/null
    sudo rm -f /usr/local/share/applications/imt.desktop 2>/dev/null
    
    # Remove all icons
    sudo rm -f /usr/share/icons/hicolor/*/apps/gt-imt.png 2>/dev/null
    sudo rm -f /usr/share/icons/hicolor/*/apps/imt.png 2>/dev/null
    
    mkdir -p "$CONFIG_DIR"
    print_success "$(msg remove_ok)"
    echo ""
}

# ============================================
# Install icons and desktop entry
# ============================================
install_desktop_entry() {
    print_step "$(msg install_icon)"
    
    local icon_sizes=("16x16" "24x24" "32x32" "48x48" "64x64" "128x128" "256x256" "512x512")
    local icons_found=0
    
    for size in "${icon_sizes[@]}"; do
        local icon_source="$WORK_DIR/icons/$size.png"
        local icon_dest="/usr/share/icons/hicolor/$size/apps/gt-imt.png"
        if [ -f "$icon_source" ]; then
            sudo mkdir -p "$(dirname "$icon_dest")"
            sudo cp "$icon_source" "$icon_dest"
            sudo chmod 644 "$icon_dest"
            # Also copy as imt.png for compatibility
            sudo cp "$icon_source" "$(dirname "$icon_dest")/imt.png"
            icons_found=1
        fi
    done
    
    if [ $icons_found -eq 1 ]; then
        print_success "$(msg icon_ok)"
    else
        print_warning "⚠ لم يتم العثور على أيقونات، سيتم استخدام الأيقونة الافتراضية للنظام"
    fi
    
    # Create .desktop file
    local desktop_file="/usr/share/applications/gt-imt.desktop"
    local desktop_content='[Desktop Entry]
Version=2.0
Type=Application
Name=GT-IMT
Name[ar]=GT-IMT
GenericName=ISO Mount Tool
GenericName[ar]=أداة ضم ملفات ISO
Comment=Mount and extract ISO/IMG files
Comment[ar]=ضم وفك ضغط ملفات ISO و IMG
Exec=imt
Icon=gt-imt
Terminal=true
Categories=Utility;Archiving;FileTools;
Keywords=iso;mount;extract;image;
StartupNotify=false
'
    
    echo "$desktop_content" | sudo tee "$desktop_file" > /dev/null
    sudo chmod 644 "$desktop_file"
    sudo ln -sf "$desktop_file" "/usr/share/applications/imt.desktop" 2>/dev/null
    
    print_success "$(msg desktop_ok)"
    
    # Update icon cache
    if command -v gtk-update-icon-cache &> /dev/null; then
        sudo gtk-update-icon-cache -f /usr/share/icons/hicolor/ &>/dev/null || true
    fi
    
    echo ""
}

# ============================================
# System installation
# ============================================
do_install() {
    print_step "$(msg installing)"

    sudo cp "$WORK_DIR/imt.sh" "$INSTALL_BIN"
    sudo chmod +x "$INSTALL_BIN"
    
    # Install icons and desktop entry
    install_desktop_entry

    mkdir -p "$CONFIG_DIR"
    
    local installed_version="2.0.0"
    if [ -f "$WORK_DIR/version.txt" ]; then
        installed_version=$(cat "$WORK_DIR/version.txt")
    fi
    echo "$installed_version" > "$VERSION_FILE"
    echo "$LANG_MODE" > "$CONFIG_DIR/language"

    echo ""
    print_success "$(msg install_ok)"
    echo ""
    print_info "$(msg final_message)"
    echo ""
}

# ============================================
# Handle existing installation
# ============================================
handle_existing_install() {
    local installed_ver remote_ver

    installed_ver=$(get_installed_version)
    echo -e "${YELLOW}$(msg already_installed)${NC}"
    echo -e "$(msg installed_ver) ${CYAN}${installed_ver:-unknown}${NC}"

    print_info "Fetching remote version..."
    remote_ver=$(get_remote_version)
    echo -e "$(msg remote_ver) ${CYAN}${remote_ver}${NC}"
    echo ""

    echo "$(msg choose_action)"
    echo "$(msg opt_reinstall)"
    echo "$(msg opt_update)"
    echo "$(msg opt_remove)"
    echo "$(msg opt_cancel)"
    echo ""
    safe_read "Choice [1-4]: " action_choice

    case $action_choice in
        1|2)
            download_files
            download_icons
            remove_old
            do_install
            ;;
        3)
            remove_old
            safe_read "$(if [ "$LANG_MODE" = "AR" ]; then echo "هل تريد حذف ملفات الإعدادات أيضاً؟ (y/n): "; else echo "Also remove configuration files? (y/n): "; fi)" rm_config
            if [ "$rm_config" = "y" ] || [ "$rm_config" = "Y" ]; then
                rm -rf "$CONFIG_DIR"
                print_success "$(if [ "$LANG_MODE" = "AR" ]; then echo "تم حذف ملفات الإعدادات"; else echo "Configuration files removed"; fi)"
            fi
            # Extra cleanup
            sudo rm -f /usr/share/applications/gt-imt.desktop 2>/dev/null
            sudo rm -f /usr/share/applications/imt.desktop 2>/dev/null
            sudo rm -f /usr/share/icons/hicolor/*/apps/gt-imt.png 2>/dev/null
            sudo rm -f /usr/share/icons/hicolor/*/apps/imt.png 2>/dev/null
            echo ""
            download_files
            download_icons
            do_install
            ;;
        4|*)
            print_warning "$(msg cancelled)"
            exit 0
            ;;
    esac
}

# ============================================
# Main program
# ============================================
main() {
    show_banner
    select_language
    check_internet
    check_sudo
    
    # Attempt to install dependencies
    install_dependencies

    # Download files and icons
    download_files
    download_icons

    if [ -f "$INSTALL_BIN" ]; then
        handle_existing_install
    else
        remove_old  # Ensure clean before fresh install
        do_install
    fi

    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo -e "${GREEN}  $TOOL_NAME — Developer: $DEV_NAME${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}📌 ${LANG_MODE}${NC}"
    echo ""
}

main "$@"
