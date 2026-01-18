
# Troubleshooting Log

## Assembly Issues

- **3U Extension Mounts:** The small rectangular joints initially used to mount the 3u extension were not strong enough. I opted for a long brace connection instead for better stability.
  <img width="953" height="1270" alt="image" src="https://github.com/user-attachments/assets/1a39d742-1778-4bb8-92fb-f5a9beb83df8" />


- **Faulty RAM Stick:** One stick of RAM was not functional and did not appear in the BIOS. This required a full disassembly of the PC to swap out the faulty stick.
  <img width="714" height="1270" alt="image" src="https://github.com/user-attachments/assets/db66f14c-930b-41fa-8f00-3926a7805a27" />


- **Warped 5U Posts:** The original 5U posts were warped due to the ambient temperature in the room being too cold during printing. I reprinted the posts to resolve the issue.
  <img width="953" height="1270" alt="image" src="https://github.com/user-attachments/assets/abf2ec05-060e-4ac0-9592-cd374a53ed93" />


- **Incorrect buttons** The buttons originally purchased on Amazon had stated they were goo for PC assembly. This was not the case as they were self locking (Attempted anyway due to explicitly saying in the description) This meant a resolder of new buttons was needed. This was admittedly an oversight for me! All part of learning however.
 <img width="921" height="401" alt="image" src="https://github.com/user-attachments/assets/cc6cbbf3-b88c-45d1-9d76-ee217cf809f5" />
<img width="899" height="385" alt="image" src="https://github.com/user-attachments/assets/8b3e4b77-377d-43ed-a173-db341320ad81" />

## Software & Configuration Issues

- **Issue:** Jellyfin media scan fails or appears stuck, with `DirectoryNotFoundException` in the logs.
  - **Symptom:** The Jellyfin log shows errors like `System.IO.DirectoryNotFoundException: Could not find a part of the path '/media/Family videos'`. The scan does not progress.
  - **Solution:** This can happen if Jellyfin's internal library configuration is out of sync. Removing and re-adding the media libraries via the Jellyfin web UI (**Dashboard > Libraries**) forces it to re-evaluate the paths and can resolve the issue.

- **Issue:** Jellyfin media scan is extremely slow or hangs indefinitely.
  - **Symptom:** The scan makes very slow progress or stops completely (e.g., stuck at 78%). If using CIFS/SMB, logs may show `ffmpeg image extraction failed` or `ffprobe failed` errors. The `top` command on the host VM shows moderate CPU usage for `jellyfin` and `cifsd` (if using CIFS), indicating a performance bottleneck, not a crash.
  - **Solution:** This is typically a performance problem with the network file share protocol.
    1.  **Attempted (CIFS):** Adding the `nobrl` option to the CIFS mount in `/etc/fstab` can resolve explicit `ffmpeg` errors, but may not fix the underlying slowness.
    2.  **Recommended (NFS):** The most effective solution is to use an NFS mount instead of CIFS/SMB. NFS is more performant for the type of file I/O that `ffmpeg` and Jellyfin perform. This involves enabling the NFS service on OMV, creating an NFS share, and updating the `/etc/fstab` file on the Jellyfin VM to use the `nfs` type.

- **Issue:** Jellyfin repeatedly shows the initial "tell us about yourself" setup screen on every visit.
  - **Symptom:** Jellyfin does not save its configuration (users, libraries, settings) and prompts for new admin user creation on every startup.
  - **Solution:** This is caused by incorrect file permissions on the host directory mapped to the container's `/config` volume. The user ID (`PUID`/`PGID`) that Jellyfin runs as does not have write permission to the host directory. Stop the container and use `sudo chown -R <user>:<group> ./config` on the host to set the correct ownership to match the `PUID`/`PGID`.

- **Issue:** Jellyfin hanging on scan due to corrupt media
  - **Symptom:** Jellyfins log file showing that there is an issue with the process
  - **Solution:** Look through the log file and remove the photos:
  - <img width="792" height="246" alt="image" src="https://github.com/user-attachments/assets/53665bab-4c97-4653-838d-fa79c2e57c74" />
  - <img width="1259" height="287" alt="image" src="https://github.com/user-attachments/assets/2efd00f8-c99e-459e-b325-be1e7aaf4705" />
