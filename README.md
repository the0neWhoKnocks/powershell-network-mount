# Powershell Network Mount

A powershell script with a flat UI that'll mount network drives and give feedback on success or error.

---

## Notes

In order for PowerShell scripts to run on startup you'll have to start a
PowerShell terminal with Admin rights. Then type `Set-ExecutionPolicy RemoteSigned`,
and choose `All`.

On Windows 10 you can type Win+R to open a Run dialog, then type `shell:startup`
to access the Startup directory where you can drop a shortcut to the script.

---

## Configuration

There's a `conf.psd1` file that allows for configuring

```
ip     - The IP address where the shares reside on your network.
user   - The user name that has access to the drive.
pass   - The password for the user.
drives - A hashmap of 'drive letter' - 'drive path' pairs.
```


