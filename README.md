# GT-IMT - ISO Mount Tool

<div dir="rtl">

## 📌 نظرة عامة
**GT-IMT (ISO Mount Tool)** هي أداة سطر أوامر متقدمة ومتعددة الاستخدامات مكتوبة بلغة **Bash**، مصممة لتسهيل عملية إدارة ملفات ISO و IMG على أنظمة لينكس. تتميز بواجهة تفاعلية سهلة، ودعم كامل للغتين العربية والإنجليزية مع الكشف التلقائي عن لغة النظام، وتجربة مستخدم سلسة.

![لقطة شاشة رئيسية للبرنامج توضح الشعار والقائمة الرئيسية](https://github.com/user-attachments/assets/fff4c0ac-987e-4ed2-8391-0f7b15e1f138)

**المطور**: SalehGNUTUX  
**الإصدار**: 2.0.0  
**الرخصة**: رخصة جنو العمومية الإصدار الثاني (GPL-2.0)  
**المستودع**: https://github.com/SalehGNUTUX/gt-imt

---

## ✨ الميزات الرئيسية
*   **واجهة تفاعلية سهلة**: قوائم واضحة ومريحة للتنقل.
*   **دعم كامل للغتين**: العربية والإنجليزية مع اكتشاف تلقائي للغة النظام.
*   **ضم وإلغاء ضم الملفات**: ضم ملفات ISO/IMG بسهولة إلى نقطة ضم موحدة (`/mnt/iso_mounts`) وعرضها وإلغاء ضمها.
*   **فك ضغط متقدم**: استخراج محتويات ملفات ISO مع خيارات ذكية للتعامل مع الملفات الموجودة مسبقاً (استبدال الكل، التخطي).
*   **إدارة مجلدات ISO**: إنشاء وفتح المجلد الافتراضي للملفات (`~/iso`) بسرعة.
*   **تحديث ذاتي**: التحقق من وجود إصدارات أحدث وتحديث الأداة مباشرة من القائمة.
*   **إزالة كاملة**: خيار مدمج لإلغاء تثبيت البرنامج بالكامل مع جميع ملفاته.
*   **حزمة AppImage**: إمكانية تشغيل البرنامج كحزمة محمولة بدون تثبيت.

---

## 📦 تحميل حزمة AppImage (محمول)

يمكنك تحميل أحدث إصدار من الأداة كحزمة **AppImage** من صفحة الإصدارات على GitHub. هذه الحزمة لا تحتاج إلى تثبيت وتعمل مباشرة على معظم توزيعات لينكس.

*   **تحميل الإصدار**: [GT-IMT-ISO-Mount-Tool-Version-2.0.0-x86_64.AppImage](https://github.com/SalehGNUTUX/gt-imt/releases/tag/GT-IMT-26.02)

**طريقة الاستخدام:**
1.  امنح ملف `AppImage` صلاحية التنفيذ:
    ```bash
    chmod +x GT-IMT-*-x86_64.AppImage
    ```
2.  شغّل الملف:
    ```bash
    ./GT-IMT-*-x86_64.AppImage
    ```

---

## 🚀 طرق التثبيت السريعة

### 1. تثبيت سطر أوامر واحد (موصى به)
هذه الطريقة تقوم بتحميل ملف التثبيت الرئيسي `install.sh` من المستودع وتنفيذه. الملف سيقوم بكل الخطوات اللازمة، بما في ذلك تنزيل جميع الملفات، تثبيت البرنامج نظامياً، وإضافته إلى قائمة التطبيقات.

```bash
curl -sSL https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main/install.sh | bash
```

أو باستخدام `wget`:
```bash
wget -qO- https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main/install.sh | bash
```

### 2. التثبيت اليدوي
إذا كنت تفضل تنزيل الملفات والتعامل معها بنفسك:
1.  **انسخ المستودع** أو حمّل الملفات من [GitHub](https://github.com/SalehGNUTUX/gt-imt).
2.  **اجعل الملف الرئيسي قابلاً للتنفيذ:**
    ```bash
    chmod +x imt.sh
    ```
3.  **شغّل البرنامج:**
    ```bash
    ./imt.sh
    ```
*(ملاحظة: هذه الطريقة لن تثبت البرنامج نظامياً ولن تنشئ أيقونة في القائمة.)*

### 3. التثبيت النظامي عبر السكربت
إذا قمت بتنزيل الملفات يدوياً، يمكنك تشغيل البرنامج مرة واحدة، ثم اختيار "نعم" عندما يُسألك عن التثبيت النظامي. بعدها، سيتم نسخ الملفات إلى المسار المناسب ويمكنك تشغيل البرنامج من أي مكان بأمر واحد:
```bash
imt
```

---

## 🖥️ لقطات شاشة توضيحية

### القائمة الرئيسية - النسخة العربية
![لقطة شاشة للقائمة الرئيسية باللغة العربية](https://github.com/user-attachments/assets/731fe836-2e95-436b-a0e2-c5f04bf13d40)

كما ترى، تعرض القائمة الرئيسية المسار الحالي لمجلد ISO (`~/iso`) ونقطة الضم (`/mnt/iso_mounts`) واللغة الحالية.

### قائمة الإعدادات المتقدمة
تحتوي القائمة على خيارات ذكية مثل:
*   **التحقق من التحديثات**: للبقاء على أحدث إصدار.
*   **إزالة البرنامج**: خيار آمن لحذف البرنامج وملفاته بالكامل.

### فتح مدير الملفات
يمكنك بسهولة فتح مجلد ISO الافتراضي (`~/iso`) أو مجلد الضم (`/mnt/iso_mounts`) مباشرة من قائمة "إعداد مجلد ISO" لاستعراض الملفات.

---

## 🗑️ إلغاء التثبيت

لإزالة GT-IMT بشكل نظيف من نظامك، لديك خياران:

1.  **من داخل البرنامج**: شغّل الأمر `imt`، ثم اختر "الإعدادات" (الخيار 6) ← "إزالة البرنامج" (الخيار 4). هذا الخيار سيزيل الملف التنفيذي والأيقونة وملفات الإعدادات.
2.  **إذا كنت تستخدم AppImage**: فقط احذف ملف `AppImage`.

---

## 📄 الرخصة
هذا المشروع مرخص تحت **رخصة جنو العمومية الإصدار الثاني (GPL-2.0)**. هذا يعني أنه برنامج مجاني ويمكنك استخدامه وتعديله وتوزيعه بحرية مع الالتزام بشروط الرخصة.

```
هذا البرنامج مجاني؛ يمكنك إعادة توزيعه و/أو تعديله
تحت بنود رخصة جنو العمومية الإصدار الثاني
المنشورة من قبل مؤسسة البرمجيات الحرة.
```

---

## 🤝 المساهمة والدعم
يسعدني تلقي ملاحظاتك واقتراحاتك! يمكنك المساهمة عبر:
*   **الإبلاغ عن مشكلة**: [صفحة Issues](https://github.com/SalehGNUTUX/gt-imt/issues)
*   **تقديم تحسينات**: فتح `Pull Request` على GitHub.

</div>

---

# GT-IMT - ISO Mount Tool (English)

## 📌 Overview
**GT-IMT (ISO Mount Tool)** is an advanced and versatile Bash command-line tool designed to simplify managing ISO and IMG files on Linux systems. It features an easy-to-use interactive interface, full bilingual support (Arabic/English) with automatic language detection, and a smooth user experience.

**Developer**: SalehGNUTUX  
**Version**: 2.0.0  
**License**: GNU General Public License v2.0 (GPL-2.0)  
**Repository**: https://github.com/SalehGNUTUX/gt-imt

## ✨ Key Features
*   **Interactive UI**: Clear and comfortable menu-driven navigation.
*   **Bilingual Support**: Full Arabic/English interface with auto-detection.
*   **Mount/Unmount Files**: Easily mount ISO/IMG files to a central mount point (`/mnt/iso_mounts`), list them, and unmount them.
*   **Advanced Extraction**: Extract ISO contents with smart options for handling existing files (overwrite all, skip).
*   **ISO Folder Management**: Quickly create and open the default ISO folder (`~/iso`).
*   **Self-Update**: Check for newer versions and update the tool directly from the settings menu.
*   **Full Uninstall**: A built-in option to completely remove the program and its files.
*   **AppImage Package**: A portable, pre-compiled version that runs without installation.

## 📦 Download AppImage (Portable)
You can download the latest version as an **AppImage** from the GitHub Releases page. This package requires no installation and runs on most Linux distributions.

*   **Download**: [GT-IMT-ISO-Mount-Tool-Version-2.0.0-x86_64.AppImage](https://github.com/SalehGNUTUX/gt-imt/releases/tag/GT-IMT-26.02)

**How to use:**
1.  Make the `AppImage` file executable:
    ```bash
    chmod +x GT-IMT-*-x86_64.AppImage
    ```
2.  Run the file:
    ```bash
    ./GT-IMT-*-x86_64.AppImage
    ```

## 🚀 Quick Installation

### 1. One-Line Installation (Recommended)
This command downloads the main installer `install.sh` from the repository and executes it. The installer handles downloading all files, performing a system-wide installation, and adding the program to your applications menu.

```bash
curl -sSL https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main/install.sh | bash
```

Using `wget`:
```bash
wget -qO- https://raw.githubusercontent.com/SalehGNUTUX/gt-imt/main/install.sh | bash
```

### 2. Manual Installation
1.  **Clone the repository** or download the files from [GitHub](https://github.com/SalehGNUTUX/gt-imt).
2.  **Make the main script executable:**
    ```bash
    chmod +x imt.sh
    ```
3.  **Run the program:**
    ```bash
    ./imt.sh
    ```
*(Note: This method will not install the program system-wide or create a desktop icon.)*

### 3. System-wide Installation via Script
If you downloaded the files manually, you can run the script once. The first time you run it, it will ask if you want to install it system-wide. Answering "yes" will copy the necessary files and allow you to run the program from anywhere using a single command:
```bash
imt
```

## 🗑️ Uninstallation
To cleanly remove GT-IMT from your system:

1.  **From within the program**: Run `imt`, then navigate to "Settings" (option 6) → "Uninstall" (option 4). This will remove the binary, the icon, and configuration files.
2.  **If using the AppImage**: Simply delete the `AppImage` file.

## 📄 License
This project is licensed under the **GNU General Public License v2.0 (GPL-2.0)**. This ensures it remains free software, allowing you to use, modify, and distribute it under the terms of the license.

## 🤝 Contributing
Feedback and contributions are welcome! Please use:
*   **Issues**: [GitHub Issues page](https://github.com/SalehGNUTUX/gt-imt/issues)
*   **Pull Requests**: For code contributions and improvements.
```
