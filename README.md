# Powershell Network Mount

A Powershell script with a flat UI that'll mount network drives and give feedback on success or error.

---

## Usage

- Right-click the `mountNAS.ps1` file and choose **Create shortcut**
- Right-click the new shortcut and go to **Properties**
- In the `Target` field, surround the current path with double quotes, and
  prepend that path with `powershell.exe -ExecutionPolicy Bypass -File `, so
  that you end up with something like:
  ```
  powershell.exe -ExecutionPolicy Bypass -File "D:\powershell-network-mount\mountNAS.ps1"
  ```
- In the `Run` dropdown, select `Minimized`.
- Then (on Windows 10), type `Win+R` to open a Run dialog, then type 
  `shell:startup` to open the Startup directory and move the shortcut there.

---

## Configuration

There's a `conf.psd1` file that allows for configuring

```
ip     - The IP address where the shares reside on your network.
user   - The user name that has access to the drive.
pass   - The password for the user.
drives - A hashmap of 'drive letter' - 'drive path' pairs.
```


