#  aOrganizing Messy Photos and Videos with Automation

This guide outlines a process to organize a messy collection of photos and videos into a date-ordered structure using a combination of PowerShell scripts and the `sortphotos` Python package.

---

## 1. Initial Preparation of Media

Before automated sorting, perform a rough initial separation and flattening of your media.

1.  **Rough Separation:**
    *   Manually separate your media into two main categories: photos and videos. Place them in their respective temporary folders (e.g., `~/TempPhotos` and `~/TempVideos`).
    *   **Important:** Do not convert any file formats at this stage.

2.  **Flatten Folder Structure:**
    *   If your media is currently organized in many subfolders (e.g., `holiday/Day1/IMG_001.JPG`), use the provided PowerShell script `Flattenfolders.ps1` to move all files into a single, flat directory.
    *   *Reference:* The `Flattenfolders.ps1` script can be found in the `Preperation of media` directory.

3.  **Final Manual Split (if necessary):**
    *   After flattening, manually sort any remaining mixed files by type into separate `Photos` and `Videos` folders. This makes the next steps easier.

---

## 2. Setting Up `sortphotos` for Date-Based Sorting

`sortphotos` is a Python package that uses EXIF metadata (date and time information embedded in photos and videos) to sort files into a structured hierarchy (e.g., `Year/Month/Day`).

### 2.1. Prerequisites

Before installing `sortphotos`, you need to install its dependencies:

1.  **Strawberry Perl (for ExifTool):**
    *   `sortphotos` relies on `ExifTool` (which is part of Strawberry Perl) to read metadata from media files.
    *   Download and install Strawberry Perl from: [https://strawberryperl.com/](https://strawberryperl.com/)

2.  **Python `setuptools`:**
    *   This is a standard Python package necessary for installing other Python packages.
    *   Install it using `pip`:
        ```bash
        pip install setuptools
        ```

3.  **`sortphotos` Python Package:**
    *   Download the `sortphotos` package from its GitHub repository: [https://github.com/andrewning/sortphotos](https://github.com/andrewning/sortphotos)
    *   Once downloaded and extracted, navigate to the `sortphotos` directory in your terminal.
    *   Install the package:
        ```bash
        python setup.py install
        ```

### 2.2. Sorting Your Media

Once `sortphotos` is installed, you can use it to organize your photos and videos.

1.  **Create a Destination Folder:**
    *   Create a new, empty folder where you want your sorted media to be placed (e.g., `~/SortedMedia`).

2.  **Run `sortphotos`:**
    *   Use the `sortphotos` command, specifying your source and destination folders. The `-r` flag tells `sortphotos` to recursively scan the source directory.
    *   Example:
        ```bash
        sortphotos -r "C:\Users\YourUser\TempPhotos" "C:\Users\YourUser\SortedMedia\Photos"
        ```
        ```bash
        sortphotos -r "C:\Users\YourUser\TempVideos" "C:\Users\YourUser\SortedMedia\Videos"
        ```
    *   *Explanation:* `sortphotos` will read the metadata from each file and move it to a new location within the destination folder, typically organized by year, month, and day (e.g., `2023/12/15/IMG_001.JPG`).

---

## 3. Troubleshooting `sortphotos`

*   **Stuck on a File:** If `sortphotos` appears to hang, it often indicates a corrupted media file.
    *   **Diagnosis:** The process usually hangs on the corrupted file, or the file alphabetically just before it. Locate these files.
    *   **Solution:** Remove or quarantine the suspected corrupted files from the source directory and re-run `sortphotos`.
    *   **Note:** `sortphotos` is designed to be safe; it will not move any files until all metadata has been successfully read, preventing partial or failed moves if corruption is detected early.

---

## 4. Complementary PowerShell Scripts

The `Preperation of media` directory also contains other PowerShell scripts that can be useful in conjunction with this sorting process. These include:

*   `Duplicate mover.ps1`: For moving duplicate files.
*   `Duplicate remover.ps1`: For deleting duplicate files.
*   `Finddupes.ps1`: For identifying duplicate files.

These scripts can be used before or after running `sortphotos` to manage duplicates effectively.
